import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/winch/winchCard.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/get_offers_provider.dart';
import '../../../../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/snackbars.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../winch/map_ploying.dart';
import 'emergency_details_done_screen.dart';

class EmergencyResultsScreen extends StatefulWidget {
  const EmergencyResultsScreen({
    Key? key,
    required this.orderId,
    required this.cost,
    required this.car,
  }) : super(key: key);

  final int orderId;
  final String cost;
  final String car;

  @override
  State<EmergencyResultsScreen> createState() => _EmergencyResultsScreenState();
}

class _EmergencyResultsScreenState extends State<EmergencyResultsScreen>
    with WidgetsBindingObserver {
  late GetWinchOffersProvider _emergencyProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emergencyProvider =
          Provider.of<GetWinchOffersProvider>(context, listen: false);
      _startTimer();
    });
  }

  void _startTimer() {
    final locale = Localizations.localeOf(context);
    _emergencyProvider.startTimerEmergency(
        locale: locale, orderId: widget.orderId);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _emergencyProvider.closeTimer();
        break;
      case AppLifecycleState.resumed:
        _startTimer();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _emergencyProvider.closeTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetWinchOffersProvider>(
        builder: (context, provider, child) {
      return Directionality(
        textDirection:
            Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: ColorsPalette.lightGrey,
          appBar: AppBarApp(
            title: '${LocaleKeys.carPartsResults.tr()} ${widget.orderId}',
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                color: ColorsPalette.primaryLightColor,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(AssetsManager.carShape),
                        UtilValues.gap4,
                        Text(
                          '${widget.car}',
                          style: TextStyle(
                            color: ColorsPalette.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AssetsManager.billing,
                          color: ColorsPalette.primaryColor,
                        ),
                        UtilValues.gap4,
                        Text(
                          LocaleKeys.suggestsCost.tr(),
                          style: TextStyle(
                              color: ColorsPalette.customGrey,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                        UtilValues.gap4,
                        Text(
                          '${widget.cost} ${LocaleKeys.le.tr()}',
                          style: TextStyle(
                            color: ColorsPalette.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              UtilValues.gap8,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${provider.listEmergency.length} ${LocaleKeys.avaiOffer.tr()}',
                  style: TextStyle(
                      color: ColorsPalette.customGrey,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
              ),
              UtilValues.gap8,
              Expanded(
                child: Builder(
                    builder: (context) {
                  if (provider.listEmergency.isEmpty) {
                    return _noResult();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return UtilValues.gap8;
                      },
                      itemCount: provider.listEmergency.length ?? 0,
                      itemBuilder: (context, index) {
                        final offer = provider.listEmergency[index];

                        return InkResponse(
                            child: WinchCard(
                                imageUrl: offer.name ?? '',
                                vendorName: offer.vendor?.name ?? '',
                                time: /*offer.expiresAt ??*/ '',
                                carNum: offer.carPlateNumber ?? '',
                                accept: () => _acceptOffer(
                                    offer.vendor?.id ?? 0,
                                    offer.id ?? 0,
                                    offer.phione ?? '',
                                    offer.vendor?.name ?? ''),
                                reject: () => _rejectOffer(
                                    offer.vendor?.id ?? 0, offer.id ?? 0)));
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

  _noResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50.w,
            child: const ClipRRect(
              child: Image(
                image: AssetImage('assets/images/no_orders.png'),
              ),
            ),
          ),
          UtilValues.gap8,
          Text(
            LocaleKeys.noResult.tr(),
            style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontFamily: ZainTextStyles.font),
          ),
          CircularProgressIndicator(),
          Text(
            LocaleKeys.canRequestWinch.tr(),
            style: TextStyle(
                fontSize: 14.sp,
                color: ColorsPalette.customGrey,
                fontWeight: FontWeight.w500,
                fontFamily: ZainTextStyles.font),
          ),
          SizedBox(
            height: 3.h,
          ),
          _startSearchButton()
        ],
      ),
    );
  }

  bool _loading = false;
  _acceptOffer(
      int vendorId, int workerId, String vendorNum, String vendorName) async {
    try {
      final order = await MiscellaneousApi.acceptEmergencyOffer(
        locale: context.locale,
        orderId: widget.orderId,
        vendorId: vendorId,
        workerId: workerId,
      );
      showSnackbar(
        context: context,
        status: SnackbarStatus.success,
        message: '${LocaleKeys.done.tr()}',
      );
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return EmergencyOrderDetailsScreen(
          vendorNum: vendorNum,
          vendorName: vendorName,
          orderNum: order.data?.order?.id ?? 0,
          orderType: 4,
        );
      }), (e) => false);
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
      setState(() => _loading = false);
    } finally {
      setState(() => _loading = false);
    }
  }

  _rejectOffer(int vendorId, int workerId) async {
    try {
      await MiscellaneousApi.rejectEmergencyOffer(
        locale: context.locale,
        orderId: widget.orderId,
        vendorId: vendorId,
        workerId: workerId,
      );
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
      setState(() => _loading = false);
    } finally {
      setState(() => _loading = false);
    }
  }

  _startSearchButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(14.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MapPolylineScreen();
          }));
        },
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: ColorsPalette.primaryColor),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all<Color>(ColorsPalette.primaryColor),
        ),
        child: Center(
          child: Text(
            LocaleKeys.moveToWinch.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorsPalette.white,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}
