import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ma7lola/controller/products_provider.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/form_widgets/primary_button/primary_button.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../model/batteries_products_model.dart';
import '../../../../../../model/car_model.dart';
import '../car_parts/local_widets/no_products_found.dart';
import 'batteries_cart_screen.dart';
import 'local_widets/battery_card.dart';

class BatteriesResultsScreen extends StatefulWidget {
  const BatteriesResultsScreen(
      {Key? key,
      required this.brandId,
      required this.car,
      required this.carId,
      required this.voltage,
      required this.userCarId})
      : super(key: key);

  final int brandId;
  final int carId;
  final String voltage;
  final int userCarId;
  final Car? car;

  @override
  State<BatteriesResultsScreen> createState() => _BatteriesResultsScreenState();
}

class _BatteriesResultsScreenState extends State<BatteriesResultsScreen> {
  final _numberOfPostsPerRequest = 10;

  final PagingController<int, Batteries> _pagingController =
      PagingController(firstPageKey: 1);

  int batteriesLength = 0;
  Future<void> _fetchPage(int pageKey) async {
    try {
      final items = await MiscellaneousApi.getSearchProductsBatteries(
        locale: context.locale,
        voltage: widget.voltage,
        brandId: widget.brandId,
        carId: widget.carId,
        page: pageKey,
        perPage: _numberOfPostsPerRequest,
      );

      setState(() {
        batteriesLength = items.pagination?.total ?? 0;
        if (items.data?.batteries?.isEmpty ?? false)
          _pagingController.appendLastPage([]);

        final isLastPage =
            (items.data?.batteries?.length ?? 0) < _numberOfPostsPerRequest;
        if (isLastPage) {
          _pagingController.appendLastPage(items.data!.batteries!);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(items.data!.batteries!, nextPageKey);
        }
      });
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _pagingController.error = e;
    }
  }

  int subCategoryId = -1;
  String sortID = '0';
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (!(_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse)) {
        // User is scrolling up, don't do anything.
        return;
      }

      // Unfocus any currently focused text input fields.
      FocusScope.of(context).unfocus();
    });
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          backgroundColor: ColorsPalette.lightGrey,
          appBar: AppBarApp(
            title: LocaleKeys.carPartsResults.tr(),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: ColorsPalette.primaryLightColor,
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    SvgPicture.asset(AssetsManager.carShape),
                    UtilValues.gap8,
                    Text(
                      widget.car != null
                          ? '${widget.car?.model?.brand?.name} ${widget.car?.model?.name} - ${widget.car?.year}'
                          : '',
                      style: TextStyle(
                          color: ColorsPalette.black,
                          fontWeight: FontWeight.w400,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
              UtilValues.gap8,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '$batteriesLength ${LocaleKeys.avaiOffer.tr()}',
                  style: TextStyle(
                      color: ColorsPalette.customGrey,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
              ),
              Expanded(child:  buildGridView(height: MediaQuery.of(context).size.height - 270)),

              // Spacer(),
              Container(
                  color: ColorsPalette.white,
                  padding: UtilValues.padding16,
                  child:
                      _addToCartButton() /*SimplePrimaryButton(
                  backgroundColor: productProvider.batteries.isNotEmpty
                      ? ColorsPalette.black
                      : ColorsPalette.customGrey,
                  label: LocaleKeys.addToCart.tr(),
                  onPressed: productProvider.batteries.isNotEmpty
                      ? () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CartScreen(
                              carID: widget.carId,
                              car: widget.car,
                            );
                          }));
                        }
                      : () {},
                ),*/
                  )
            ],
          )),
    );
  }

  var total;
  var prices;
  _addToCartButton() {
    final productProvider = context.watch<ProductsProvider>();

    return PrimaryButton(
      onPressed: _isLoading
          ? () {}
          : productProvider.batteries.isNotEmpty
              ? () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BatteriesCartScreen(
                      carID: widget.userCarId,
                      car: widget.car,
                    );
                  }));
                }
              : () {},
      backgroundColor: productProvider.batteries.isNotEmpty
          ? ColorsPalette.black
          : ColorsPalette.customGrey,
      child: Center(
        child: _isLoading
            ? LoadingWidget(
                size: 20,
                color: ColorsPalette.white,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(builder: (context) {
                    if (productProvider.batteries.isNotEmpty) {
                      prices = productProvider.batteries
                          .map((e) => e.price)
                          .toList();
                      total = prices.reduce((a, b) => a + b);
                    }
                    return Text(
                      productProvider.batteries.isNotEmpty
                          ? '${Helpers.formatPrice(total).toString()} ${LocaleKeys.le.tr()}'
                          : '0.00',
                      style: TextStyle(
                          color: ColorsPalette.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          fontFamily: ZainTextStyles.font),
                    );
                  }),
                  Spacer(),
                  Text(
                    LocaleKeys.addToCart.tr(),
                    style: TextStyle(
                        color: ColorsPalette.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        fontFamily: ZainTextStyles.font),
                  ),
                  UtilValues.gap8,
                  SvgPicture.asset(
                    AssetsManager.angleRight,
                    width: 12,
                    height: 13,
                    color: ColorsPalette.white,
                  ),
                ],
              ),
      ),
    );
  }

  SizedBox buildGridView({required double height}) {
    return SizedBox(
      height: height,
      child: RefreshIndicator(
        color: ColorsPalette.primaryColor,
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedGridView<int, Batteries>(
          scrollController: _scrollController,
          showNewPageProgressIndicatorAsGridChild: false,
          showNewPageErrorIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          pagingController: _pagingController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 16.w / 3.h,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            crossAxisCount: 1,
          ),
          builderDelegate: PagedChildBuilderDelegate<Batteries>(
              firstPageProgressIndicatorBuilder: (context) =>
                  const Center(child: LoadingWidget()),
              newPageProgressIndicatorBuilder: (context) =>
                  const Center(child: LoadingWidget()),
              noItemsFoundIndicatorBuilder: (context) => _isLoading
                  ? const Center(child: LoadingWidget())
                  : NoProductsFound(),
              itemBuilder: (context, item, index) {
                final productProvider = context.watch<ProductsProvider>();
                final battery = item;
                return Padding(
                  padding: EdgeInsets.all(5.0.sp),
                  child: InkWell(
                    onTap: () {},
                    child: ProductCard(
                      imageUrl: battery.images?.first.url ?? '',
                      title: battery.name ?? '',
                      onTap: () {},
                      onPressed: () =>
                          productProvider.addIncrementBatteries(battery),
                      onPressedMinus: () =>
                          productProvider.decrementBatteries(battery),
                      inCart: productProvider.batteries.contains(battery),
                      description: battery.description ?? '',
                      price: battery.price ?? 0.0,
                      discount: battery.priceBeforeDiscount ?? 0.0,
                      by: LocaleKeys.by.tr(),
                      vendorName: battery.vendor?.name ?? '',
                      productName: battery.brand?.name ?? '',
                      qtyProduct: battery.qty ?? 1,
                      products: battery,
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
