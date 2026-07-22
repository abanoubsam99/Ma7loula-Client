import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

enum SnackbarStatus { success, error, info }

/// Patterns that indicate a raw technical exception (Dio/Http/runtime) which
/// must never be shown to the user. If matched, the message is replaced by a
/// clean, localized generic error message.
final RegExp _technicalErrorPattern = RegExp(
  r'DioException|DioError|HttpException|SocketException|TimeoutException|'
  r'FormatException|Connection|status code|uri\s*=|Null check|'
  r"type '|Exception:|Error:|Stacktrace|http",
  caseSensitive: false,
);

/// Returns a user-safe message. Raw Dio/Http/runtime exceptions are swallowed
/// and replaced with the localized generic error message.
String _sanitizeMessage(String message) {
  if (message.trim().isEmpty || _technicalErrorPattern.hasMatch(message)) {
    return LocaleKeys.genericErrorMessage.tr();
  }
  return message;
}

void showSnackbar(
    {required BuildContext context,
    required SnackbarStatus status,
    required String message}) {
  // Never surface raw exceptions on error snackbars.
  if (status == SnackbarStatus.error) {
    message = _sanitizeMessage(message);
  }
  switch (status) {
    case SnackbarStatus.success:
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: message,
          maxLines: 3,
          backgroundColor: ColorsPalette.green,
          boxShadow: const [],
        ),
      );
      break;
    case SnackbarStatus.error:
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: message,
          maxLines: 3,
          boxShadow: const [],
        ),
      );
      break;
    case SnackbarStatus.info:
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: message,
          maxLines: 1,
          backgroundColor: Colors.purple,
          boxShadow: const [],
        ),
      );
      break;
  }
}

enum ToastStates { SUCCESS, ERROR, WARNING }

void showToast({
  required String text,
  required ToastStates state,
}) =>
    Fluttertoast.showToast(
      msg: state == ToastStates.ERROR ? _sanitizeMessage(text) : text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 5,
      backgroundColor: chooseToastColor(state),
      textColor: Colors.white,
      fontSize: 14.0,
    );

Color chooseToastColor(ToastStates state) {
  Color color;

  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }

  return color;
}
