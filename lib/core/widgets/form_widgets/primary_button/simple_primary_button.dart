import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/utils/util_values.dart';
import 'package:ma7lola/core/widgets/form_widgets/primary_button/primary_button.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/colors_palette.dart';
import '../../../utils/font.dart';
import '../../loading_widget.dart';

class SimplePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor, loadingWidgetColor;
  final Color? labelColor, iconColor;
  final bool isLoading;
  final BorderRadius? borderRadius;
  final String? icon;
  final double? fontSize;
  final double? width;
  final double? height;

  const SimplePrimaryButton(
      {Key? key,
      this.loadingWidgetColor = ColorsPalette.white,
      required this.label,
      this.onPressed,
      this.backgroundColor = ColorsPalette.primaryColor,
      this.labelColor = ColorsPalette.white,
      this.isLoading = false,
      this.borderRadius,
      this.width,
      this.height,
      this.icon,
      this.iconColor,
      this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: PrimaryButton(
        onPressed: isLoading ? () {} : onPressed,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        labelColor: labelColor,
        child: Center(
          child: isLoading
              ? LoadingWidget(
                  size: 20,
                  color: loadingWidgetColor,
                )
              : icon != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          icon!,
                          width: 12,
                          height: 13,
                          color: iconColor,
                        ),
                        UtilValues.gap4,
                        Text(
                          label,
                          style: TextStyle(
                              color: labelColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              fontFamily: ZainTextStyles.font),
                        ),
                      ],
                    )
                  : Text(
                      label,
                      style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          fontFamily: ZainTextStyles.font),
                    ),
        ),
      ),
    );
  }
}

class SimplePrimaryButtonLang extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor, loadingWidgetColor;
  final Color? labelColor, iconColor;
  final bool isLoading;
  final BorderRadius? borderRadius;
  final String? icon;
  final double? fontSize;
  final double? width;
  final double? height;

  const SimplePrimaryButtonLang(
      {Key? key,
      this.loadingWidgetColor = ColorsPalette.white,
      required this.label,
      this.onPressed,
      this.backgroundColor = ColorsPalette.primaryColor,
      this.labelColor = ColorsPalette.white,
      this.isLoading = false,
      this.borderRadius,
      this.width,
      this.height,
      this.icon,
      this.iconColor,
      this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: PrimaryButton(
        onPressed: isLoading ? () {} : onPressed,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        labelColor: labelColor,
        child: Center(
          child: isLoading
              ? LoadingWidget(
                  size: 20,
                  color: loadingWidgetColor,
                )
              : icon != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          icon!,
                          width: 30,
                          height: 30,
                          color: iconColor,
                        ),
                        UtilValues.gap4,
                        Text(
                          label,
                          style: TextStyle(
                              color: labelColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              fontFamily: ZainTextStyles.font),
                        ),
                      ],
                    )
                  : Text(
                      label,
                      style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          fontFamily: ZainTextStyles.font),
                    ),
        ),
      ),
    );
  }
}
