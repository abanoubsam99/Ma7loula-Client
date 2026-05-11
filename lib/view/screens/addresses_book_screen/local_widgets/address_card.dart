import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/utils/assets_manager.dart';
import '../../../../core/utils/colors_palette.dart';
import '../../../../core/utils/util_values.dart';

class AddressCard extends StatelessWidget {
  final String name;
  final String city;
  final String? details;
  final bool selected;
  final bool? fromCheckout;

  const AddressCard({
    super.key,
    required this.name,
    required this.city,
    this.details,
    required this.selected,
    this.fromCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                    color: ColorsPalette.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: ZainTextStyles.font),
              ),
              UtilValues.gap4,
              Text(
                city,
                style: TextStyle(
                    color: ColorsPalette.customGrey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: ZainTextStyles.font),
              ),
              UtilValues.gap4,
              if (details != null)
                Text(
                  details ?? '',
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: ColorsPalette.customGrey,
                      fontWeight: FontWeight.w500,
                      fontFamily: ZainTextStyles.font),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (selected)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: ColorsPalette.default1),
            child: Text(
              LocaleKeys.defualt.tr(),
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: ColorsPalette.black,
                  fontFamily: ZainTextStyles.font),
              textAlign: TextAlign.center,
              //maxLines: 3,
            ),
          ),
        if (fromCheckout != null)
          SvgPicture.asset(
            AssetsManager.angleRight,
            color: ColorsPalette.customGrey,
          )
      ],
    );
  }
}
