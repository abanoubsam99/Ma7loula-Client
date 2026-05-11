import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:ma7lola/view/screens/auth/LoginScreen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/products_provider.dart';
import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/local_orders/database.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../model/batteries_products_model.dart';
import '../../../../../../model/car_model.dart';
import '../../../../addresses_book_screen/add_new_address_screen.dart';
import '../car_parts/local_widets/no_products_found.dart';
import 'batteries_checkout_screen.dart';
import 'local_widets/battery_card.dart';

class BatteriesCartScreen extends StatefulWidget {
  const BatteriesCartScreen({Key? key, required this.carID, required this.car})
      : super(key: key);

  final int carID;
  final Car? car;

  @override
  State<BatteriesCartScreen> createState() => _BatteriesCartScreenState();
}

class _BatteriesCartScreenState extends State<BatteriesCartScreen> {
  final _numberOfPostsPerRequest = 10;

  final PagingController<int, Batteries> _pagingController =
      PagingController(firstPageKey: 1);

  List<int> allProductsIdsPreview = [];
  List<Batteries>? allProductsPreview = [];

  _getALL() async {
    await SQLHelper.getOrders().then((value) {
      for (int i = 0; i < value.length; i++) {
        setState(() {
          if (value[i]['productType'] == 0) {
            allProductsIdsPreview.add(value[i]['productID']);
          }
        });
      }
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // final productProvider = context.read<ProductsProvider>();
      await _getALL();

      final pro = await MiscellaneousApi.getProductsBatteriesByID(
          locale: context.locale,
          page: pageKey,
          perPage: _numberOfPostsPerRequest,
          productIds: allProductsIdsPreview.toSet().toList());

      allProductsPreview = pro.data?.batteries;
      setState(() {
        if (allProductsPreview?.isEmpty ?? false) {
          _pagingController.appendLastPage([]);
          return;
        }

        Set<Batteries> uniquebatteries = Set.from(allProductsPreview!);
        List<Batteries> uniqueBatteriesList = uniquebatteries.toList();

        final isLastPage =
            uniqueBatteriesList.length < _numberOfPostsPerRequest;
        if (isLastPage) {
          _pagingController.appendLastPage(uniqueBatteriesList);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(uniqueBatteriesList, nextPageKey);
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
  final _scrollController = ScrollController();
  bool _isLoading = false;
  var total;
  var prices;
  @override
  void initState() {
    _scrollController.addListener(() {
      if (!(_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse)) {
        return;
      }

      FocusScope.of(context).unfocus();
    });
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductsProvider>();
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          backgroundColor: ColorsPalette.lightGrey,
          appBar: AppBarApp(
            title: LocaleKeys.cart.tr(),
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
              if (productProvider.batteries.isEmpty) UtilValues.gap32,
              productProvider.batteries.isNotEmpty
                  ? buildGridView(
                      height: MediaQuery.of(context).size.height - 300)
                  : NoProductsFound(),
              Spacer(),
              Container(
                color: ColorsPalette.white,
                padding: UtilValues.padding16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LocaleKeys.total.tr(),
                          style: TextStyle(
                              color: ColorsPalette.customGrey,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
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
                                color: ColorsPalette.customGrey,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp),
                          );
                        }),
                      ],
                    ),
                    UtilValues.gap8,
                    SimplePrimaryButton(
                      backgroundColor: productProvider.batteries.isNotEmpty
                          ? ColorsPalette.primaryColor
                          : ColorsPalette.customGrey,
                      label: LocaleKeys.placeOrder.tr(),
                      onPressed: productProvider.batteries.isNotEmpty
                          ? () async {
                              final userProvider = context.read<UserProvider>();
                              if (!userProvider.isLoggedIn) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return LoginScreen(
                                    products: [],
                                    batteries: productProvider.batteries,
                                    tires: [],
                                    carID: widget.carID,
                                    fromCart: false,
                                    fromCartBatteries: true,
                                    fromCartTires: false,
                                    car: widget.car,
                                  );
                                }));
                                return;
                              } else if (userProvider
                                      .user?.data?.user?.defaultAddress ==
                                  null) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return AddNewAddressScreen(
                                    batteries: productProvider.batteries,
                                    products: [],
                                    carID: widget.carID,
                                    fromCart: false,
                                    fromCartTires: false,
                                    fromCartBatteries: true,
                                    car: widget.car,
                                    tires: [],
                                  );
                                }));
                              } else {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return BatteriesCheckoutScreen(
                                    batteries: productProvider.batteries,
                                    carID: widget.carID,
                                    car: widget.car,
                                  );
                                }));
                              }
                              setState(() {});
                            }
                          : () {},
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }

  SizedBox buildGridView({required double height}) {
    final productProvider = context.watch<ProductsProvider>();

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
              noItemsFoundIndicatorBuilder: (context) =>
                  (productProvider.batteries.isEmpty)
                      ? NoProductsFound()
                      : const Center(child: LoadingWidget()),
              itemBuilder: (context, item, index) {
                final battery = item;
                if (battery.qty != null && battery.qty != 0) {
                  return Padding(
                    padding: EdgeInsets.all(5.0.sp),
                    child: InkWell(
                      onTap: () {},
                      child: ProductCard(
                        inCart: true,
                        qtyProduct: battery.qty ?? 1,
                        imageUrl: battery.images?.first.url ?? '',
                        title: battery.name ?? '',
                        onTap: () {},
                        onPressed: () {
                          productProvider.addIncrementBatteries(battery);
                          // _fetchPage(1);
                        },
                        onPressedMinus: () {
                          productProvider.decrementBatteries(battery);
                          // _fetchPage(1);
                        },
                        description: battery.description ?? '',
                        price: battery.price ?? 0.0,
                        discount: battery.priceBeforeDiscount ?? 0.0,
                        by: LocaleKeys.by.tr(),
                        vendorName: battery.vendor?.name ?? '',
                        productName: battery.brand?.name ?? '',
                        products: battery,
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
        ),
      ),
    );
  }
}

class Pro {
  int id = -1;
  int? qty;
  int? type;
  Pro();

  Pro.fromDbMap(Map<String, dynamic> map) {
    id = map['id'];
    qty = map['productQty'];
    id = map['productType'];
  }
}
