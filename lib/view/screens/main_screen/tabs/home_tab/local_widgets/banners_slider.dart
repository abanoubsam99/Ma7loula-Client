// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../../../core/services/http/apis/miscellaneous_api.dart';
// import '../../../../../../core/utils/colors_palette.dart';
// import '../../../../../../core/utils/util_values.dart';
//
// class BannersSlider extends StatelessWidget {
//   const BannersSlider({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Banners>(
//       future: MiscellaneousApi.getBanners(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting ||
//             snapshot.data == null) {
//           return Container(
//             height: 15.h,
//             decoration: BoxDecoration(
//               color: ColorsPalette.lightGrey,
//               borderRadius: UtilValues.borderRadius10,
//             ),
//             child: const Center(
//               child: SizedBox.shrink(),
//             ),
//           );
//         }
//
//         final banners = snapshot.data!;
//         //print('ghjk ${banners.data!.firstWhere((element) => element.bannerAr)}');
//
//         if (banners.bannerAr == null && banners.bannerEn == null) {
//           return const SizedBox.shrink();
//         }
//
//         return ImagesSlider(
//           imagesUrls: banners.bannerEn!.data!,
//           imagesUrlsAr: banners.bannerAr!.data!,
//         );
//       },
//     );
//   }
// }
