// import 'package:ma7lola/controller/user_provider.dart';
//
// import 'package:easy_localization/easy_localization.dart';
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../../../core/generated/locale_keys.g.dart';
// import '../../../../../../core/utils/colors_palette.dart';
// import '../../../../../../core/utils/util_values.dart';
// import '../../../../../../core/widgets/contained_icon_button.dart';
//
//
// class HomeTabAppBar extends StatefulWidget implements PreferredSizeWidget {
//
//   const HomeTabAppBar({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<HomeTabAppBar> createState() => _HomeTabAppBarState();
//
//   @override
//   Size get preferredSize => const Size.fromHeight(56);
// }
//
// class _HomeTabAppBarState extends State<HomeTabAppBar> {
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       centerTitle: true,
//       leading: Padding(
//         padding: UtilValues.padding8,
//         child: ContainedIconButton(
//           backgroundColor: ColorsPalette.lightGrey,
//                 icon: const Icon(Icons.menu, color: ColorsPalette.primaryColor,),
//                 //iconColor: ColorsPalette.primaryColor,
//                 onTap: () => Scaffold.of(context).openDrawer(),
//         ),
//       ),
//       title: Selector<UserProvider, bool>(
//               selector: (context, provider) => true/*provider.isLoggedIn*/,
//               builder: (_, isLoggedIn, __) {
//                 return GestureDetector(
//                   onTap: isLoggedIn
//                       ? () => SelectAddressBottomSheet.show(context)
//                       : () => Navigator.of(context)
//                           .pushNamed(LoginScreen.routeName),
//                   child: Container(
//                     height: 56,
//                     color: Colors.transparent,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               LocaleKeys.deliverTo.tr(),
//                               style: const TextStyle(
//                                 color: ColorsPalette.extraDarkGrey,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             UtilValues.gap4,
//                             const Icon(
//                               Icons.keyboard_arrow_down_outlined,
//                               color: ColorsPalette.extraDarkGrey,
//                               size: 16,
//                             )
//                           ],
//                         ),
//                         UtilValues.gap4,
//                         Consumer<AddressProvider>(
//                           builder: (_, addressProvider, __) {
//                             return Text(
//                               addressProvider.addresses.isEmpty ? LocaleKeys.setYourAddress.tr() : Helpers.formatAddress(addressProvider.selectedAddress),
//                               style: const TextStyle(
//                                   color: ColorsPalette.primaryColor,
//                                   fontWeight: FontWeight.w400,
//                                   fontSize: 12),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//       actions: [
//               Center(
//                 child: Padding(
//                   padding: UtilValues.padding6,
//                   child: ContainedIconButton(
//                     icon: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Image.asset(AssetsManager.cart),
//                     ),
//                     backgroundColor: ColorsPalette.lightGrey,
//                     //iconColor: ColorsPalette.primaryColor,
//                     onTap: () async{
//                       if(selectedBranch == 0 && activeButton == 1){
//                         showSnackbar(context: context, status: SnackbarStatus.info, message: 'Please Select branch');
//                         SelectBranchBottomSheet.show(context);
//                       }else {
//                         final userProvider = context.read<UserProvider>();
//                         final addressProvider = context.read<AddressProvider>();
//                         await userProvider.autoLogin();
//                         await addressProvider.getAddresses();
//                         if (!userProvider.hasAtLeastOneAddress) {
//                           showSnackbar(
//                             context: context,
//                             status: SnackbarStatus.info,
//                             message: LocaleKeys.shouldHaveAtLeastOneAddress.tr(),
//                           );
//                           await userProvider.autoLogin();
//
//                           Navigator.of(context).pushNamed(
//                             AddNewAddressScreen.routeName,
//                             arguments: {'fromRegistration': true},
//                           );
//                           await userProvider.autoLogin();
//
//                           return;
//                         }else{
//                           Navigator.of(context).pushNamed(CartScreen.routeName);
//                         }
//                     }
//                     }
//                   ),
//                 ),
//               ),
//             ],
//     );
//   }
// }
