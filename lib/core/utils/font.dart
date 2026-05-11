import 'package:flutter/material.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:sizer/sizer.dart';

class ZainTextStyles {
  static const font = 'Zain-Regular';

  static TextStyle body = TextStyle(
    color: ColorsPalette.white,
    fontFamily: font,
    fontSize: 17.sp,
    letterSpacing: -0.43,
  );
  static TextStyle callout = TextStyle(
    fontFamily: font,
    color: ColorsPalette.white,
    fontSize: 15.sp,
    letterSpacing: -0.31,
  );
  static TextStyle med = TextStyle(
      fontFamily: font,
      fontSize: 14.sp,
      letterSpacing: -0.20,
      color: ColorsPalette.lightGrey);
  static TextStyle caption = TextStyle(
    fontSize: 7.sp,
    color: ColorsPalette.darkGrey,
  );
}
