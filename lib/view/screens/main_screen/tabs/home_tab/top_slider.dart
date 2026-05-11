import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sizer/sizer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../../core/widgets/fixed_cached_network_image.dart';

import '../../../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../../../model/slider_model.dart';

class TopSlider extends StatefulWidget {
  TopSlider({
    Key? key,
  }) : super(key: key);

  @override
  State<TopSlider> createState() => _TopSliderState();
}

class _TopSliderState extends State<TopSlider> {
  CarouselSliderController carouselController = CarouselSliderController();

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SliderModel>(
        future: MiscellaneousApi.getSliders(locale: context.locale),
        builder: (context, snapshot) {
          if (/*snapshot.connectionState == ConnectionState.waiting ||*/
              snapshot.data == null) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.18,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SizedBox.shrink(),
              ),
            );
          }

          final banners = snapshot.data!;

          if (banners.data == null) {
            return SizedBox.shrink();
          }
          final sliders = banners.data?.sliders;
          return Center(
            child: Column(
              children: [
                CarouselSlider.builder(
                  carouselController: carouselController,
                  itemCount: sliders?.length,
                  options: CarouselOptions(
                    onPageChanged: (index, reason) {
                      setState(() {
                        _index = index;
                      });
                    },
                    viewportFraction: 0.75,
                    enlargeCenterPage: false,
                    initialPage: _index,
                    height: MediaQuery.of(context).size.height * 0.18,
                    autoPlay: true,
                    enableInfiniteScroll: true,
                  ),
                  itemBuilder:
                      (BuildContext context, int index, int realIndex) {
                    return InkWell(
                      // onTap: () {
                      //   if (images[index].entityId != 0 &&
                      //       images[index].entityType == 'Product') {
                      //     onItemClicked(
                      //         context, images[index].entityId);
                      //   } else if (images[index].entityId != 0 &&
                      //       images[index].entityType == 'Category') {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => ProductsScreen(
                      //           categoryId: images[index].entityId,
                      //           title: S.current.productsScreenAppBarTitle,
                      //         ),
                      //       ),
                      //     );
                      //   } else if (images[index].entityId != 0 &&
                      //       images[index].entityType ==
                      //           'Manufacturer') {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => ProductsScreen(
                      //           manufactureId: images[index].entityId,
                      //           title: S.current.productsScreenAppBarTitle,
                      //         ),
                      //       ),
                      //     );
                      //   } else {}
                      // },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 4,
                          right: 4,
                        ),
                        // padding: EdgeInsets.only(left: 5.sp, right: 5.sp,),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkResponse(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: FixedCachedNetworkImage(
                                  imageUrl: (sliders?.isNotEmpty ?? false)
                                      ? (sliders?[index].image ?? '')
                                      : '',
                                  fit: BoxFit.fill,
                                  height: MediaQuery.of(context).size.height * 0.18,
                                  width: double.maxFinite,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        });
  }
  /* } else if (state is Loading) {
          return Container();
        }

        return Container();
      },
    );
  }*/

  // void onItemClicked(BuildContext context, int productId) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ProductDetailsScreen(
  //         productId,
  //         heroSuffix: "home_screen",
  //         userRepository: getIt.get<UserRepository>(),
  //       ),
  //     ),
  //   );
  // }
}
