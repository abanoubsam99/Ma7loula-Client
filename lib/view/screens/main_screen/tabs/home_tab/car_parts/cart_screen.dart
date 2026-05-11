import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:ma7lola/model/products_model.dart';
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
import '../../../../../../model/car_model.dart';
import '../../../../addresses_book_screen/add_new_address_screen.dart';
import '../../../../auth/LoginScreen.dart';
import '../local_widgets/product_card.dart';
import 'checkout_screen.dart';
import 'local_widets/no_products_found.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key, required this.carID, required this.car})
      : super(key: key);

  final int carID;
  final Car? car;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _numberOfPostsPerRequest = 10;

  final PagingController<int, Products> _pagingController =
      PagingController(firstPageKey: 1);

  Future<void> _fetchPage(int pageKey) async {
    try {
      await _getALL();

      final productProvider = context.read<ProductsProvider>();

      setState(() {
        if (productProvider.products.isEmpty) {
          _pagingController.appendLastPage([]);
          return;
        }

        Set<Products> uniqueProducts = Set.from(productProvider.products);
        List<Products> uniqueProductsList = uniqueProducts.toList();

        final isLastPage = uniqueProductsList.length < _numberOfPostsPerRequest;
        if (isLastPage) {
          _pagingController.appendLastPage(uniqueProductsList);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(uniqueProductsList, nextPageKey);
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

  List<int> allProductsIdsPreview = [];
  List<Products>? allProductsPreview = [];

  _getALL() async {
    await SQLHelper.getOrders().then((value) {
      for (int i = 0; i < value.length; i++) {
        setState(() {
          if (value[i]['productType'] == 2) {
            allProductsIdsPreview.add(value[i]['productID']);
          }
        });
      }
    });
  }

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
          body:  Column(
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
              if (productProvider.products.isEmpty) UtilValues.gap32,
              productProvider.products.isNotEmpty
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
                          if (productProvider.products.isNotEmpty) {
                            prices = productProvider.products
                                .map((e) => e.price)
                                .toList();
                            total = prices.reduce((a, b) => a + b);
                          }
                          return Text(
                            productProvider.products.isNotEmpty
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
                      backgroundColor: productProvider.products.isNotEmpty
                          ? ColorsPalette.primaryColor
                          : ColorsPalette.customGrey,
                      label: LocaleKeys.placeOrder.tr(),
                      onPressed: productProvider.products.isNotEmpty
                          ? () async {
                              final userProvider = context.read<UserProvider>();
                              if (!userProvider.isLoggedIn) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return LoginScreen(
                                    products: productProvider.products,
                                    batteries: [],
                                    tires: [],
                                    carID: widget.carID,
                                    fromCart: true,
                                    fromCartBatteries: false,
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
                                    batteries: [],
                                    products: productProvider.products,
                                    carID: widget.carID,
                                    fromCart: true,
                                    fromCartTires: false,
                                    fromCartBatteries: false,
                                    car: widget.car,
                                    tires: [],
                                  );
                                }));
                              } else {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return CheckoutScreen(
                                    products: productProvider.products,
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

  _startSearchButton() {
    return Container(
      margin: EdgeInsets.all(14.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: ColorsPalette.primaryColor),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all<Color>(ColorsPalette.primaryColor),
        ),
        child: Center(
          child: _isLoading
              ? const LoadingWidget(
                  color: ColorsPalette.white,
                )
              : Text(
                  LocaleKeys.editProfile.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorsPalette.white,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
        ),
      ),
    );
  }

  SizedBox buildGridView({required double height}) {
    final productProvider = context.watch<ProductsProvider>();

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
              noItemsFoundIndicatorBuilder: (context) =>
                  (productProvider.products.isEmpty)
                      ? NoProductsFound()
                      : const Center(child: LoadingWidget()),
              itemBuilder: (context, item, index) {
                final product = item;
                if (product.qty != null && product.qty != 0) {
                  return Padding(
                    padding: EdgeInsets.all(5.0.sp),
                    child: InkWell(
                      onTap: () {},
                      child: ProductCard(
                        inCart: true,
                        qtyProduct: product.qty ?? 1,
                        imageUrl: (product.images != null && product.images!.isNotEmpty && product.images!.first.url != null) 
                            ? product.images!.first.url! 
                            : (product.thumbnail?.url ?? ''),
                        title: product.name ?? '',
                        onTap: () {},
                        onPressed: () =>
                            productProvider.addIncrementProduct(product),
                        onPressedMinus: () =>
                            productProvider.decrementProduct(product),
                        description: product.description ?? '',
                        price: product.price ?? 0.0,
                        discount: product.priceBeforeDiscount ?? 0.0,
                        by: LocaleKeys.by.tr(),
                        vendorName: product.vendor?.name ?? '',
                        productName: product.brand?.name ?? '',
                        products: product,
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
