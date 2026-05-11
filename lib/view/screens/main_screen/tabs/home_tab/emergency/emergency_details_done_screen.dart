import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_card.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/snackbars.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../model/order_details_model.dart';
import '../../../../../../model/user.dart' as user;
import '../../../../addresses_book_screen/local_widgets/address_card.dart';
import '../../../main_screen.dart';
import '../../my_orders_tab/local_widet/my_orders_card.dart';
import '../car_parts/order_success_screen.dart';

class EmergencyOrderDetailsScreen extends StatefulWidget {
  const EmergencyOrderDetailsScreen({
    Key? key,
    required this.vendorNum,
    required this.vendorName,
    required this.orderNum,
    required this.orderType,
  }) : super(key: key);

  final String vendorNum;
  final String vendorName;
  final int orderNum;
  final int orderType;

  @override
  State<EmergencyOrderDetailsScreen> createState() =>
      _EmergencyOrderDetailsScreenState();
}

class _EmergencyOrderDetailsScreenState
    extends State<EmergencyOrderDetailsScreen> {
  bool _isLoading = false;

  user.DefaultAddress? address;
  var prices;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ColorsPalette.lightGrey,
        body: FutureBuilder<OrderRateModel>(
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
              final color = _getColors(order);
              return FutureBuilder(
                  future: _splashOperation(context, order),
                  builder: (context, snapshot) {
                    return Scaffold(
                        backgroundColor: ColorsPalette.lightGrey,
                        appBar: AppBarApp(
                          backButton: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainScreen(
                                            index: 0,
                                          )),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Helpers.isArabic(context)
                                    ? SvgPicture.asset(
                                        AssetsManager.angleLeft,
                                        fit: BoxFit.scaleDown,
                                        width: 16.sp,
                                      )
                                    : Transform(
                                        transform: Matrix4.rotationY(
                                            180 * 3.1415927 / 180),
                                        alignment: Alignment.center,
                                        child: SvgPicture.asset(
                                          AssetsManager.angleLeft,
                                          fit: BoxFit.scaleDown,
                                          width: 16.sp,
                                        )),
                              )),
                          title:
                              '${LocaleKeys.orderNumber.tr()} ${widget.orderNum}',
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
                                    _vendorCard(),
                                    UtilValues.gap8,
                                    Builder(builder: (context) {
                                      final userProvider =
                                          context.read<UserProvider>();
                                      if (userProvider.user != null) {
                                        address = userProvider
                                            .user?.data?.user?.defaultAddress;
                                        if (address != null) {
                                          return CustomCard(
                                            color: ColorsPalette.white,
                                            border: Border.all(
                                                color: ColorsPalette.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                      border:
                                          Border.all(color: ColorsPalette.grey),
                                      color: ColorsPalette.white,
                                      child: Column(
                                        children: [
                                          _orderDetails(
                                              LocaleKeys.orderDate.tr(),
                                              order?.deliveryTime ?? ''),
                                          // _orderDetails(
                                          //     LocaleKeys.onTheWay.tr(),
                                          //     /* order?.deliveryTime ??*/ ''),
                                          // _orderDetails(
                                          //     LocaleKeys.deliveryDate.tr(),
                                          //     /*order?.deliveryTime ??*/ ''),
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
                                        border: Border.all(
                                            color: ColorsPalette.grey),
                                        color: ColorsPalette.white,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  LocaleKeys.paymentMethod.tr(),
                                                  style: TextStyle(
                                                      color: ColorsPalette
                                                          .customGrey,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          ZainTextStyles.font,
                                                      fontSize: 14.sp),
                                                ),
                                                Spacer(),
                                                Text(
                                                  (order?.paymentMethod == 0 ||
                                                          order?.paymentMethod ==
                                                              2)
                                                      ? LocaleKeys.cash.tr()
                                                      : LocaleKeys.credit.tr(),
                                                  style: TextStyle(
                                                      color:
                                                          ColorsPalette.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily:
                                                          ZainTextStyles.font,
                                                      fontSize: 14.sp),
                                                ),
                                                UtilValues.gap4,
                                                SvgPicture.asset(
                                                  (order?.paymentMethod == 0 ||
                                                          order?.paymentMethod ==
                                                              2)
                                                      ? AssetsManager.cash
                                                      : AssetsManager
                                                          .masterCard,
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                          onPressed: _callVendor,
                                          style: ButtonStyle(
                                              textStyle: MaterialStateProperty
                                                  .all<TextStyle>(
                                                TextStyle(
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  side: const BorderSide(
                                                      color: ColorsPalette
                                                          .primaryColor),
                                                ),
                                              ),
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .all<Color>(ColorsPalette
                                                          .primaryColor)),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                AssetsManager.phone,
                                                color: ColorsPalette.white,
                                              ),
                                              UtilValues.gap8,
                                              Text(
                                                LocaleKeys.callVendor.tr(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        ColorsPalette.lightGrey,
                                                    fontFamily:
                                                        ZainTextStyles.font),
                                                //maxLines: 3,
                                              ),
                                            ],
                                          )),
                                    ),
                                    UtilValues.gap8,
                                    if (order?.status != 'cancelled')
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: cancelOrder,
                                          style: ButtonStyle(
                                            textStyle: MaterialStateProperty
                                                .all<TextStyle>(
                                              TextStyle(
                                                  fontSize: 14.sp,
                                                  fontFamily:
                                                      ZainTextStyles.font),
                                            ),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                side: const BorderSide(
                                                    color: ColorsPalette.black),
                                              ),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    ColorsPalette.lightGrey),
                                          ),
                                          child: Text(
                                            LocaleKeys.cancelOrder.tr(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: ColorsPalette.black,
                                                fontFamily:
                                                    ZainTextStyles.font),
                                            //maxLines: 3,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ));
                  });
            }),
      ),
    );
  }

  void cancelOrder() async {
    try {
      await MiscellaneousApi.cancelEmergencyOrder(
          id: widget.orderNum, locale: context.locale);
      await MiscellaneousApi.getEmergencyDetails(
          locale: context.locale, id: widget.orderNum);
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

  void _callVendor() async {
    await launchUrlString("tel://${widget.vendorNum}");
  }

  void _openSmsChat() async {
    await launchUrlString("sms://${widget.vendorNum}");
  }

  void _rateOrder({
    required double productsRate,
    required double servicesRate,
    required String comment,
  }) async {
    try {
      await MiscellaneousApi.rateEmergencyOrder(
        id: widget.orderNum,
        locale: context.locale,
        comment: comment,
      );
      await MiscellaneousApi.getEmergencyDetails(
          locale: context.locale, id: widget.orderNum);
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
                Text(
                  LocaleKeys.rateProducts.tr(),
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
                      _ratingProducts = rating;
                    });
                  },
                  displayRatingValue: true, // Display the rating value
                  interactiveTooltips: true, // Allow toggling half-star state
                  customFilledIcon: Icons.star,
                  customHalfFilledIcon: Icons.star_half,
                  customEmptyIcon: Icons.star_border,
                  starSize: 40.0,
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
                  starSize: 40.0,
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

  _vendorCard() {
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
                widget.vendorName,
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
                      widget.vendorNum,
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
                            onTap: _callVendor,
                            child: SvgPicture.asset(
                              AssetsManager.phone,
                            )),
                        UtilValues.gap24,
                        InkWell(
                            onTap: _openSmsChat,
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

  List<Color> _getColors(Order? order) {
    switch (order?.status) {
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

  Future<void> _splashOperation(BuildContext context, Order? order) async {
    try {
      await Future.delayed(const Duration(seconds: 10));
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return OrderSuccessScreen(
          orderNumber: order?.id,
          selectedDate: '',
          total: order?.total,
          myOrdersIndex: 4,
        );
      }), (e) => false);
    } catch (_) {}
  }
}
