import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:sizer/sizer.dart';

class NoProductsFound extends StatelessWidget {
  const NoProductsFound({super.key});

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
                image: AssetImage('assets/images/empty_cart.png'),
              ),
            ),
          ),
          Text(
            LocaleKeys.noProductsFound.tr(),
            style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
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
