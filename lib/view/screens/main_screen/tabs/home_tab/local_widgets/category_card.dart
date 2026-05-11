import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/util_values.dart';

class CategoriesCard extends StatelessWidget {
  final String title;
  final String pic;
  final VoidCallback onTap;

  const CategoriesCard({
    Key? key,
    required this.title,
    required this.pic,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int l = title.split(' ').length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 23.sp, vertical: 20),
        decoration: BoxDecoration(
          color: ColorsPalette.veryDarkGrey2,
          borderRadius: UtilValues.borderRadius10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(pic),
            Text(
              title,
              style: TextStyle(
                  color: ColorsPalette.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: ZainTextStyles.font),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
