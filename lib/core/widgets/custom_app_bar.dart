import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/utils/util_values.dart';
import 'package:sizer/sizer.dart';

import '../utils/font.dart';
import 'contained_icon_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final backButton;

  const CustomAppBar(
      {Key? key, this.title, this.actions, this.bottom, this.backButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: ColorsPalette.white,
      iconTheme: const IconThemeData(color: ColorsPalette.black),
      leadingWidth: 25.w,
      leading: Image.asset(
        AssetsManager.appBlackLogo,
        width: 25.w,
      ),
      actions: [
        if (actions != null)
          ...actions!
        else
          Container(
            width: 18.w,
          )
      ],
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(56 + (bottom?.preferredSize.height ?? 0.0));
}

class AppBarApp extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? backButton;

  const AppBarApp(
      {Key? key, this.title, this.actions, this.bottom, this.backButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: ColorsPalette.white,
      iconTheme: const IconThemeData(color: ColorsPalette.black),
      leading: backButton == null
          ? InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Helpers.isArabic(context)
                    ? SvgPicture.asset(
                        AssetsManager.angleLeft,
                        fit: BoxFit.scaleDown,
                        width: 16.sp,
                      )
                    : Transform(
                        transform: Matrix4.rotationY(180 * 3.1415927 / 180),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          AssetsManager.angleLeft,
                          fit: BoxFit.scaleDown,
                          width: 16.sp,
                        )),
              ))
          : backButton,
      title: Text(
        title ?? '',
        style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: ColorsPalette.black,
            fontFamily: ZainTextStyles.font),
        textAlign: TextAlign.center,
        //maxLines: 3,
      ),
      actions: [
        if (actions != null)
          ...actions!
        else
          Container(
            width: 18.w,
          )
      ],
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(56 + (bottom?.preferredSize.height ?? 0.0));
}

class CustomAppBarWithSearch extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final BackButton? backButton;
  final TextEditingController? searchController;
  final void Function(String?) onSearchFieldChanged;

  const CustomAppBarWithSearch(
      {Key? key,
      this.title,
      this.actions,
      this.bottom,
      this.backButton,
      this.searchController,
      required this.onSearchFieldChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: UtilValues.padding12,
        child: ContainedIconButton(
          backgroundColor: ColorsPalette.customGrey,
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: ColorsPalette.lightGrey,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      elevation: 0,
      backgroundColor: ColorsPalette.black,
      iconTheme: const IconThemeData(color: ColorsPalette.black),
      centerTitle: true,
      /*title: SizedBox(
        height: 10.h,
        width: 50.w,
        child: TextInputField(
          controller: searchController,
//          backgroundColor: ColorsPalette.white,
          name: 'search',
          hint: LocaleKeys.search.tr(),
          borderRadius: UtilValues.borderRadius10,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          padding: const EdgeInsets.all(10.5),
          //onSave: widget.onSearchFieldChanged,
          onChanged: onSearchFieldChanged,
        ),
      ),*/
      actions: [
        if (actions != null)
          ...actions!
        else
          Container(
            width: 18.w,
          )
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(56 + (bottom?.preferredSize.height ?? 0.0));
}
