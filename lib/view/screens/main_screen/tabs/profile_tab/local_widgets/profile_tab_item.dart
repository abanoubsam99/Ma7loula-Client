import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_card.dart';

class ProfileTabItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color iconColor;

  const ProfileTabItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = ColorsPalette.white,
    this.foregroundColor = ColorsPalette.extraDarkGrey,
    this.iconColor = ColorsPalette.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      color: backgroundColor,
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            color: ColorsPalette.black,
            width: 20,
            height: 20,
          ),
          UtilValues.gap12,
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  color: ColorsPalette.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: ZainTextStyles.font),
            ),
          ),
          /*UtilValues.gap12,
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: foregroundColor,
          )*/
        ],
      ),
    );
  }
}
