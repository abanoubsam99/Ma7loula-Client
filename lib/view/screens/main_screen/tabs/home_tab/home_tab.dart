import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:ma7lola/core/widgets/horizontal_list_view.dart';
import 'package:ma7lola/model/category_model.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/batteries/batteries_search_screen.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/local_widgets/category_card.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/notification_screen.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/services.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/tires/tires_search_screen.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/top_slider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';

import '../../../../../controller/user_provider.dart';
import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../addresses_book_screen/addresses_book_screen.dart';
import '../../../auth/LoginScreen.dart';
import 'car_parts/categories_screen.dart';
import 'emergency/emergency_services_screen.dart';
import 'winch/map_ploying.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeTabState();
  }
}

class _HomeTabState extends State<HomeTab> {
  bool _isInit = false;
  DateTime _backButtonTimestamp = DateTime.now();
  // late dynamic apiController;
  late UserProvider userProvider;
  List _fetchedTrendProducts = [];

  bool _isLoading = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      checkInternetConnectivity();

      //SizeConfig.screenWidth = MediaQuery.of(context).size.width;
      //SizeConfig.screenHeight = MediaQuery.of(context).size.height;
      userProvider = context.read<UserProvider>();

      // apiController = context.read<ApiController>();

      // userProvider.autoLogin();
      // MiscellaneousApi.getCategories();
      // MiscellaneousApi.getTrendProducts().then((trendProducts) {
      //   setState(() => _fetchedTrendProducts = trendProducts);
      // });

      _scrollController = ScrollController()
        ..addListener(
          () {
            setState(() {
              if (_scrollController.offset >= 400) {
                _showBackToTopButton = true;
              } else {
                _showBackToTopButton = false;
              }
            });
          },
        );
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  bool _showBackToTopButton = false;
  late ScrollController _scrollController;
  int index1 = 2;

  Future<bool> checkInternetConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isInternetConnected = false;
      });
      return false;
    } else {
      setState(() {
        isInternetConnected = true;
      });
      return true;
    }
  }

  bool isInternetConnected = false;

  /* Future<void> checkInternet() async {
    final result = await checkInternetConnectivity();
    setState(() {
      isInternetConnected = result;
    });
  }
*/

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      setState(() {
        isOnline = true;
      });
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      setState(() {
        isOnline = false;
      });
      return false;
    }
  }

  bool isOnline = false;

  @override
  Widget build(BuildContext context) {
    final List<CategoriesModel> categories = [
      CategoriesModel(
          pic: AssetsManager.simple,
          title: LocaleKeys.tires.tr(),
          onTap: () {
            Navigator.pushNamed(context, TiresSearchScreen.routeName);
          }),
      CategoriesModel(
          pic: AssetsManager.simple1,
          title: LocaleKeys.batteries.tr(),
          onTap: () {
            Navigator.pushNamed(context, BatteriesSearchScreen.routeName);
          }),
      CategoriesModel(
          pic: AssetsManager.simple2,
          title: LocaleKeys.carParts.tr(),
          onTap: () {
            Navigator.pushNamed(context, CategoriesScreen.routeName);
          }),
    ];
    return WillPopScope(
      onWillPop: () => _doubleBackToExit(context),
      child: UpgradeAlert(
        child: Scaffold(
          backgroundColor: ColorsPalette.white,
          appBar: CustomAppBar(
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, NotificationsScreen.routeName);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SvgPicture.asset(AssetsManager.notification),
                ),
              ),
            ],
          ),
          body: isInternetConnected == true || isOnline == true
              ? CustomScrollView(
                  physics: UtilValues.scrollPhysics,
                  controller: _scrollController,
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          _homeGetAddress(),
                          UtilValues.gap12,
                          TopSlider(),
                          UtilValues.gap16,
                          Services(
                            image: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
                            title: LocaleKeys.emergency.tr(),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                EmergencyServicesScreen.routeName,
                              );
                            },
                          ),
                          UtilValues.gap8,
                          Services(
                              image: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
                              title: LocaleKeys.winch.tr(),
                              onTap: () {
                                final userProvider = context.read<UserProvider>();
                                if (!userProvider.isLoggedIn) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return LoginScreen(
                                      products: [],
                                      batteries: [],
                                      tires: [],
                                      carID: 0,
                                      fromWinch: true,
                                      fromCart: false,
                                      fromCartBatteries: false,
                                      fromCartTires: false,
                                      car: null,
                                    );
                                  }));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return MapPolylineScreen();
                                  }));
                                }
                              }),
                          UtilValues.gap8,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              LocaleKeys.categories.tr(),
                              style: TextStyle(
                                color: ColorsPalette.veryDarkGrey,
                                fontWeight: FontWeight.w600,
                                fontFamily: ZainTextStyles.font,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          UtilValues.gap8,
                          HorizontalListView(
                            itemCount: categories.length,
                            itemBuilder: (index) {
                              return CategoriesCard(
                                title: categories[index].title ?? '',
                                pic: categories[index].pic ?? '',
                                onTap: categories[index].onTap,
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : const Center(child: Text('Check Internet Connectivity')),
        ),
      ),
    );
  }

  _homeGetAddress() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AddressesBookScreen(
            products: [],
            carID: 0,
            car: null,
            batteries: [],
            fromCart: false,
            fromCartBatteries: false,
            tires: [],
            fromCartTires: false,
          );
        }));
      },
      child: Consumer<UserProvider>(builder: (context, userProvider, child) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(color: ColorsPalette.primaryColor, borderRadius: BorderRadius.circular(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AssetsManager.location2),
              UtilValues.gap12,
              Expanded(
                child: Row(
                  children: [
                    Text(
                      LocaleKeys.address.tr(),
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: ColorsPalette.white, fontFamily: ZainTextStyles.font),
                      textDirection: TextDirection.rtl,
                    ),
                    UtilValues.gap8,
                    Text(
                      userProvider.isLoggedIn && userProvider.user?.data?.user?.defaultAddress != null
                          ? '${userProvider.user?.data?.user?.defaultAddress?.city?.name} - ${userProvider.user?.data?.user?.defaultAddress?.name}'
                          : LocaleKeys.address.tr(),
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorsPalette.white, fontFamily: ZainTextStyles.font),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(AssetsManager.angleRight),
            ],
          ),
        );
      }),
    );
  }

  Future<bool> _doubleBackToExit(BuildContext context) async {
    final differenceBetweenNowAndLastTimestamp = DateTime.now().difference(_backButtonTimestamp);
    if (differenceBetweenNowAndLastTimestamp.inSeconds > 1) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.info,
        message: LocaleKeys.doubleBackToExit.tr(),
      );
      _backButtonTimestamp = DateTime.now();
      return false;
    } else {
      return true;
    }
  }
}
