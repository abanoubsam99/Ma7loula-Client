import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../controller/start_up_slides_provider.dart';
import '../../../core/generated/locale_keys.g.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/font.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../model/start_up_slides.dart';
import '../auth/LoginScreen.dart';
import 'local_widgets/intro_screen.dart';

enum IndicatorType { CIRCLE, LINE, DIAMOND }

enum FooterShape { NORMAL, CURVED_TOP, CURVED_BOTTOM }

class IntroScreens extends StatefulWidget {
  const IntroScreens({super.key});
  static const String routeName = '/intro_screens';

  @override
  _IntroScreensState createState() => _IntroScreensState();
}

class _IntroScreensState extends State<IntroScreens>
    with TickerProviderStateMixin {
  PageController? _controller;
  double? pageOffset = 0;
  int currentPage = 0;
  bool lastPage = false;
  late AnimationController animationController;
  Registration? currentScreen;
  late StartUpSlidesProvider slidesProvider;
  @override
  void initState() {
    super.initState();

    _controller = PageController(
      initialPage: currentPage,
      viewportFraction: 1.0,
    )..addListener(() {
        pageOffset = _controller!.page;
      });

    animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    slidesProvider = context.read<StartUpSlidesProvider>();
    slidesProvider
        .getStartUpSlides(locale: context.locale)
        .then((value) => setState(() {
              currentScreen = slidesProvider
                  .startUpSlides.startUpSlides?.startUpSlides?.first;
            }));
  }

  double skipTextOffset = 0.0;

  TextStyle get titleStyle => const TextStyle(
        fontFamily: ZainTextStyles.font,
        fontSize: 12,
        color: ColorsPalette.white,
        fontWeight: FontWeight.w500,
      );

  TextStyle get descriptionStyle => const TextStyle(
        fontFamily: ZainTextStyles.font,
        fontSize: 16,
        color: ColorsPalette.white,
        fontWeight: FontWeight.w500,
      );

  defaultOnSkip() => animationController.animateTo(
        slidesProvider.startUpSlides.startUpSlides!.startUpSlides!.length - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );

  LinearGradient get gradients => const LinearGradient(
        colors: [
          ColorsPalette.primaryColor,
          ColorsPalette.primaryColor,
        ],
      );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: ColorsPalette.primaryColor,
      body: Builder(builder: (context) {
        if (currentScreen == null) {
          return const Center(
              child: CircularProgressIndicator(
            color: ColorsPalette.lightpre,
          ));
        }
        return SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              PageView.builder(
                controller: _controller,
                itemCount: slidesProvider
                    .startUpSlides.startUpSlides!.startUpSlides?.length,
                itemBuilder: (context, index) {
                  return buildPage(index: index);
                },
                onPageChanged: (int index) {
                  setState(() {
                    currentPage = index;
                    currentScreen = slidesProvider.startUpSlides.startUpSlides
                        ?.startUpSlides?[currentPage];

                    if (currentPage ==
                        slidesProvider.startUpSlides.startUpSlides!
                                .startUpSlides!.length -
                            1) {
                      lastPage = true;
                      animationController.forward();
                    } else {
                      lastPage = false;
                      animationController.reverse();
                    }
                  });
                  // setState(() {
                  //   currentPage = index;
                  //   if (currentPage == slides.length - 1) {
                  //     lastPage = true;
                  //     animationController.forward();
                  //   } else {
                  //     lastPage = false;
                  //     animationController.reverse();
                  //   }
                  // });
                },
              ),
              Positioned.fill(
                bottom: 0,
                left: 0,
                right: 0,
                top: MediaQuery.of(context).size.height * .78,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: <Widget>[
                      Text(
                        currentScreen?.title ?? '',
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: ZainTextStyles.font,
                            color: ColorsPalette.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 20.sp),
                        textAlign: TextAlign.center,
                      ),
                      UtilValues.gap12,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text(
                          currentScreen!.description!,
                          softWrap: true,
                          style: TextStyle(
                              fontFamily: ZainTextStyles.font,
                              color: ColorsPalette.grey,
                              fontWeight: FontWeight.w200,
                              fontSize: 14.sp,
                              height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (!lastPage) ...[
                        UtilValues.gap24,
                        SmoothPageIndicator(
                          controller: _controller!,
                          count: slidesProvider.startUpSlides.startUpSlides!
                              .startUpSlides!.length,
                          effect: const ExpandingDotsEffect(
                              expansionFactor: 4,
                              spacing: 8.0,
                              radius: 5,
                              dotWidth: 4,
                              dotHeight: 4,
                              strokeWidth: 1.5,
                              dotColor: ColorsPalette.white,
                              activeDotColor: ColorsPalette.grey),
                        ),
                      ],
                      UtilValues.gap24,
                      if (lastPage)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SimplePrimaryButton(
                            backgroundColor: ColorsPalette.primaryColor,
                            label: LocaleKeys.startNow.tr(),
                            onPressed: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return LoginScreen(
                                  products: [],
                                  batteries: [],
                                  tires: [],
                                  carID: 0,
                                  fromCart: false,
                                  fromCartBatteries: false,
                                  fromCartTires: false,
                                  car: null,
                                );
                              }));
                            },
                          ),
                        )
                      else
                        InkWell(
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              _controller?.animateToPage(
                                currentPage + 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            });
                          },
                          child: Text(
                            LocaleKeys.skip.tr(),
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: ZainTextStyles.font,
                              color: ColorsPalette.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
          //)
          ),
    );
  }

  Widget buildPage(
          {required int index, double angle = 0.0, double scale = 1.0}) =>
      // print(pageOffset - index);
      Container(
        color: Colors.transparent,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, .001)
            ..rotateY(angle),
          child: IntroScreen(
            title: slidesProvider
                .startUpSlides.startUpSlides!.startUpSlides?[index].title,
            description: slidesProvider
                .startUpSlides.startUpSlides!.startUpSlides?[index].description,
            imageNetwork: slidesProvider.startUpSlides.startUpSlides!
                .startUpSlides?[index].pictureModel,
          ),
        ),
      );
}

// class BuildPage extends StatelessWidget {
//   BuildPage({super.key, required this.index, required this.slidesProvider, this.angle = 0.0, this.scale = 1.0});
//   int index;
//   double scale;
//   double angle;
//   StartUpSlidesProvider slidesProvider;
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent
//     ));
//     return Scaffold(
//         extendBodyBehindAppBar: true,
//         body: Container(
//         color: Colors.transparent,
//         child: Transform(
//           transform: Matrix4.identity()
//             ..setEntry(3, 2, .001)
//             ..rotateY(angle),
//           child: IntroScreen(title: slidesProvider.startUpSlides.startUpSlides![index].title, description: slidesProvider.startUpSlides.startUpSlides![index].description, imageNetwork: slidesProvider.startUpSlides.startUpSlides![index].pictureModel!.imageUrl,),
//         ),
//       )
//     );
//   }
// }
