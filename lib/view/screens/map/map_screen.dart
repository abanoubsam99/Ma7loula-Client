import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import 'package:ma7lola/model/tires_products_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/utils/colors_palette.dart';
import '../../../model/batteries_products_model.dart';
import '../../../model/car_model.dart';
import '../../../model/products_model.dart';
import '../addresses_book_screen/add_new_address_screen.dart';

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  static String routeName = '/map';
  MapScreen(
      {Key? key,
      required this.carID,
      required this.products,
      required this.batteries,
      required this.fromCart,
      required this.fromCartBatteries,
      required this.car,
      required this.tires,
      required this.fromCartTires,
      required this.addressName,
      required this.addressDetails})
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

  var latitude = 30.033333;
  var longitude = 31.233334;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  LatLng? _selectedPosition; // Track user selected position
  String _selectedAddress = '';
  bool _isGettingAddress = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // Request location permission
    final status = await Permission.location.request();

    if (status.isGranted) {
      try {
        // Get current position
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        setState(() {
          _currentPosition = position;
        });

        // Animate camera to current position if controller is available
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 15.0,
              ),
            ),
          );
        }
      } catch (e) {
        print("Error getting location: $e");
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    }
  }

  Future<bool> _doubleBackToExit(BuildContext context) async {
    return true;
  }

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(30.0444, 31.2357),
    zoom: 14.0,
  );

  // Build markers for the map
  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};
    
    // Add marker for selected position if available
    if (_selectedPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selectedPosition'),
          position: _selectedPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    
    // Add marker for current position if available and different from selected
    else if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentPosition'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    
    return markers;
  }

  // Get address from latitude and longitude
  Future<void> _getAddressFromLatLng(LatLng location) async {
    setState(() {
      _isGettingAddress = true;
    });
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          // Format address from placemark
          _selectedAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((element) => element != null && element.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _selectedAddress = '${location.latitude}, ${location.longitude}';
      });
    } finally {
      setState(() {
        _isGettingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _doubleBackToExit(context),
      child: Directionality(
        textDirection:
            Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _currentPosition?.latitude ?? 30.033333, // Default latitude
                    _currentPosition?.longitude ?? 31.233334, // Default longitude
                  ),
                  zoom: 15,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  if (_currentPosition != null) {
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          zoom: 15,
                        ),
                      ),
                    );
                  }
                },
                // Allow user to tap on map to select location
                onTap: (LatLng location) {
                  setState(() {
                    _selectedPosition = location;
                    _getAddressFromLatLng(location); // Get address when tapping
                  });
                },
                markers: _buildMarkers(),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
              ),
              // Show selected address with loading indicator
              if (_selectedPosition != null)
                Positioned(
                  bottom: 15.h,
                  left: 10.w,
                  right: 10.w,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: _isGettingAddress
                        ? const Center(child: CircularProgressIndicator())
                        : Text(
                            _selectedAddress.isNotEmpty
                                ? _selectedAddress
                                : "Tap to select a location", // Using direct text since the locale key might not exist
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                  ),
                ),
              
              Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 5.h,
                  ),
                  child: SimplePrimaryButton(
                    label: LocaleKeys.selectAddress.tr(),
                    width: 200.w,
                    height: 40,
                    onPressed: () {
                      // Use selected position if available, otherwise use current position
                      final latitude = _selectedPosition?.latitude ?? _currentPosition?.latitude;
                      final longitude = _selectedPosition?.longitude ?? _currentPosition?.longitude;
                      
                      if (latitude != null && longitude != null) {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return AddNewAddressScreen(
                              carID: widget.carID,
                              products: widget.products,
                              batteries: widget.batteries,
                              fromCart: widget.fromCart,
                              fromCartBatteries: widget.fromCartBatteries,
                              car: widget.car,
                              tires: widget.tires,
                              fromCartTires: widget.fromCartTires,
                              long: longitude,
                              late: latitude,
                              addressDetails: _selectedAddress.isNotEmpty ? _selectedAddress : widget.addressDetails,
                              addressName: widget.addressName,
                            );
                          }));
                      } else {
                        // Show error if no location is selected or available
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(LocaleKeys.locationPermissionDenied.tr())),
                        );
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                top: 5.h,
                right: 5.w,
                left: 5.w,
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Card(
                    elevation: 5,
                    color: Colors.white,
                    child: IconButton(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(
                        Icons.my_location,
                        color: ColorsPalette.darkGrey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
