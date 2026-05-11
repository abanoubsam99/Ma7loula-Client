import 'package:flutter/material.dart';

import '../../../../core/utils/colors_palette.dart';

class IntroScreen extends StatelessWidget {
  final String? title;

  final String? description;

  final String? imageNetwork;

  final TextStyle? textStyle;

  final Color headerBgColor;

  final EdgeInsets headerPadding;

  final Widget? header;

  int? _pageIndex;

  IntroScreen({
    super.key,
    this.title,
    this.headerPadding = const EdgeInsets.all(12),
    this.description,
    this.header,
    this.headerBgColor = ColorsPalette.primaryColor,
    this.textStyle,
    this.imageNetwork,
  });

  set index(val) => this._pageIndex = val;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: screenSize.height,
      //height: screenSize.height * .1,
      padding: headerPadding,
      decoration: BoxDecoration(
        color: ColorsPalette.darkGrey,
        /*gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(0, 0, 0, 0.31),
            Color.fromRGBO(0, 0, 0, 0),
            Color.fromRGBO(0, 0, 0, 0.49),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),*/
        image: DecorationImage(
          image: NetworkImage(imageNetwork!),
          fit: BoxFit.cover,
          /*colorFilter: const ColorFilter.mode(
                ColorsPalette.yellow, BlendMode.overlay)*/
        ),
      ),
    );
  }
}
