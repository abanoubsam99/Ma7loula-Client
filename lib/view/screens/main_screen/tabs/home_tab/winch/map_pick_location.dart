import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/widgets/app_snack_bar.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';

class MapPickerScreen extends StatefulWidget {
  final bool isSource;
  final TextEditingController myLocController;
  final TextEditingController disController;

  const MapPickerScreen({
    Key? key,
    required this.isSource,
    required this.myLocController,
    required this.disController,
  }) : super(key: key);

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? mapController;
  LatLng? _selectedLocation;
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(30.033333, 31.233334),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _getCurrentLocation(context);
  }

  Future<Position?> _getCurrentLocation(context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.locationServicesDisabled.tr())),
        );
        return null;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocaleKeys.locationPermissionDenied.tr())),
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.locationPermissionPermanentlyDenied.tr())),
        );
        return null;
      }
      
      // Use a timeout to prevent hanging if location service is slow
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      ).catchError((error) {
        print('Error getting location: $error');
        return Position(
          longitude: 31.233334, 
          latitude: 30.033333,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      });
      
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        );
      });
      
      return position;
    } catch (e) {
      print('Error in _getCurrentLocation: $e');
      return null;
    }
  }

  Future<void> _requestPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Don't throw an error, just return silently - we'll handle this in getCurrentLocation
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        try {
          // Set a timeout for the permission request to prevent hanging
          permission = await Geolocator.requestPermission()
              .timeout(const Duration(seconds: 5));
          if (permission == LocationPermission.denied) {
            // Just return silently - we'll handle this in getCurrentLocation
            return;
          }
        } catch (e) {
          print('Error requesting location permission: $e');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Just return silently - we'll handle this in getCurrentLocation
        return;
      }
      
      // If we got here, permissions are granted
    } catch (e) {
      print('Error in _requestPermission: $e');
      // Return silently instead of throwing an error
      return;
    }
  }

  void _onMapTapped(LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });

    try {
      // تحويل الموقع إلى عنوان
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
        // localeIdentifier: 'ar_EG',
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address =
            '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.country}';

        // تحديث الحقل المناسب
        if (widget.isSource) {
          widget.myLocController.text = address;
        } else {
          widget.disController.text = address;
        }
      }
    } catch (e) {
      print("Error getting placemark: $e");
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      // Ensure the text controllers are populated with address data
      if (widget.isSource && widget.myLocController.text.isEmpty) {
        // Fallback in case the geocoding failed but we have coordinates
        widget.myLocController.text = '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}';
      } else if (!widget.isSource && widget.disController.text.isEmpty) {
        // Fallback in case the geocoding failed but we have coordinates
        widget.disController.text = '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}';
      }
      
      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.locationSelected.tr(),
            style: TextStyle(
                color: ColorsPalette.white,
                fontWeight: FontWeight.w400,
                fontFamily: ZainTextStyles.font,
                fontSize: 14.sp),
          ),
          backgroundColor: ColorsPalette.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
      
      print('Location confirmed: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}');
      print('Source address: ${widget.myLocController.text}');
      print('Destination address: ${widget.disController.text}');
      
      // Return to the previous screen with the location data
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.chooseOnMap.tr(),
            style: TextStyle(
                color: ColorsPalette.white,
                fontWeight: FontWeight.w400,
                fontFamily: ZainTextStyles.font,
                fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(
        title: LocaleKeys.chooseOnMap.tr(),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (controller) {
              mapController = controller;
            },
            onTap: _onMapTapped,
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selectedLocation!,
                    )
                  }
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsPalette.primaryColor,
              ),
              child: Text(
                LocaleKeys.chooseOnMap.tr(),
                style: TextStyle(
                    color: ColorsPalette.white,
                    fontWeight: FontWeight.w400,
                    fontFamily: ZainTextStyles.font,
                    fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
