// import 'package:ma7lola/controller/user_provider.dart';
// import 'package:ma7lola/generated/locale_keys.g.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:progress_indicator/progress_indicator.dart';
// import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';
// import '../../../../../utils/assets_manager.dart';
// import '../../../../../utils/colors_palette.dart';
// import '../../../../../utils/util_values.dart';
// import '../../../../login_screen.dart';
// import '../../../../redeem_points_screen/redeem_points_screen.dart';
//
// class LoyaltyPointsWidget extends StatefulWidget {
//   const LoyaltyPointsWidget({Key? key, required this.loyaltyPoints, required this.height}) : super(key: key);
//   final int loyaltyPoints;
//   final double height;
//
//   @override
//   State<LoyaltyPointsWidget> createState() => _LoyaltyPointsWidgetState();
// }
//
// class _LoyaltyPointsWidgetState extends State<LoyaltyPointsWidget> {
//
//   @override
//   Widget build(BuildContext context) {
//     int totalPoints = 1000 - widget.loyaltyPoints;
//     // 980
//     double value = totalPoints / 10;
//     double points = 100 - value;
//     double level = 1000;
//     double level4 = level - level/4;
//     return InkWell(
//       onTap: (){
//         final user = context.read<UserProvider>();
//         if(user.isLoggedIn){
//           Navigator.pushNamed(context, RedeemPointsScreen.routeName);
//         } else{
//           Navigator.of(context).pushNamed(LoginScreen.routeName);
//         }
//       },
//       child: Container(
//         height: widget.height,
//         margin: UtilValues.padding16T8,
//         decoration: BoxDecoration(color: ColorsPalette.white, borderRadius: UtilValues.borderRadius10),
//         child: ListTile(
//           //contentPadding: UtilValues.padding16,
//           leading: Container(
//             //margin: UtilValues.paddingTop50,
//             width: 60,
//             decoration: BoxDecoration(image: DecorationImage(image: AssetImage(level/4 >= widget.loyaltyPoints? AssetsManager.bronze : level/2 >= widget.loyaltyPoints ? AssetsManager.silver : level4 >= widget.loyaltyPoints ? AssetsManager.gold :  AssetsManager.platinum,), fit: BoxFit.fill)),
//                height: double.infinity,
//
//              // child: Image.asset(level/4 >= widget.loyaltyPoints? AssetsManager.bronze : level/2 >= widget.loyaltyPoints ? AssetsManager.silver : level4 >= widget.loyaltyPoints ? AssetsManager.gold :  AssetsManager.platinum,)
//           ),
//           title: Padding(
//             padding: const EdgeInsets.only(top: 8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 SizedBox(
//                   //width: 100,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(level/4 >= widget.loyaltyPoints? LocaleKeys.bronze.tr() : level/2 >= widget.loyaltyPoints ? LocaleKeys.silver.tr() : level4 >= widget.loyaltyPoints ? LocaleKeys.gold.tr() : LocaleKeys.platinum.tr(), style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1,),
//                       Text(LocaleKeys.thousandPoints.tr(),style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, ), maxLines: 1,),
//                     ],
//                   ),
//                 ),
//                 UtilValues.gap8,
//                 Center(
//                   //padding: Helpers.isEnglish(context) ? EdgeInsets.only(left: 34.w) : const EdgeInsets.only(right: 50),
//                   child: SizedBox(
//                     width: 65.w,
//                   child: BarProgress(
//                         percentage: points > 100 ? 100 : points,
//                         textStyle: const TextStyle(color: Colors.transparent),
//                         backColor: /*Helpers.isEnglish(context) ? */ColorsPalette.lightGrey /*: ColorsPalette.primaryColor*/,
//                         //showPercentage: true,
//                         color:  /*Helpers.isEnglish(context) ? */ColorsPalette.primaryColor/* : ColorsPalette.lightGrey*/,
//                         stroke: 7,
//                         round: true,
//                       ),
//                   ),
//                 ),
//                 UtilValues.gap8,
//                 totalPoints < 0 ? Text(LocaleKeys.done.tr(), style: const TextStyle(fontSize: 8,  fontWeight: FontWeight.w600, color: ColorsPalette.green), maxLines: 1,) : Text('${LocaleKeys.earn.tr()} $totalPoints ${LocaleKeys.reachPlatinumLevel.tr()}', style: const TextStyle(fontSize: 8,  fontWeight: FontWeight.w600, color: ColorsPalette.darkGrey), maxLines: 1,),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
