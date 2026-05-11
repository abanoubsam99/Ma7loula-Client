import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: FutureBuilder(
          future: _splashOperation(context),
          builder: (context, snapshot) {
            return Scaffold(
              appBar: AppBarApp(
                title: LocaleKeys.payment.tr(),
              ),
            );
          }),
    );
  }

  Future<void> _splashOperation(BuildContext context) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    } catch (_) {}
  }
}
