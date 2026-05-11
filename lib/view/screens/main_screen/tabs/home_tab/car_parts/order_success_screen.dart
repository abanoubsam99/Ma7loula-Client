import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/view/screens/main_screen/main_screen.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_card.dart';
import '../../my_orders_tab/local_widet/my_orders_card.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen(
      {Key? key,
      required this.orderNumber,
      required this.selectedDate,
      required this.total,
       this.status,
      required this.myOrdersIndex})
      : super(key: key);

  final int? orderNumber;
  final String? selectedDate;
  final total;
  final int myOrdersIndex;
  final String? status;
  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ColorsPalette.lightGrey,
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                  ColorsPalette.light.withOpacity(.9), BlendMode.lighten),
              image: AssetImage(AssetsManager.backgroundLogo),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SingleChildScrollView(
              child: Column(children: [
                UtilValues.gap48,
                SizedBox(
                  width: 80.w,
                  height: 35.h,
                  child: Center(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AssetsManager.checkCircle,
                      ),
                      UtilValues.gap16,
                      Text(
                        _getStatus(widget.status??""),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 20.sp),
                      ),
                      if(widget.status!=OrderStatus.ORDER_COMPELETED&&widget.status!=OrderStatus.ORDER_CANCELLED)
                      Text(
                        LocaleKeys.orderBookedSuccessfullyDesc.tr(),
                        style: TextStyle(
                            color: ColorsPalette.customGrey,
                            fontWeight: FontWeight.w400,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 16.sp),
                      ),
                    ],
                  )),
                ),
                UtilValues.gap64,
                CustomCard(
                    border: Border.all(color: ColorsPalette.grey),
                    color: ColorsPalette.white,
                    child: Column(
                      children: [
                        _paymentDetails(LocaleKeys.orderNumber.tr(),
                            widget.orderNumber.toString(), false),
                        if (widget.selectedDate != null)
                          _paymentDetails(LocaleKeys.orderBookedTime.tr(),
                              widget.selectedDate ?? '', false),
                        Divider(
                          color: ColorsPalette.grey,
                        ),
                        _paymentDetails(LocaleKeys.total.tr(),
                            widget.total.toString(), true),
                      ],
                    )),
                UtilValues.gap12,
                _goMyOrdersButton(),
                UtilValues.gap12,
                _goHomeButton(),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  _goMyOrdersButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(1.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MainScreen(index: 2, myOrdersIndex: widget.myOrdersIndex)),
          );
        },
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(
              fontSize: 16.sp,
            ),
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
          child: Text(
            LocaleKeys.myOrders.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorsPalette.white,
                fontFamily: ZainTextStyles.font,
                fontSize: 16.sp),
          ),
        ),
      ),
    );
  }

  _goHomeButton() {
    return Container(
      margin: EdgeInsets.all(1.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      index: 0,
                    )),
          );
        },
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorsPalette.black,
              fontFamily: ZainTextStyles.font,
              fontSize: 16.sp,
            ),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: ColorsPalette.black),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all<Color>(ColorsPalette.lighttGrey),
        ),
        child: Center(
          child: Text(
            LocaleKeys.home.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorsPalette.black,
                fontFamily: ZainTextStyles.font,
                fontSize: 16.sp),
          ),
        ),
      ),
    );
  }

  _paymentDetails(String text, String num, bool le) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
              color: ColorsPalette.customGrey,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 16.sp),
        ),
        Spacer(),
        Text(
          num.toString(),
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w600,
              fontFamily: ZainTextStyles.font,
              fontSize: 16.sp),
        ),
        UtilValues.gap4,
        if (le)
          Text(
            LocaleKeys.le.tr(),
            style: TextStyle(
                color: ColorsPalette.customGrey,
                fontWeight: FontWeight.w400,
                fontFamily: ZainTextStyles.font,
                fontSize: 16.sp),
          ),
      ],
    );
  }
  String _getStatus(String? status) {
    switch (status) {
      case OrderStatus.ORDER_CANCELLED:
        return "${LocaleKeys.canceled.tr()}";
      case OrderStatus.ORDER_ON_THE_RUN:
        return "${LocaleKeys.orderBookedSuccessfully.tr()}";
      case OrderStatus.ORDER_DELIVERED:
        return "${LocaleKeys.delivered.tr()}";
      case OrderStatus.ORDER_COMPELETED:
      return "${LocaleKeys.delivered.tr()}";
      case OrderStatus.ORDER_PREPARING:
        return "${LocaleKeys.orderBookedSuccessfully.tr()}";
      case OrderStatus.ORDER_NEW:
      return "${LocaleKeys.orderBookedSuccessfully.tr()}";
      default:
        return "${LocaleKeys.orderBookedSuccessfully.tr()}";
    }
  }
}
