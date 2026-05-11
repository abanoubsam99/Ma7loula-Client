import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/widgets/message_widget.dart';
import 'package:ma7lola/view/screens/auth/LoginScreen.dart';

import '../utils/colors_palette.dart';

class LoginNowMessage extends StatelessWidget {
  const LoginNowMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return MessageWidget(
      iconColor: ColorsPalette.darkGrey,
      icon: Icons.person_pin,
      message: LocaleKeys.loginToStartManagingOrders.tr(),
      actionButtonLabel: LocaleKeys.login.tr(),
      onActionButtonTapped: () {
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
    );
  }
}
