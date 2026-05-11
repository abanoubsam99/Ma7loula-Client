import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola/controller/user_provider.dart';
import 'package:ma7lola/view/screens/auth/LoginScreen.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../../core/utils/colors_palette.dart';
import '../../../../../../../core/utils/util_values.dart';
import '../../../../../../../core/widgets/app_logo.dart';
import '../../../../../../../core/widgets/language_switcher.dart';
import 'local_widgets/custom_drawer_item.dart';
import 'local_widgets/drawer_logout_button.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context
        .locale; // NOTE: This one is added to solve the bug of not translation after changing the local

    return Drawer(
      elevation: 0,
      backgroundColor: ColorsPalette.white,
      child: SingleChildScrollView(
        physics: UtilValues.scrollPhysics,
        child: Column(
          children: [
            UtilValues.gap32,
            const AppLogo(size: 150),
            UtilValues.gap32,
            Consumer<UserProvider>(builder: (context, userProvider, child) {
              return Text(
                /*userProvider.isLoggedIn
                    ? userProvider.user!.name!
                    : */
                LocaleKeys.guestUser.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ColorsPalette.primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
              );
            }),
            const SizedBox(
              height: 40,
            ),
            CustomDrawerItem(
              icon: Icons.location_on_rounded,
              title: LocaleKeys.drawerAddressBook.tr(),
              onPressed:
                  () {} /*=> Navigator.of(context)
                  .pushNamed(AddressesBookScreen.routeName)*/
              ,
            ),
            // CustomDrawerItem(
            //   icon: Icons.account_balance_wallet_rounded,
            //   title: LocaleKeys.drawerWallet.tr(),
            //   onPressed: () => Navigator.of(context).pushNamed(WalletScreen.routeName),
            // ),

            CustomDrawerItem(
              icon: Icons.notifications_rounded,
              title: LocaleKeys.drawerNotify.tr(),
              onPressed:
                  () {} /*=> Navigator.of(context)
                  .pushNamed(NotificationsScreen.routeName)*/
              ,
            ),

            CustomDrawerItem(
              icon: Icons.info_rounded,
              title: LocaleKeys.drawerAbout.tr(),
              onPressed:
                  () {} /*=>
                  Navigator.of(context).pushNamed(AboutScreen.routeName)*/
              ,
            ),

            CustomDrawerItem(
              icon: Icons.support_agent_rounded,
              title: LocaleKeys.drawerSupport.tr(),
              onPressed:
                  () {} /*=>
                  Navigator.of(context).pushNamed(ContactUsScreen.routeName)*/
              ,
            ),

            Selector<UserProvider, bool>(
              selector: (context, provider) => true /* => provider.isLoggedIn*/,
              builder: (context, isLoggedIn, child) {
                if (isLoggedIn) {
                  return const DrawerLogoutButton();
                } else {
                  return CustomDrawerItem(
                      icon: Icons.login_rounded,
                      title: LocaleKeys.login.tr(),
                      onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
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
                          })));
                }
              },
            ),

            const LanguageSwitcher(),
          ],
        ),
      ),
    );
  }
}
