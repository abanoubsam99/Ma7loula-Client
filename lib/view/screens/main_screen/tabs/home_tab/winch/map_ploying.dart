import 'dart:async';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/winch/searchPlaces.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/services/http/api_endpoints.dart';
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
import 'winchResultsOffers.dart';

class MapPolylineScreen extends StatefulWidget {
  @override
  _MapPolylineScreenState createState() => _MapPolylineScreenState();
}

class _MapPolylineScreenState extends State<MapPolylineScreen> {
  final _myLocController = TextEditingController();
  final _distinationController = TextEditingController();
  int? selected;
  int? selectedUserCar;
  Car? selectedCar;
  GoogleMapController? mapController;
  Position? currentPosition;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? pickupLocation;
  LatLng? dropoffLocation;
  Marker? carMarker;
  Timer? _timer;
  int _markerIndex = 0;
  List<LatLng> polylineCoordinates = [];
  BitmapDescriptor? carIcon;

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
    // setState(() {
    //   currentPosition = position;
    //   _updateCamera();
    // });
    setState(() {
      currentPosition = position;
      // Add current location marker
      LatLng searchedLocation = LatLng(position.latitude, position.longitude);
      pickupLocation = searchedLocation;
      _myLocController.text="Current Location".tr();
      markers.add(
        Marker(
          markerId: MarkerId('pickup'),
          position: searchedLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'نقطة الانطلاق'),
        ),
      );
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
    _getCurrentLocation(context);
    _createCarIcon();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // إنشاء أيقونة السيارة
  Future<void> _createCarIcon() async {
    final ByteData byteData = await rootBundle.load(AssetsManager.carIcon);
    final ui.Codec codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: 80,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final data = await fi.image.toByteData(format: ui.ImageByteFormat.png);

    if (data != null) {
      setState(() {
        carIcon = BitmapDescriptor.fromBytes(data.buffer.asUint8List());
      });
    }
  }

  // تحريك السيارة على المسار
  void _animateMarker() {
    if (polylineCoordinates.isEmpty) return;

    _timer?.cancel();
    const duration = Duration(milliseconds: 100);
    _timer = Timer.periodic(duration, (timer) {
      if (_markerIndex < polylineCoordinates.length - 1) {
        setState(() {
          _markerIndex++;
          carMarker = Marker(
            markerId: MarkerId('car'),
            position: polylineCoordinates[_markerIndex],
            icon: carIcon ?? BitmapDescriptor.defaultMarker,
            rotation: _getMarkerRotation(
              polylineCoordinates[_markerIndex - 1],
              polylineCoordinates[_markerIndex],
            ),
          );
          markers.add(carMarker!);
        });
      } else {
        timer.cancel();
      }
    });
  }

  // حساب زاوية دوران السيارة
  double _getMarkerRotation(LatLng start, LatLng end) {
    double bearing = Geolocator.bearingBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    return bearing;
  }

  // أضف هذه الدالة كحل بديل إذا استمرت المشكلة
  void _addDirectPolyline() {
    if (pickupLocation == null || dropoffLocation == null) return;

    setState(() {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('direct_route'),
          color: Colors.blue,
          points: [
            pickupLocation!,
            dropoffLocation!,
          ],
          width: 5,
          patterns: [
            PatternItem.dash(20),
            PatternItem.gap(10),
          ],
        ),
      );
    });
  }

  Future<void> _getPolyline() async {
    if (pickupLocation == null || dropoffLocation == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      '$googleMapApiKey',
      PointLatLng(pickupLocation!.latitude, pickupLocation!.longitude),
      PointLatLng(dropoffLocation!.latitude, dropoffLocation!.longitude),
      travelMode: TravelMode.driving,
      optimizeWaypoints: true,
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        polylines.clear();
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
            patterns: [
              PatternItem.dash(20),
              PatternItem.gap(10),
            ],
          ),
        );

        // تحديث موقع السيارة للبداية
        if (carIcon != null) {
          carMarker = Marker(
            markerId: const MarkerId('car'),
            position: polylineCoordinates.first,
            icon: carIcon!,
            rotation: _getMarkerRotation(
              polylineCoordinates.first,
              polylineCoordinates[1],
            ),
          );
          markers.add(carMarker!);
        }
      });

      // تحريك الكاميرا لتظهر المسار كاملاً
      LatLngBounds bounds = _getBounds(polylineCoordinates);
      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );

      // بدء تحريك السيارة
      _animateMarker();
    }
  }

