import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/home_tab.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/my_orders_tab/my_orders_screen.dart';

import '../../../core/generated/locale_keys.g.dart';
import '../../../core/services/requestNotificationsPermission.dart';
import '../../../core/utils/colors_palette.dart';
import 'tabs/home_tab/emergency/emergency_services_screen.dart';
import 'tabs/profile_tab/profile_tab.dart';

class MainScreen extends StatefulWidget {
  // static const String routeName = '/main';

  int index = 0;
  int? myOrdersIndex = 0;
  MainScreen({Key? key, required this.index, this.myOrdersIndex})
      : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();

  @override
  void initState() {
    requestNotificationsPermission();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final List<Widget> _tabs = [
      const HomeTab(),
      EmergencyServicesScreen(
        back: true,
      ),
      MyOrdersTab(
        index: widget.myOrdersIndex ?? 0,
      ),
      const ProfileTab(),
    ];

    final List<BottomNavigationBarItem> buildNavBarItems = [
      BottomNavigationBarItem(
        icon: SvgPicture.asset(
          AssetsManager.home,
          color:
              widget.index == 0 ? ColorsPalette.white : ColorsPalette.darkGrey,
        ),
        label: LocaleKeys.home.tr(),
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset(
          AssetsManager.emergency,
          color:
              widget.index == 1 ? ColorsPalette.white : ColorsPalette.darkGrey,
        ),
        label: LocaleKeys.emergency.tr(),
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset(
          AssetsManager.fileList,
          color:
              widget.index == 2 ? ColorsPalette.white : ColorsPalette.darkGrey,
        ),
        label: LocaleKeys.myOrders.tr(),
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset(
          AssetsManager.user,
          color:
              widget.index == 3 ? ColorsPalette.white : ColorsPalette.darkGrey,
        ),
        label: LocaleKeys.more.tr(),
      ),

/*

      Icon(Icons.menu_book, color: widget.index == 1 ? ColorsPalette.white : ColorsPalette.white,),
      Icon(Icons.store,color: widget.index == 2 ? ColorsPalette.white : ColorsPalette.white,),
      Icon(Icons.receipt_outlined,color: widget.index == 3 ? ColorsPalette.white : ColorsPalette.white,),
      Icon(Icons.card_giftcard, color: widget.index == 4 ? ColorsPalette.white : ColorsPalette.white,),
      Icon(Icons.person_outline_rounded, color: widget.index == 5 ? ColorsPalette.white : ColorsPalette.white,),
*/
    ];
    context
        .locale; // NOTE: This one is added to solve the bug of not translation after changing the local
    return ClipRect(
      child: Scaffold(
        body: _tabs[widget.index],
        extendBody: true,
        bottomNavigationBar: ClipPath(
          clipper: BottomNavBarClipper(),
          child: BottomNavigationBar(
            selectedLabelStyle: TextStyle(fontFamily: ZainTextStyles.font),
            unselectedLabelStyle: TextStyle(fontFamily: ZainTextStyles.font),
            type: BottomNavigationBarType.fixed,
            key: navigationKey,
            selectedItemColor: ColorsPalette.white,
            unselectedItemColor: ColorsPalette.darkGrey,
            backgroundColor: ColorsPalette.black,
            currentIndex: widget.index,
            onTap: onTabChange,
            items: buildNavBarItems,
          ),
        ),
      ),
    );
  }

  void onTabChange(int index) {
    /*final userProvider = context.read<UserProvider>();
    if(userProvider.isLoggedIn && userProvider.user!.lastCancel == OrderCanceled.yup){
      alert();
    }else */
    if (index != widget.index) {
      setState(() {
        widget.index = index;
      });
    }
  }

  /*alert() async{
    final confirmed = await showPlatformDialog(
      context: context,
      builder: (_) =>
          BasicDialogAlert(
            title: Text(LocaleKeys.yourLastOrderCancel.tr()),
            content:
            Text(LocaleKeys.loading.tr()),
            actions: <Widget>[
              BasicDialogAction(
                title: Text(LocaleKeys.ok.tr()),
                onPressed: () async {
                  await MiscellaneousApi.convertLastCancel();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }*/
}

class BottomNavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
