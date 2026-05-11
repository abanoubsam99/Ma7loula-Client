import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/utils/font.dart';

import '../../../../../../../core/utils/colors_palette.dart';
import '../../../../../../../core/utils/util_values.dart';

class ScheduleCard extends StatelessWidget {
  final String name;
  final int? value;
  final Function(int?)? onChanged;
  final int? selectedValue;
  String? icon;
  String? icon2;
  Widget? widget;
  Widget? widget2;

  ScheduleCard(
      {super.key,
      required this.name,
      this.value,
      this.onChanged,
      this.selectedValue,
      this.icon,
      this.widget,
      this.widget2,
      this.icon2});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
              color: ColorsPalette.white,
              borderRadius: UtilValues.borderRadius10,
              border: Border.all(color: ColorsPalette.grey)),
          child: Column(
            children: [
              Row(
                children: [
                  Radio(
                      value: value!,
                      groupValue: selectedValue,
                      onChanged: onChanged!,
                      activeColor: ColorsPalette.primaryColor),
                  Text(
                    name,
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontSize: icon == null ? 13 : 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: ZainTextStyles.font),
                  ),
                  Spacer(),
                  icon2 == null
                      ? Container()
                      : SvgPicture.asset(
                          icon2!,
                          height: 14,
                          width: 14,
                          fit: BoxFit.fill,
                        ),
                  UtilValues.gap4,
                  icon == null
                      ? Container()
                      : SvgPicture.asset(
                          icon!,
                          height: 14,
                          width: 14,
                          fit: BoxFit.fill,
                        ),
                  widget == null ? Container() : widget!,
                  UtilValues.gap8
                ],
              ),
              widget2 == null ? Container() : widget2!,
            ],
          ),
        );
      },
    );
  }
}
