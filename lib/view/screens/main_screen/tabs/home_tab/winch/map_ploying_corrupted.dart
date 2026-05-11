// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer' as dev;
// import 'dart:math';
// import 'dart:ui' as ui;
//
// import 'package:http/http.dart' as http;
//
// import 'package:collection/collection.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
// import 'package:ma7lola/core/utils/colors_palette.dart';
// import 'package:ma7lola/model/addresses_model.dart';
// import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/winch/address_selection.dart';
// import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/winch/map_pick_location.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../../../core/generated/locale_keys.g.dart';
// import '../../../../../../core/services/http/apis/car_api.dart';
// import '../../../../../../core/utils/assets_manager.dart';
// import '../../../../../../core/utils/font.dart';
// import '../../../../../../core/utils/snackbars.dart';
// import '../../../../../../core/utils/util_values.dart';
// import '../../../../../../core/widgets/app_snack_bar.dart';
// import '../../../../../../core/widgets/custom_app_bar.dart';
// import '../../../../../../core/widgets/custom_card.dart';
// import '../../../../../../core/widgets/custom_future_builder.dart';
// import '../../../../../../core/widgets/form_widgets/text_input_field.dart';
// import '../../../../../../core/widgets/horizontal_list_view.dart';
// import '../../../../../../core/widgets/loading_widget.dart';
// import '../../../../../../model/car_model.dart';
// import '../../../../addresses_book_screen/local_widgets/address_card.dart';
// import '../../../../auth/YourCarDetails.dart';
// import 'map_helper.dart';
// import 'winchResultsOffers.dart';
//
// class MapPolylineScreen extends StatefulWidget {
//   @override
//   _MapPolylineScreenState createState() => _MapPolylineScreenState();
// }
//
// class _MapPolylineScreenState extends State<MapPolylineScreen> {
//   bool _isGettingLocation = false;
//   final _myLocController = TextEditingController();
//   final _distinationController = TextEditingController();
//   int? selected;
//   int? selectedUserCar;
//   Car? selectedCar;
//   GoogleMapController? mapController;
//   Position? currentPosition;
//   Set<Marker> markers = {};
//   Set<Polyline> polylines = {};
//   LatLng? pickupLocation;
//   LatLng? dropoffLocation;
//   Marker? carMarker;
//   Timer? _timer;
//   int _markerIndex = 0;
//   List<LatLng> polylineCoordinates = [];
//   BitmapDescriptor? carIcon;
//   double distanceInKm = 0.0;
//   int timeInMinutes = 0;
//   bool _loading = false;
//   bool _isSearching = false; // Flag to prevent multiple searches
//
//   // For address selection
//   int? selectedSourceAddressId;
//   int? selectedDestinationAddressId;
//   List<Addresses>? savedAddresses;
//
//   static const CameraPosition initialPosition = CameraPosition(
//     target: LatLng(30.0444, 31.2357),
//     zoom: 14.0,
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermission();
//     _createCarIcon();
//     _getCar();
//     // Load saved addresses immediately on screen open
//     _loadSavedAddresses();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _myLocController.dispose();
//     _distinationController.dispose();
//     mapController?.dispose();
//     super.dispose();
//   }
//
//   // Load saved addresses from API
//   Future<void> _loadSavedAddresses() async {
//     try {
//       if (mounted) setState(() {
//         // Set loading state if needed
//       });
//
//       final addressesResult = await MiscellaneousApi.getAddresses(locale: context.locale);
//
//       if (mounted) {
//         if (mounted) setState(() {
//           savedAddresses = addressesResult.data?.addresses;
//
//           // If there are no addresses, we'll still show an empty state in the UI
//           if (savedAddresses == null || savedAddresses!.isEmpty) {
//             print('No saved addresses found');
//           } else {
//             print('Loaded ${savedAddresses!.length} saved addresses');
//           }
//         });
//       }
//     } catch (error) {
//       if (mounted) {
//         print('Error loading addresses: $error');
//         // Don't show an error to the user, just let them use the map selection
//       }
//     }
//   }
//
//   void _updateCamera() {
//     if (currentPosition != null && mapController != null) {
//       mapController!.animateCamera(
//         CameraUpdate.newLatLng(
//           LatLng(currentPosition!.latitude, currentPosition!.longitude),
//         ),
//       );
//     }
//   }
//
//   Future<void> _requestLocationPermission() async {
//     LocationPermission permission = await Geolocator.requestPermission();
//
//     if (permission == LocationPermission.always ||
//         permission == LocationPermission.whileInUse) {
//       Position position = await Geolocator.getCurrentPosition();
//       if (mounted) setState(() {
//         currentPosition = position;
//       });
//     }
//   }
//
//   Future<void> _requestPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       showSnackbar(
//         context: context,
//         status: SnackbarStatus.error,
//         message: LocaleKeys.locationServicesDisabled.tr(),
//       );
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         showSnackbar(
//           context: context,
//           status: SnackbarStatus.error,
//           message: LocaleKeys.locationPermissionDenied.tr(),
//         );
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       showSnackbar(
//         context: context,
//         status: SnackbarStatus.error,
//         message: LocaleKeys.locationPermissionPermanentlyDenied.tr(),
//       );
//       return;
//     }
//
//     // Location permissions are granted, get current location
//     await _getCurrentLocation(context);
//   }
//
//   Future<Position> _getCurrentLocation(context) async {
//     // Default position to return in case of errors
//     final Position defaultPosition = Position(
//       longitude: 30.0444,
//       latitude: 31.2357,
//       timestamp: DateTime.now(),
//       accuracy: 0,
//       altitude: 0,
//       heading: 0,
//       speed: 0,
//       speedAccuracy: 0,
//       altitudeAccuracy: 0,
//       headingAccuracy: 0
//     );
//
//     // Check if the widget is mounted before continuing
//     if (!mounted) {
//       return defaultPosition;
//     }
//
//     // Prevent concurrent location requests
//     if (_isGettingLocation) {
//       return defaultPosition;
//     }
//
//     _isGettingLocation = true;
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       if (mounted) {
//         setState(() {
//           currentPosition = position;
//           // Add marker for current position
//           markers.add(
//             Marker(
//               markerId: const MarkerId('currentLocation'),
//               position: LatLng(position.latitude, position.longitude),
//               infoWindow: InfoWindow(
//                 title: 'Your Location',
//                 snippet: '${position.latitude}, ${position.longitude}',
//               ),
//             ),
//           );
//         });
//       }
//
//       // Set camera position to current location
//       if (mapController != null) {
//         mapController!.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(
//               target: LatLng(position.latitude, position.longitude),
//               zoom: 15.0,
//             ),
//           ),
//         );
//       }
//       _isGettingLocation = false;
//       return position;
//     } catch (e) {
//       dev.log('Error getting location: $e');
//       _isGettingLocation = false;
//       return defaultPosition;
//     }
//   }
//
//   Future<void> _createCarIcon() async {
//     try {
//       final ByteData byteData = await rootBundle.load(AssetsManager.carIcon);
//       final ui.Codec codec = await ui.instantiateImageCodec(
//         byteData.buffer.asUint8List(),
//         targetWidth: 70,
//       );
//       final ui.FrameInfo frameInfo = await codec.getNextFrame();
//       final ByteData? data = await frameInfo.image.toByteData(
//         format: ui.ImageByteFormat.png,
//       );
//
//       if (data != null) {
//         final Uint8List uint8List = data.buffer.asUint8List();
//         if (mounted) setState(() {
//           carIcon = BitmapDescriptor.fromBytes(uint8List);
//         });
//       }
//     } catch (e) {
//       print('Error creating car icon: $e');
//     }
//   }
//
//   void _animateMarker() {
//     if (_markerIndex < polylineCoordinates.length - 1) {
//       _markerIndex++;
//       if (mounted) setState(() {
//         markers.removeWhere(
//             (marker) => marker.markerId == const MarkerId('car_marker'));
//         markers.add(
//           Marker(
//             markerId: const MarkerId('car_marker'),
//             position: polylineCoordinates[_markerIndex],
//             icon: carIcon ?? BitmapDescriptor.defaultMarker,
//             rotation: _getMarkerRotation(
//                 polylineCoordinates[_markerIndex - 1],
//                 polylineCoordinates[_markerIndex]),
//           ),
//         );
//       });
//     } else {
//       _timer?.cancel();
//     }
//   }
//
//   double _getMarkerRotation(LatLng start, LatLng end) {
//     final double startLat = start.latitude;
//     final double startLng = start.longitude;
//     final double endLat = end.latitude;
//     final double endLng = end.longitude;
//
//     final double dx = endLng - startLng;
//     final double dy = endLat - startLat;
//
//     return 90 - (180 / 3.14159) * (dx != 0 ? atan2(dy, dx) : 0);
//   }
//
//   void _addDirectPolyline() {
//     if (mounted) setState(() {
//       polylines.add(
//         Polyline(
//           polylineId: const PolylineId('direct_polyline'),
//           points: [
//             LatLng(
//               pickupLocation!.latitude,
//               pickupLocation!.longitude,
//             ),
//             LatLng(
//               dropoffLocation!.latitude,
//               dropoffLocation!.longitude,
//             ),
//           ],
//           color: ColorsPalette.primaryColor,
//           width: 5,
//         ),
//       );
//     });
//   }
//
//   Future<void> _getPolyline() async {
//     if (pickupLocation == null || dropoffLocation == null) {
//       return;
//     }
//
//     if (mounted) setState(() {
//       polylineCoordinates.clear();
//       polylines.clear();
//       markers.clear();
//     });
//
//     try {
//       // Add markers for pickup and dropoff locations
//       markers.add(
//         Marker(
//           markerId: const MarkerId('pickup'),
//           position: pickupLocation!,
//           infoWindow: InfoWindow(
//             title: 'Pickup',
//             snippet: _myLocController.text,
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         ),
//       );
//
//       markers.add(
//         Marker(
//           markerId: const MarkerId('dropoff'),
//           position: dropoffLocation!,
//           infoWindow: InfoWindow(
//             title: 'Dropoff',
//             snippet: _distinationController.text,
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       );
//
//       // Get route between points using Google's Directions API directly for more accurate distance
//       final directionsUrl = Uri.parse(
//         'https://maps.googleapis.com/maps/api/directions/json?origin=${pickupLocation!.latitude},${pickupLocation!.longitude}'
//         '&destination=${dropoffLocation!.latitude},${dropoffLocation!.longitude}'
//         '&mode=driving'
//         '&key=AIzaSyDa8jLzBYCRX1ZmZ3b16Jj5FrNXV2QiTOA'
//       );
//
//       try {
//         final http.Response directionsResponse = await http.get(directionsUrl);
//         if (directionsResponse.statusCode == 200) {
//           final directionsData = json.decode(directionsResponse.body);
//
//           if (directionsData['status'] == 'OK') {
//             // Extract distance and duration from the API response
//             final routes = directionsData['routes'];
//             if (routes.isNotEmpty) {
//               final legs = routes[0]['legs'];
//               if (legs.isNotEmpty) {
//                 // Get real distance in meters from Google's calculation
//                 final distance = legs[0]['distance']['value']; // meters
//                 final duration = legs[0]['duration']['value']; // seconds
//
//                 // Update our distance and time values with the accurate Google data
//                 if (mounted) setState(() {
//                   distanceInKm = distance / 1000.0;
//                   timeInMinutes = (duration / 60).round();
//                 });
//
//                 dev.log('Google distance: $distance m, duration: $duration sec');
//               }
//             }
//           }
//         }
//       } catch (e) {
//         dev.log('Error getting directions: $e');
//         // Continue with polyline method as fallback
//       }
//
//       // Still get polyline for drawing the route
//       PolylinePoints polylinePoints = PolylinePoints();
//       PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         'AIzaSyDa8jLzBYCRX1ZmZ3b16Jj5FrNXV2QiTOA', // API Key
//         PointLatLng(pickupLocation!.latitude, pickupLocation!.longitude),
//         PointLatLng(dropoffLocation!.latitude, dropoffLocation!.longitude),
//         travelMode: TravelMode.driving,
//       );
//
//       if (result.points.isNotEmpty) {
//         for (var point in result.points) {
//           polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//         }
//
//         if (mounted) setState(() {
//           polylines.add(
//             Polyline(
//               polylineId: const PolylineId('polyline'),
//               points: polylineCoordinates,
//               color: ColorsPalette.primaryColor,
//               width: 5,
//             ),
//           );
//         });
//
//         // Calculate distance and time
//         _calculateDistanceAndTime();
//
//         // Fit map to show the route with both pickup and dropoff visible
//         final bounds = _getBounds(polylineCoordinates);
//
//         // Use a smoother camera movement with longer duration
//         mapController?.animateCamera(
//             }
//           }
//
//           void _animateMarker() {
//             if (_markerIndex < polylineCoordinates.length - 1) {
//               _markerIndex++;
//               if (mounted) setState(() {
//                 markers.removeWhere(
//                     (marker) => marker.markerId == const MarkerId('car_marker'));
//                 markers.add(
//                   Marker(
//                     markerId: const MarkerId('car_marker'),
//                     position: polylineCoordinates[_markerIndex],
//                     icon: carIcon ?? BitmapDescriptor.defaultMarker,
//                     rotation: _getMarkerRotation(
//                         polylineCoordinates[_markerIndex - 1],
//                         polylineCoordinates[_markerIndex]),
//                   ),
//                 );
//               });
//       }
//
//       Future<void> _getPolyline() async {
//         if (pickupLocation == null || dropoffLocation == null) {
//           return;
//       double totalDistance = 0;
//       for (int i = 0; i < polylineCoordinates.length - 1; i++) {
//         totalDistance += _calculateDistance(
//           polylineCoordinates[i].latitude,
//           polylineCoordinates[i].longitude,
//           polylineCoordinates[i + 1].latitude,
//           polylineCoordinates[i + 1].longitude,
//         );
//       }
//
//       // Estimate time in minutes (assuming average speed of 40 km/h)
//       int estimatedTime = (totalDistance / 40 * 60).round();
//
//       if (mounted) setState(() {
//         distanceInKm = double.parse(totalDistance.toStringAsFixed(2));
//         timeInMinutes = estimatedTime;
//       });
//     } catch (e) {
//       print('Error calculating distance and time: $e');
//     }
//   }
//
//   double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const double p = 0.017453292519943295; // Math.PI / 180
//     final double a = 0.5 -
//         cos((lat2 - lat1) * p) / 2 +
//         cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
//     return 12742 * asin(sqrt(a)); // 2 * R * asin(sqrt(a)) where R = 6371 km
//   }
//
//   // Direct distance calculation (as-crow-flies) between two points
//   double _calculateDirectDistance(double lat1, double lon1, double lat2, double lon2) {
//     const double p = 0.017453292519943295; // Math.PI / 180
//     final double a = 0.5 -
//         cos((lat2 - lat1) * p) / 2 +
//         cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
//     return 12742 * asin(sqrt(a)); // 2 * R * asin(sqrt(a)) where R = 6371 km
//   }
//
//   // Calculate distance and time explicitly, with stronger fallbacks
//   Future<void> _calculateDistanceAndTimeExplicit() async {
//     try {
//       if (pickupLocation == null || dropoffLocation == null) {
//         return;
//       }
//
//       // First try to get distance from polyline coordinates if available
//       if (polylineCoordinates.isNotEmpty && polylineCoordinates.length >= 2) {
//         double totalDistance = 0;
//         for (int i = 0; i < polylineCoordinates.length - 1; i++) {
//           totalDistance += _calculateDistance(
//             polylineCoordinates[i].latitude,
//             polylineCoordinates[i].longitude,
//             polylineCoordinates[i + 1].latitude,
//             polylineCoordinates[i + 1].longitude,
//           );
//         }
//
//         // Only update if we got a reasonable value
//         if (totalDistance > 0) {
//           distanceInKm = double.parse(totalDistance.toStringAsFixed(2));
//           timeInMinutes = max((distanceInKm / 30 * 60).round(), 5); // Minimum 5 minutes, assume 30km/h avg speed
//         }
//       }
//
//       // If we still don't have valid values, use direct distance as fallback
//       if (distanceInKm <= 0) {
//         double directDist = _calculateDirectDistance(
//           pickupLocation!.latitude, pickupLocation!.longitude,
//           dropoffLocation!.latitude, dropoffLocation!.longitude
//         );
//
//         // Apply a factor of 1.3 for road distance vs direct distance
//         directDist = directDist * 1.3;
//
//         distanceInKm = double.parse(directDist.toStringAsFixed(2));
//         timeInMinutes = max((distanceInKm / 30 * 60).round(), 5);
//       }
//
//       dev.log("Explicit calculation: Distance=$distanceInKm km, Time=$timeInMinutes min");
//     } catch (e) {
//       dev.log("Error in explicit distance calculation: $e");
//       // Set minimum values if calculation fails
//       if (distanceInKm <= 0) distanceInKm = 1.0;
//       if (timeInMinutes <= 0) timeInMinutes = 5;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorsPalette.lightGrey,
//       appBar: AppBarApp(
//         title: LocaleKeys.requestWinch.tr(),
//       ),
//       bottomNavigationBar: _buildSearchButton(),
//       body: Column(
//         children: [
//           // TOP SECTION: Map
//           Flexible(
//             flex: 3, // Give more space to the map
//             child: GoogleMap(
//               initialCameraPosition: initialPosition,
//               onMapCreated: (controller) {
//                 mapController = controller;
//                 _getCurrentLocation(context);
//               },
//               markers: markers,
//               polylines: polylines,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//               zoomControlsEnabled: true,
//               mapType: MapType.normal,
//             ),
//           ),
//
//           // MIDDLE & BOTTOM SECTIONS: Car selection and address sections
//           Flexible(
//             flex: 4,
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   // MIDDLE SECTION: Car selection
//                   Container(
//                     color: ColorsPalette.primaryLightColor,
//                     width: double.infinity,
//                     child: Column(
//                       children: [
//                         // Car selection header
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                           child: Row(
//                             children: [
//                               SvgPicture.asset(AssetsManager.carShape),
//                               SizedBox(width: 8),
//                               Text(
//                                 LocaleKeys.chooseFromCars.tr(),
//                                 style: TextStyle(
//                                   color: ColorsPalette.black,
//                                   fontWeight: FontWeight.w500,
//                                   fontFamily: ZainTextStyles.font,
//                                   fontSize: 14.sp,
//                                 ),
//                               ),
//                               Spacer(),
//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => YourCarDetails(type: 1)
//                                     ),
//                                   );
//                                 },
//                                 child: Row(
//                                   children: [
//                                     SvgPicture.asset(AssetsManager.addCircle),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       LocaleKeys.addCar.tr(),
//                                       style: TextStyle(
//                                         color: ColorsPalette.primaryColor,
//                                         fontWeight: FontWeight.w500,
//                                         fontFamily: ZainTextStyles.font,
//                                         fontSize: 14.sp,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         // Car list
//                         Container(
//                           height: 100,
//                           color: ColorsPalette.primaryLightColor,
//                           child: Builder(
//                             builder: (context) {
//                               return CustomFutureBuilder<List<UserCars>>(
//                                 future: CarApi.getCars(locale: context.locale),
//                                 successBuilder: (List<UserCars> cars) {
//                                   if (cars.isEmpty) {
//                                     return Center(
//                                       child: Column(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Icon(
//                                             Icons.directions_car_outlined,
//                                             size: 40,
//                                             color: ColorsPalette.primaryColor,
//                                           ),
//                                           SizedBox(height: 8),
//                                           Text(
//                                             LocaleKeys.noCarsFound.tr(),
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                               color: ColorsPalette.black,
//                                               fontSize: 14.sp,
//                                               fontFamily: ZainTextStyles.font
//                                             ),
//                                           ),
//                                         ],
//                                       )
//                                     );
//                                   }
//
//                                   return SizedBox(
//                                     height: 100,
//                                     child: HorizontalListView(
//                                       padding: EdgeInsets.all(5),
//                                       itemCount: cars.length,
//                                       itemBuilder: (index) {
//                                         final car = cars[index];
//                                         final isSelected = (selected == null)
//                                             ? (car.isDefault ?? false)
//                                             : (selected == car.car?.id);
//
//                                         return InkWell(
//                                           onTap: () {
//                                             if (mounted) setState(() {
//                                               selected = car.car?.id;
//                                               selectedUserCar = car.id;
//                                               selectedCar = car.car;
//                                             });
//                                           },
//                                           child: SizedBox(
//                                             width: MediaQuery.of(context).size.width / 3.5,
//                                             child: CustomCard(
//                                               padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                                               borderRadius: BorderRadius.circular(12),
//                                               border: Border.all(
//                                                 color: isSelected
//                                                   ? ColorsPalette.primaryColor
//                                                   : ColorsPalette.extraDarkGrey,
//                                                 width: isSelected ? 2 : 1,
//                                               ),
//                                               color: ColorsPalette.white,
//                                               child: AddressCard(
//                                                 name: '${car.car?.model?.brand?.name}, ${car.car?.model?.name}' ?? '',
//                                                 city: car.car?.year ?? '',
//                                                 selected: false,
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   SizedBox(height: 8),
//
//                   // BOTTOM SECTION: Source Address
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Column(
//                       children: [
//                         // Source address
//                         Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: ColorsPalette.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 4,
//                                 offset: Offset(0, 1),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Source header
//                               Padding(
//                                 padding: const EdgeInsets.all(12.0),
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.location_on, color: Colors.green, size: 24),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       "Current Location",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 16.sp,
//                                         fontFamily: ZainTextStyles.font,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//
//                               Divider(height: 1, thickness: 1, color: ColorsPalette.lightGrey),
//
//                               // Saved addresses section
//                               if (savedAddresses != null && savedAddresses!.isNotEmpty) _buildSourceSavedAddresses(),
//
//                               // Select on map button
//                               Padding(
//                                 padding: const EdgeInsets.all(12.0),
//                                 child: InkWell(
//                                   onTap: () async {
//                                     final result = await Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => MapPickerScreen(
//                                           isSource: true,
//                                           myLocController: _myLocController,
//                                           disController: _distinationController,
//                                         ),
//                                       ),
//                                     );
//
//                                     if (result != null && result is LatLng) {
//                                       if (mounted) setState(() {
//                                         selectedSourceAddressId = null;
//                                         pickupLocation = result;
//
//                                         if (dropoffLocation != null) {
//                                           _getPolyline();
//                                         } else {
//                                           // If only pickup is set, move camera to it
//                                           _animateCameraToLocation(pickupLocation!);
//                                         }
//                                       });
//                                     }
//                                   },
//                                   child: Container(
//                                     width: double.infinity,
//                                     height: 50,
//                                     decoration: BoxDecoration(
//                                       color: ColorsPalette.white,
//                                       borderRadius: BorderRadius.circular(8),
//                                       border: Border.all(color: ColorsPalette.primaryColor),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Icon(Icons.map, color: ColorsPalette.primaryColor),
//                                         SizedBox(width: 8),
//                                         Text(
//                                           "Select on Map",
//                                           style: TextStyle(
//                                             color: ColorsPalette.primaryColor,
//                                             fontWeight: FontWeight.w600,
//                                             fontFamily: ZainTextStyles.font,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//
//                               // Display selected location if any
//                               if (_myLocController.text.isNotEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
//                                   child: Container(
//                                     width: double.infinity,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                       color: ColorsPalette.lightGrey.withOpacity(0.2),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Text(
//                                       _myLocController.text,
//                                       style: TextStyle(
//                                         fontFamily: ZainTextStyles.font,
//                                         fontSize: 14.sp,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//
//                         SizedBox(height: 16),
//
//                         // Destination address
//                         Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: ColorsPalette.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 4,
//                                 offset: Offset(0, 1),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Destination header
//                               Padding(
//                                 padding: const EdgeInsets.all(12.0),
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.flag, color: Colors.red, size: 24),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       "Destination",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 16.sp,
//                                         fontFamily: ZainTextStyles.font,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//
//                               Divider(height: 1, thickness: 1, color: ColorsPalette.lightGrey),
//
//                               // Saved addresses section
//                               if (savedAddresses != null && savedAddresses!.isNotEmpty) _buildDestinationSavedAddresses(),
//
//                               // Select on map button
//                               Padding(
//                                 padding: const EdgeInsets.all(12.0),
//                                 child: InkWell(
//                                   onTap: () async {
//                                     final result = await Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => MapPickerScreen(
//                                           isSource: false,
//                                           myLocController: _myLocController,
//                                           disController: _distinationController,
//                                         ),
//                                       ),
//                                     );
//
//                                     if (result != null && result is LatLng) {
//                                       if (mounted) setState(() {
//                                         selectedDestinationAddressId = null;
//                                         dropoffLocation = result;
//
//                                         if (pickupLocation != null) {
//                                           _getPolyline();
//                                         } else {
//                                           // If only dropoff is set, move camera to it
//                                           _animateCameraToLocation(dropoffLocation!);
//                                         }
//                                       });
//                                     }
//                                   },
//                                   child: Container(
//                                     width: double.infinity,
//                                     height: 50,
//                                     decoration: BoxDecoration(
//                                       color: ColorsPalette.white,
//                                       borderRadius: BorderRadius.circular(8),
//                                       border: Border.all(color: ColorsPalette.primaryColor),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Icon(Icons.map, color: ColorsPalette.primaryColor),
//                                         SizedBox(width: 8),
//                                         Text(
//                                           "Select on Map",
//                                           style: TextStyle(
//                                             color: ColorsPalette.primaryColor,
//                                             fontWeight: FontWeight.w600,
//                                             fontFamily: ZainTextStyles.font,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//
//                               // Display selected location if any
//                               if (_distinationController.text.isNotEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
//                                   child: Container(
//                                     width: double.infinity,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                       color: ColorsPalette.lightGrey.withOpacity(0.2),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Text(
//                                       _distinationController.text,
//                                       style: TextStyle(
//                                         fontFamily: ZainTextStyles.font,
//                                         fontSize: 14.sp,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//
//                         // Distance and time information
//                         if (distanceInKm != 0.0 && timeInMinutes != 0)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 16.0),
//                             child: Container(
//                               padding: EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: ColorsPalette.primaryLightColor.withOpacity(0.3),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.access_time, color: ColorsPalette.primaryColor),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     '$timeInMinutes ${LocaleKeys.timeBetweenLocs.tr()}',
//                                     style: TextStyle(
//                                       color: ColorsPalette.darkGrey,
//                                       fontWeight: FontWeight.w500,
//                                       fontFamily: ZainTextStyles.font,
//                                       fontSize: 14.sp,
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   Icon(Icons.straighten, color: ColorsPalette.primaryColor),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     '${distanceInKm} ${LocaleKeys.disBetweenLocs.tr()}',
//                                     style: TextStyle(
//                                       color: ColorsPalette.darkGrey,
//                                       fontWeight: FontWeight.w500,
//                                       fontFamily: ZainTextStyles.font,
//                                       fontSize: 14.sp,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//
//                   // Add extra space at the bottom for scrolling
//                   SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchButton() {
//     bool isEnabled = (pickupLocation != null && dropoffLocation != null) && !_isSearching;
//
//     return Container(
//       margin: EdgeInsets.all(14.sp),
//       height: 6.h,
//       child: ElevatedButton(
//         onPressed: isEnabled ? startSearch : null,
//         style: ButtonStyle(
//           textStyle: MaterialStateProperty.all<TextStyle>(
//             TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
//           ),
//           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//             RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//               side: BorderSide(
//                   color: isEnabled
//                       ? ColorsPalette.primaryColor
//                       : ColorsPalette.customGrey),
//             ),
//           ),
//           backgroundColor: MaterialStateProperty.resolveWith<Color>(
//             (Set<MaterialState> states) {
//               if (states.contains(MaterialState.disabled)) {
//                 return ColorsPalette.customGrey;
//               }
//               return ColorsPalette.primaryColor;
//             },
//           ),
//         ),
//         child: Center(
//           child: _loading
//               ? const LoadingWidget(
//                   color: ColorsPalette.white,
//                 )
//               : Text(
//                   LocaleKeys.startSearch.tr(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: ColorsPalette.white,
//                       fontFamily: ZainTextStyles.font,
//                       fontSize: 14.sp),
//                 ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> startSearch() async {
//     if (_isSearching) {
//       return;
//     }
//
//     if (pickupLocation == null || dropoffLocation == null) {
//       showSnackbar(
//         context: context,
//         status: SnackbarStatus.error,
//         message: LocaleKeys.selectAddress.tr(),
//       );
//       return;
//     }
//
//     if (selectedCar == null || selectedUserCar == null) {
//       showSnackbar(
//         context: context,
//         status: SnackbarStatus.error,
//         message: LocaleKeys.pleaseSelectAllOptions.tr(),
//       );
//       return;
//     }
//
//     if (mounted) setState(() {
//       _loading = true;
//       _isSearching = true;
//     });
//
//     try {
//       // Create proper API parameters
//       final fromLatLng = "${pickupLocation!.latitude},${pickupLocation!.longitude}";
//       final toLatLng = "${dropoffLocation!.latitude},${dropoffLocation!.longitude}";
//
//       // Recalculate distance and time explicitly to ensure we have valid values
//       await _calculateDistanceAndTimeExplicit();
//
//       // Calculate price based on distance
//       int price = (distanceInKm * 5).round();
//
//       // Convert distance to meters for the API (API expects meters, not km)
//       int distanceInMeters = (distanceInKm * 1000).round();
//
//       // Ensure we have valid duration and distance values (use fallbacks if calculations failed)
//       if (timeInMinutes <= 0) {
//         timeInMinutes = max((distanceInKm / 30 * 60).round(), 5); // Minimum 5 minutes
//       }
//
//       if (distanceInMeters <= 0) {
//         // Calculate direct distance if route calculation failed
//         final directDistance = _calculateDirectDistance(
//           pickupLocation!.latitude, pickupLocation!.longitude,
//           dropoffLocation!.latitude, dropoffLocation!.longitude
//         );
//         distanceInMeters = max((directDistance * 1000).round(), 100); // Minimum 100 meters
//       }
//
//       // Log the values being sent to API
//       dev.log("Sending to API - Distance: $distanceInMeters meters, Duration: $timeInMinutes minutes");
//
//       // Call the actual API to create winch order
//       final createOrderResponse = await MiscellaneousApi.createWinchOrder(
//         locale: context.locale,
//         distance: distanceInMeters, // Send distance in meters
//         fromLat: pickupLocation!.latitude,
//         fromLon: pickupLocation!.longitude,
//         toLat: dropoffLocation!.latitude,
//         toLon: dropoffLocation!.longitude,
//         duration: timeInMinutes,
//         userCarId: selectedUserCar!,
//         price: price,
//         fromText: _myLocController.text,
//         toText: _distinationController.text,
//       );
//
//       // Log success for debugging
//       dev.log("Winch order created successfully", error: createOrderResponse.toString());
//
//       if (mounted) {
//         // Use Navigator.push with a then() callback to reset state when returning
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) {
//             return WinchResultsScreen(
//               orderId: createOrderResponse.data?.order?.id ?? 0,
//               fromText: _myLocController.text,
//               toText: _distinationController.text,
//               cost: price.toString(),
//             );
//           })
//         ).then((_) {
//           // Reset state when returning from results screen
//           if (mounted) {
//             setState(() {
//               _loading = false;
//               _isSearching = false;
//             });
//           }
//         });
//       }
//     } catch (e) {
//       dev.log("Error creating winch order", error: e.toString());
//       showSnackbar(
//         context: context,
//         status: SnackbarStatus.error,
//         message: "Failed to create winch order. Please try again.",
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _loading = false;
//           _isSearching = false;
//         });
//       }
//     }
//   }
//
//   // Display saved addresses for source location
//   Widget _buildSourceSavedAddresses() {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Select from saved addresses:",
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               fontSize: 14.sp,
//               fontFamily: ZainTextStyles.font,
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             height: 120,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: savedAddresses?.length ?? 0,
//               itemBuilder: (context, index) {
//                 final address = savedAddresses![index];
//                 final isSelected = selectedSourceAddressId == address.id;
//
//                 return GestureDetector(
//                   onTap: () {
//                     // Update location in controller
//                     _myLocController.text = "${address.name}: ${address.details ?? ''}";
//
//                     // Create LatLng if coordinates are available
//                     LatLng? coordinates;
//                     if (address.lat != null && address.lon != null) {
//                       try {
//                         coordinates = LatLng(
//                           double.parse(address.lat!),
//                           double.parse(address.lon!)
//                         );
//                       } catch (e) {
//                         print("Error parsing coordinates: $e");
//                       }
//                     }
//
//                     if (mounted) setState(() {
//                       selectedSourceAddressId = address.id;
//                       if (coordinates != null) {
//                         pickupLocation = coordinates;
//
//                         if (dropoffLocation != null) {
//                           _getPolyline();
//                         }
//                       }
//                     });
//                   },
//                   child: Container(
//                     width: 160,
//                     margin: EdgeInsets.only(right: 8),
//                     decoration: BoxDecoration(
//                       color: isSelected ? ColorsPalette.primaryLightColor : Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: isSelected ? ColorsPalette.primaryColor : ColorsPalette.extraDarkGrey,
//                         width: isSelected ? 2 : 1,
//                       ),
//                     ),
//                     padding: EdgeInsets.all(8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           address.name ?? "Address",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontFamily: ZainTextStyles.font,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 4),
//                         Expanded(
//                           child: Text(
//                             address.details ?? "",
//                             style: TextStyle(
//                               color: ColorsPalette.darkGrey,
//                               fontSize: 12.sp,
//                               fontFamily: ZainTextStyles.font,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         if (address.isDefault == true)
//                           Container(
//                             margin: EdgeInsets.only(top: 4),
//                             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: ColorsPalette.default1,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Text(
//                               "Default",
//                               style: TextStyle(
//                                 fontSize: 10.sp,
//                                 fontFamily: ZainTextStyles.font,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Display saved addresses for destination location
//   Widget _buildDestinationSavedAddresses() {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Select from saved addresses:",
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               fontSize: 14.sp,
//               fontFamily: ZainTextStyles.font,
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             height: 120,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: savedAddresses?.length ?? 0,
//               itemBuilder: (context, index) {
//                 final address = savedAddresses![index];
//                 final isSelected = selectedDestinationAddressId == address.id;
//
//                 return GestureDetector(
//                   onTap: () {
//                     // Update location in controller
//                     _distinationController.text = "${address.name}: ${address.details ?? ''}";
//
//                     // Create LatLng if coordinates are available
//                     LatLng? coordinates;
//                     if (address.lat != null && address.lon != null) {
//                       try {
//                         coordinates = LatLng(
//                           double.parse(address.lat!),
//                           double.parse(address.lon!)
//                         );
//                       } catch (e) {
//                         print("Error parsing coordinates: $e");
//                       }
//                     }
//
//                     if (mounted) setState(() {
//                       selectedDestinationAddressId = address.id;
//                       if (coordinates != null) {
//                         dropoffLocation = coordinates;
//
//                         if (pickupLocation != null) {
//                           _getPolyline();
//                         }
//                       }
//                     });
//                   },
//                   child: Container(
//                     width: 160,
//                     margin: EdgeInsets.only(right: 8),
//                     decoration: BoxDecoration(
//                       color: isSelected ? ColorsPalette.primaryLightColor : Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: isSelected ? ColorsPalette.primaryColor : ColorsPalette.extraDarkGrey,
//                         width: isSelected ? 2 : 1,
//                       ),
//                     ),
//                     padding: EdgeInsets.all(8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           address.name ?? "Address",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontFamily: ZainTextStyles.font,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 4),
//                         Expanded(
//                           child: Text(
//                             address.details ?? "",
//                             style: TextStyle(
//                               color: ColorsPalette.darkGrey,
//                               fontSize: 12.sp,
//                               fontFamily: ZainTextStyles.font,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         if (address.isDefault == true)
//                           Container(
//                             margin: EdgeInsets.only(top: 4),
//                             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: ColorsPalette.default1,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Text(
//                               "Default",
//                               style: TextStyle(
//                                 fontSize: 10.sp,
//                                 fontFamily: ZainTextStyles.font,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _getCar() async {
//     try {
//       final List<UserCars> cars = await CarApi.getCars(locale: context.locale);
//       if (mounted) setState(() {
//         selected ??= cars
//             .firstWhereOrNull((element) => element.isDefault ?? false)
//             ?.car
//             ?.id;
//         selectedCar ??=
//             cars.firstWhereOrNull((element) => element.isDefault ?? false)?.car;
//         selectedUserCar ??=
//             cars.firstWhereOrNull((element) => element.isDefault ?? false)?.id;
//       });
//     } catch (e) {
//       print('Error getting cars: $e');
//     }
//   }
// }
