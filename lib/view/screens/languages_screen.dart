import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ma7lola/core/utils/util_values.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../controller/user_provider.dart';
import '../../core/generated/locale_keys.g.dart';
import '../../core/utils/assets_manager.dart';
import '../../core/utils/colors_palette.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/font.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import 'onboarding_screens/intro_screens.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({Key? key}) : super(key: key);
  static const String routeName = '/chooseLang';

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //color: ColorsPalette.white,
        decoration: const BoxDecoration(
          color: ColorsPalette.primaryColor,
          image: DecorationImage(
            fit: BoxFit.fill,
            /*colorFilter: ColorFilter.mode(
                ColorsPalette.primaryColor, BlendMode.overlay),*/
            image: AssetImage(AssetsManager.splash),
          ),
        ),
        alignment: Alignment.center,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              UtilValues.gap64,
              UtilValues.gap32,
              const AppLogo(
                size: 400,
              ),
              const Spacer(),
              Text(
                LocaleKeys.chooseLang.tr(),
                style: TextStyle(
                    fontFamily: ZainTextStyles.font,
                    color: ColorsPalette.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 24.sp),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SimplePrimaryButtonLang(
                    height: 90,
                    width: 150,
                    backgroundColor: ColorsPalette.white,
                    label: LocaleKeys.arabic.tr(),
                    labelColor: ColorsPalette.black,
                    icon: AssetsManager.arabic,
                    // fontFamily: ZainTextStyles.font,
                    onPressed: () async {
                      try {
                        Constants.initProgressDialog(
                            isShowing: true, context: context);

                        setState(() {
                          context.setLocale(const Locale('ar'));
                        });
                        final userProvider = context.read<UserProvider>();

                        // await userProvider.login();
                        /// //Navigator.pushReplacementNamed(context, IntroScreens.routeName);
                        // await userProvider.setLang(1);
                        Constants.initProgressDialog(
                            context: context, isShowing: false);
                        Navigator.pushReplacementNamed(
                            context, IntroScreens.routeName);
                      } catch (e) {
                        Constants.initProgressDialog(
                            isShowing: false, context: context);
                        Fluttertoast.showToast(
                            msg: e.toString(),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: ColorsPalette.lightpre,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    },
                  ),
                  SimplePrimaryButtonLang(
                    height: 90,
                    width: 150,
                    backgroundColor: ColorsPalette.white,
                    label: LocaleKeys.english.tr(),
                    labelColor: ColorsPalette.black,
                    icon: AssetsManager.english,
                    onPressed: () async {
                      try {
                        Constants.initProgressDialog(
                            isShowing: true, context: context);

                        setState(() {
                          context.setLocale(const Locale('en'));
                        });
                        final userProvider = context.read<UserProvider>();

                        // await userProvider.login();
                        /// //Navigator.pushReplacementNamed(context, IntroScreens.routeName);
                        // await userProvider.setLang(1);
                        Constants.initProgressDialog(
                            context: context, isShowing: false);
                        Navigator.pushReplacementNamed(
                            context, IntroScreens.routeName);
                      } catch (e) {
                        Constants.initProgressDialog(
                            isShowing: false, context: context);
                        Fluttertoast.showToast(
                            msg: e.toString(),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: ColorsPalette.lightpre,
                            textColor: ColorsPalette.white,
                            fontSize: 16.0);
                      }
                    },
                  ),
                ],
              ),
              UtilValues.gap32
            ],
          ),
        ),
      ),
    );
  }
}
