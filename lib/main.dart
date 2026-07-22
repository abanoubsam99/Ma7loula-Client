import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // التطبيق ياخد الشاشة كلها (edge-to-edge) على Android و iOS — من غير شريط أبيض
  // تحت ولا لون مصمت ورا الـ status bar. لو خلفية الشاشة غامقة غيّر الـ Brightness.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // Android:
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark, // light لو الخلفية غامقة
    statusBarIconBrightness: Brightness.dark,
    // iOS:
    statusBarBrightness: Brightness.light, // light = نص داكن للستاتس بار في iOS
  ));

  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, name: 'Mahloula');
  await NotificationsHelper().initialize();

  runApp(
    EasyLocalization(
      path: AssetsManager.translationsFolder,
      supportedLocales: AppConfig.supportedLocales,
      fallbackLocale: AppConfig.fallbackLocale,
      child: MyApp(),
    ),
  );

  // بعد أول إطار يكون الـ Navigator جاهز — نفتح صفحة تفاصيل الطلب لو التطبيق
  // اتفتح من الضغط على إشعار وهو مقفول (terminated).
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationsHelper().handleLaunchNotification();
  });
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
            // التطبيق ياخد الشاشة كلها — شيلنا الـ SafeArea اللي كان بيعمل
            // شريط أبيض تحت. سيبنا خلفية بيضا تمنع أي ومضة سوداء وقت الانتقالات.
            // الشاشات اللي محتاجة تبعد عن الـ home indicator/الإيماءات بتلف
            // المحتوى السفلي بتاعها في SafeArea بنفسها.
            return Container(
              color: ColorsPalette.white,
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
