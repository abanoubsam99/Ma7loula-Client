import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:ma7lola/view/screens/main_screen/main_screen.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/notification_screen.dart';

import '../../../../../core/utils/assets_manager.dart';
import '../../../../../core/utils/util_values.dart';
import 'local_widgets/profile_tab_item.dart';

class SettingsScreen extends StatelessWidget {
  static String routeName = '/settings';
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ColorsPalette.lightGrey,
        appBar: AppBarApp(
          title: LocaleKeys.drawerSettings.tr(),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UtilValues.gap8,
              ProfileTabItem(
                icon: AssetsManager.notification,
                label: LocaleKeys.notification.tr(),
                onTap: () => Navigator.of(context)
                    .pushNamed(NotificationsScreen.routeName),
              ),
              UtilValues.gap8,
              ProfileTabItem(
                icon: AssetsManager.earth,
                label: LocaleKeys.lang.tr(),
                onTap: () async {
                  if (Helpers.isEnglish(context)) {
                    context.setLocale(const Locale('ar'));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainScreen(
                                index: 3,
                              )),
                    );
                  } else {
                    context.setLocale(const Locale('en'));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainScreen(
                                index: 3,
                              )),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
