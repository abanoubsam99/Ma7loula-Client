import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola/controller/user_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../core/dialogs/confirmation_dialog.dart';
import '../../../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../../../core/utils/snackbars.dart';
import '../../../../../main_screen.dart';
import 'custom_drawer_item.dart';

class DrawerLogoutButton extends StatefulWidget {
  const DrawerLogoutButton({
    Key? key,
  }) : super(key: key);

  @override
  State<DrawerLogoutButton> createState() => _DrawerLogoutButtonState();
}

class _DrawerLogoutButtonState extends State<DrawerLogoutButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    context
        .locale; // NOTE: This one is added to solve the bug of not translation after changing the local

    return CustomDrawerItem(
      isLoading: _isLoading,
      icon: Icons.exit_to_app_rounded,
      title: LocaleKeys.drawerLogout.tr(),
      onPressed: () => _logout(context),
    );
  }

  void _logout(BuildContext context) async {
    try {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: LocaleKeys.drawerLogout.tr(),
        message: LocaleKeys.logoutConfirmation.tr(),
      );

      if (!confirmed) return;

      setState(() => _isLoading = true);
      final userProvider = context.read<UserProvider>();
      // final fcmToken = await FirebaseMessaging.instance.getToken();

      // await userProvider.logout(userProvider.user!.email, fcmToken);

      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainScreen(
                  index: 0,
                )),
      );
    } catch (error) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: error.toString(),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
