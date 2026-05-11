import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola/core/widgets/app_logo.dart';
import 'package:ma7lola/view/screens/languages_screen.dart';
import 'package:ma7lola/view/screens/main_screen/main_screen.dart';
import 'package:provider/provider.dart';

import '../../controller/user_provider.dart';
import '../../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../../core/services/secure_storage/secure_storage_service.dart';
import '../../core/utils/assets_manager.dart';
import '../../core/utils/colors_palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _splashOperation(context),
        builder: (context, snapshot) {
          return Container(
            //color: ColorsPalette.white,
            decoration: const BoxDecoration(
              // color: ColorsPalette.primaryColor,
              image: DecorationImage(
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                    ColorsPalette.primaryColor, BlendMode.overlay),
                image: AssetImage(AssetsManager.splash),
              ),
            ),
            alignment: Alignment.center,
            child: AppLogo(
              size: 400,
            ),
          );
        });
  }

  Future<void> _splashOperation(BuildContext context) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      final storedToken = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);

      if (![storedToken].contains(null)) {
        final userProvider = context.read<UserProvider>();

        await userProvider.autoLogin(locale: context.locale, context: context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    index: 0,
                  )),
        );
      } else {
        Navigator.of(context).pushReplacementNamed(LanguagesScreen.routeName);
      }
    } catch (_) {}
  }
}
