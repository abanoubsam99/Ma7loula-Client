import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../generated/locale_keys.g.dart';

/// Password validator to enforce strong password requirements
class AppPasswordValidator {
  /// Validates password with the following requirements:
  /// - At least 8 characters
  /// - At least one uppercase letter
  /// - At least one special character
  static String? validate(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.fieldRequired.tr();
    }
    
    if (value.length < 8) {
      return LocaleKeys.passwordLengthError.tr();
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return LocaleKeys.passwordUppercaseError.tr();
    }
    
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return LocaleKeys.passwordSpecialCharError.tr();
    }
    
    return null;
  }
}
