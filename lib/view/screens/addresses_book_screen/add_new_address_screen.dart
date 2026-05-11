import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ma7lola/view/screens/addresses_book_screen/addresses_preview_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ma7lola/model/cities_model.dart';
import 'package:ma7lola/model/states_model.dart';
import 'package:ma7lola/model/tires_products_model.dart';
import 'package:ma7lola/view/screens/main_screen/main_screen.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/tires/tires_checkout_screen.dart';
import 'package:ma7lola/view/screens/map/map_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controller/user_provider.dart';
import '../../../core/generated/locale_keys.g.dart';
import '../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/font.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/message_widget.dart';
import '../../../model/batteries_products_model.dart';
import '../../../model/car_model.dart';
import '../../../model/products_model.dart';
import '../main_screen/tabs/home_tab/batteries/batteries_checkout_screen.dart';
import '../main_screen/tabs/home_tab/car_parts/checkout_screen.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen(
      {Key? key,
      required this.carID,
      required this.products,
      required this.batteries,
      required this.fromCart,
      required this.fromCartBatteries,
      required this.car,
      required this.tires,
      this.late,
      this.long,
      required this.fromCartTires,
      this.addressName,
      this.addressDetails})
      : super(key: key);

  final List<Products> products;
  final List<Batteries> batteries;
  final List<Tires> tires;
  final int carID;
  final String? addressName;
  final String? addressDetails;
  final bool fromCart;
  final bool fromCartBatteries;
  final bool fromCartTires;
  final Car? car;
  final double? late;
  final double? long;
  @override
  State<StatefulWidget> createState() {
    return _AddNewAddressScreenState();
  }
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  var _addressNameController = TextEditingController();
  var _addressDetailsController = TextEditingController();

  CitiesModel? citiesList;
  bool _isLoading = false;
  bool changeModel = false;
  bool changeModel2 = false;
  int? isChangeState;
  int? isChangeCities;
  String? phone;
  @override
  void initState() {
    // TODO: implement initState
    _fetch();
    super.initState();
  }

  _fetch() {
    _addressNameController.text = widget.addressName ?? '';
    // If we have coordinates and address details from the map, use them
    if (widget.late != null && widget.long != null && widget.addressDetails != null) {
      _addressDetailsController.text = widget.addressDetails ?? '';
    }
    // Fetch states list if we don't have it yet
    _fetchStatesList();
  }
  
  // Fetch states and cities list from API
  Future<void> _fetchStatesList() async {
    try {
      // First fetch states
      final statesResult = await MiscellaneousApi.getStates(locale: context.locale);
      if (statesResult.data?.states != null && statesResult.data!.states!.isNotEmpty) {
        // Select first state as default
        setState(() {
          isChangeState = statesResult.data?.states?.first.id;
        });
        
        // Then fetch cities for the first state
        if (isChangeState != null) {
          final citiesResult = await MiscellaneousApi.getCities(
            locale: context.locale, 
            stateID: isChangeState!,
          );
          setState(() {
            citiesList = citiesResult;
            // Select first city as default
            if (citiesList?.data?.cities != null && citiesList!.data!.cities!.isNotEmpty) {
              isChangeCities = citiesList?.data?.cities?.first.id;
            }
          });
        }
      }
    } catch (error) {
      log('Error fetching states/cities: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.lightGrey,
      appBar: AppBarApp(title: LocaleKeys.addNewAddress.tr()),
      bottomNavigationBar: Container(
        color: ColorsPalette.white,
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: SimplePrimaryButton(
            isLoading: _isLoading,
            loadingWidgetColor: ColorsPalette.white,
            label: LocaleKeys.saveAddress.tr(),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                _saveAddress();
              }
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                // Use await to get the result back from the map screen
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MapScreen(
                    carID: widget.carID,
                    products: widget.products,
                    batteries: widget.batteries,
                    fromCart: widget.fromCart,
                    fromCartBatteries: widget.fromCartBatteries,
                    car: widget.car,
                    tires: widget.tires,
                    fromCartTires: widget.fromCartTires,
                    addressDetails: _addressDetailsController.text,
                    addressName: _addressNameController.text,
                  );
                })).then((value) {
                  // Refresh the form fields when returning from map screen
                  setState(() {
                    // Reload data since it may have been updated
                    _fetch();
                  });
                });
              },
              child: Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/testMap.png'),
                        fit: BoxFit.cover,
                        /* colorFilter: ColorFilter.mode(
                            ColorsPalette.primaryColor.withOpacity(0.4),
                            BlendMode.overlay),*/
                      ),
                    ),
                  ),
                  Positioned(
                    top: 35,
                    bottom: 35,
                    left: 60,
                    right: 60,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                          color: ColorsPalette.white,
                          border: Border.all(color: ColorsPalette.primaryColor),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        LocaleKeys.choice.tr(),
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FormBuilder(
              key: _formKey,
              child: Padding(
                padding: UtilValues.padding16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    nameFormField(),
                    UtilValues.gap16,
                    buildStatesField(),
                    UtilValues.gap16,
                    if (citiesList != null) buildCitiesField(),
                    UtilValues.gap16,
                    detailsFormField(),
                  ],
                ),
              ),
            ),
            UtilValues.gap64,
            if (citiesList == null) UtilValues.gap64,
            if (citiesList == null) UtilValues.gap20,
          ],
        ),
      ),
    );
  }

  Widget nameFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.addressName.tr(),
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 16.sp),
        ),
        TextInputField(
          padding: EdgeInsets.all(16.sp),
          focusedBorder: OutlineInputBorder(
            borderRadius: UtilValues.borderRadius10,
            borderSide:
                const BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: UtilValues.borderRadius10,
            borderSide:
                BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          color: ColorsPalette.darkGrey,
          backgroundColor: ColorsPalette.white,
          controller: _addressNameController,
          inputType: TextInputType.name,
          name: LocaleKeys.name.tr(),
          key: const ValueKey('name'),
          hint: LocaleKeys.addressNameEx.tr(),
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  Widget detailsFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.addressDetails.tr(),
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
        TextInputField(
          padding: EdgeInsets.all(11.sp),
          focusedBorder: OutlineInputBorder(
            borderRadius: UtilValues.borderRadius10,
            borderSide:
                const BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: UtilValues.borderRadius10,
            borderSide:
                BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          color: ColorsPalette.darkGrey,
          backgroundColor: ColorsPalette.white,
          controller: _addressDetailsController,
          inputType: TextInputType.name,
          name: LocaleKeys.name.tr(),
          key: const ValueKey('details'),
          hint: LocaleKeys.addressDetailsEx.tr(),
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  Widget buildStatesField() {
    return FutureBuilder<StatesModel>(
      future: MiscellaneousApi.getStates(locale: context.locale),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final statesList = snapshot.data;

        // Check if carBrands is null or empty
        if (statesList == null || (statesList.data?.states?.isEmpty ?? false)) {
          return MessageWidget(
            icon: Icons.map_outlined,
            message: LocaleKeys.noAddressesFound.tr(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.states.tr(),
              style: TextStyle(
                  color: ColorsPalette.black,
                  fontWeight: FontWeight.w400,
                  fontFamily: ZainTextStyles.font,
                  fontSize: 14.sp),
            ),
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
                    color: changeModel
                        ? ColorsPalette.primaryColor
                        : ColorsPalette.darkGrey,
                  ),
                  alignment: Alignment.center,
                  hint: Text(
                    LocaleKeys.choose.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: changeModel
                          ? ColorsPalette.black
                          : ColorsPalette.darkGrey,
                      fontFamily: ZainTextStyles.font,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: ZainTextStyles.font,
                    color: ColorsPalette.black,
                  ),
                  value: isChangeState,
                  onChanged: (int? newValue) async {
                    try {
                      setState(() {
                        changeModel = true;
                      });
                      isChangeState = newValue;
                      isChangeCities = null;
                      citiesList = await MiscellaneousApi.getCities(
                          locale: context.locale, stateID: newValue!);
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
                  items: statesList.data?.states?.map((States states) {
                    return DropdownMenuItem<int>(
                      value: states.id,
                      child: Text(
                        states.name ?? 'Unknown',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 14.sp,
                          fontFamily: ZainTextStyles.font,
                        ),
                      ),
                    );
                  }).toList(),
                )),
          ],
        );
      },
    );
  }

  Widget buildCitiesField() {
    return Builder(builder: (context) {
      if (citiesList != null && !changeModel) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.cities.tr(),
              style: TextStyle(
                  color: ColorsPalette.black,
                  fontWeight: FontWeight.w400,
                  fontFamily: ZainTextStyles.font,
                  fontSize: 14.sp),
            ),
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
                  color: changeModel2
                      ? ColorsPalette.primaryColor
                      : ColorsPalette.darkGrey,
                ),
                alignment: Alignment.center,
                hint: Text(
                  LocaleKeys.choose.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: changeModel2
                        ? ColorsPalette.black
                        : ColorsPalette.darkGrey,
                    fontFamily: ZainTextStyles.font,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: ZainTextStyles.font,
                  color: ColorsPalette.black,
                ),
                value: isChangeCities,
                onChanged: (int? newValue) {
                  setState(() {
                    changeModel2 = true;
                    isChangeCities = newValue;
                  });
                },
                items: citiesList != null
                    ? citiesList?.data?.cities?.map((Cities cities) {
                        return DropdownMenuItem<int>(
                          value: cities.id, // Make sure cities.id is unique
                          child: Text(
                            cities.name ?? 'Unknown',
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
            ),
          ],
        );
      } else {
        return Container(); // Return an empty container or another placeholder widget
      }
    });
  }

  void _saveAddress() async {
    try {
      final formState = _formKey.currentState!;
      if (formState.validate()) {
        setState(() => _isLoading = true);

        // Check if we have valid coordinates
        if (widget.late == null || widget.long == null) {
          showSnackbar(
            context: context,
            status: SnackbarStatus.error,
            message: "Please select a location on the map", // Direct message since locale key may not exist
          );
          setState(() => _isLoading = false);
          return;
        }
        
        // If state/city are not selected but we have coordinates from map,
        // we'll use default values to allow the process to continue
        final stateId = isChangeState ?? 1;  // Default to first state if not selected
        final cityId = isChangeCities ?? 1;  // Default to first city if not selected
        
        await MiscellaneousApi.addAddress(
            locale: context.locale,
            stateID: stateId,
            cityID: cityId,
            lat: widget.late.toString(),
            long: widget.long.toString(),
            name: _addressNameController.text.isEmpty ? "My Address" : _addressNameController.text,
            details: _addressDetailsController.text,
            isDefault: true);
        final userPR = context.read<UserProvider>();
        await userPR.autoLogin(locale: context.locale, context: context);

        if (widget.fromCart) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return CheckoutScreen(
              products: widget.products,
              carID: widget.carID,
              car: widget.car,
            );
          }));
          return;
        } else if (widget.fromCartBatteries) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return BatteriesCheckoutScreen(
              batteries: widget.batteries,
              carID: widget.carID,
              car: widget.car,
            );
          }));
          return;
        } else if (widget.fromCartTires) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return TiresCheckoutScreen(
              tires: widget.tires,
              carID: widget.carID,
              car: widget.car,
            );
          }));
          return;
        } else {
          showSnackbar(
            context: context,
            status: SnackbarStatus.success,
            message: LocaleKeys.done.tr(),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AddressesPreviewScreen()),
          );
        }
      }
    } catch (error) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: error.toString(),
      );
      log('dkdkkdknfubvgry $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
