import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/emergency/emergency_map_ploying.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../auth/LoginScreen.dart';
import 'local_widgets/emergency_card.dart';

class EmergencyServicesScreen extends StatefulWidget {
  static String routeName = '/emergency-services';
  EmergencyServicesScreen({Key? key, this.back = false}) : super(key: key);

  bool back = false;
  @override
  State<EmergencyServicesScreen> createState() =>
      _EmergencyServicesScreenState();
}

class _EmergencyServicesScreenState extends State<EmergencyServicesScreen> {
  List<EmergencyServiceModel> productCategories = [
    EmergencyServiceModel(
      name: LocaleKeys.deriveBattery.tr(),
      img: AssetsManager.emergencyService1,
    ),
    EmergencyServiceModel(
      name: LocaleKeys.needGaz.tr(),
      img: AssetsManager.emergencyService2,
    ),
    EmergencyServiceModel(
      name: LocaleKeys.otherServices.tr(),
      img: AssetsManager.emergencyService3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection:
            Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
        child: Builder(builder: (context) {
          final category = productCategories;
          return Scaffold(
            backgroundColor: ColorsPalette.white,
            appBar: AppBarApp(
              title: LocaleKeys.emergency.tr(),
              backButton: widget.back ? Container() : null,
            ),
            body: Column(
              children: [
                UtilValues.gap8,
                // if (categories.data != null && category != null)
                ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => UtilValues.gap8,
                  itemCount: category.length ?? 2,
                  itemBuilder: (context, index) {
                    final categ = category[index];
                    return EmergencyServiceCard(
                      height: 13.h,
                      image: categ.img ?? '',
                      title: categ.name ?? '',
                      onTap: () {
                        final userProvider = context.read<UserProvider>();
                        if (!userProvider.isLoggedIn) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return LoginScreen(
                              products: [],
                              batteries: [],
                              tires: [],
                              carID: 0,
                              fromEmergency: true,
                              fromCart: false,
                              fromCartBatteries: false,
                              fromCartTires: false,
                              car: null,
                            );
                          }));
                        } else {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return EmergencyMapPolylineScreen();
                          }));
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          );
        }));
  }
}

class EmergencyServiceModel {
  String img;
  String name;
  EmergencyServiceModel({required this.name, required this.img});
}
