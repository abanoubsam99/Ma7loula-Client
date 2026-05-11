import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart' as t;
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../../../../../../core/services/secure_storage/secure_storage_service.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../../../../model/car_model.dart';
import '../../../../../../model/time_ava.dart';

class SelectDateAndTimeScreen extends StatefulWidget {
  const SelectDateAndTimeScreen({
    Key? key,
    required this.carID,
    required this.car,
    required this.index,
    required this.cityID,
    required this.stateID,
    required this.products,
  }) : super(key: key);

  final int carID;
  final Car? car;
  final int index;
  final int stateID;
  final int cityID;
  final List<Map<String, dynamic>> products;

  @override
  State<SelectDateAndTimeScreen> createState() =>
      _SelectDateAndTimeScreenState();
}

class _SelectDateAndTimeScreenState extends State<SelectDateAndTimeScreen> {
  String? selected;
  DateTime _currentDate = DateTime.now();
  List<Slots>? times;
  @override
  Widget build(BuildContext context) {
    final generalStyle = TextStyle(
        color: ColorsPalette.black,
        fontFamily: ZainTextStyles.font,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp);
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          appBar: AppBarApp(
            title: LocaleKeys.dateTime.tr(),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UtilValues.gap32,
              CalendarCarousel(
                height: 350,
                // locale:context.locale.languageCode,
                showHeaderButton: false,
                  customDayBuilder: (
                      bool isSelectable,
                      int index,
                      bool isSelectedDay,
                      bool isToday,
                      bool isPrevMonthDay,
                      TextStyle textStyle,
                      bool isNextMonthDay,
                      bool isThisMonthDay,
                      DateTime day,
                      ) {
                    final today = DateTime.now();
                    final cleanToday = DateTime(today.year, today.month, today.day);
                    final cleanDay = DateTime(day.year, day.month, day.day);
                    if (cleanDay.isBefore(cleanToday)) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.4), // لون رمادي باهت
                            fontFamily: ZainTextStyles.font,
                            fontSize: 14.sp,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                headerTextStyle: TextStyle(
                    color: ColorsPalette.black,
                    fontFamily: ZainTextStyles.font,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp),
                daysHaveCircularBorder: true,
                selectedDateTime: _currentDate,
                onDayPressed: (DateTime date, List events) async {
                  final now = DateTime.now();
                  if (date.isBefore(DateTime(now.year, now.month, now.day))) return;
                  _currentDate = date;
                  final toot = widget.index == 1
                      ? await MiscellaneousApi.getTiresTime(
                      locale: context.locale,
                      cityID: widget.cityID,
                      stateID: widget.stateID,
                      dateTime: _currentDate,
                      products: widget.products)
                      : widget.index == 2
                      ? await MiscellaneousApi.getBatteriesTime(
                      locale: context.locale,
                      cityID: widget.cityID,
                      stateID: widget.stateID,
                      dateTime: _currentDate,
                      products: widget.products)
                      : await MiscellaneousApi.getCarPartsTime(
                      locale: context.locale,
                      cityID: widget.cityID,
                      stateID: widget.stateID,
                      dateTime: _currentDate,
                      products: widget.products);

                  times = toot.data?.slots;
                  setState(() {});
                },
                todayButtonColor: ColorsPalette.white,
                selectedDayButtonColor: ColorsPalette.primaryLightColor,
                dayButtonColor: ColorsPalette.white,
                weekDayFormat: WeekdayFormat.short,
                weekdayTextStyle: TextStyle(
                    color: ColorsPalette.grey2,
                    fontFamily: ZainTextStyles.font,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp),
                daysTextStyle: generalStyle,
                prevDaysTextStyle: generalStyle,
                minSelectedDate: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
                inactiveDaysTextStyle: generalStyle,
                inactiveWeekendTextStyle: generalStyle,
                markedDateCustomTextStyle: generalStyle,
                selectedDayBorderColor: ColorsPalette.primaryLightColor,
                selectedDayTextStyle: TextStyle(
                    color: ColorsPalette.primaryColor,
                    fontFamily: ZainTextStyles.font,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp),
                todayBorderColor: ColorsPalette.primaryColor,
                todayTextStyle: generalStyle,
                weekendTextStyle: generalStyle,
              ),
              Divider(
                color: ColorsPalette.grey,
              ),
              UtilValues.gap8,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  LocaleKeys.avaiTimes.tr(),
                  style: TextStyle(
                      color: ColorsPalette.black,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
              ),
              UtilValues.gap8,
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (times != null) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 16 / 8,
                        ),
                        itemCount: times?.length,
                        itemBuilder: (context, index) {
                          return IconButton(
                            onPressed: () {
                              if (times?[index].isAvailable ?? false) {
                                setState(() {
                                  selected = times?[index].time;
                                });
                              }
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                  color: selected == times?[index].time
                                      ? ColorsPalette.primaryLightColor
                                      : (!(times?[index].isAvailable ?? false))
                                          ? ColorsPalette.lightGrey
                                          : ColorsPalette.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: selected == times?[index].time
                                          ? ColorsPalette.primaryLightColor
                                          : ColorsPalette.grey)),
                              child: Center(
                                child: Text(times?[index].time ?? '',
                                    style: TextStyle(
                                        color: selected == times?[index].time
                                            ? ColorsPalette.primaryColor
                                            : ColorsPalette.black,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: ZainTextStyles.font,
                                        fontSize: 14.sp)),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return Center(
                        child: Column(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 50,
                          color: ColorsPalette.primaryColor,
                        ),
                        UtilValues.gap16,
                        Text(
                          LocaleKeys.noTimesFound.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: ColorsPalette.black,
                              fontSize: 12,
                              fontFamily: ZainTextStyles.font),
                        ),
                      ],
                    ));
                  },
                ),
              ),
              Container(
                color: ColorsPalette.white,
                padding: UtilValues.padding16,
                child: SimplePrimaryButton(
                  label: LocaleKeys.saveDate.tr(),
                  onPressed: () async {
                    if (selected != null) {
                      List<String> parts = selected?.split(':') ?? [];
                      int hours = int.parse(parts[0]);
                      int minutes = int.parse(parts[1]);
                      int seconds = int.parse(parts[2]);

                      DateTime newDateTime = _currentDate.add(Duration(
                          hours: hours, minutes: minutes, seconds: seconds));

                      String formattedDateTime =
                          t.DateFormat('yyyy-MM-dd HH:mm').format(newDateTime);

                      await Future.wait([
                        SecureStorageService.instance.writeString(
                          key: SecureStorageKeys.dateTime,
                          value: formattedDateTime.toString(),
                        ),
                      ]);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }
}
