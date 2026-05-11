import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/model/my_orders_model.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../model/my_emergency_order_model.dart' as em;

class MyOrderCard extends StatelessWidget {
  final String status;
  final total;
  final String date;
  final String? fromText;
  final String? toText;
  final String? myLocText;
  final int orderNum;
  final UserCar? car;
  final em.UserCar? carEm;
  final List<Products>? products;
  final VoidCallback onTap;

  const MyOrderCard({
    super.key,
    required this.status,
    required this.date,
    required this.total,
    required this.orderNum,
    this.car,
    this.carEm,
    this.products,
    required this.onTap,
    this.fromText,
    this.toText,
    this.myLocText,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColors();
    return GestureDetector(
        onTap: onTap,
        child: Container(
          // height: 60,
          width: MediaQuery.of(context).size.width,
          // margin: UtilValues.paddinglrt8,
          padding: UtilValues.padding8,
          decoration: BoxDecoration(
              color: ColorsPalette.white,
              borderRadius: UtilValues.borderRadius10,
              border: Border.all(color: ColorsPalette.border2)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: color.first,
                        borderRadius: BorderRadius.circular(25.sp)),
                    child: Text(
                      status.tr(),
                      style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: ZainTextStyles.font),
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${Helpers.formatPrice(total)}${LocaleKeys.le.tr()}',
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: ZainTextStyles.font),
                  )
                ],
              ),
              UtilValues.gap8,
              Row(
                children: [
                  Text(
                    '${LocaleKeys.orderNumber.tr()} $orderNum',
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: ZainTextStyles.font),
                  ),
                  Spacer(),
                  Text(
                    date,
                    style: TextStyle(
                        color: ColorsPalette.customGrey,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: ZainTextStyles.font),
                  )
                ],
              ),
              UtilValues.gap8,
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorsPalette.grey,
                  borderRadius: BorderRadius.circular(5.sp),
                  border: Border.all(color: ColorsPalette.customGrey),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(AssetsManager.key),
                    UtilValues.gap12,
                    if (car != null)
                      Text(
                        '${car?.car?.model?.brand?.name} ${car?.car?.model?.name} ${car?.car?.year}',
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: ZainTextStyles.font),
                      ),
                    if (carEm != null)
                      Text(
                        '${carEm?.car?.model?.brand?.name} ${carEm?.car?.model?.name} ${carEm?.car?.year}',
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: ZainTextStyles.font),
                      ),
                  ],
                ),
              ),
              UtilValues.gap12,
              if (products != null && products!.isNotEmpty)
                Expanded(
                  // height: products.length == 1 ? 30 : 60,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 100,
                        width: 1,
                        color: ColorsPalette.customGrey.withOpacity(.5),
                      ),
                      UtilValues.gap12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  products!.length > 3 ? 3 : products!.length,
                              itemBuilder: (context, index) {
                                final product = products![index];
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(AssetsManager.box),
                                    UtilValues.gap4,
                                    Text(
                                      product.name ?? '',
                                      style: TextStyle(
                                        color: ColorsPalette.black,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: ZainTextStyles.font,
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                            if (products!.length > 3)
                              Text(
                                '+${products!.length - 3} ${LocaleKeys.otherProducts.tr()}',
                                style: TextStyle(
                                  color: ColorsPalette.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: ZainTextStyles.font,
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              if (fromText != null &&
                  toText != null &&
                  toText!.isNotEmpty &&
                  fromText!.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorsPalette.grey,
                        borderRadius: BorderRadius.circular(5.sp),
                        border: Border.all(color: ColorsPalette.customGrey),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(AssetsManager.lc),
                          UtilValues.gap12,
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .27,
                            child: Text(
                              fromText ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: ColorsPalette.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: ZainTextStyles.font),
                            ),
                          ),
                        ],
                      ),
                    ),
                    UtilValues.gap12,
                    Icon(Icons.arrow_right_alt),
                    UtilValues.gap12,
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorsPalette.grey,
                        borderRadius: BorderRadius.circular(5.sp),
                        border: Border.all(color: ColorsPalette.customGrey),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(AssetsManager.lc),
                          UtilValues.gap12,
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .27,
                            child: Text(
                              fromText ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: ColorsPalette.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: ZainTextStyles.font),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (myLocText != null && myLocText!.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorsPalette.grey,
                    borderRadius: BorderRadius.circular(5.sp),
                    border: Border.all(color: ColorsPalette.customGrey),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(AssetsManager.lc),
                      UtilValues.gap12,
                      Text(
                        fromText ?? '',
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: ZainTextStyles.font),
                      ),
                    ],
                  ),
                ),
              Divider(
                color: ColorsPalette.customGrey.withOpacity(.5),
                endIndent: 10,
                indent: 10,
              ),
              UtilValues.gap8,
              InkWell(
                onTap: () {},
                child: Text(
                  LocaleKeys.orderDetails.tr(),
                  style: TextStyle(
                      color: ColorsPalette.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: ZainTextStyles.font),
                ),
              )
            ],
          ),
        ));
  }

  List<Color> _getColors() {
    switch (status) {
      case OrderStatus.ORDER_CANCELLED:
      case OrderStatus.ORDER_ON_THE_RUN:
        return [ColorsPalette.yellow];

      case OrderStatus.ORDER_DELIVERED:
      case OrderStatus.ORDER_COMPELETED:
        return [ColorsPalette.lightGreen];

      case OrderStatus.ORDER_PREPARING:
      case OrderStatus.ORDER_NEW:
        return [ColorsPalette.lightBlue];

      default:
        return [ColorsPalette.lightpre];
    }
  }
}

class OrderStatus {
  static const ORDER_CANCELLED = 'cancelled';
  static const ORDER_NEW = 'new';
  static const ORDER_PREPARING = 'preparing';
  static const ORDER_COMPELETED = 'complete';
  static const ORDER_DELIVERED = 'delivered';
  static const ORDER_ON_THE_RUN = 'on_the_run';
}

/// serm حرارى سيلكون فرى
///
