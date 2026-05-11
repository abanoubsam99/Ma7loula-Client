import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:ma7lola/core/widgets/custom_card.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../model/order_details_model.dart';
import '../../../../../model/user.dart';
import '../../../addresses_book_screen/local_widgets/address_card.dart';
import 'local_widet/my_orders_card.dart';
import 'local_widet/product_card.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({
    Key? key,
    required this.orderNum,
    required this.orderType,
  }) : super(key: key);

  final int orderNum;
  final int orderType;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool _isLoading = false;

  DefaultAddress? address;
  var prices;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ColorsPalette.lightGrey,
        body: /*widget.orderType == 4 ? _emergencyWidget() :*/ _allWidget(),
      ),
    );
  }

  _allWidget() {
    return FutureBuilder<OrderRateModel>(
        future: (widget.orderType == 0)
            ? MiscellaneousApi.getBatteryOrderDetails(
                locale: context.locale, id: widget.orderNum)
            : (widget.orderType == 1)
                ? MiscellaneousApi.getTiresOrderDetails(
                    locale: context.locale, id: widget.orderNum)
                : (widget.orderType == 2)
                    ? MiscellaneousApi.getCarPartsOrderDetails(
                        locale: context.locale, id: widget.orderNum)
                    : (widget.orderType == 3)
                        ? MiscellaneousApi.getWinchDetails(
                            locale: context.locale, id: widget.orderNum)
                        : MiscellaneousApi.getEmergencyDetails(
                            locale: context.locale, id: widget.orderNum),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(
                color: ColorsPalette.primaryColor,
              ),
            );
          }

          final orderDetails = snapshot.data!;

          if (orderDetails.data == null) {
            return SizedBox.shrink();
          }
          final order = orderDetails.data?.order;
          final color = _getColors(order?.status);

          return Scaffold(
              backgroundColor: ColorsPalette.lightGrey,
              appBar: AppBarApp(
                title: '${LocaleKeys.orderNumber.tr()} ${widget.orderNum}',
                actions: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: color.first,
                        borderRadius: BorderRadius.circular(25.sp)),
                    child: Text(
                      "${order?.status ?? ''}" .tr(),
                      style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: ZainTextStyles.font),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: ColorsPalette.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SvgPicture.asset(AssetsManager.carShape),
                          UtilValues.gap8,
                          Text(
                            (order?.userCar != null)
                                ? '${order?.userCar?.car?.model?.brand?.name} ${order?.userCar?.car?.model?.name} ${order?.userCar?.car?.year}'
                                : '----',
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                    if (order?.products != null &&
                        order!.products!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${LocaleKeys.products.tr()} (${order.products?.length})',
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w500,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                      ),
                      _productsWidget(order),
                    ],
                    if (widget.orderType == 4)
                      _vendorCard(order?.id.toString() ?? '',
                          order?.id.toString() ?? ''),
                    UtilValues.gap8,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.addressSelected.tr(),
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp),
                          ),
                          UtilValues.gap4,
                          Builder(builder: (context) {
                            final userProvider = context.read<UserProvider>();
                            if (userProvider.user != null) {
                              address =
                                  userProvider.user?.data?.user?.defaultAddress;
                              if (address != null) {
                                return CustomCard(
                                  color: ColorsPalette.white,
                                  border: Border.all(color: ColorsPalette.grey),
                                  borderRadius: BorderRadius.circular(10),
                                  child: AddressCard(
                                    name: address?.name ?? '',
                                    city: address?.city?.name ?? '',
                                    details: address?.details ?? '',
                                    selected: false,
                                    // fromCheckout: true,
                                  ),
                                );
                              }
                            }
                            return SizedBox.shrink();
                          }),
                          UtilValues.gap8,
                          Text(
                            LocaleKeys.orderDate.tr(),
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp),
                          ),
                          UtilValues.gap4,
                          CustomCard(
                            border: Border.all(color: ColorsPalette.grey),
                            color: ColorsPalette.white,
                            child: Column(
                              children: [
                                _orderDetails(LocaleKeys.orderDate.tr(),
                                    order?.deliveryTime ?? ''),
                                // _orderDetails(LocaleKeys.onTheWay.tr(),
                                //     order?.deliveryTime ?? ''),
                                // _orderDetails(LocaleKeys.deliveryDate.tr(),
                                //     order?.deliveryTime ?? ''),
                              ],
                            ),
                          ),
                          UtilValues.gap8,
                          Text(
                            LocaleKeys.paymentData.tr(),
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp),
                          ),
                          UtilValues.gap4,
                          CustomCard(
                              border: Border.all(color: ColorsPalette.grey),
                              color: ColorsPalette.white,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        LocaleKeys.paymentMethod.tr(),
                                        style: TextStyle(
                                            color: ColorsPalette.customGrey,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: ZainTextStyles.font,
                                            fontSize: 14.sp),
                                      ),
                                      Spacer(),
                                      Text(
                                        (order?.paymentMethod == 0 ||
                                                order?.paymentMethod == 2)
                                            ? LocaleKeys.cash.tr()
                                            : LocaleKeys.credit.tr(),
                                        style: TextStyle(
                                            color: ColorsPalette.black,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: ZainTextStyles.font,
                                            fontSize: 14.sp),
                                      ),
                                      UtilValues.gap4,
                                      SvgPicture.asset(
                                        (order?.paymentMethod == 0 ||
                                                order?.paymentMethod == 2)
                                            ? AssetsManager.cash
                                            : AssetsManager.masterCard,
                                      ),
                                    ],
                                  ),
                                  if(order?.productsPrice!=null)
                                  _paymentDetails(
                                    LocaleKeys.priceOnSelection.tr(),
                                    Helpers.formatPrice(order?.productsPrice??0).toString(),
                                  ),
                                  if(order?.vendorLines!=null&& order!.vendorLines!.isNotEmpty&&order.vendorLines!.first.offeredTotal!=null)
                                  _paymentDetails(
                                    "Offered Total".tr(),
                                    Helpers.formatPrice(order.vendorLines!.first.offeredTotal??0).toString(),
                                  ),
                                  if(order?.productsPrice!=null)
                                    _paymentDetails(
                                    LocaleKeys.taxes.tr(),
                                    Helpers.formatPrice(((order?.vendorLines!=null&& order!.vendorLines!.isNotEmpty&&order.vendorLines!.first.offeredTotal!=null)?(order.vendorLines!.first.offeredTotal??0):(order?.productsPrice??0))/(order?.taxPrice??0)).toString(),
                                  ),
                                   _paymentDetails(
                                    LocaleKeys.total.tr(),
                                    Helpers.formatPrice((order?.vendorLines!=null&& order!.vendorLines!.isNotEmpty&&order.vendorLines!.first.offeredTotal!=null)?order.vendorLines!.first.total:order?.total).toString(),
                                  ),

                                ],
                              )),

                        ],
                      ),
                    ),
                    UtilValues.gap8,
                    if (order?.rate != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          LocaleKeys.rate.tr(),
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w500,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomCard(
                            border: Border.all(color: ColorsPalette.grey),
                            color: ColorsPalette.white,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      LocaleKeys.rateService.tr(),
                                      style: TextStyle(
                                          color: ColorsPalette.customGrey,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: ZainTextStyles.font,
                                          fontSize: 14.sp),
                                    ),
                                    Spacer(),
                                    AnimatedRatingStars(
                                      readOnly: true,
                                      initialRating: order?.rate?.services !=
                                              null
                                          ? double.parse(order?.rate?.services
                                                  ?.toString() ??
                                              '')
                                          : 2.2,
                                      onChanged: (rating) {},
                                      displayRatingValue:
                                          true, // Display the rating value
                                      interactiveTooltips:
                                          true, // Allow toggling half-star state
                                      customFilledIcon: Icons.star,
                                      customHalfFilledIcon: Icons.star_half,
                                      customEmptyIcon: Icons.star_border,
                                      starSize: 15.0,
                                      animationDuration:
                                          const Duration(milliseconds: 500),
                                      animationCurve: Curves.easeInOut,
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                      if(widget.orderType != 3&&widget.orderType != 4)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomCard(
                            border: Border.all(color: ColorsPalette.grey),
                            color: ColorsPalette.white,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      LocaleKeys.rateProducts.tr(),
                                      style: TextStyle(
                                          color: ColorsPalette.customGrey,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: ZainTextStyles.font,
                                          fontSize: 14.sp),
                                    ),
                                    Spacer(),
                                    AnimatedRatingStars(
                                      readOnly: true,
                                      initialRating: order?.rate?.products !=
                                          null
                                          ? double.parse(order?.rate?.products
                                          ?.toString() ??
                                          '')
                                          : 2.2,
                                      onChanged: (rating) {},
                                      displayRatingValue:
                                      true, // Display the rating value
                                      interactiveTooltips:
                                      true, // Allow toggling half-star state
                                      customFilledIcon: Icons.star,
                                      customHalfFilledIcon: Icons.star_half,
                                      customEmptyIcon: Icons.star_border,
                                      starSize: 15.0,
                                      animationDuration:
                                      const Duration(milliseconds: 500),
                                      animationCurve: Curves.easeInOut,
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ],
                    // if (order?.status =="offer_pending")
                    if(order?.vendorLines!=null&& order!.vendorLines!.isNotEmpty&&order.vendorLines!.first.offeredTotal!=null&&order?.status != 'cancelled'&&order?.status!="completed")
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              // color: ColorsPalette.white,
                              padding: UtilValues.padding16,
                              child: Container(
                                // padding: EdgeInsets.symmetric(vertical: 2.h),
                                margin: EdgeInsets.all(1.sp),
                                height: 6.h,
                                child: ElevatedButton(
                                  onPressed: (){
                                    actionOffersOrder(order.vendorLines!.first.orderVendorId.toString());
                                  },
                                  style: ButtonStyle(
                                    textStyle: MaterialStateProperty.all<TextStyle>(
                                      TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ColorsPalette.black,
                                        fontFamily: ZainTextStyles.font,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(color: ColorsPalette.black),
                                      ),
                                    ),
                                    backgroundColor: MaterialStateProperty.all<Color>(ColorsPalette.lighttGrey),
                                    foregroundColor: MaterialStateProperty.all<Color>(ColorsPalette.lighttGrey),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Accept Offer".tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ColorsPalette.black,
                                          fontFamily: ZainTextStyles.font,
                                          fontSize: 14.sp),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Container(
                              // color: ColorsPalette.white,
                              padding: UtilValues.padding16,
                              child: Container(
                                // padding: EdgeInsets.symmetric(vertical: 2.h),
                                margin: EdgeInsets.all(1.sp),
                                height: 6.h,
                                child: ElevatedButton(
                                  onPressed: cancelOrder,
                                  style: ButtonStyle(
                                    textStyle: MaterialStateProperty.all<TextStyle>(
                                      TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ColorsPalette.black,
                                        fontFamily: ZainTextStyles.font,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(
                                            color: ColorsPalette.black),
                                      ),
                                    ),
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                        ColorsPalette.lighttGrey),
                                    foregroundColor: MaterialStateProperty.all<Color>(
                                        ColorsPalette.lighttGrey),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Cancel Offer".tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ColorsPalette.black,
                                          fontFamily: ZainTextStyles.font,
                                          fontSize: 14.sp),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (order?.status != 'cancelled'&&order?.status!="completed")
                      Container(
                        // color: ColorsPalette.white,
                        padding: UtilValues.padding16,
                        child: Container(
                          // padding: EdgeInsets.symmetric(vertical: 2.h),
                          margin: EdgeInsets.all(1.sp),
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed: cancelOrder,
                            style: ButtonStyle(
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorsPalette.black,
                                  fontFamily: ZainTextStyles.font,
                                  fontSize: 14.sp,
                                ),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: ColorsPalette.black),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  ColorsPalette.lighttGrey),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  ColorsPalette.lighttGrey),
                            ),
                            child: Center(
                              child: Text(
                                LocaleKeys.cancelOrder.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorsPalette.black,
                                    fontFamily: ZainTextStyles.font,
                                    fontSize: 14.sp),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (order?.status == 'cancelled') UtilValues.gap16,
                    if (order?.rate == null)
                      Container(
                        // color: ColorsPalette.white,
                        padding:
                            EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: Container(
                          // padding: EdgeInsets.symmetric(vertical: 2.h),
                          margin: EdgeInsets.all(1.sp),
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed: _showDialog,
                            style: ButtonStyle(
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorsPalette.black,
                                  fontFamily: ZainTextStyles.font,
                                  fontSize: 14.sp,
                                ),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: ColorsPalette.black),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  ColorsPalette.lighttGrey),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  ColorsPalette.lighttGrey),
                            ),
                            child: Center(
                              child: Text(
                                LocaleKeys.rateOrder.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorsPalette.black,
                                    fontFamily: ZainTextStyles.font,
                                    fontSize: 14.sp),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ));
        });
  }

  void actionOffersOrder(String order_vendor_id) async {
    try {
      await MiscellaneousApi.CarPartsRespondVendorOffer(
          locale: context.locale, order_vendor_id: widget.orderNum.toString(),action:"accept");
      // if (widget.orderType == 0) {
      //   await MiscellaneousApi.CarPartsRespondVendorOffer(
      //       order_vendor_id: widget.orderNum.toString(), locale: context.locale,action:"accept");
      //   await MiscellaneousApi.CarPartsRespondVendorOffer(
      //       locale: context.locale, order_vendor_id: widget.orderNum.toString(),action:"accept");
      // } else if (widget.orderType == 1) {
      //   await MiscellaneousApi.cancelTiresOrder(
      //       id: widget.orderNum, locale: context.locale);
      //   await MiscellaneousApi.getTiresOrderDetails(
      //       locale: context.locale, id: widget.orderNum);
      // } else if (widget.orderType == 2) {
      //   await MiscellaneousApi.cancelCarPartsOrder(
      //       id: widget.orderNum, locale: context.locale);
      //   await MiscellaneousApi.getCarPartsOrderDetails(
      //       locale: context.locale, id: widget.orderNum);
      // } else if (widget.orderType == 3) {
      //   await MiscellaneousApi.cancelWinchOrder(
      //       id: widget.orderNum, locale: context.locale);
      //   await MiscellaneousApi.getWinchDetails(
      //       locale: context.locale, id: widget.orderNum);
      // } else {
      //   await MiscellaneousApi.cancelEmergencyOrder(
      //       id: widget.orderNum, locale: context.locale);
      //   await MiscellaneousApi.getEmergencyDetails(
      //       locale: context.locale, id: widget.orderNum);
      // }
      setState(() {});
      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
      // Navigator.pop(context);
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }
  void cancelOrder() async {
    try {
      if (widget.orderType == 0) {
        await MiscellaneousApi.cancelBatteryOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.cancelBatteryOrder(
            locale: context.locale, id: widget.orderNum);
      } else if (widget.orderType == 1) {
        await MiscellaneousApi.cancelTiresOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.getTiresOrderDetails(
            locale: context.locale, id: widget.orderNum);
      } else if (widget.orderType == 2) {
        await MiscellaneousApi.cancelCarPartsOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.getCarPartsOrderDetails(
            locale: context.locale, id: widget.orderNum);
      } else if (widget.orderType == 3) {
        await MiscellaneousApi.cancelWinchOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.getWinchDetails(
            locale: context.locale, id: widget.orderNum);
      } else {
        await MiscellaneousApi.cancelEmergencyOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.getEmergencyDetails(
            locale: context.locale, id: widget.orderNum);
      }
      setState(() {});
      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
      // Navigator.pop(context);
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }

  void _rateOrder({
    required double productsRate,
    required double servicesRate,
    required String comment,
  }) async {
    try {
      if (widget.orderType == 0) {
        await MiscellaneousApi.rateBatteryOrder(
          id: widget.orderNum,
          locale: context.locale,
          productsRate: productsRate,
          servicesRate: servicesRate,
          comment: comment,
        );
        await MiscellaneousApi.getBatteryOrderDetails(
            locale: context.locale, id: widget.orderNum);
      } else if (widget.orderType == 1) {
        await MiscellaneousApi.rateTiresOrder(
          id: widget.orderNum,
          locale: context.locale,
          productsRate: productsRate,
          servicesRate: servicesRate,
          comment: comment,
        );
        await MiscellaneousApi.getTiresOrderDetails(
            locale: context.locale, id: widget.orderNum);
      } else if (widget.orderType == 2) {
        await MiscellaneousApi.rateCarPartsOrder(
          id: widget.orderNum,
          locale: context.locale,
          productsRate: productsRate,
          servicesRate: servicesRate,
          comment: comment,
        );
        await MiscellaneousApi.getCarPartsOrderDetails(
            locale: context.locale, id: widget.orderNum);
      } else if (widget.orderType == 3) {
        await MiscellaneousApi.rateWinchOrder(
          id: widget.orderNum,
          locale: context.locale,
          productsRate: productsRate,
          servicesRate: servicesRate,
          comment: comment,
        );
        await MiscellaneousApi.getWinchDetails(
            locale: context.locale, id: widget.orderNum);
      } else {
        await MiscellaneousApi.rateEmergencyOrder(
          id: widget.orderNum,
          locale: context.locale,
          comment: comment,
        );
        await MiscellaneousApi.getEmergencyDetails(
            locale: context.locale, id: widget.orderNum);
      }
      setState(() {});
      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
      Navigator.pop(context);
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }

  double _ratingService = 0;
  double _ratingProducts = 0;
  String _comment = '';
  _showDialog() {
    showDialog(
      // barrierDismissible: isButtonEnabled,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              LocaleKeys.rateOrder.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: ColorsPalette.black,
                fontFamily: ZainTextStyles.font,
              ),
              //maxLines: 3,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if(widget.orderType != 3&&widget.orderType != 4)
                Text(
                  LocaleKeys.rateProducts.tr(),
                  style: TextStyle(
                      color: ColorsPalette.customGrey,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
                if(widget.orderType != 3&&widget.orderType != 4)
                  AnimatedRatingStars(
                  initialRating: 0,
                  onChanged: (rating) { 
                    setState(() {
                      _ratingProducts = rating;
                    });
                  },
                  displayRatingValue: true, // Display the rating value
                  interactiveTooltips: true, // Allow toggling half-star state
                  customFilledIcon: Icons.star,
                  customHalfFilledIcon: Icons.star_half,
                  customEmptyIcon: Icons.star_border,
                  starSize: 35.0,
                  animationDuration: const Duration(milliseconds: 500),
                  animationCurve: Curves.easeInOut,
                ),
                UtilValues.gap16,
                Text(
                  LocaleKeys.rateService.tr(),
                  style: TextStyle(
                      color: ColorsPalette.customGrey,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
                AnimatedRatingStars(
                  initialRating: 0,
                  onChanged: (rating) {
                    setState(() {
                      _ratingService = rating;
                    });
                  },
                  displayRatingValue: true, // Display the rating value
                  interactiveTooltips: true, // Allow toggling half-star state
                  customFilledIcon: Icons.star,
                  customHalfFilledIcon: Icons.star_half,
                  customEmptyIcon: Icons.star_border,
                  starSize: 35.0,
                  animationDuration: const Duration(milliseconds: 500),
                  animationCurve: Curves.easeInOut,
                ),
                UtilValues.gap16,
              ],
            ),
            actions: <Widget>[
              Row(
                children: [
                  Container(
                    // padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    // margin: EdgeInsets.all(1.sp),
                    height: 5.h,
                    child: ElevatedButton(
                        onPressed: () {
                          _rateOrder(
                              productsRate: _ratingProducts,
                              servicesRate: _ratingService,
                              comment: _comment);
                        },
                        style: ButtonStyle(
                            textStyle: MaterialStateProperty.all<TextStyle>(
                              TextStyle(
                                fontSize: 14.sp,
                              ),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: ColorsPalette.primaryColor),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                ColorsPalette.primaryColor)),
                        child: Text(
                          LocaleKeys.save.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: ColorsPalette.lightGrey,
                              fontFamily: ZainTextStyles.font),
                          //maxLines: 3,
                        )),
                  ),
                  UtilValues.gap8,
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(
                            fontSize: 14.sp, fontFamily: ZainTextStyles.font),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: ColorsPalette.black),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorsPalette.lightGrey),
                    ),
                    child: Text(
                      LocaleKeys.cancel.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: ColorsPalette.black,
                          fontFamily: ZainTextStyles.font),
                      //maxLines: 3,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  _paymentDetails(String text, String num) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
              color: ColorsPalette.customGrey,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
        Spacer(),
        Text(
          num.toString(),
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w600,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
        UtilValues.gap4,
        Text(
          LocaleKeys.le.tr(),
          style: TextStyle(
              color: ColorsPalette.customGrey,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
      ],
    );
  }

  _orderDetails(String text, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
              color: ColorsPalette.customGrey,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
        Spacer(),
        Text(
          date,
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w600,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> prepareProductData(List<Products> products) {
    List<Map<String, dynamic>> productData = [];

    for (var product in products.toSet()) {
      productData.add({
        "id": product.id,
        "qty": product.qty,
      });
    }

    return productData;
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

  List<Color> _getColors(String? status) {
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

  _productsWidget(Order? order) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: order?.products?.length,
          itemBuilder: (context, index) {
            final product = order?.products?[index];
            return Padding(
              padding: EdgeInsets.all(5.0.sp),
              child: InkWell(
                onTap: () {},
                child: ProductCard(
                  imageUrl: product?.thumbnail?.url ?? '',
                  title: product?.name ?? '',
                  onTap: () {},
                  onPressed: () {},
                  onPressedMinus: () {},
                  inCart: false,
                  inDatails: true,
                  description: '',
                  price: product?.total ?? 0.0,
                  discount: 0.0,
                  by: LocaleKeys.by.tr(),
                  vendorName: product?.vendor?.name ?? '',
                  productName: '',
                  qtyProduct: product?.qty ?? 1,
                  products: product!,
                ),
              ),
            );
          }),
    );
  }

  _vendorCard(String vendorName, String vendorNum) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                AssetsManager.userPic,
                width: MediaQuery.of(context).size.width * .2,
                fit: BoxFit.fill,
              ),
            ),
          ),
          UtilValues.gap12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UtilValues.gap8,
              Text(
                vendorName,
                style: const TextStyle(
                    color: ColorsPalette.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: ZainTextStyles.font),
              ),
              UtilValues.gap8,
              SizedBox(
                height: 20,
                width: MediaQuery.of(context).size.width * .57,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vendorNum,
                      style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: ZainTextStyles.font),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        InkWell(
                            onTap: () => _callVendor(vendorNum),
                            child: SvgPicture.asset(
                              AssetsManager.phone,
                            )),
                        UtilValues.gap24,
                        InkWell(
                            onTap: () => _openSmsChat(vendorNum),
                            child: Icon(
                              CupertinoIcons.chat_bubble_text,
                              size: 17,
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          UtilValues.gap4
        ],
      ),
    );
  }

  void _callVendor(String vendorNum) async {
    await launchUrlString("tel://$vendorNum");
  }

  void _openSmsChat(String vendorNum) async {
    await launchUrlString("sms://$vendorNum");
  }
}

