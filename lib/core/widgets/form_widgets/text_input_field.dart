import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:sizer/sizer.dart';

import '../../utils/colors_palette.dart';
import '../../utils/util_values.dart';

class TextInputField extends StatelessWidget {
  final String name;
  final String hint;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool obscured;
  final TextInputType inputType;
  final int? maxLength;
  final BorderRadius? borderRadius;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final EdgeInsets? padding;
  final int maxLines;
  final Function(String?)? onChanged;
  final String? initialValue;
  final Color? backgroundColor, color;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final bool enabled;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String?)? onSave;
  final InputBorder? enabledBorder, focusedBorder, errorBorder;
  final prefixIcon, suffixIcon;

  const TextInputField({
    Key? key,
    required this.name,
    required this.hint,
    this.validator,
    this.obscured = false,
    this.inputType = TextInputType.text,
    this.maxLength,
    this.borderRadius,
    this.floatingLabelBehavior,
    this.padding = const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
    this.maxLines = 1,
    this.onChanged,
    this.initialValue,
    this.focusNode,
    this.controller,
    this.onSave,
    this.enabled = true,
    this.readOnly = false,
    this.color,
    this.inputFormatters,
    this.backgroundColor,
    this.enabledBorder,
    this.focusedBorder,
    this.prefixIcon,
    this.suffixIcon,
    this.errorBorder,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSaved: onSave,
      enabled: enabled,
      focusNode: focusNode,
      name: name,
      initialValue: initialValue,
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscured,
      maxLength: maxLength,
      keyboardType: inputType,
      maxLines: maxLines,
      style: TextStyle(
          color: ColorsPalette.primaryColor,
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
          fontFamily: ZainTextStyles.font),
      cursorColor: ColorsPalette.primaryColor,
      //textAlign: TextAlign.left,
//      textDirection: TextDirection.ltr,

      readOnly: readOnly,
      onTap: onTap,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: '',
        contentPadding: padding,
        isDense: true,
        border: _border,
        filled: true,
        fillColor: backgroundColor,
        hintText: hint,
        focusedBorder: focusedBorder,
        enabledBorder: enabledBorder,
        errorBorder: errorBorder,
        hintStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            fontFamily: ZainTextStyles.font),
      ),
    );
  }

  OutlineInputBorder get _border => OutlineInputBorder(
        borderSide: BorderSide(color: ColorsPalette.extraDarkGrey),
        borderRadius: borderRadius ?? BorderRadius.circular(10),
      );
}

class TextInputFieldPaste extends StatelessWidget {
  final String name;
  final String hint;
  final String? Function(String?)? validator;
  final bool obscured;
  final TextInputType inputType;
  final int? maxLength;
  final BorderRadius? borderRadius;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final EdgeInsets? padding;
  final int maxLines;
  final Function(String?)? onChanged;
  final String? initialValue;
  final Color? backgroundColor, color;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final bool enabled;
  final Icon? prefixIcon, suffixIcon;
  final void Function(String?)? onSave;

  const TextInputFieldPaste(
      {Key? key,
      required this.name,
      required this.hint,
      this.validator,
      this.obscured = false,
      this.inputType = TextInputType.text,
      this.maxLength,
      this.borderRadius,
      this.floatingLabelBehavior,
      this.padding,
      this.maxLines = 1,
      this.onChanged,
      this.initialValue,
      this.backgroundColor = ColorsPalette.lightGrey,
      this.focusNode,
      this.controller,
      this.onSave,
      this.enabled = true,
      this.color,
      this.prefixIcon,
      this.suffixIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSave,
      enabled: enabled,
      focusNode: focusNode,
      //name: name,
      initialValue: initialValue,
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscured,
      maxLength: maxLength,
      keyboardType: inputType,
      maxLines: maxLines,
      style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
          fontFamily: ZainTextStyles.font),
      cursorColor: ColorsPalette.primaryColor,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: '',
        contentPadding: padding,
        isDense: true,
        border: _border,
        filled: true,
        fillColor: backgroundColor,
        hintText: hint,
        hintStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            fontFamily: ZainTextStyles.font),
      ),
    );
  }

  OutlineInputBorder get _border => OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: borderRadius ?? UtilValues.borderRadius10,
      );
}
