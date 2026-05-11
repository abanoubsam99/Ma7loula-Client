import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'controller/car_provider.dart';
import 'controller/get_offers_provider.dart';
import 'controller/products_provider.dart';
import 'controller/start_up_slides_provider.dart';
import 'controller/user_provider.dart';
import 'core/generated/locale_keys.g.dart';
import 'core/utils/app_config.dart';
import 'core/utils/assets_manager.dart';
import 'core/utils/colors_palette.dart';
import 'core/utils/notifyHelper.dart';
import 'core/widgets/responsive_helper.dart';
import 'firebase_options.dart';
/// Client:
/// 01155093466
/// 12345677A^
///  Client:
/// 01227120519
/// Aa@123456
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // NotificationsHelper().initialize();
  EasyLocalization.logger.enableBuildModes = [];
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, name: 'Mahloula');

  runApp(
    EasyLocalization(
      path: AssetsManager.translationsFolder,
      supportedLocales: AppConfig.supportedLocales,
      fallbackLocale: AppConfig.fallbackLocale,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
        ResponsiveHelper.init(context);

    return Sizer(builder: ((context, constraints, deviceType) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => StartUpSlidesProvider()),
          ChangeNotifierProvider(create: (context) => ProductsProvider()),
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => CarProvider()),
          ChangeNotifierProvider(create: (context) => GetWinchOffersProvider()),
        ],
        child: MaterialApp(
          navigatorKey: NotificationsHelper.navigatorKey,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return SafeArea(
              top: false,   // don't add padding from status bar
              bottom: true, // always keep padding from bottom (home indicator / notch)
              child: child!,
            );
          },
          localizationsDelegates: [
            ...context.localizationDelegates,
            FormBuilderLocalizations.delegate,
          ],
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          onGenerateTitle: (context) => LocaleKeys.appName.tr(),
          theme: ThemeData(
            canvasColor: ColorsPalette.white,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: ColorsPalette.primarySwatch,
            )
                .copyWith(
                  secondary: ColorsPalette.accentColor,
                )
                .copyWith(background: ColorsPalette.white),
          ),
          routes: AppConfig.routes,
        ),
      );
    }));
  }
}