/*
  _emergencyWidget() {
    return FutureBuilder<em.CreateEmergencyOrderModel>(
        future: MiscellaneousApi.getEmergencyDetails(
            locale: context.locale, id: widget.orderNum),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(
                color: ColorsPalette.primaryColor,
              ),
            );
          }

          final orderDetails = snapshot.data!;

          if (orderDetails.data == null) {
            return SizedBox.shrink();
          }
          final order = orderDetails.data?.order;
          final color = _getColors(order?.status);

          return Scaffold(
              backgroundColor: ColorsPalette.lightGrey,
              appBar: AppBarApp(
                title: '${LocaleKeys.orderNumber.tr()} ${widget.orderNum}',
                actions: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        color: color.first,
                        borderRadius: BorderRadius.circular(25.sp)),
                    child: Text(
                      order?.status ?? '',
                      style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: ZainTextStyles.font),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: ColorsPalette.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SvgPicture.asset(AssetsManager.carShape),
                          UtilValues.gap8,
                          Text(
                            (order?.userCar != null)
                                ? '${order?.userCar?.car?.model?.brand?.name} ${order?.userCar?.car?.model?.name} ${order?.userCar?.car?.year}'
                                : '----',
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                    _vendorCard(
                        order?.vendor?.name ?? '', order?.id.toString() ?? ''),
                    UtilValues.gap8,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.addressSelected.tr(),
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp),
                          ),
                          UtilValues.gap4,
                          Builder(builder: (context) {
                            final userProvider = context.read<UserProvider>();
                            if (userProvider.user != null) {
                              address =
                                  userProvider.user?.data?.user?.defaultAddress;
                              if (address != null) {
                                return CustomCard(
                                  color: ColorsPalette.white,
                                  border: Border.all(color: ColorsPalette.grey),
                                  borderRadius: BorderRadius.circular(10),
                                  child: AddressCard(
                                    name: address?.name ?? '',
                                    city: address?.city?.name ?? '',
                                    details: address?.details ?? '',
                                    selected: false,
                                    // fromCheckout: true,
                                  ),
                                );
                              }
                            }
                            return SizedBox.shrink();
                          }),
                          UtilValues.gap8,
                          Text(
                            LocaleKeys.paymentData.tr(),
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp),
                          ),
                          UtilValues.gap4,
                          CustomCard(
                            border: Border.all(color: ColorsPalette.grey),
                            color: ColorsPalette.white,
                            child: Column(
                              children: [
                                _orderDetails(LocaleKeys.orderDate.tr(),
                                    */
