// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../../../bottom_sheets/select_address_bottom_sheet/select_address_bottom_sheet.dart';
// import '../../../../../bottom_sheets/select_branch_bottom_sheet/select_branch_bottom_sheet.dart';
// import '../../../../../controller/address_provider.dart';
// import '../../../../../controller/user_provider.dart';
// import '../../../../../generated/locale_keys.g.dart';
// import '../../../../../services/http/apis/miscellaneous_api.dart';
// import '../../../../../services/http/interceptors/api_interceptor.dart';
// import '../../../../../utils/assets_manager.dart';
// import '../../../../../utils/colors_palette.dart';
// import '../../../../../utils/size_config.dart';
// import '../../../../../utils/snackbars.dart';
// import '../../../../../utils/util_values.dart';
//
// class PickUpWidget extends StatefulWidget {
//   const PickUpWidget({Key? key}) : super(key: key);
//
//   @override
//   State<PickUpWidget> createState() => _PickUpWidgetState();
// }
//
// class _PickUpWidgetState extends State<PickUpWidget> {
//   late AddressProvider _addressProvider;
//   late UserProvider userProvider;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _addressProvider = context.read<AddressProvider>();
//     userProvider = context.read<UserProvider>();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Column(
//           children: [
//             GestureDetector(
//               onTap: (){
//                 setState(() {
//                   activeButton = 0;
//                 });
//                 if(userProvider.isLoggedIn){
//                   pickUp;
//                   SelectAddressBottomSheet.show(context);
//                 }/* else{
//                         Navigator.of(context).pushNamed(LoginScreen.routeName);
//                       }*/
//               },
//               child: Container(
//                 width: 60, height: 40,
//                 margin: UtilValues.padding12V16H,
//                 decoration: BoxDecoration(
//                   boxShadow: [
//                     const BoxShadow(color: ColorsPalette.grey, offset: Offset(3, 3), blurRadius: 3),
//
//                     activeButton == 1 ? const BoxShadow(color: ColorsPalette.white, offset: Offset(-3, -3), blurRadius: 5.0)
//                         : const BoxShadow(),
//                   ],
//                   color: ColorsPalette.lightpre,
//                   borderRadius: UtilValues.borderRadius15,
//                   border: Border.all(
//                     color: (activeButton == 0 ? ColorsPalette.primaryColor :  ColorsPalette.lightGrey),
//                     width: 2,
//                   ),
//                   //image: const DecorationImage(image: AssetImage(AssetsManager.delivery,), fit: BoxFit.cover)
//                 ),
//                 child: Image.asset(AssetsManager.delivery, width: 4, height: 12,),
//               ),
//             ),
//             SizedBox(
//               width: 61, height: 20,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Visibility(
//                       visible: activeButton == 0 ? true : false,
//                       child: Image.asset(AssetsManager.right,)
//                   ),
//                   Text(
//                     LocaleKeys.delivery.tr(),
//                     style: TextStyle(
//                       color: (activeButton == 0 ?  ColorsPalette.primaryColor :  ColorsPalette.black),
//                       fontSize: 9,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         UtilValues.gap4,
//         Column(
//           children: [
//             GestureDetector(
//               onTap: (){
//                 setState(() {
//                   activeButton = 1;
//                 });
//                 if(userProvider.isLoggedIn){
//                   pickUp;
//                 }
//                 //SelectAddressBottomSheet.show(context);
//                 SelectBranchBottomSheet.show(context);
//               },
//               child: Container(
//                 width: 60, height: 40,
//                 margin: UtilValues.padding12V16H,
//                 decoration: BoxDecoration(
//                   boxShadow: [
//                     const BoxShadow(color: ColorsPalette.grey, offset: Offset(3, 3), blurRadius: 3),
//
//                     activeButton == 0 ? const BoxShadow(color: ColorsPalette.white, offset: Offset(-3, -3), blurRadius: 5.0)
//                         : const BoxShadow(),
//                   ],
//                   color: ColorsPalette.lightpre,
//                   borderRadius: UtilValues.borderRadius15,
//                   border: Border.all(
//                     color: (activeButton == 1 ?  ColorsPalette.primaryColor : ColorsPalette.lightGrey),
//                     width: 2,
//                   ),
//                   // image: const DecorationImage(image: AssetImage(AssetsManager.pickup,), fit: BoxFit.cover)
//                 ),
//                 child: Image.asset(AssetsManager.pickup, width:12, height: 12,),
//               ),
//             ),
//             SizedBox(
//               width: 64, height: 20,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Visibility(
//                       visible: activeButton == 1 ? true : false,
//                       child: Image.asset(AssetsManager.right,)
//                   ),
//                   Text(
//                     LocaleKeys.selfPickup.tr(),
//                     style: TextStyle(
//                       color: (activeButton == 1 ?  ColorsPalette.primaryColor :  ColorsPalette.black),
//                       fontSize: 9,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   pickUp() async{
//     try{
//       await MiscellaneousApi.sendShippingFees(pickup: activeButton, addressId: _addressProvider.selectedAddress.id);
//     }catch(error){
//       showSnackbar(
//         context: context,
//         status: SnackbarStatus.error,
//         message: error.toString(),
//       );
//     }
//   }
// }
