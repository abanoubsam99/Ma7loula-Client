import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/services/http/apis/car_api.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/snackbars.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/app_snack_bar.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../core/widgets/custom_card.dart';
import '../../../../../../core/widgets/custom_future_builder.dart';
import '../../../../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../../../../core/widgets/horizontal_list_view.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../model/car_model.dart';
import '../../../../addresses_book_screen/local_widgets/address_card.dart';
import '../../../../auth/YourCarDetails.dart';
import 'EmergencyResultsOffers.dart';

class EmergencyMapPolylineScreen extends StatefulWidget {
  @override
  _EmergencyMapPolylineScreenState createState() =>
      _EmergencyMapPolylineScreenState();
}

class _EmergencyMapPolylineScreenState
    extends State<EmergencyMapPolylineScreen> {
  var _orderDetailsController = TextEditingController();
  bool _loading = false;
  bool _isSearching = false; // Flag to prevent multiple searches
  int? selected;
  int? selectedUserCar;
  Car? selectedCar;
  GoogleMapController? mapController;
  Position? currentPosition;
  Set<Marker> markers = {};
  LatLng? pickupLocation;
  LatLng? dropoffLocation;

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(30.0444, 31.2357),
    zoom: 14.0,
  );

  void _updateCamera() {
    if (currentPosition != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(currentPosition!.latitude, currentPosition!.longitude),
        ),
      );
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = position;
      });
    }
  }

  Future<void> _requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request the user to enable them
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show an error message
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle the case accordingly
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Future<Position> _getCurrentLocation(context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled .');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        var snackBar = AppSnackBar(
          text: 'Location permission are denied',
          isSuccess: false,
        ) as SnackBar;
        return ScaffoldMessenger.of(context).showSnackBar(snackBar) as Position;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permission are permanently, we cannot permission');
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentPosition = position;
      _updateCamera();
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _getCar();
    _requestPermission();
    // _getCurrentLocation(context);
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (currentPosition == null) {
      _getCurrentLocation(context);
    }
  }
  num price = 0;

  int distanceInKm = 0;
  int distanceInMater = 0;
  int timeInMinutes = 0;
  // دالة جديدة لحساب المسافة والوقت
  Future<void> _calculateDistanceAndTime() async {
    if (pickupLocation == null || dropoffLocation == null) return;

    try {
      double distanceInMeters = await Geolocator.distanceBetween(
        pickupLocation!.latitude,
        pickupLocation!.longitude,
        dropoffLocation!.latitude,
        dropoffLocation!.longitude,
      );

      // تحويل المسافة إلى كيلومترات
      distanceInKm = distanceInMeters ~/ 1000;
      distanceInMater = distanceInMeters.toInt();

      // تقدير الوقت (افتراض متوسط السرعة 40 كم/ساعة)
      double timeInHours = distanceInKm / 40;
      timeInMinutes = (timeInHours * 60).round();
      _getCar();
      setState(() {});
      final cars = await CarApi.getCars(locale: context.locale);

      if (cars.isEmpty) {
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: LocaleKeys.pleaseSelectAllOptions.tr(),
        );
        return;
      }

      // final userCarId = cars.firstWhereOrNull((element) => element.isDefault ?? false)?.id;
      final userCarId = selectedUserCar;
      print("userCarId2=${userCarId}");
      setState(() {});

      final calculatePrice = await MiscellaneousApi.getPrice(
          locale: context.locale,
          distance: distanceInMater,
          fromLat: pickupLocation!.latitude,
          fromLon: pickupLocation!.longitude,
          toLat: dropoffLocation!.latitude,
          toLon: dropoffLocation!.longitude,
          duration: timeInMinutes,
          userCarId: userCarId??14);

      price = calculatePrice.data?.price ?? 0;
      setState(() {});
    } catch (e) {
      print("Error calculating distance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.lightGrey,
      appBar: AppBarApp(
        title: LocaleKeys.emergency.tr(),
      ),
      bottomNavigationBar: _startSearchButton(),
      body: Column(
        children: [
          Flexible(
            child: GoogleMap(
              initialCameraPosition: initialPosition,
              onMapCreated: (controller) {
                mapController = controller;
                _getCurrentLocation(context);
              },
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapType: MapType.normal,
            ),
          ),
          Container(
            color: ColorsPalette.lightGrey,
            width: double.maxFinite,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Column(
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
                                          type: 1,
                                        )),
                              );
                              // Navigator.pushNamed(context, YourCarDetails.routeName);
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
                      height: 80,
                      color: ColorsPalette.primaryLightColor,
                      child: Builder(
                        builder: (context) {
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
                                        style: TextStyle(
                                            color: ColorsPalette.black,
                                            fontSize: 14.sp,
                                            fontFamily: ZainTextStyles.font),
                                      ),
                                    ],
                                  ));
                                }
                                return SizedBox(
                                  height: 80,
                                  child: HorizontalListView(
                                      padding: EdgeInsets.all(5),
                                      itemCount: cars.length,
                                      itemBuilder: (index) {
                                        final car = cars[index];
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              selected = car.car?.id;
                                              selectedUserCar = car.id;
                                              selectedCar = car.car;
                                            });
                                          },
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3.5,
                                            child: CustomCard(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 10),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: ((selected == null)
                                                          ? (car.isDefault ??
                                                              false)
                                                          : (selected ==
                                                              car.car?.id))
                                                      ? ColorsPalette.primaryColor
                                                      : ColorsPalette
                                                          .extraDarkGrey),
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
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                    detailsFormField(),
                    UtilValues.gap8
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void startSearch() async {
  //   // Check if already searching to prevent multiple searches
  //   if (_isSearching) {
  //     return;
  //   }
  //
  //   setState(() {
  //     _loading = true;
  //     _isSearching = true; // Set flag to prevent multiple searches
  //   });
  //
  //   try {
  //     final cars = await CarApi.getCars(locale: context.locale);
  //     if (cars.isEmpty || cars == null) {
  //       showSnackbar(
  //         context: context,
  //         status: SnackbarStatus.error,
  //         message: LocaleKeys.pleaseSelectAllOptions.tr(),
  //       );
  //       return;
  //     }
  //
  //     // final userCarId =
  //     //     cars.firstWhereOrNull((element) => element.isDefault ?? false)?.id;
  //     final userCarId = selectedUserCar;
  //     print("userCarId1=${userCarId}");
  //     final userCar =
  //         '${cars.firstWhereOrNull((element) => element.isDefault ?? false)?.car?.model?.brand?.name} - ${cars.firstWhereOrNull((element) => element.isDefault ?? false)?.car?.model?.name} - ${cars.firstWhereOrNull((element) => element.isDefault ?? false)?.car?.year}';
  //     if (_orderDetailsController.text.isNotEmpty &&
  //         currentPosition != null &&
  //         userCarId != null) {
  //       List<Placemark> placemarks = await placemarkFromCoordinates(
  //         currentPosition?.latitude ?? 30.118617883609,
  //         currentPosition?.longitude ?? 31.303159675297,
  //       );
  //
  //       if (placemarks.isNotEmpty) {
  //         Placemark place = placemarks[0];
  //         // Format the address
  //         String address = '${place.street}, ${place.subLocality}, '
  //             '${place.locality}, ${place.postalCode}, '
  //             '${place.country}';
  //
  //         final order = await MiscellaneousApi.createEmergencyOrder(
  //           locale: context.locale,
  //           userCarId: userCarId ?? 14,
  //           description: _orderDetailsController.text,
  //           record: '', // Empty record as audio feature is removed
  //           lat: currentPosition?.latitude.toString() ?? '',
  //           long: currentPosition?.longitude.toString() ?? '',
  //           location: address.toString(),
  //         );
  //
  //         final orderId = order.data?.order?.id;
  //         final orderCost = order.data?.order?.total;
  //         if (orderId != null && mounted) {
  //           // Use Navigator.push with a then() callback to reset state when returning
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) {
  //               return EmergencyResultsScreen(
  //                 car: userCar ?? '',
  //                 orderId: orderId,
  //                 cost: orderCost.toString() ?? '300',
  //               );
  //             })
  //           ).then((_) {
  //             // Reset state when returning from results screen
  //             if (mounted) {
  //               setState(() {
  //                 _loading = false;
  //                 _isSearching = false;
  //                 // Reset other necessary state variables if needed
  //               });
  //             }
  //           });
  //         }
  //       }
  //     } else {
  //       showSnackbar(
  //         context: context,
  //         status: SnackbarStatus.error,
  //         message: LocaleKeys.pleaseSelectAllOptions.tr(),
  //       );
  //     }
  //   } catch (e) {
  //     showSnackbar(
  //       context: context,
  //       status: SnackbarStatus.error,
  //       message: e.toString(),
  //     );
  //     if (mounted) {
  //       setState(() {
  //         _loading = false;
  //         _isSearching = false;
  //       });
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _loading = false;
  //         _isSearching = false;
  //       });
  //     }
  //   }
  // }
  void startSearch() async {
    if (_isSearching) return;

    setState(() {
      _loading = true;
      _isSearching = true;
    });

    try {
      final cars = await CarApi.getCars(locale: context.locale);

      if (cars.isEmpty) {
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: LocaleKeys.pleaseSelectAllOptions.tr(),
        );
        return;
      }

      final userCarId = selectedUserCar;

      if (_orderDetailsController.text.isNotEmpty &&
          currentPosition != null &&
          userCarId != null) {

        List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition!.latitude,
          currentPosition!.longitude,
        );

        if (placemarks.isEmpty) return;

        Placemark place = placemarks[0];

        String address = '${place.street}, ${place.locality}, ${place.country}';

        final order = await MiscellaneousApi.createEmergencyOrder(
          locale: context.locale,
          userCarId: userCarId,
          description: _orderDetailsController.text,
          record: '',
          lat: currentPosition!.latitude.toString(),
          long: currentPosition!.longitude.toString(),
          location: address,
        );

        final orderId = order.data?.order?.id;

        if (orderId != null && mounted) {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => EmergencyResultsScreen(
              car: selectedCar?.model?.name ?? '',
              orderId: orderId,
              cost: order.data?.order?.total.toString() ?? '0',
            ),
          ));
        }

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
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _isSearching = false;
        });
      }
    }
  }
  _startSearchButton() {
    // Determine if the button should be enabled
    bool isEnabled = (_orderDetailsController.text.isNotEmpty &&
                    currentPosition != null) && !_isSearching;
                    
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(14.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: isEnabled ? startSearch : null, // Disable button when searching
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                  color: isEnabled
                      ? ColorsPalette.primaryColor
                      : ColorsPalette.customGrey),
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return ColorsPalette.customGrey; // Color when disabled
              }
              return ColorsPalette.primaryColor; // Default color
            },
          ),
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

  Widget detailsFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.malfunctionDetails.tr(),
            style: TextStyle(
                color: ColorsPalette.black,
                fontWeight: FontWeight.w400,
                fontFamily: ZainTextStyles.font,
                fontSize: 14.sp),
          ),
          TextInputField(
            padding: EdgeInsets.only(
                top: 11.sp, bottom: 20.sp, left: 11.sp, right: 11.sp),
            focusedBorder: OutlineInputBorder(
              borderRadius: UtilValues.borderRadius10,
              borderSide: const BorderSide(
                  color: ColorsPalette.extraDarkGrey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: UtilValues.borderRadius10,
              borderSide:
                  BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
            ),
            color: ColorsPalette.darkGrey,
            backgroundColor: ColorsPalette.white,
            controller: _orderDetailsController,
            inputType: TextInputType.name,
            name: LocaleKeys.name.tr(),
            key: const ValueKey('details'),
            hint: LocaleKeys.addressDetailsEx.tr(),
            validator: FormBuilderValidators.required(),
          ),
        ],
      ),
    );
  }

  _getCar() async {
    final List<UserCars> cars = await CarApi.getCars(locale: context.locale);
    setState(() {
      selected ??= cars
          .firstWhereOrNull((element) => element.isDefault ?? false)
          ?.car
          ?.id;
      selectedCar ??=
          cars.firstWhereOrNull((element) => element.isDefault ?? false)?.car;
      // selectedUserCar ??=
      //     cars.firstWhereOrNull((element) => element.isDefault ?? false)?.id;
      selectedUserCar ??=
          cars.firstWhereOrNull((element) => element.isDefault ?? false)?.id;
    });
  }
}
