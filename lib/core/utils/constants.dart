import 'package:flutter/material.dart';

import 'colors_palette.dart';

class Constants {
  static initProgressDialog(
      {required bool isShowing, required BuildContext context}) {
    if (isShowing) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorsPalette.lightpre),
              ),
            ),
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }
}
