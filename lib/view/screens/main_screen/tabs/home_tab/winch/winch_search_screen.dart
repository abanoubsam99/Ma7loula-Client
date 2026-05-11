// import 'package:collection/collection.dart';
// import 'package:easy_localization/easy_localization.dart' as e;
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:ma7lola/core/generated/locale_keys.g.dart';
// import 'package:ma7lola/core/utils/assets_manager.dart';
// import 'package:ma7lola/core/utils/colors_palette.dart';
// import 'package:ma7lola/core/widgets/custom_app_bar.dart';
// import 'package:ma7lola/view/screens/auth/YourCarDetails.dart';
// import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../../../controller/products_provider.dart';
// import '../../../../../../core/services/http/apis/car_api.dart';
// import '../../../../../../core/utils/font.dart';
// import '../../../../../../core/utils/snackbars.dart';
// import '../../../../../../core/utils/util_values.dart';
// import '../../../../../../core/widgets/app_snack_bar.dart';
// import '../../../../../../core/widgets/custom_card.dart';
// import '../../../../../../core/widgets/custom_future_builder.dart';
// import '../../../../../../core/widgets/horizontal_list_view.dart';
// import '../../../../../../core/widgets/loading_widget.dart';
// import '../../../../../../model/car_model.dart';
// import '../../../../addresses_book_screen/local_widgets/address_card.dart';
//
// class WinchSearchScreen extends StatefulWidget {
//   static String routeName = '/WinchSearchScreen';
//   WinchSearchScreen({Key? key}) : super(key: key);
//   var latitude = 30.033333;
//   var longitude = 31.233334;
//   @override
//   State<WinchSearchScreen> createState() => _WinchSearchScreenState();
// }
//
// class _WinchSearchScreenState extends State<WinchSearchScreen> {
//   bool _loading = false;
//   int? selected;
//   int? selectedUserCar;
//   Car? selectedCar;
//   late LatLng position;
//
//   late GoogleMapController googleMapController;
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermission();
//     getCurrentLocation(context).then((value) {
//       widget.latitude = value.latitude;
//       widget.longitude = value.longitude;
//     });
//     position = LatLng(
//       widget.latitude,
//       widget.longitude,
//     );
//   }
//
//   Future<bool> _doubleBackToExit(BuildContext context) async {
//     return true;
//   }
//
//   Future<void> _requestPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled, request the user to enable them
//       return Future.error('Location services are disabled.');
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Permissions are denied, show an error message
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are denied forever, handle the case accordingly
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//   }
//
//   Future<Position> getCurrentLocation(context) async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled .');
//     }
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         var snackBar = AppSnackBar(
//           text: 'Location permission are denied',
//           isSuccess: false,
//         ) as SnackBar;
//         return ScaffoldMessenger.of(context).showSnackBar(snackBar) as Position;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permission are permanently, we cannot permission');
//     }
//
//     return await Geolocator.getCurrentPosition();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: ColorsPalette.lightGrey,
//         appBar: AppBarApp(
//           title: LocaleKeys.winch.tr(),
//         ),
//         bottomNavigationBar: _startSearchButton(),
//         body: Stack(
//           children: [
//             GoogleMap(
//               onMapCreated: (mapController) {
//                 googleMapController = mapController;
//               },
//               initialCameraPosition: CameraPosition(
//                 target: position,
//                 zoom: 14,
//               ),
//               onTap: (LatLng pos) {
//                 setState(() {
//                   widget.latitude = pos.latitude;
//                   widget.longitude = pos.longitude;
//                   position = LatLng(
//                     pos.latitude,
//                     pos.longitude,
//                   );
//                   googleMapController.animateCamera(
//                     CameraUpdate.newLatLngZoom(
//                       LatLng(pos.latitude, pos.longitude),
//                       14,
//                     ),
//                   );
//                 });
//               },
//               markers: {
//                 Marker(
//                   markerId: const MarkerId('currentPosition'),
//                   position: position,
//                 ),
//               },
//             ),
//             Positioned(
//                 top: 5.h,
//                 right: 5.w,
//                 left: 5.w,
//                 child: Align(
//                   alignment: AlignmentDirectional.topStart,
//                   child: Column(
//                     children: [
//                       Container(
//                         color: ColorsPalette.primaryLightColor,
//                         child: Row(
//                           children: [
//                             UtilValues.gap8,
//                             SvgPicture.asset(AssetsManager.carShape),
//                             UtilValues.gap8,
//                             Text(
//                               LocaleKeys.chooseFromCars.tr(),
//                               style: TextStyle(
//                                   color: ColorsPalette.black,
//                                   fontWeight: FontWeight.w400,
//                                   fontFamily: ZainTextStyles.font,
//                                   fontSize: 14.sp),
//                             ),
//                             Spacer(),
//                             IconButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => YourCarDetails(
//                                             type: 0,
//                                           )),
//                                 );
//                               },
//                               icon: Row(
//                                 children: [
//                                   SvgPicture.asset(AssetsManager.addCircle),
//                                   UtilValues.gap8,
//                                   Text(
//                                     LocaleKeys.addCar.tr(),
//                                     style: TextStyle(
//                                         color: ColorsPalette.primaryColor,
//                                         fontWeight: FontWeight.w400,
//                                         fontFamily: ZainTextStyles.font,
//                                         fontSize: 14.sp),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             UtilValues.gap8,
//                           ],
//                         ),
//                       ),
//                       Container(
//                         height: 100,
//                         color: ColorsPalette.primaryLightColor,
//                         child: Builder(builder: (context) {
//                           return CustomFutureBuilder<List<UserCars>>(
//                               future: CarApi.getCars(locale: context.locale),
//                               successBuilder: (List<UserCars> cars) {
//                                 if (cars.isEmpty) {
//                                   return Center(
//                                       child: Column(
//                                     children: [
//                                       Icon(
//                                         Icons.map_outlined,
//                                         size: 50,
//                                         color: ColorsPalette.primaryColor,
//                                       ),
//                                       UtilValues.gap16,
//                                       Text(
//                                         LocaleKeys.noCarsFound.tr(),
//                                         textAlign: TextAlign.center,
//                                         style: const TextStyle(
//                                             color: ColorsPalette.black,
//                                             fontSize: 12,
//                                             fontFamily: ZainTextStyles.font),
//                                       ),
//                                     ],
//                                   ));
//                                 }
//                                 return SizedBox(
//                                   height: 100,
//                                   child: HorizontalListView(
//                                       padding: EdgeInsets.all(5),
//                                       itemCount: cars.length,
//                                       itemBuilder: (index) {
//                                         final car = cars[index];
//                                         return InkWell(
//                                           onTap: () {
//                                             setState(() {
//                                               selected = car.car?.id;
//                                               selectedUserCar = car.id;
//                                               selectedCar = car.car;
//                                             });
//                                           },
//                                           child: SizedBox(
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width /
//                                                 3.5,
//                                             child: CustomCard(
//                                               padding: EdgeInsets.symmetric(
//                                                   vertical: 5, horizontal: 10),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               border: Border.all(
//                                                   color: ((selected == null)
//                                                           ? (car.isDefault ??
//                                                               false)
//                                                           : (selected ==
//                                                               car.car?.id))
//                                                       ? ColorsPalette
//                                                           .primaryColor
//                                                       : ColorsPalette
//                                                           .extraDarkGrey),
//                                               color: ColorsPalette.white,
//                                               child: AddressCard(
//                                                 name:
//                                                     '${car.car?.model?.brand?.name}, ${car.car?.model?.name}' ??
//                                                         '',
//                                                 city: car.car?.year ?? '',
//                                                 selected: false,
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       }),
//                                 );
//                               });
//                         }),
//                       ),
//                       Container(
//                         color: ColorsPalette.primaryLightColor,
//                         height: 10,
//                       ),
//                       UtilValues.gap12,
//                     ],
//                   ),
//                 )),
//           ],
//         ));
//   }
//
//   yourLocationForm() {}
//
//   _startSearchButton() {
//     return Container(
//       // padding: EdgeInsets.symmetric(vertical: 2.h),
//       margin: EdgeInsets.all(14.sp),
//       height: 6.h,
//       child: ElevatedButton(
//         onPressed: startSearch,
//         style: ButtonStyle(
//           textStyle: MaterialStateProperty.all<TextStyle>(
//             TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
//           ),
//           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//             RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//               side: const BorderSide(color: ColorsPalette.primaryColor),
//             ),
//           ),
//           backgroundColor:
//               MaterialStateProperty.all<Color>(ColorsPalette.primaryColor),
//         ),
//         child: Center(
//           child: _loading
//               ? const LoadingWidget(
//                   color: ColorsPalette.white,
//                 )
//               : Text(
//                   LocaleKeys.startWinchSearch.tr(),
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
//   void startSearch() async {
//     try {
//       final productProvider = context.read<ProductsProvider>();
//       productProvider.clear();
//
//       await _getCar();
//       setState(() {});
//       // await Future.delayed(Duration(seconds: 3));
//
//       if ((selected != null)) {
//         // Navigator.push(context, MaterialPageRoute(builder: (context) {
//         //   return CarPartsResultsScreen(
//         //     categoryID: _isChangeDropDownAllCarParts ?? 5,
//         //     carId: selected ?? 1,
//         //     car: selectedCar,
//         //     userCarId: selectedUserCar ?? 1,
//         //   );
//         // }));
//         return;
//       } else {
//         showSnackbar(
//           context: context,
//           status: SnackbarStatus.error,
//           message: LocaleKeys.pleaseSelectAllOptions.tr(),
//         );
//       }
//     } catch (e) {
//       showSnackbar(
//         context: context,
//         status: SnackbarStatus.error,
//         message: e.toString(),
//       );
//       setState(() => _loading = false);
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   _getCar() async {
//     final List<UserCars> cars = await CarApi.getCars(locale: context.locale);
//     setState(() {
//       selected ??= cars
//           .firstWhereOrNull((element) => element.isDefault ?? false)
//           ?.car
//           ?.id;
//       selectedCar ??=
//           cars.firstWhereOrNull((element) => element.isDefault ?? false)?.car;
//       selectedUserCar ??=
//           cars.firstWhereOrNull((element) => element.isDefault ?? false)?.id;
//     });
//     setState(() {});
//   }
// }
