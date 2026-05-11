import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/font.dart';

import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_card.dart';
import '../settings_screen.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback? onTap;

  const ProfileCard({
    Key? key,
    required this.name,
    required this.email,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      color: ColorsPalette.white,
      child: Row(
        children: [
          // const Icon(
          //   Icons.person_rounded,
          //   color: ColorsPalette.primaryColor,
          //   size: 80,
          // ),
          SvgPicture.asset(AssetsManager.userPic),
          UtilValues.gap8,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      color: ColorsPalette.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: ZainTextStyles.font),
                ),
                Text(
                  email,
                  style: const TextStyle(
                      color: ColorsPalette.customGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: ZainTextStyles.font),
                ),
              ],
            ),
          ),
          InkWell(
              onTap: () {
                Navigator.pushNamed(context, SettingsScreen.routeName);
              },
              child: SvgPicture.asset(AssetsManager.settings)),
        ],
      ),
    );
  }
}