// أضف هذه الدالة المساعدة لحساب حدود الخريطة
  LatLngBounds _getBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (LatLng point in points) {
      if (minLat == null || point.latitude < minLat) minLat = point.latitude;
      if (maxLat == null || point.latitude > maxLat) maxLat = point.latitude;
      if (minLng == null || point.longitude < minLng) minLng = point.longitude;
      if (maxLng == null || point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  Future<void> searchPlace(String query,bool? isSource, {LatLng? locationOnMap}) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        LatLng searchedLocation = LatLng(
          locationOnMap!=null?locationOnMap.latitude:locations.first.latitude,
          locationOnMap!=null?locationOnMap.longitude:locations.first.longitude,
        );
        // setState(() {
        //   if(isSource==true)
        //     pickupLocation=null;
        // });
        setState(() {
          if (isSource==true) {
          // if (pickupLocation ==null&&isSource==true) {
            print("I am in نقطة الانطلاق");
            pickupLocation = searchedLocation;
            markers.add(
              Marker(
                markerId: MarkerId('pickup'),
                position: searchedLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
                infoWindow: InfoWindow(title: 'نقطة الانطلاق'),
              ),
            );
            if(dropoffLocation!=null)
            _getPolyline(); // استخدم هذه بدلاً من _getPolyline()
          } else if (isSource==false){
            print("I am in نقطة الوصول");
            dropoffLocation = searchedLocation;
            markers.add(
              Marker(
                markerId: MarkerId('dropoff'),
                position: searchedLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
                infoWindow: InfoWindow(title: 'نقطة الوصول'),
              ),
            );
            // _addDirectPolyline();
            _getPolyline(); // استخدم هذه بدلاً من _getPolyline()
          }else {
            print("I am in else");
          }
        });

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(searchedLocation, 15),
        );

        // حساب المسافة والوقت إذا تم تحديد نقطتين
        if (pickupLocation != null && dropoffLocation != null) {
          _calculateDistanceAndTime();
        }
      }
    } catch (e) {
      print("Error searching for place: $e");
    }
  }

  num price = 0;

  num distanceInKm = 0;
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

      if (cars.isEmpty || cars == null || selected == null) {
        return showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: LocaleKeys.pleaseSelectAllOptions.tr(),
        );
      }

      final userCarId =
          cars.firstWhereOrNull((element) => element.isDefault ?? false)?.id;

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
        title: LocaleKeys.requestWinch.tr(),
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
              polylines: polylines,
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
                              fontSize: 14.sp,
                            ),
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
                                    fontSize: 14.sp,
                                  ),
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
                                  height: 100,
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
                    UtilValues.gap8,
                    myLocationFormField(),
                    UtilValues.gap8,
                    disFormField(),
                    UtilValues.gap8,
                    if (distanceInKm != 0.0 && timeInMinutes != 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Text(
                              '$timeInMinutes ${LocaleKeys.timeBetweenLocs.tr()}',
                              style: TextStyle(
                                color: ColorsPalette.customGrey,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${distanceInKm} ${LocaleKeys.disBetweenLocs.tr()}',
                              style: TextStyle(
                                color: ColorsPalette.customGrey,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    UtilValues.gap8,
                    if (distanceInKm != 0.0 &&
                        timeInMinutes != 0 &&
                        selectedUserCar != null)
                      Container(
                        decoration: BoxDecoration(
                            color: ColorsPalette.grey,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Text(
                              LocaleKeys.priceAW.tr(),
                              style: TextStyle(
                                color: ColorsPalette.customGrey,
                                fontWeight: FontWeight.w400,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${price != 0 ? price : ''} ${LocaleKeys.le.tr()}',
                              style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w600,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  bool _loading = false;
  void startSearch() async {
    try {
      final cars = await CarApi.getCars(locale: context.locale);

      if (cars.isEmpty || cars == null || selected == null) {
        return showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: LocaleKeys.pleaseSelectAllOptions.tr(),
        );
      }

      final userCarId =
          cars.firstWhereOrNull((element) => element.isDefault ?? false)?.id;

      // Calculate price according to requirements
// final double distanceInKm = distanceInMater / 1000.0;
// int calculatedPrice;
// if (distanceInKm <= 10) {
//   calculatedPrice = 350;
// } else {
//   calculatedPrice = (distanceInKm * 35).ceil();
// }

final order = await MiscellaneousApi.createWinchOrder(
          locale: context.locale,
          distance: distanceInMater,
          fromLat: pickupLocation!.latitude,
          fromLon: pickupLocation!.longitude,
          toLat: dropoffLocation!.latitude,
          toLon: dropoffLocation!.longitude,
          duration: timeInMinutes,
          userCarId: userCarId ?? 14,
          price: price,
          fromText: _myLocController.text,
          toText: _distinationController.text);
      final orderId = order.data?.order?.id;
      if (orderId != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return WinchResultsScreen(
            orderId: orderId,
            fromText: _myLocController.text,
            toText: _distinationController.text,
            cost: price.toString(),
          );
        }));
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

  _startSearchButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(14.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed:
            (distanceInKm != 0.0 && timeInMinutes != 0) ? startSearch : () {},
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                  color: (distanceInKm != 0.0 && timeInMinutes != 0)
                      ? ColorsPalette.primaryColor
                      : ColorsPalette.customGrey),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
              (distanceInKm != 0.0 && timeInMinutes != 0)
                  ? ColorsPalette.primaryColor
                  : ColorsPalette.customGrey),
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
                    fontSize: 14.sp,
                  ),
                ),
        ),
      ),
    );
  }

  Widget myLocationFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextInputField(
        padding: EdgeInsets.all(11.sp),
        focusedBorder: OutlineInputBorder(
          borderRadius: UtilValues.borderRadius10,
          borderSide:
              const BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: UtilValues.borderRadius10,
          borderSide: BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
        ),
        color: ColorsPalette.darkGrey,
        backgroundColor: ColorsPalette.white,
        controller: _myLocController,
        inputType: TextInputType.name,
        key: const ValueKey('myLocation'),
        hint: LocaleKeys.searchYourCurrentLoc.tr(),
        validator: FormBuilderValidators.required(),
        name: 'myLocation',
        readOnly: true,
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceSearchScreen(
                isSource: true,
                myLocController: _myLocController,
                disController: _distinationController,
              ),
            ),
          );
          if (result != null) {
            print("myLocation result = $result");
            if (result is LatLng) {
              // هنا لازم تحول الـ LatLng إلى اسم مكان باستخدام reverse geocoding
              String placeName = await getPlaceNameFromCoordinates(result.latitude, result.longitude);
              await searchPlace(placeName, true,locationOnMap: result);
            } else {
              await searchPlace(result.description ?? "", true);
            }
          }
        },
        prefixIcon: SvgPicture.asset(
          AssetsManager.location,
          color: ColorsPalette.grey,
          fit: BoxFit.scaleDown,
          width: 1,
          height: 1,
        ),
      ),
    );
  }

  Widget disFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextInputField(
        padding: EdgeInsets.all(11.sp),
        focusedBorder: OutlineInputBorder(
          borderRadius: UtilValues.borderRadius10,
          borderSide:
              const BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: UtilValues.borderRadius10,
          borderSide: BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
        ),
        color: ColorsPalette.darkGrey,
        backgroundColor: ColorsPalette.white,
        controller: _distinationController,
        inputType: TextInputType.name,
        key: const ValueKey('dis'),
        hint: LocaleKeys.searchYourDis.tr(),
        validator: FormBuilderValidators.required(),
        name: 'dis',
        readOnly: true, // جعل الحقل للقراءة فقط
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceSearchScreen(
                isSource: false,
                myLocController: _myLocController,
                disController: _distinationController,
              ),
            ),
          );
          if (result != null) {
            print("dis Location result = $result");
            if (result is LatLng) {
              // هنا لازم تحول الـ LatLng إلى اسم مكان باستخدام reverse geocoding
              String placeName = await getPlaceNameFromCoordinates(result.latitude, result.longitude);
              await searchPlace(placeName, false,locationOnMap: result);
            } else {
              await searchPlace(result.description!,false);
            }
          }
        },
        prefixIcon: SvgPicture.asset(
          AssetsManager.flag,
          color: ColorsPalette.grey,
          fit: BoxFit.scaleDown,
          width: 1,
          height: 1,
        ),
      ),
    );
  }

  // Future<List<UserCars>> _getca() async {
  //   final List<UserCars> cars = await CarApi.getCars(locale: context.locale);
  //   return cars;
  // }
  //
  // int? _getUSerID() {
  //   final cars = _getca();
  //   final id =
  //       cars.firstWhereOrNull((element) => element.isDefault ?? false)?.id;
  //   return id;
  // }

  _getCar() async {
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
  }
  Future<String> getPlaceNameFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.name}, ${place.locality}, ${place.country}";
      } else {
        return "$lat, $lng"; // fallback لو مفيش نتائج
      }
    } catch (e) {
      print("Reverse geocoding error: $e");
      return "$lat, $lng";
    }
  }
}