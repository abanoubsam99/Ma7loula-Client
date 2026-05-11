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
import 'package:ma7lola/model/products_model.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/car_parts/local_widets/no_products_found.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/form_widgets/primary_button/primary_button.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../model/car_model.dart';
import '../local_widgets/product_card.dart';
import 'cart_screen.dart';

class CarPartsResultsScreen extends StatefulWidget {
  const CarPartsResultsScreen(
      {Key? key,
      required this.categoryID,
      required this.car,
      required this.carId,
      required this.name,
      required this.userCarId})
      : super(key: key);

  final int categoryID;
  final int carId;
  final int userCarId;
  final Car? car;
  final String? name;

  @override
  State<CarPartsResultsScreen> createState() => _CarPartsResultsScreenState();
}

class _CarPartsResultsScreenState extends State<CarPartsResultsScreen> {
  final _numberOfPostsPerRequest = 10;

  final PagingController<int, Products> _pagingController =
      PagingController(firstPageKey: 1);

  int productsLength = 0;
  Future<void> _fetchPage(int pageKey) async {
    try {
      final items = await MiscellaneousApi.getSearchProducts(
        locale: context.locale,
        categoryID: widget.categoryID,
        carId: widget.carId,
        page: pageKey,
        perPage: _numberOfPostsPerRequest,
        name: widget.name,
      );

      setState(() {
        productsLength = items.pagination?.total ?? 0;
        if (items.data?.products?.isEmpty ?? false)
          _pagingController.appendLastPage([]);

        final isLastPage =
            (items.data?.products?.length ?? 0) < _numberOfPostsPerRequest;
        if (isLastPage) {
          _pagingController.appendLastPage(items.data!.products!);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(items.data!.products!, nextPageKey);
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
                  '$productsLength ${LocaleKeys.avaiOffer.tr()}',
                  style: TextStyle(
                      color: ColorsPalette.customGrey,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
              ),
              buildGridView(height: MediaQuery.of(context).size.height - 280),
              Spacer(),
              Container(
                  color: ColorsPalette.white,
                  padding: UtilValues.padding16,
                  child:_addToCartButton() /*SimplePrimaryButton(
                  backgroundColor: productProvider.products.isNotEmpty
                      ? ColorsPalette.black
                      : ColorsPalette.customGrey,
                  label: LocaleKeys.addToCart.tr(),
                  onPressed: productProvider.products.isNotEmpty
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
          : productProvider.products.isNotEmpty
              ? () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CartScreen(
                      carID: widget.userCarId,
                      car: widget.car,
                    );
                  }));
                }
              : () {},
      backgroundColor: productProvider.products.isNotEmpty
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
                    if (productProvider.products.isNotEmpty) {
                      prices =
                          productProvider.products.map((e) => e.price).toList();
                      total = prices.reduce((a, b) => a + b);
                    }
                    return Text(
                      productProvider.products.isNotEmpty
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
        child: PagedGridView<int, Products>(
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
          builderDelegate: PagedChildBuilderDelegate<Products>(
              firstPageProgressIndicatorBuilder: (context) =>
                  const Center(child: LoadingWidget()),
              newPageProgressIndicatorBuilder: (context) =>
                  const Center(child: LoadingWidget()),
              noItemsFoundIndicatorBuilder: (context) => _isLoading
                  ? const Center(child: LoadingWidget())
                  : NoProductsFound(),
              itemBuilder: (context, item, index) {
                final productProvider = context.watch<ProductsProvider>();
                final product = item;
                // Debug print all image URLs for this product
                print('\n======== PRODUCT IMAGES DEBUG ========');
                print('Product ID: ${product.id}');
                print('Product Name: ${product.name}');
                print('Thumbnail: ${product.thumbnail?.url ?? "None"}');
                print('Number of Images: ${product.images?.length ?? 0}');
                if (product.images != null) {
                  for (int i = 0; i < product.images!.length; i++) {
                    print('Image $i URL: "${product.images![i].url}"');
                  }
                }
                print('======================================\n');
                
                return Padding(
                  padding: EdgeInsets.all(5.0.sp),
                  child: InkWell(
                    onTap: () {},
                    child: ProductCard(
                      imageUrl: (product.images != null && product.images!.isNotEmpty && product.images!.first.url != null) 
                          ? product.images!.first.url! 
                          : (product.thumbnail?.url ?? ''),
                      title: product.name ?? '',
                      onTap: () {},
                      onPressed: () =>
                          productProvider.addIncrementProduct(product),
                      onPressedMinus: () =>
                          productProvider.decrementProduct(product),
                      inCart: productProvider.products.contains(product),
                      description: product.description ?? '',
                      price: product.price ?? 0.0,
                      discount: product.priceBeforeDiscount ?? 0.0,
                      by: LocaleKeys.by.tr(),
                      vendorName: product.vendor?.name ?? '',
                      productName: product.brand?.name ?? '',
                      qtyProduct: product.qty ?? 1,
                      products: product,
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
