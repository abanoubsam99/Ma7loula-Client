import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/controller/user_provider.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:ma7lola/view/screens/auth/YourCarDetails.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/local_orders/car_id.dart';
import '../../../../../../core/services/http/apis/car_api.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/snackbars.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_card.dart';
import '../../../../../../core/widgets/custom_future_builder.dart';
import '../../../../../../core/widgets/horizontal_list_view.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../model/batteries_brands_model.dart';
import '../../../../../../model/car_model.dart';
import '../../../../../../model/local_car.dart' as s;
import '../../../../../../model/voltages_model.dart';
import '../../../../addresses_book_screen/local_widgets/address_card.dart';
import 'batteries_cart_screen.dart';
import 'batteries_resualts_screen.dart';
import 'local_widets/voltage_card.dart';

class BatteriesSearchScreen extends StatefulWidget {
  static String routeName = '/BatteriesSearch';
  const BatteriesSearchScreen({Key? key}) : super(key: key);

  @override
  State<BatteriesSearchScreen> createState() => _BatteriesSearchScreenState();
}

class _BatteriesSearchScreenState extends State<BatteriesSearchScreen> {
  List<BatteryBrands>? brands;
  bool changeModel = false;
  bool _loading = false;
  int? selected;
  int? selectedUserCar;
  Car? selectedCar;
  @override
  void initState() {
    // TODO: implement initState
    final userProvider = context.read<UserProvider>();

    if (!userProvider.isLoggedIn) _addLocalData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorsPalette.lightGrey,
        appBar: AppBarApp(
          title: LocaleKeys.batteries.tr(),
          actions: [
            IconButton(
                onPressed: () {
                  final userProvider = context.read<UserProvider>();
                  if (!userProvider.isLoggedIn) {
                    if (selected != null && selected != 0) {
                      _addLocalData();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BatteriesCartScreen(
                          carID: selected ?? 1,
                          car: selectedCar,
                        );
                      }));
                    } else {
                      showSnackbar(
                          context: context,
                          status: SnackbarStatus.error,
                          // message: LocaleKeys.pleaseSelectAllOptions.tr(),
                          message: 'plz add/select car');
                    }
                  } else {
                    _getCar();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BatteriesCartScreen(
                        carID: selected ?? 1,
                        car: selectedCar,
                      );
                    }));
                  }
                },
                icon: SvgPicture.asset(AssetsManager.cart)),
          ],
        ),
        bottomNavigationBar: _startSearchButton(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: ColorsPalette.primaryLightColor,
              height: 10,
            ),
            Container(
              color: ColorsPalette.primaryLightColor,
              child: Row(
                children: [
                  UtilValues.gap8,
                  SvgPicture.asset(AssetsManager.carShape),
                  UtilValues.gap8,
                  Text(
                    LocaleKeys.chooseFromCars.tr(),
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: ZainTextStyles.font,
                        fontSize: 14.sp),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => YourCarDetails(
                                  type: 2,
                                )),
                      );
                    },
                    icon: Row(
                      children: [
                        SvgPicture.asset(AssetsManager.addCircle),
                        UtilValues.gap8,
                        Text(
                          LocaleKeys.addCar.tr(),
                          style: TextStyle(
                              color: ColorsPalette.primaryColor,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  UtilValues.gap8,
                ],
              ),
            ),
            Container(
              height: 100,
              color: ColorsPalette.primaryLightColor,
              child: Builder(builder: (context) {
                final userProvider = context.read<UserProvider>();
                if (userProvider.isLoggedIn) {
                  return CustomFutureBuilder<List<UserCars>>(
                      future: CarApi.getCars(locale: context.locale),
                      successBuilder: (List<UserCars> cars) {
                        if (cars.isEmpty) {
                          return Center(
                              child: Column(
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 50,
                                color: ColorsPalette.primaryColor,
                              ),
                              UtilValues.gap16,
                              Text(
                                LocaleKeys.noCarsFound.tr(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: ColorsPalette.black,
                                    fontSize: 12,
                                    fontFamily: ZainTextStyles.font),
                              ),
                            ],
                          ));
                        }
                        return SizedBox(
                          height: 100,
                          child: HorizontalListView(
                              padding: EdgeInsets.all(5),
                              itemCount: cars.length,
                              itemBuilder: (index) {
                                final car = cars[index];
                                if(selected==null){
                                  Timer(Duration(seconds: 1), () {
                                    setState(() {
                                      _voltage=null;
                                      _isChangeDropDownBrands=null;
                                      brands = null;
                                      selected = cars[0].car?.id;
                                      selectedUserCar = cars[0].id;
                                      selectedCar = cars[0].car;
                                    });
                                  });

                                }
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _voltage=null;
                                      _isChangeDropDownBrands=null;
                                      brands = null;
                                      selected = car.car?.id;
                                      selectedUserCar = car.id;
                                      selectedCar = car.car;
                                    });
                                  },
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3.5,
                                    child: CustomCard(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: ((selected == null)
                                                  ? (car.isDefault ?? false)
                                                  : (selected == car.car?.id))
                                              ? ColorsPalette.primaryColor
                                              : ColorsPalette.extraDarkGrey),
                                      color: ColorsPalette.white,
                                      child: AddressCard(
                                        name:
                                            '${car.car?.model?.brand?.name}, ${car.car?.model?.name}' ??
                                                '',
                                        city: car.car?.year ?? '',
                                        selected: false,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        );
                      });
                }
                return Builder(builder: (context) {
                  final cars = allCarsPreview.toSet().toList();
                  if (cars.isEmpty) {
                    return Center(
                        child: Column(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 50,
                          color: ColorsPalette.primaryColor,
                        ),
                        UtilValues.gap16,
                        Text(
                          LocaleKeys.noCarsFound.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: ColorsPalette.black,
                              fontSize: 12,
                              fontFamily: ZainTextStyles.font),
                        ),
                      ],
                    ));
                  }
                  return SizedBox(
                    height: 100,
                    child: HorizontalListView(
                        padding: EdgeInsets.all(5),
                        itemCount: allCarsPreview.toSet().toList().length,
                        itemBuilder: (index) {
                          final car = allCarsPreview.toSet().toList()[index];

                          return InkWell(
                            onTap: () {
                              setState(() {
                                selected = car?.id;
                                selectedUserCar = car?.id;
                                // selectedCar = car;
                              });
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 3.5,
                              child: CustomCard(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: (selected == car?.id)
                                        ? ColorsPalette.primaryColor
                                        : ColorsPalette.extraDarkGrey),
                                color: ColorsPalette.white,
                                child: AddressCard(
                                  name:
                                      '${car?.model?.brand?.name}, ${car?.model?.name}' ??
                                          '',
                                  city: car?.year ?? '',
                                  selected: false,
                                ),
                              ),
                            ),
                          );
                        }),
                  );
                });
              }),
            ),
            Container(
              color: ColorsPalette.primaryLightColor,
              height: 10,
            ),
            UtilValues.gap12,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _volts(),
                  if (brands != null && (brands?.isNotEmpty ?? false))
                    buildDropDownBrands(),
                ],
              ),
            )
          ],
        ));
  }

  String? _voltage;
  int? _isChangeDropDownBrands;

  _volts() {
    return FutureBuilder<VoltagesModel>(
        future: MiscellaneousApi.getVoltages(
            locale: context.locale, carID: selected ?? 1),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container(
              height: 1.h,
              decoration: BoxDecoration(
                color: ColorsPalette.lightGrey,
                borderRadius: UtilValues.borderRadius10,
              ),
              child: const Center(
                child: SizedBox.shrink(),
              ),
            );
          }

          final voltages = snapshot.data!;

          if (voltages.data == null ||
              (voltages.data?.batteryVolts?.isEmpty ?? false)) {
            return const SizedBox.shrink();
          }
          final batteryVolts = voltages.data?.batteryVolts;
          return SizedBox(
            height: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.choseVoltage.tr(),
                  style: TextStyle(
                      color: ColorsPalette.black,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
                UtilValues.gap2,
                Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _voltage,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: ColorsPalette.primaryColor),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    icon: SvgPicture.asset(
                      'assets/images/expanded.svg',
                      fit: BoxFit.scaleDown,
                      width: 1.w,
                      height: .8.h,
                      color: changeModel
                          ? ColorsPalette.primaryColor
                          : ColorsPalette.darkGrey,
                    ),
                    alignment: Alignment.center,
                    hint: Text(
                      LocaleKeys.choose.tr(), // localized "Choose"
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: ColorsPalette.black,
                        fontFamily: ZainTextStyles.font,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: ZainTextStyles.font,
                      color: ColorsPalette.black,
                    ),
                    items: batteryVolts?.map((volt) {
                      return DropdownMenuItem<String>(
                        value: volt,
                        child: Text(
                          volt,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 14.sp,
                            fontFamily: ZainTextStyles.font,
                          ),
                        ),
                      );
                    }).toList() ??
                        [],
                    onChanged: (value) {
                      setState(() {
                        // _voltage = value;
                        _onVoltage(value);
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        // return LocaleKeys.select_voltage_validation.tr(); // or 'Please select a voltage'
                      }
                      return null;
                    },
                  ),
                ),
                // Expanded(
                //   child: ListView.separated(
                //       separatorBuilder: (context, index) {
                //         return UtilValues.gap4;
                //       },
                //       shrinkWrap: true,
                //       itemCount: batteryVolts != null ? batteryVolts.length : 0,
                //       itemBuilder: (context, index) {
                //         final name = batteryVolts?[index];
                //         if (batteryVolts != null) {
                //           return _voltages(name, name);
                //         }
                //         return SizedBox.shrink();
                //       }),
                // ),
              ],
            ),
          );
        });
  }

  // _voltages(String? name, String? value) {
  //   return CardVoltages(
  //     name: name ?? '',
  //     value: value,
  //     selectedValue: _voltage,
  //     onChanged: _onVoltage,
  //   );
  // }

  void _onVoltage(String? voltage) async {
    setState(() {
      brands = null;
      _isChangeDropDownBrands = null;
      _voltage = voltage;
    });
    final all = await MiscellaneousApi.getBrands(
        locale: context.locale, voltage: voltage ?? '', carID: selected ?? 1);
    brands = all.data?.batteryBrands;
    setState(() {});
  }

  Widget buildDropDownBrands() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.brand.tr(),
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
        UtilValues.gap2,
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: ColorsPalette.primaryColor),
              ),
            ),
            dropdownColor: Colors.white,
            icon: SvgPicture.asset(
              'assets/images/expanded.svg',
              fit: BoxFit.scaleDown,
              width: 1.w,
              height: .8.h,
              color: changeModel
                  ? ColorsPalette.primaryColor
                  : ColorsPalette.darkGrey,
            ),
            alignment: Alignment.center,
            hint: Text(
              LocaleKeys.choose.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsPalette.black,
                fontFamily: ZainTextStyles.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: const TextStyle(
              fontFamily: ZainTextStyles.font,
              color: ColorsPalette.black,
            ),
            value: _isChangeDropDownBrands,
            onChanged: (int? newValue) async {
              _isChangeDropDownBrands = newValue!;
              setState(() {});
            },
            items: brands?.map((BatteryBrands batteryBrands) {
                  return DropdownMenuItem<int>(
                    value: batteryBrands.id,
                    child: Text(
                      batteryBrands.name ?? 'Unknown',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorsPalette.black,
                        fontSize: 14.sp,
                        fontFamily: ZainTextStyles.font,
                      ),
                    ),
                  );
                }).toList() ??
                [],
          ),
        ),
      ],
    );
  }

  _startSearchButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(14.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: startSearch,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
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
          child: _loading
              ? const LoadingWidget(
                  color: ColorsPalette.white,
                )
              : Text(
                  LocaleKeys.startSearch.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorsPalette.white,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
        ),
      ),
    );
  }

  void startSearch() async {
    try {
      await _getCar();
      setState(() {});
      // await Future.delayed(Duration(seconds: 3));
      if ((selected != null) &&
          _voltage != null &&
          _isChangeDropDownBrands != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return BatteriesResultsScreen(
            voltage: _voltage ?? '',
            carId: selected ?? 1,
            brandId: _isChangeDropDownBrands ?? 0,
            car: selectedCar,
            userCarId: selectedUserCar ?? 1,
          );
        }));
        return;
      } else {
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: LocaleKeys.pleaseSelectAllOptions.tr(),
        );
      }
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
      setState(() => _loading = false);
    } finally {
      setState(() => _loading = false);
    }
  }

  _getCar() async {
    final userProvider = context.read<UserProvider>();

    if (userProvider.isLoggedIn) {
      final List<UserCars> cars = await CarApi.getCars(locale: context.locale);
      setState(() {
        selected ??= cars
            .firstWhereOrNull((element) => element.isDefault ?? false)
            ?.car
            ?.id;
        selectedCar ??=
            cars.firstWhereOrNull((element) => element.isDefault ?? false)?.car;
        selectedUserCar ??=
            cars.firstWhereOrNull((element) => element.isDefault ?? false)?.id;
      });
    } else {
      selected ??= allCarsPreview.last?.id;
    }
    setState(() {});
  }

  // List<CarS> allCars = [];
  List<s.Car?> allCarsPreview = [];

  _addLocalData() {
    SQLCarsHelper.getCars().then((value) async {
      for (int i = 0; i < value.length; i++) {
        s.LocalCarModel car = await CarApi.getCarById(
            locale: context.locale, carId: value[i]['carID']);

        allCarsPreview.add(car.data?.car);
        setState(() {
          // allCars.add(CarS.fromDbMap(value[i]));
        });
      }
    });
  }
}

class CarS {
  int id = -1;
  CarS();

  CarS.fromDbMap(Map<String, dynamic> map) {
    id = map['carID'];
  }
}
