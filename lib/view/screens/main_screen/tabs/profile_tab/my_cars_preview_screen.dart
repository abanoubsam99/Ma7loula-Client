import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../controller/user_provider.dart';
import '../../../../../core/dialogs/confirmation_dialog.dart';
import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/services/http/apis/car_api.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../core/widgets/custom_card.dart';
import '../../../../../core/widgets/custom_future_builder.dart';
import '../../../../../core/widgets/login_now_message.dart';
import '../../../../../core/widgets/message_widget.dart';
import '../../../../../model/car_model.dart';
import '../../../addresses_book_screen/local_widgets/address_card.dart';
import '../../../auth/YourCarDetails.dart';

class MyCarsPreviewScreen extends StatefulWidget {
  static const String routeName = '/myCarsPreview';

  const MyCarsPreviewScreen({super.key});

  @override
  State<MyCarsPreviewScreen> createState() => _MyCarsPreviewScreenState();
}

class _MyCarsPreviewScreenState extends State<MyCarsPreviewScreen> {
  bool _isLoading = false;
  GlobalKey _carsListKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorsPalette.lightGrey,
        appBar: AppBarApp(
          title: LocaleKeys.car.tr(),
          actions: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, YourCarDetails.routeName);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: ColorsPalette.primaryColor,
                      size: 20,
                    ),
                    UtilValues.gap2,
                    Text(
                      LocaleKeys.addCar.tr(),
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorsPalette.primaryColor,
                          fontFamily: ZainTextStyles.font),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        body: Selector<UserProvider, bool>(
            selector: (context, provider) => provider.isLoggedIn,
            builder: (context, isLoggedIn, child) {
              if (!isLoggedIn) {
                return const Center(child: LoginNowMessage());
              }
              return Column(
                children: [
                  UtilValues.gap12,
                  Expanded(
                      child: CustomFutureBuilder<List<UserCars>>(
                          key: _carsListKey,
                          future: CarApi.getCars(locale: context.locale),
                          successBuilder: (List<UserCars> cars) {
                            if (cars.isEmpty) {
                              return Center(
                                child: MessageWidget(
                                  icon: Icons.map_outlined,
                                  message: LocaleKeys.noCarsFound.tr(),
                                ),
                              );
                            }
                            return ListView.separated(
                              padding: UtilValues.padding16T12,
                              physics: UtilValues.scrollPhysics,
                              itemCount: cars.length,
                              separatorBuilder: (context, index) =>
                                  UtilValues.gap12,
                              itemBuilder: (context, index) {
                                final car = cars[index];
                                return CustomCard(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: ColorsPalette.extraDarkGrey),
                                  color: ColorsPalette.white,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: AddressCard(
                                          name:
                                              car.car?.model?.brand?.name ?? '',
                                          city:
                                              '${car.car?.engine} | ${car.car?.year}' ??
                                                  '',
                                          selected: car.isDefault ?? false,
                                        ),
                                      ),
                                      _buttons(car.id ?? 0,
                                          car.car?.model?.brand?.name ?? '')
                                    ],
                                  ),
                                );
                              },
                            );
                          })),
                ],
              );
            }));
  }

  _buttons(int carId, String carName) {
    return Row(
      children: [
        IconButton(
            onPressed: () => _setDefaultCar(carName: carName, carId: carId),
            icon: SvgPicture.asset(AssetsManager.edit)),
        IconButton(
          onPressed: () => _deleteCar(carId: carId, carName: carName),
          icon: SvgPicture.asset(AssetsManager.delete),
        ),
      ],
    );
  }

  Future<void> _deleteCar({required String carName, required int carId}) async {
    try {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        message: LocaleKeys.deleteCarConfirmation.tr(args: [carName]),
      );

      if (confirmed) {
        await CarApi.deleteCar(carId: carId, locale: context.locale);
        setState(() {});
      }
    } catch (error) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: error.toString(),
      );
    }
  }

  Future<void> _setDefaultCar(
      {required String carName, required int carId}) async {
    try {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        message: LocaleKeys.setDefault.tr(args: [carName]),
      );

      if (confirmed) {
        // Show loading indicator
        setState(() => _isLoading = true);
        
        // Set car as default
        await CarApi.setCarDefault(carId: carId, locale: context.locale);
        
        // Force refresh user data
        final userProvider = context.read<UserProvider>();
        await userProvider.autoLogin(locale: context.locale, context: context);
        
        // Force refresh cars list
        setState(() {
          _carsListKey = GlobalKey();
          _isLoading = false;
        });

        showSnackbar(
          context: context,
          status: SnackbarStatus.success,
          message: LocaleKeys.done.tr(),
        );
      }
    } catch (error) {
      setState(() => _isLoading = false);
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: error.toString(),
      );
    }
  }
}
