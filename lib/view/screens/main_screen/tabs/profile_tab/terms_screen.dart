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

class TermsScreen extends StatefulWidget {
  static const String routeName = '/terms';
  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.lightGrey,
      appBar: AppBarApp(
        title: LocaleKeys.terms.tr(),
      ),
      body: FutureBuilder<AboutAppModel>(
          future: MiscellaneousApi.getTerms(locale: context.locale),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(
                  color: ColorsPalette.primaryColor,
                ),
              );
            }

            final terms = snapshot.data!;

            if (terms.data == null) {
              return SizedBox.shrink();
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  // Text(
                  //   terms.data?.text ?? '',
                  //   style: TextStyle(
                  //       color: ColorsPalette.black,
                  //       fontWeight: FontWeight.w400,
                  //       fontFamily: ZainTextStyles.font,
                  //       fontSize: 14.sp),
                  // ),
                  Html(
                    data: terms.data?.text ?? '',
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
