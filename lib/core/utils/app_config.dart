import 'package:flutter/material.dart';
import 'package:ma7lola/view/screens/onboarding_screens/intro_screens.dart';

import '../../view/screens/addresses_book_screen/addresses_preview_screen.dart';
import '../../view/screens/auth/SignUpForm.dart';
import '../../view/screens/auth/YourCarDetails.dart';
import '../../view/screens/languages_screen.dart';
import '../../view/screens/main_screen/tabs/home_tab/batteries/batteries_search_screen.dart';
import '../../view/screens/main_screen/tabs/home_tab/car_parts/categories_screen.dart';
import '../../view/screens/main_screen/tabs/home_tab/emergency/emergency_services_screen.dart';
import '../../view/screens/main_screen/tabs/home_tab/notification_screen.dart';
import '../../view/screens/main_screen/tabs/home_tab/tires/tires_search_screen.dart';
import '../../view/screens/main_screen/tabs/profile_tab/about_app_screen.dart';
import '../../view/screens/main_screen/tabs/profile_tab/edit_profile_screen.dart';
import '../../view/screens/main_screen/tabs/profile_tab/faq_screen.dart';
import '../../view/screens/main_screen/tabs/profile_tab/help_chat_screen.dart';
import '../../view/screens/main_screen/tabs/profile_tab/my_cars_preview_screen.dart';
import '../../view/screens/main_screen/tabs/profile_tab/privacy_screen.dart';
import '../../view/screens/main_screen/tabs/profile_tab/settings_screen.dart';
import '../../view/screens/main_screen/tabs/profile_tab/terms_screen.dart';
import '../../view/screens/main_screen/tabs/profile_tab/update_mail_screen.dart';
import '../../view/screens/main_screen/tabs/profile_tab/update_password_screen.dart';
import '../../view/screens/main_screen/tabs/profile_tab/update_phone_screen.dart';
import '../../view/screens/splash_screen.dart';

class AppConfig {
  static const String appName = 'Recepo';

  static const fallbackLocale = Locale('en');
  static final supportedLocales = [const Locale('en'), const Locale('ar')];

  static Map<String, Widget Function(BuildContext)> routes = {
    SplashScreen.routeName: (_) => const SplashScreen(),
    LanguagesScreen.routeName: (_) => const LanguagesScreen(),
    IntroScreens.routeName: (_) => const IntroScreens(),
    // PostScreen.routeName:(_) => const PostScreen(),
    RegisterScreen.routeName: (_) => RegisterScreen(),
    ChatScreen.routeName: (_) => ChatScreen(),
    EditProfileScreen.routeName: (_) => EditProfileScreen(),
    NotificationsScreen.routeName: (_) => NotificationsScreen(),
    CategoriesScreen.routeName: (_) => CategoriesScreen(),
    // OtpScreen.routeName: (_) => OtpScreen(),
    YourCarDetails.routeName: (_) => YourCarDetails(),
    SettingsScreen.routeName: (_) => SettingsScreen(),
    AddressesPreviewScreen.routeName: (_) => AddressesPreviewScreen(),
    MyCarsPreviewScreen.routeName: (_) => MyCarsPreviewScreen(),
    UpdatePasswordScreen.routeName: (_) => UpdatePasswordScreen(),
    UpdateMailScreen.routeName: (_) => UpdateMailScreen(),
    UpdatePhoneScreen.routeName: (_) => UpdatePhoneScreen(),
    BatteriesSearchScreen.routeName: (_) => BatteriesSearchScreen(),
    TiresSearchScreen.routeName: (_) => TiresSearchScreen(),
    AboutAppScreen.routeName: (_) => AboutAppScreen(),
    PrivacyScreen.routeName: (_) => PrivacyScreen(),
    TermsScreen.routeName: (_) => TermsScreen(),
    FAQScreen.routeName: (_) => FAQScreen(),
    EmergencyServicesScreen.routeName: (_) => EmergencyServicesScreen(),
  };
}
