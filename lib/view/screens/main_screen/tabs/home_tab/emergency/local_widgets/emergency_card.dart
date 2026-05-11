import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../core/utils/colors_palette.dart';
import '../../../../../../../core/utils/font.dart';

class EmergencyServiceCard extends StatefulWidget {
  String image;
  String title;
  double? height;
  final VoidCallback onTap;

  EmergencyServiceCard(
      {Key? key,
      required this.image,
      required this.title,
      this.height,
      required this.onTap})
      : super(key: key);

  @override
  State<EmergencyServiceCard> createState() => _EmergencyServiceCardState();
}

class _EmergencyServiceCardState extends State<EmergencyServiceCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.only(
            left: 4.sp,
            right: 4.sp,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ColorsPalette.lightGrey),
          alignment: Alignment.centerRight,
          // padding: EdgeInsets.only(left: 5.sp, right: 5.sp,),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  widget.title,
                  style: TextStyle(
                      color: ColorsPalette.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 15.sp),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  widget.image ?? '',
                  height: 8.h,
                  fit: BoxFit.scaleDown,
                  // width: double.maxFinite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
