import 'package:flutter/material.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/core/utils/util_values.dart';

class TernaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool dense;
  final bool underLine;
  final EdgeInsets? padding;
  final double? fontSize;

  const TernaryButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.color = ColorsPalette.primaryColor,
    this.dense = false,
    this.underLine = false,
    this.fontSize = 12,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: padding,
        textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            fontFamily: ZainTextStyles.font),
        elevation: 0,
        foregroundColor: color,
        visualDensity: dense ? VisualDensity.compact : null,
        tapTargetSize: dense ? MaterialTapTargetSize.shrinkWrap : null,
        shape: RoundedRectangleBorder(borderRadius: UtilValues.borderRadius10),
      ),
      child: Text(
        label,
        style: underLine
            ? const TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: ColorsPalette.primaryColor,
                height: 2,
              )
            : null,
      ),
    );
  }
}
