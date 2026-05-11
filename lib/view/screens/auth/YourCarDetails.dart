import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/core/local_orders/car_id.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/profile_tab/my_cars_preview_screen.dart';
import 'package:ma7lola/core/widgets/loading_widget.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/batteries/batteries_search_screen.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/car_parts/car_parts_search_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controller/car_provider.dart';
import '../../../controller/user_provider.dart';
import '../../../core/generated/locale_keys.g.dart';
import '../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/form_widgets/ternary_button.dart';
import '../../../model/car_model_model.dart';
import '../../../model/car_type_model.dart';
import '../../../model/cars_list_model.dart';
import '../../../model/years_model.dart';
import '../main_screen/main_screen.dart';
import '../main_screen/tabs/home_tab/tires/tires_search_screen.dart';

class YourCarDetails extends StatefulWidget {
  static const String routeName = '/YourCarDetails';

  int? type;
  YourCarDetails({Key? key, this.type}) : super(key: key);

  @override
  State<YourCarDetails> createState() => _YourCarDetailsState();
}

class _YourCarDetailsState extends State<YourCarDetails> {
  final _formKey = GlobalKey<FormState>();

  bool showSniper = false;

  bool showPass = true;
  bool _loading = false;

  CarModelModel? carModels;
  CarsListModel? allCarsList;
  YearsModel? yearsList;
  String? password;
  int? isChangeDropDownCarsType;
  int? isChangeDropDownCarsModel;
  int? isChangeDropDownCars;
  int? isChangeDropDownCarsEng;
  // CarsTypesModel? isChangeDropDownCarsS;
  // CarsTypesModel? isChangeDropDownCarsYear;
  Map<String, int> carTypeId = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: ColorsPalette.lighttGrey,
              image: DecorationImage(
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                    ColorsPalette.light.withOpacity(.9), BlendMode.lighten),
                image: AssetImage(AssetsManager.backgroundLogo),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80.w,
                        height: 28.h,
                        child: Center(
                            child: Image.asset(
                          AssetsManager.cars,
                        )),
                      ),
                      UtilValues.gap32,
                      Center(
                        child: Text(
                          LocaleKeys.addYourCar.tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 22.sp),
                        ),
                      ),
                      UtilValues.gap24,
                      buildDropDownCarsTypesField(),
                      UtilValues.gap24,
                      if (carModels != null) buildDropDownCarsModelsField(),
                      UtilValues.gap24,
                      if (carModels != null && yearsList != null)
                        buildDropDownAllCarsField(),
                      UtilValues.gap20,
                      if (carModels != null && allCarsList != null)
                        buildDropDownAllCarsEng(),
                      UtilValues.gap20,
                      _changePasswordButton(),
                      UtilValues.gap32,
                      Center(
                        child: TernaryButton(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            label: LocaleKeys.addLater.tr(),
                            underLine: false,
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainScreen(
                                          index: 0,
                                        )),
                              );
                            }),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void changePassword() async {
    try {
      final userProvider = context.read<UserProvider>();

      if (isChangeDropDownCarsModel != null &&
          isChangeDropDownCars != null &&
          isChangeDropDownCarsType != null &&
          isChangeDropDownCarsEng != null) {
        if (userProvider.isLoggedIn) {
          setState(() => _loading = true);
          await context.read<CarProvider>().addCar(
              carId: isChangeDropDownCarsEng ?? 0, locale: context.locale);
          setState(() => _loading = true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const MyCarsPreviewScreen()),
          );
        } else {
          print('lddddddddddddddddd ${isChangeDropDownCarsEng}');
          await SQLCarsHelper.addCar(isChangeDropDownCarsEng!);
          if (widget.type == 1) {
            Navigator.pushReplacementNamed(
                context, TiresSearchScreen.routeName);
          } else if (widget.type == 2) {
            Navigator.pushReplacementNamed(
                context, BatteriesSearchScreen.routeName);
          } else if (widget.type == 0) {
            Navigator.pushReplacementNamed(context, CarPartsSearch.routeName);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(
                        index: 0,
                      )),
            );
          }
        }
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

  _changePasswordButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(1.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: changePassword,
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
          child: _loading
              ? const LoadingWidget(
                  color: ColorsPalette.white,
                )
              : Text(
                  LocaleKeys.addCar.tr(),
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

  bool change = false;
  bool changeModel = false;
  bool changeCar = false;

  Widget buildDropDownCarsTypesField() {
    return FutureBuilder<CarTypeModel>(
      future: MiscellaneousApi.getCarsType(locale: context.locale),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final carBrands = snapshot.data?.data?.carBrands;

        // Check if carBrands is null or empty
        if (carBrands == null || carBrands.isEmpty) {
          return Text('No car brands available');
        }

        return Container(
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: ColorsPalette.primaryColor),
                ),
              ),
              dropdownColor: Colors.white,
              icon: SvgPicture.asset(
                'assets/images/expanded.svg',
                fit: BoxFit.scaleDown,
                width: 1.w,
                height: .8.h,
                color: change
                    ? ColorsPalette.primaryColor
                    : ColorsPalette.darkGrey,
              ),
              alignment: Alignment.center,
              hint: Text(
                LocaleKeys.carType.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: change ? ColorsPalette.black : ColorsPalette.darkGrey,
                  fontFamily: ZainTextStyles.font,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: const TextStyle(
                fontFamily: ZainTextStyles.font,
                color: ColorsPalette.black,
              ),
              value: isChangeDropDownCarsType,
              onChanged: (int? newValue) async {
                try {
                  setState(() {
                    change = true;
                    changeModel = true;
                    changeCar = true;
                  });
                  isChangeDropDownCarsType = newValue;
                  isChangeDropDownCarsModel = null;
                  isChangeDropDownCars = null;
                  isChangeDropDownCarsEng = null;
                  carModels = await MiscellaneousApi.getCarsModel(
                      locale: context.locale, carBrandId: newValue!);
                  setState(() {
                    change = false;
                    changeModel = false;
                    changeCar = false;
                  });
                } catch (e) {
                } finally {
                  setState(() {
                    change = false;
                    changeModel = false;
                    changeCar = false;
                  });
                }
              },
              items: carBrands.map((CarBrands carsType) {
                return DropdownMenuItem<int>(
                  value: carsType.id,
                  child: Text(
                    carsType.name ?? 'Unknown',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorsPalette.black,
                      fontSize: 14.sp,
                      fontFamily: ZainTextStyles.font,
                    ),
                  ),
                );
              }).toList(),
            ));
      },
    );
  }

  Widget buildDropDownCarsModelsField() {
    return Builder(builder: (context) {
      if (carModels != null && !change) {
        return Container(
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
              LocaleKeys.carModel.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color:
                    changeModel ? ColorsPalette.black : ColorsPalette.darkGrey,
                fontFamily: ZainTextStyles.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: const TextStyle(
              fontFamily: ZainTextStyles.font,
              color: ColorsPalette.black,
            ),
            value: isChangeDropDownCarsModel,
            onChanged: (int? newValue) async {
              try {
                setState(() {
                  change = true;
                  changeModel = true;
                  changeCar = true;
                });
                isChangeDropDownCarsModel = newValue;
                isChangeDropDownCars = null;
                yearsList = await MiscellaneousApi.getYears(
                    locale: context.locale,
                    carTypeId: isChangeDropDownCarsType!,
                    carModelId: newValue!);
                setState(() {
                  change = false;
                  changeModel = false;
                  changeCar = false;
                });
              } catch (e) {
              } finally {
                setState(() {
                  change = false;
                  changeModel = false;
                  changeCar = false;
                });
              }
            },
            items: carModels != null
                ? carModels?.data?.carModels?.map((CarModels carModels) {
                    return DropdownMenuItem<int>(
                      value: carModels.id,
                      child: Text(
                        carModels.name ?? 'Unknown',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 14.sp,
                          fontFamily: ZainTextStyles.font,
                        ),
                      ),
                    );
                  }).toList()
                : [],
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  Widget buildDropDownAllCarsField() {
    return Builder(builder: (context) {
      if (yearsList != null && !changeModel && carModels != null && !change) {
        return Container(
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
              LocaleKeys.car.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color:
                    changeModel ? ColorsPalette.black : ColorsPalette.darkGrey,
                fontFamily: ZainTextStyles.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: const TextStyle(
              fontFamily: ZainTextStyles.font,
              color: ColorsPalette.black,
            ),
            value: isChangeDropDownCars,
            onChanged: (int? newValue) async {
              try {
                setState(() {
                  changeModel = true;
                });
                isChangeDropDownCars = newValue;
                allCarsList = await MiscellaneousApi.getCars(
                    locale: context.locale,
                    carTypeId: isChangeDropDownCarsType!,
                    carModelId: isChangeDropDownCarsModel!,
                    year: newValue!);
                setState(() {
                  changeModel = false;
                });
              } catch (e) {
              } finally {
                setState(() {
                  changeModel = false;
                });
              }
            },
            items: yearsList != null
                ? yearsList?.data?.years?.map((String year) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(year),
                      child: Text(
                        year,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 14.sp,
                          fontFamily: ZainTextStyles.font,
                        ),
                      ),
                    );
                  }).toList()
                : [],
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  Widget buildDropDownAllCarsEng() {
    return Builder(builder: (context) {
      if (allCarsList != null &&
          !changeModel &&
          carModels != null &&
          !change &&
          !changeModel) {
        return Container(
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
              color: changeCar
                  ? ColorsPalette.primaryColor
                  : ColorsPalette.darkGrey,
            ),
            alignment: Alignment.center,
            hint: Text(
              LocaleKeys.engine.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color: changeCar ? ColorsPalette.black : ColorsPalette.darkGrey,
                fontFamily: ZainTextStyles.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: const TextStyle(
              fontFamily: ZainTextStyles.font,
              color: ColorsPalette.black,
            ),
            value: isChangeDropDownCarsEng,
            onChanged: (int? newValue) {
              setState(() {
                isChangeDropDownCarsEng = newValue;
              });
            },
            items: (allCarsList != null && isChangeDropDownCars != null)
                ? allCarsList?.data?.cars?.map((Cars cars) {
                    return DropdownMenuItem<int>(
                      value: cars.id,
                      child: Text(
                        cars.engine ?? 'Unknown',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 14.sp,
                          fontFamily: ZainTextStyles.font,
                        ),
                      ),
                    );
                  }).toList()
                : [],
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }
}
