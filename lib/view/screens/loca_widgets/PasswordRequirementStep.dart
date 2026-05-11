import 'package:flutter/material.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/core/utils/util_values.dart';
import 'package:sizer/sizer.dart';

class PasswordRequirementStep extends StatelessWidget {
  final String text;

  PasswordRequirementStep(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.circle,
            color: ColorsPalette.passwordRequirementGrey,
            size: 5,
          ),
          UtilValues.gap8,
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: ZainTextStyles.font,
                  color: ColorsPalette.passwordRequirementGrey),
            ),
          ),
        ],
      ),
    );
  }
}
