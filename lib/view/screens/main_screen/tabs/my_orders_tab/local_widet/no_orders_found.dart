import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/core/utils/util_values.dart';
import 'package:sizer/sizer.dart';

class NoOrdersFound extends StatelessWidget {
  const NoOrdersFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50.w,
            child: const ClipRRect(
              child: Image(
                image: AssetImage('assets/images/no_orders.png'),
              ),
            ),
          ),
          UtilValues.gap8,
          Text(
            LocaleKeys.noProductsFound.tr(),
            style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontFamily: ZainTextStyles.font),
          ),
          Text(
            LocaleKeys.noProductsFound.tr(),
            style: TextStyle(
                fontSize: 14.sp,
                color: ColorsPalette.customGrey,
                fontWeight: FontWeight.w500,
                fontFamily: ZainTextStyles.font),
          ),
          SizedBox(
            height: 3.h,
          ),
        ],
      ),
    );
  }
}
