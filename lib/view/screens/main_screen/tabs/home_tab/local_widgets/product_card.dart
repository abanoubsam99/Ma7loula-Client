import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/local_widgets/product_details_screen.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_network_image.dart';
import '../../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../../../../model/products_model.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String by;
  final String vendorName;
  final String title;
  final bool inCart;
  final String productName;
  final String description;
  final int? qtyProduct;
  final price;
  final discount;
  // final DiscountUnit discountUnit;
  final int? loyalityPoints;
  final VoidCallback onTap;
  final VoidCallback onPressed;
  final VoidCallback onPressedMinus;
  final Products products;
  //int pickup = 0;

  const ProductCard({
    super.key,
    required this.imageUrl,
    this.qtyProduct = 1,
    required this.onPressedMinus,
    required this.by,
    required this.inCart,
    required this.vendorName,
    required this.productName,
    required this.title,
    required this.description,
    required this.price,
    required this.discount,
    // required this.discountUnit,
    required this.onTap,
    required this.onPressed,
    this.loyalityPoints,
    required this.products,
    //required this.pickup
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          width: MediaQuery.of(context).size.width,
          // margin: UtilValues.paddinglrt8,
          // padding: UtilValues.padding8,
          decoration: BoxDecoration(
              color: ColorsPalette.white,
              borderRadius: UtilValues.borderRadius10,
              border: Border.all(color: ColorsPalette.border2)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                child: CustomNetworkImage(
                  height: 120,
                  width: MediaQuery.of(context).size.width * .33,
                  imageUrl: imageUrl,
                  fit: BoxFit.fill,
                ),
              ),
              UtilValues.gap12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UtilValues.gap8,
                  SizedBox(
                    height: 20,
                    width: MediaQuery.of(context).size.width * .57,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                              color: ColorsPalette.customGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: ZainTextStyles.font),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ProductDetailsScreen(
                                product: products,
                              );
                            }));
                          },
                          child: Row(
                            children: [
                              Text(
                                LocaleKeys.details.tr(),
                                style: TextStyle(
                                    color: ColorsPalette.customGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: ZainTextStyles.font),
                              ),
                              UtilValues.gap4,
                              SvgPicture.asset(AssetsManager.rightCircle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .5,
                    child: Text(
                      title,
                      maxLines: 1,
                      style: const TextStyle(
                          color: ColorsPalette.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    width: MediaQuery.of(context).size.width * .58,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          by,
                          style: TextStyle(
                              color: ColorsPalette.customGrey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font),
                        ),
                        UtilValues.gap4,
                        Text(
                          vendorName,
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: ZainTextStyles.font),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .58,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (discount > 0) ...[
                              Text(
                                discount.toString(),
                                style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: ColorsPalette.red,
                                    color: ColorsPalette.red,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: ZainTextStyles.font),
                              ),
                            ],
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  // ((qtyProduct ?? 1) * price).toString()
                                  price.toString()
                                  /*== 0
                                      ? LocaleKeys.priceOnSelection.tr()
                                      : Helpers.formatPrice(price)*/
                                  ,
                                  style: TextStyle(
                                    color: ColorsPalette.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  LocaleKeys.le.tr(),
                                  style: TextStyle(
                                    color: ColorsPalette.customGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        if (inCart)
                          Container(
                            height: 25,
                            width: MediaQuery.of(context).size.width * .37,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: ColorsPalette.grey),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: InkWell(
                                    onTap: onPressed,
                                    child: SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: SvgPicture.asset(
                                        AssetsManager.addToCart,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  qtyProduct.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton(
                                  onPressed: onPressedMinus,
                                  icon: SvgPicture.asset(
                                    AssetsManager.minus,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            height: 25,
                            width: MediaQuery.of(context).size.width * .37,
                            child: SimplePrimaryButton(
                              borderRadius: BorderRadius.circular(5),
                              label: LocaleKeys.addToCart.tr(),
                              icon: AssetsManager.addToCart,
                              iconColor: ColorsPalette.white,
                              onPressed: onPressed,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
