import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:ma7lola/model/about_app.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../../core/utils/font.dart';

class PrivacyScreen extends StatefulWidget {
  static const String routeName = '/privacy';
  @override
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.lightGrey,
      appBar: AppBarApp(
        title: LocaleKeys.privacy.tr(),
      ),
      body: FutureBuilder<AboutAppModel>(
          future: MiscellaneousApi.getPrivacy(locale: context.locale),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(
                  color: ColorsPalette.primaryColor,
                ),
              );
            }

            final privacy = snapshot.data!;

            if (privacy.data == null) {
              return SizedBox.shrink();
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  // Text(
                  //   privacy.data?.text ?? '',
                  //   style: TextStyle(
                  //       color: ColorsPalette.black,
                  //       fontWeight: FontWeight.w400,
                  //       fontFamily: ZainTextStyles.font,
                  //       fontSize: 14.sp),
                  // ),
                  Html(
                    data: privacy.data?.text ?? '',
                    // style: {
                    //   "body": Style(
                    //     color: ColorsPalette.black,
                    //     fontWeight: FontWeight.w400,
                    //     fontFamily: ZainTextStyles.font,
                    //     fontSize: FontSize(14.sp),
                    //     margin: Margins.zero,
                    //     // padding: EdgeInsets.zero,
                    //   ),
                    // },
                  ),
                ]),
              ),
            );
          }),
    );
  }
}
