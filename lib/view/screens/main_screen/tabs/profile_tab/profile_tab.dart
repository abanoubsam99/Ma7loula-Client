import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/controller/user_provider.dart';
import 'package:ma7lola/core/widgets/custom_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ma7lola/view/screens/auth/LoginScreen.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/profile_tab/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/dialogs/confirmation_dialog.dart';
import '../../../../../core/dialogs/delete_account_dialog.dart';
import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/utils/assets_manager.dart';
import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../../../addresses_book_screen/addresses_preview_screen.dart';
import '../../../auth/SignUpForm.dart';
import '../../main_screen.dart';
import 'about_app_screen.dart';
import 'faq_screen.dart';
import 'help_chat_screen.dart';
import 'local_widgets/profile_card.dart';
import 'local_widgets/profile_tab_item.dart';
import 'my_cars_preview_screen.dart';
import 'privacy_screen.dart';
import 'terms_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.lightGrey,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!userProvider.isLoggedIn) ...[
                  Container(
                    alignment: Alignment.center,
                    height: 25.h,
                    color: ColorsPalette.white,
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.only(
                          top: 50.0, left: 80, right: 80, bottom: 8),
                      child: Image.asset(
                        AssetsManager.appBlackLogo,
                      ),
                    )),
                  ),
                  UtilValues.gap8,
                  _authButtons(context),
                ],
                if (userProvider.isLoggedIn) ...[
                  Container(
                    color: ColorsPalette.white,
                    padding: const EdgeInsets.only(top: 30.0),
                    child: ProfileCard(
                      name: userProvider.user?.data?.user?.name ??
                          LocaleKeys.userName.tr(),
                      email: '+2${userProvider.user?.data?.user?.phone}',
                      onTap: () {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        UtilValues.gap8,
                        ProfileTabItem(
                          icon: AssetsManager.user,
                          label: LocaleKeys.profile.tr(),
                          onTap: () => Navigator.of(context)
                              .pushNamed(EditProfileScreen.routeName),
                        ),
                        UtilValues.gap8,
                        ProfileTabItem(
                          icon: AssetsManager.taxi,
                          label: LocaleKeys.car.tr(),
                          onTap: () => Navigator.of(context)
                              .pushNamed(MyCarsPreviewScreen.routeName),
                        ),
                        UtilValues.gap8,
                        ProfileTabItem(
                          icon: AssetsManager.location,
                          label: LocaleKeys.addressBook.tr(),
                          onTap: () => Navigator.of(context)
                              .pushNamed(AddressesPreviewScreen.routeName),
                        ),
                        UtilValues.gap8,
                        ProfileTabItem(
                          icon: AssetsManager.fileList1,
                          label: LocaleKeys.myOrders.tr(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainScreen(
                                        index: 2,
                                        myOrdersIndex: 0,
                                      )),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                UtilValues.gap8,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      ProfileTabItem(
                        icon: AssetsManager.chatInfo,
                        label: LocaleKeys.aboutApp.tr(),
                        onTap: () {
                          Navigator.pushNamed(
                              context, AboutAppScreen.routeName);
                        },
                      ),
                      UtilValues.gap8,
                      ProfileTabItem(
                        icon: AssetsManager.question,
                        label: LocaleKeys.popularQuestions.tr(),
                        onTap: () {
                          Navigator.pushNamed(context, FAQScreen.routeName);
                        },
                      ),
                      UtilValues.gap8,
                      ProfileTabItem(
                        icon: AssetsManager.shieldUser,
                        label: LocaleKeys.privacy.tr(),
                        onTap: () {
                          Navigator.pushNamed(context, PrivacyScreen.routeName);
                        },
                      ),
                      UtilValues.gap8,
                      ProfileTabItem(
                        icon: AssetsManager.list,
                        label: LocaleKeys.terms.tr(),
                        onTap: () {
                          Navigator.pushNamed(context, TermsScreen.routeName);
                        },
                      ),
                      UtilValues.gap8,
                      ProfileTabItem(
                        icon: AssetsManager.text,
                        label: LocaleKeys.help.tr(),
                        onTap: () => Navigator.of(context)
                            .pushNamed(ChatScreen.routeName),
                      ),
                      if (userProvider.isLoggedIn) ...[
                        UtilValues.gap8,
                        ProfileTabItem(
                          icon: AssetsManager.logout,
                          label: LocaleKeys.drawerLogout.tr(),
                          onTap: () => _logout(context),
                        ),
                      ],
                    ],
                  ),
                ),
                UtilValues.gap8,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomCard(
                      color: ColorsPalette.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () => _launchURL('https://www.instagram.com/ma7loulaapp'),
                            child: _svgPic(AssetsManager.instagram),
                          ),
                          GestureDetector(
                            onTap: () => _launchURL('https://api.whatsapp.com/send/?phone=201114051954&text&type=phone_number&app_absent=0&wame_ctl=1'),
                            child: _svgPic(AssetsManager.whatsapp),
                          ),
                          GestureDetector(
                            onTap: () => _launchURL('https://www.facebook.com/61573058409772'),
                            child: _svgPic(AssetsManager.facebook),
                          ),
                        ],
                      )),
                ),
                if (!userProvider.isLoggedIn) ...[
                  UtilValues.gap8,
                  Text(
                    LocaleKeys.shouldLogin.tr(),
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: ZainTextStyles.font),
                    textAlign: TextAlign.center,
                  ),
                ],
                UtilValues.gap64
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: LocaleKeys.deleteAccount.tr(),
      message: LocaleKeys.deleteAccountConfirmationDialogBody.tr(),
    );

    if (!confirmed) return;

    DeleteAccountDialog.show(context: context);
  }

  _authButtons(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          margin: EdgeInsets.all(1.sp),
          height: 6.h,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return LoginScreen(
                  products: [],
                  batteries: [],
                  tires: [],
                  carID: 0,
                  fromCart: false,
                  fromCartBatteries: false,
                  fromCartTires: false,
                  car: null,
                );
              }));
            },
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all<TextStyle>(
                TextStyle(
                  fontSize: 14.sp,
                ),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: ColorsPalette.primaryColor),
                ),
              ),
              backgroundColor:
                  MaterialStateProperty.all<Color>(ColorsPalette.primaryColor),
            ),
            child: Center(
              child: false
                  ? const LoadingWidget()
                  : Text(
                      LocaleKeys.login.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorsPalette.white,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 14.sp),
                    ),
            ),
          ),
        ),
        UtilValues.gap8,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          margin: EdgeInsets.all(1.sp),
          height: 6.h,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, RegisterScreen.routeName);
            },
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all<TextStyle>(
                TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: ColorsPalette.black),
                ),
              ),
              backgroundColor:
                  MaterialStateProperty.all<Color>(ColorsPalette.lightGrey),
            ),
            child: Center(
              child: false
                  ? const LoadingWidget()
                  : Text(
                      LocaleKeys.signUp.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorsPalette.black,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 14.sp),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  _svgPic(String icon) {
    return SizedBox(
      width: 20,
      height: 20,
      child: SvgPicture.asset(
        icon,
        color: ColorsPalette.black,
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _logout(BuildContext context) async {
    try {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: LocaleKeys.drawerLogout.tr(),
        message: LocaleKeys.logoutConfirmation.tr(),
      );

      if (!confirmed) return;

      // setState(() => _isLoading = true);
      final userProvider = context.read<UserProvider>();
      // final fcmToken = await FirebaseMessaging.instance.getToken();

      await userProvider.logout(/*userProvider.user!.email, fcmToken*/);

      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return LoginScreen(
          products: [],
          batteries: [],
          tires: [],
          carID: 0,
          fromCart: false,
          fromCartBatteries: false,
          fromCartTires: false,
          car: null,
        );
      }));
    } catch (error) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: error.toString(),
      );
    } finally {
      // setState(() => _isLoading = false);
    }
  }
}