/* order?.deliveryTime ?? */ /*
 ''),
                                _orderDetails(LocaleKeys.onTheWay.tr(),
                                    */
/*order?.deliveryTime ??*/ /*
 ''),
                                _orderDetails(LocaleKeys.deliveryDate.tr(),
                                    */
/* order?.deliveryTime ??*/ /*
 ''),
                              ],
                            ),
                          ),
                          UtilValues.gap8,
                          Text(
                            LocaleKeys.paymentData.tr(),
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp),
                          ),
                          UtilValues.gap4,
                          CustomCard(
                              border: Border.all(color: ColorsPalette.grey),
                              color: ColorsPalette.white,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        LocaleKeys.paymentMethod.tr(),
                                        style: TextStyle(
                                            color: ColorsPalette.customGrey,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: ZainTextStyles.font,
                                            fontSize: 14.sp),
                                      ),
                                      Spacer(),
                                      Text(
                                        (order?.paymentMethod == 0 ||
                                                order?.paymentMethod == 2)
                                            ? LocaleKeys.cash.tr()
                                            : LocaleKeys.credit.tr(),
                                        style: TextStyle(
                                            color: ColorsPalette.black,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: ZainTextStyles.font,
                                            fontSize: 14.sp),
                                      ),
                                      UtilValues.gap4,
                                      SvgPicture.asset(
                                        (order?.paymentMethod == 0 ||
                                                order?.paymentMethod == 2)
                                            ? AssetsManager.cash
                                            : AssetsManager.masterCard,
                                      ),
                                    ],
                                  ),
                                  _paymentDetails(
                                    LocaleKeys.total.tr(),
                                    Helpers.formatPrice(order?.total)
                                        .toString(),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                    UtilValues.gap8,
                    if (order?.rate != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          LocaleKeys.rate.tr(),
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w500,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomCard(
                            border: Border.all(color: ColorsPalette.grey),
                            color: ColorsPalette.white,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      LocaleKeys.rateService.tr(),
                                      style: TextStyle(
                                          color: ColorsPalette.customGrey,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: ZainTextStyles.font,
                                          fontSize: 14.sp),
                                    ),
                                    Spacer(),
                                    AnimatedRatingStars(
                                      readOnly: true,
                                      initialRating: order?.rate?.services !=
                                              null
                                          ? double.parse(order?.rate?.services
                                                  ?.toString() ??
                                              '')
                                          : 2.2,
                                      onChanged: (rating) {},
                                      displayRatingValue:
                                          true, // Display the rating value
                                      interactiveTooltips:
                                          true, // Allow toggling half-star state
                                      customFilledIcon: Icons.star,
                                      customHalfFilledIcon: Icons.star_half,
                                      customEmptyIcon: Icons.star_border,
                                      starSize: 15.0,
                                      animationDuration:
                                          const Duration(milliseconds: 500),
                                      animationCurve: Curves.easeInOut,
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ],
                    if (order?.status != 'cancelled')
                      Container(
                        // color: ColorsPalette.white,
                        padding: UtilValues.padding16,
                        child: Container(
                          // padding: EdgeInsets.symmetric(vertical: 2.h),
                          margin: EdgeInsets.all(1.sp),
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed: cancelOrder,
                            style: ButtonStyle(
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorsPalette.black,
                                  fontFamily: ZainTextStyles.font,
                                  fontSize: 14.sp,
                                ),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: ColorsPalette.black),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  ColorsPalette.lighttGrey),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  ColorsPalette.lighttGrey),
                            ),
                            child: Center(
                              child: Text(
                                LocaleKeys.cancelOrder.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorsPalette.black,
                                    fontFamily: ZainTextStyles.font,
                                    fontSize: 14.sp),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (order?.status == 'cancelled') UtilValues.gap16,
                    if (order?.rate == null)
                      Container(
                        // color: ColorsPalette.white,
                        padding:
                            EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: Container(
                          // padding: EdgeInsets.symmetric(vertical: 2.h),
                          margin: EdgeInsets.all(1.sp),
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed: _showDialog,
                            style: ButtonStyle(
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorsPalette.black,
                                  fontFamily: ZainTextStyles.font,
                                  fontSize: 14.sp,
                                ),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: ColorsPalette.black),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  ColorsPalette.lighttGrey),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  ColorsPalette.lighttGrey),
                            ),
                            child: Center(
                              child: Text(
                                LocaleKeys.rateOrder.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorsPalette.black,
                                    fontFamily: ZainTextStyles.font,
                                    fontSize: 14.sp),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ));
        });
  }
*/
