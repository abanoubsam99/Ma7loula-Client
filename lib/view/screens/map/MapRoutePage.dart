import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math' as m;
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/my_orders_tab/order_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../controller/get_offers_provider.dart';
import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/helpers.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../core/services/http/api_endpoints.dart';
import '../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../model/order_details_model.dart';
import '../main_screen/main_screen.dart';
import '../main_screen/tabs/home_tab/car_parts/order_success_screen.dart';
import '../main_screen/tabs/my_orders_tab/local_widet/my_orders_card.dart';
class MapRoutePage extends StatefulWidget {
  final int orderNum;
  final int orderType;
  const MapRoutePage({
    Key? key,
    required this.orderNum,
    required this.orderType,
  }) : super(key: key);

  @override
  State<MapRoutePage> createState() => _MapRoutePageState();
}

class _MapRoutePageState extends State<MapRoutePage> {
  GoogleMapController? mapController;
  Position? currentLocation;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];
  bool _isLoading = true;
  Timer? _timer;
  BitmapDescriptor? customIcon;
  bool _isFirstLoad = true;
  bool _withNavigate = false;
  Future<void> _loadCustomMarker() async {
    final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(250, 250)), // adjust size if needed
     AssetsManager.carIcon,
    );
    setState(() {
      customIcon = icon;
    });
  }
  Future<void> openGoogleMapsDirections(toLat,toLon) async {
    bool serviceEnabled;
    LocationPermission permission;
    // Check location services
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: 'Location services are disabled',
      );
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: 'Location permissions are denied',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: 'Location permissions are permanently denied',
      );
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentLocation=position;
    setState(() {    });
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${position.latitude},${position.longitude}'
        '&destination=${toLat},${toLon}'
        '&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
    } else {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: 'Could not launch Google Maps',
      );
    }
  }
  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) {
          _refreshOrder();
          _isFirstLoad = false; // after first time, no full-screen loading
          setState(() {}); // re-triggers FutureBuilder
        }
      });
    });
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _refreshOrder();
        _isFirstLoad = false; // after first time, no full-screen loading
        setState(() {}); // re-triggers FutureBuilder
      }
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  // Get detailed route polyline from Google Directions API
  Future<void> _getRoutePolyline(fromLat,fromLon,fromText,toLat,toLon,toText,workerLat,workerLon) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentLocation=position;
    setState(() {
      _isLoading = true;
    });
    // Add markers for pickup and dropoff locations
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(fromLat, fromLon),
        infoWindow: InfoWindow(title: fromText),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(toLat, toLon),
        infoWindow: InfoWindow(title: toText),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    if (customIcon != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('Workers'),
          position: LatLng(double.parse(workerLat.toString()) ,double.parse(workerLon.toString()) ),
          infoWindow: const InfoWindow(title: "Workers"),
          icon: customIcon!,
        ),
      );
    }
    try {
      // Clear existing polylines
      polylineCoordinates = [];

      dev.log("🔍 Attempting to get route between locations");

      bool routeFound = false;
      PolylinePoints polylinePoints = PolylinePoints();

      // Make direct HTTP request to Google Directions API - First attempt
      try {
        const String apiKey1 = '$googleMapApiKey';

        dev.log("💡 Attempt 1: Using API key: $apiKey1 with direct HTTP request");

        final response = await http.get(
          Uri.parse('https://maps.googleapis.com/maps/api/directions/json?'
              'origin=${fromLat},${fromLon}'
              '&destination=${toLat},${toLon}'
              '&mode=driving'
              '&key=$apiKey1'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            // Get route points from the API response
            List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];

            for (var step in steps) {
              String points = step['polyline']['points'];
              polylineCoordinates.addAll(
                polylinePoints.decodePolyline(points).map(
                  (point) => LatLng(point.latitude, point.longitude)
                )
              );
            }
            dev.log("✅ Attempt 1 succeeded: Got ${polylineCoordinates.length} route points");
            routeFound = true;
          } else {
            dev.log("⚠️ Attempt 1 failed: ${data['status']}");
          }
        } else {
          dev.log("⚠️ Error fetching route data: ${response.statusCode}");
        }
      } catch (e) {
        dev.log("❌ Attempt 1 exception: $e");
      }

      // Second attempt with different API key if first attempt failed
      if (!routeFound) {
        try {
          const String apiKey2 = '$googleMapApiKey';

          dev.log("💡 Attempt 2: Using API key: $apiKey2 with direct HTTP request");

          final response = await http.get(
            Uri.parse('https://maps.googleapis.com/maps/api/directions/json?'
                'origin=${fromLat},${fromLon}'
                '&destination=${toLat},${toLon}'
                '&mode=driving'
                '&key=$apiKey2'),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['status'] == 'OK') {
              // Get route points from the API response
              List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];

              polylineCoordinates = []; // Clear any previous points
              for (var step in steps) {
                String points = step['polyline']['points'];
                polylineCoordinates.addAll(
                  polylinePoints.decodePolyline(points).map(
                    (point) => LatLng(point.latitude, point.longitude)
                  )
                );
              }
              dev.log("✅ Attempt 2 succeeded: Got ${polylineCoordinates.length} route points");
              routeFound = true;
            } else {
              dev.log("⚠️ Attempt 2 failed: ${data['status']}");
              dev.log("⚠️ IMPORTANT: Enable the Directions API in the Google Cloud Console!");
            }
          } else {
            dev.log("⚠️ Error fetching route data: ${response.statusCode}");
          }
        } catch (e) {
          dev.log("❌ Attempt 2 exception: $e");
        }
      }

      // If we still don't have a route, use direct line fallback
      if (!routeFound) {
        dev.log("⚠️ All attempts to get route failed - using direct line fallback");
        polylineCoordinates = [
          LatLng(fromLat, fromLon),
          LatLng(toLat, toLon),
        ];
      }

      // Add the polyline to the map
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: ColorsPalette.primaryColor,
            width: 5,
          ),
        );
        _isLoading = false;
      });

      // Fit map bounds to show the route
      if (mapController != null && polylineCoordinates.isNotEmpty) {
        final bounds = _getBounds(polylineCoordinates);
        mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 80.0),
        );
      }
    } catch (e) {
      dev.log('❌ Error in route calculation: $e');
      setState(() {
        // Fallback to direct line on error
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: [
              LatLng(fromLat, fromLon),
              LatLng(toLat, toLon),
            ],
            color: ColorsPalette.primaryColor,
            width: 5,
          ),
        );
        _isLoading = false;
      });
    }
  }
  // Calculate bounds to fit all polyline points
  // Calculate bounds to fit all polyline points
  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // Deprecated - now using _getBounds instead
  void _zoomToBounds() {
    if (polylineCoordinates.isEmpty || mapController == null) {
      return;
    }

    final bounds = _getBounds(polylineCoordinates);
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  int _getDisInKilo(distanceInMeters) {
    final dis = (int.tryParse(distanceInMeters) ?? 0)/1000;
    return dis.toInt();
  }

  /// Refresh order details from API
  Future<void> _refreshOrder() async {
    try {
      final orderDetails = (widget.orderType == 0)
          ? await MiscellaneousApi.getBatteryOrderDetails(locale: context.locale, id: widget.orderNum)
          : (widget.orderType == 1)
          ? await MiscellaneousApi.getTiresOrderDetails(locale: context.locale, id: widget.orderNum)
          : (widget.orderType == 2)
          ? await MiscellaneousApi.getCarPartsOrderDetails(locale: context.locale, id: widget.orderNum)
          : (widget.orderType == 3)
          ? await MiscellaneousApi.getWinchDetails(locale: context.locale, id: widget.orderNum)
          : await MiscellaneousApi.getEmergencyDetails(locale: context.locale, id: widget.orderNum);

      final order = orderDetails.data?.order;
      if (order == null) return;

      await _getRoutePolyline(
        order.fromLat,
        num.parse(order.fromLon ?? "0"),
        order.fromText,
        num.parse(order.toLat ?? "0"),
        num.parse(order.toLon ?? "0"),
        order.toText,
        order.worker?.lat,
        order.worker?.lon,
      );

      setState(() {});
    } catch (e) {
      dev.log("❌ Error refreshing order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(
        title: '${LocaleKeys.orderNumber.tr()} ${widget.orderNum}',
        backButton: InkWell(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(index: 0,)),);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Helpers.isArabic(context)
                  ? SvgPicture.asset(
                AssetsManager.angleLeft,
                fit: BoxFit.scaleDown,
                width: 16.sp,
              )
                  : Transform(
                  transform: Matrix4.rotationY(180 * 3.1415927 / 180),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AssetsManager.angleLeft,
                    fit: BoxFit.scaleDown,
                    width: 16.sp,
                  )),
            )),
      ),
      backgroundColor: Colors.white,
      body: _allWidget(),);
  }
  Widget _allWidget() {
    return FutureBuilder<OrderRateModel>(
        future: (widget.orderType == 0) ?
        MiscellaneousApi.getBatteryOrderDetails( locale: context.locale, id: widget.orderNum)
            : (widget.orderType == 1) ?
        MiscellaneousApi.getTiresOrderDetails( locale: context.locale, id: widget.orderNum)
            : (widget.orderType == 2) ?
        MiscellaneousApi.getCarPartsOrderDetails( locale: context.locale, id: widget.orderNum)
            : (widget.orderType == 3) ?
        MiscellaneousApi.getWinchDetails( locale: context.locale, id: widget.orderNum)
            :
        MiscellaneousApi.getEmergencyDetails( locale: context.locale, id: widget.orderNum),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting && _isFirstLoad) {
            return Center(
              child: CircularProgressIndicator(
                color: ColorsPalette.primaryColor,
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text("Something went wrong: ${snapshot.error}"),
            );
          }

          // No data state
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }

          final orderDetails = snapshot.data!;
          final order = orderDetails.data?.order;

          // No order inside response
          if (order == null) {
            return Center(
              child: Text("No order details found"),
            );
          }

          // Safe parsing for coordinates
          final fromLat = double.tryParse(order.fromLat?.toString() ?? "0") ?? 0;
          final fromLon = double.tryParse(order.fromLon?.toString() ?? "0") ?? 0;
          final toLat = double.tryParse(order.toLat?.toString() ?? "0") ?? 0;
          final toLon = double.tryParse(order.toLon?.toString() ?? "0") ?? 0;

          // Route polyline (safe values)
          _getRoutePolyline(fromLat, fromLon, order.fromText, toLat, toLon, order.toText, order.worker?.lat, order.worker?.lon,);

          // Status color
          final color = _getColors(order.status);

          final double height = MediaQuery.of(context).size.height;
          final double width = MediaQuery.of(context).size.width;

            if ((order?.status == OrderStatus.ORDER_COMPELETED ||order?.status == "completed" ||
                order?.status == OrderStatus.ORDER_CANCELLED)&&_withNavigate==false) {
              _withNavigate=true;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderSuccessScreen(
                orderNumber: order?.id??0,       // <-- order is null here
                selectedDate: order?.fromText,
                total: order?.total,
                status: order?.status,
                myOrdersIndex: 3,
              )),);
          }
          if(_isFirstLoad==true)
          _getRoutePolyline(order?.fromLat,num.parse(order?.fromLon),order?.fromText,num.parse(order?.toLat) ,num.parse(order?.toLon),order?.toText,order?.worker?.lat,order?.worker?.lon);
          _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
            if (mounted) {
              _isFirstLoad = false; // after first time, no full-screen loading
              (widget.orderType == 0)
                  ? MiscellaneousApi.getBatteryOrderDetails(
                  locale: context.locale, id: widget.orderNum)
                  : (widget.orderType == 1)
                  ? MiscellaneousApi.getTiresOrderDetails(
                  locale: context.locale, id: widget.orderNum)
                  : (widget.orderType == 2)
                  ? MiscellaneousApi.getCarPartsOrderDetails(
                  locale: context.locale, id: widget.orderNum)
                  : (widget.orderType == 3)
                  ? MiscellaneousApi.getWinchDetails(
                  locale: context.locale, id: widget.orderNum)
                  : MiscellaneousApi.getEmergencyDetails(
                  locale: context.locale, id: widget.orderNum);
            }
          });


          return Stack(
            children: [
              // Map fills the whole screen
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    order?.worker?.lat !=null?double.parse("${order?.worker?.lat}") : ( (num.parse(order?.fromLat ?? "0") + num.parse(order?.toLat ?? "0")) / 2 ),
                    order?.worker?.lon !=null?  double.parse("${order?.worker?.lon}") :( (num.parse(order?.fromLon ?? "0") + num.parse(order?.toLon ?? "0")) / 2 ),
                  ),
                  zoom: 13,
                ),
                markers: _markers,
                polylines: _polylines,
                zoomControlsEnabled: true,
                myLocationEnabled: false,
                compassEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  // Call _zoomToBounds to fit the map to the route if route points exist
                  if (polylineCoordinates.isNotEmpty) {
                    _zoomToBounds();
                  }
                },
              ),

              // Loading indicator overlay - shown while calculating route
              if (_isLoading&&_isFirstLoad)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: ColorsPalette.primaryColor),
                        const SizedBox(height: 16),
                        Text(
                          'جاري حساب المسار...',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom info panel
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: height * .41,
                  color: ColorsPalette.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    children: [
                      // Vendor name and car info
                      Row(
                        children: [
                          Text(
                            "${order?.vendor?.name}",
                            style: TextStyle(
                              color: ColorsPalette.customGrey,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "${order?.worker?.name}",
                            style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      UtilValues.gap8,

                      //  servicesPrice
                      Row(crossAxisAlignment: CrossAxisAlignment.start ,mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${order?.worker?.name??""}',
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: ZainTextStyles.font),
                          ),
                          Spacer(),
                          Text(
                            '${Helpers.formatPrice(order?.total!)}${LocaleKeys.le.tr()}',
                            style: TextStyle(
                                color: ColorsPalette.black,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: ZainTextStyles.font),
                          ),
                        ],
                      ),
                      UtilValues.gap8,
                      // Vendor number and time/distance
                      Row(
                        children: [
                          Text(
                            order?.worker?.phone??"",
                            style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '${order?.durationInMinutes} ${LocaleKeys.min.tr()} - ${_getDisInKilo(order?.distanceInMeters)} ${LocaleKeys.kilo.tr()} ',
                            style: TextStyle(
                              color: ColorsPalette.customGrey,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                      UtilValues.gap8,
                      // From location
                      Row(
                        children: [
                          SvgPicture.asset(
                            AssetsManager.location,
                            color: ColorsPalette.primaryColor,
                            height: 15,
                          ),
                          UtilValues.gap4,
                          Text(
                            LocaleKeys.from.tr(),
                            style: TextStyle(
                              color: ColorsPalette.customGrey,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 12.sp,
                            ),
                          ),
                          UtilValues.gap4,
                          Expanded(
                            child: Text(
                              "${order?.fromText}",
                              style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w600,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 12.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      UtilValues.gap8,

                      // To location
                      Row(
                        children: [
                          SvgPicture.asset(
                            AssetsManager.flag,
                            color: ColorsPalette.primaryColor,
                          ),
                          UtilValues.gap4,
                          Text(
                            LocaleKeys.to.tr(),
                            style: TextStyle(
                              color: ColorsPalette.customGrey,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 12.sp,
                            ),
                          ),
                          UtilValues.gap4,
                          Expanded(
                            child: Text(
                              "${order?.toText}",
                              style: TextStyle(
                                color: ColorsPalette.black,
                                fontWeight: FontWeight.w600,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 12.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      UtilValues.gap12,
                      // Action buttons
                      if(order?.status!=OrderStatus.ORDER_COMPELETED&&order?.status!=OrderStatus.ORDER_CANCELLED)
                  SizedBox(
                    height: 43,
                    child: Row(children: [
                      Expanded(
                        child: SimplePrimaryButton(
                          borderRadius: BorderRadius.circular(5),
                          label:LocaleKeys.callVendor.tr(),
                          onPressed: (){
                            _callCustomer(order?.worker?.phone ?? "");
                          },
                        ),
                      ),
                      UtilValues.gap8,
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorsPalette.black),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: SimplePrimaryButton(
                            borderRadius: BorderRadius.circular(5),
                            label:LocaleKeys.reject.tr(),
                            backgroundColor:  ColorsPalette.white,
                            labelColor: ColorsPalette.black,
                            // onPressed: (){context.watch<GetWinchOffersProvider>().listRequests.data?.acceptedOffer != null ?_callCustomer(context.watch<GetWinchOffersProvider>().listRequests.data?.acceptedOffer?.user?.phone??""):cancelOrder();
                            // },
                            onPressed:cancelOrder,
                          ),
                        ),
                      ),
                    ]),
                  ),
                      SizedBox(height: 10,),
                      if(order?.status!=OrderStatus.ORDER_COMPELETED&&order?.status!=OrderStatus.ORDER_CANCELLED)
                        SimplePrimaryButton(
                        label: LocaleKeys.OpeningGoogleMaps.tr(),
                        onPressed:(){
                          openGoogleMapsDirections(order?.worker?.lat,order?.worker?.lon);
                        },
                      ),
                      // SizedBox(height: 10,),
                      SimplePrimaryButton(
                        label: LocaleKeys.home.tr(),
                        onPressed:(){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(index: 0,)),);
                          },
                      ),
                      SizedBox(height: 10,),
                      if(order?.status==OrderStatus.ORDER_COMPELETED||order?.status=="completed")
                        Text("${LocaleKeys.delivered.tr()}",style: TextStyle(color: color),),
                      if(order?.status==OrderStatus.ORDER_CANCELLED)
                        Text("${LocaleKeys.canceled.tr()}",style: TextStyle(color: color),),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _callCustomer(String vendorNum) async {
    await launchUrlString("tel://$vendorNum");
  }
  void cancelOrder() async {
    try {
      if (widget.orderType == 0) {
        await MiscellaneousApi.cancelBatteryOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.cancelBatteryOrder(
            locale: context.locale, id: widget.orderNum);
      } else if (widget.orderType == 1) {
        await MiscellaneousApi.cancelTiresOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.getTiresOrderDetails(
            locale: context.locale, id: widget.orderNum);
      } else if (widget.orderType == 2) {
        await MiscellaneousApi.cancelCarPartsOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.getCarPartsOrderDetails(
            locale: context.locale, id: widget.orderNum);
      } else if (widget.orderType == 3) {
        await MiscellaneousApi.cancelWinchOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.getWinchDetails(
            locale: context.locale, id: widget.orderNum);
      } else {
        await MiscellaneousApi.cancelEmergencyOrder(
            id: widget.orderNum, locale: context.locale);
        await MiscellaneousApi.getEmergencyDetails(
            locale: context.locale, id: widget.orderNum);
      }
      setState(() {});
      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: LocaleKeys.done.tr(),
      );
      // Navigator.pop(context);
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
    }
  }

  // void acceptOrder() async {
  //   try {
  //     await MiscellaneousApi.sentWinchOffer(
  //         locale: context.locale, orderId: widget.orderNum);
  //
  //     showSnackbar(
  //       context: context,
  //       status: SnackbarStatus.success,
  //       message: LocaleKeys.done.tr(),
  //     );
  //     // Navigator.pop(context);
  //   } catch (e) {
  //     showSnackbar(
  //       context: context,
  //       status: SnackbarStatus.error,
  //       message: e.toString(),
  //     );
  //   }
  // }
  // void updateOrder() async {
  //   try {
  //     await MiscellaneousApi.updateOrderStatusWinch(
  //         locale: context.locale, orderId: widget.orderNum);
  //
  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
  //       return OrderDetails(
  //         orderNum: widget.orderNum,
  //         orderType: categorySelected,
  //         //
  //         // vendorName: widget.vendorName,
  //         // vendorNum: widget.vendorNum,
  //       );
  //     }));
  //     showSnackbar(
  //       context: context,
  //       status: SnackbarStatus.success,
  //       message: LocaleKeys.done.tr(),
  //     );
  //     // Navigator.pop(context);
  //   } catch (e) {
  //     showSnackbar(
  //       context: context,
  //       status: SnackbarStatus.error,
  //       message: e.toString(),
  //     );
  //   }
  // }
  Color _getColors(String? status) {
    switch (status) {
      case OrderStatus.ORDER_CANCELLED:
        return ColorsPalette.red;
      case OrderStatus.ORDER_ON_THE_RUN:
        return ColorsPalette.yellow;
      case OrderStatus.ORDER_DELIVERED:
      case OrderStatus.ORDER_COMPELETED:
        return ColorsPalette.lightGreen;

      case OrderStatus.ORDER_PREPARING:
      case OrderStatus.ORDER_NEW:
        return ColorsPalette.lightBlue;

      default:
        return ColorsPalette.lightpre;
    }
  }

}
