import 'package:flutter/material.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';

import '../utils/assets_manager.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    Key? key,
    this.size = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AssetsManager.appLogo,
        height: size,
        width: size,
        color: ColorsPalette.white,
      ),
    );
  }
}
