import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/util_values.dart';
import '../../../../../model/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  static String routeName = '/notifications';
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _numberOfPostsPerRequest = 10;

  // final PagingController<int, NotificationDetailsModel> _pagingController =
  // PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    // final items =
    // await getIt<NotificationRepository>().getNotifications(pageKey);

    // setState(() {
    //   if (items.isEmpty) _pagingController.appendLastPage([]);
    //
    //   final isLastPage = items.length < _numberOfPostsPerRequest;
    //   if (isLastPage) {
    //     _pagingController.appendLastPage(items);
    //   } else {
    //     final nextPageKey = pageKey + 1;
    //     _pagingController.appendPage(items, nextPageKey);
    //   }
    // });
  }

  @override
  void initState() {
    // _pagingController.addPageRequestListener((pageKey) {
    //   _fetchPage(pageKey);
    // });
    super.initState();
  }

  final List<NotificationDetailsModel> _list = [];
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ColorsPalette.lightGrey,
        appBar: AppBarApp(
          title: LocaleKeys.notification.tr(),
        ),
        body: Column(
          children: [
            UtilValues.gap8,
            Expanded(
              child: ListView.builder(
                itemCount: _list.length,
                itemBuilder: (context, index) {
                  return buildNotificationCard(_list[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationCard(NotificationDetailsModel notificationItem) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorsPalette.extraDarkGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            notificationItem.title ?? '',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: ColorsPalette.black,
                fontFamily: ZainTextStyles.font),
            textDirection: TextDirection.rtl,
          ),
          if (notificationItem.desc != null)
            Text(
              notificationItem.desc ?? '',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: ColorsPalette.customGrey,
                  fontFamily: ZainTextStyles.font),
              textDirection: TextDirection.rtl,
            ),
          Text(
            notificationItem.createdDate ?? '',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: ColorsPalette.customGrey,
                fontFamily: ZainTextStyles.font),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
