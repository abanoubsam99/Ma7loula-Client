import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/font.dart';
import '../../../../../model/faq.dart';
import 'package:flutter_html/flutter_html.dart';

class FAQScreen extends StatefulWidget {
  static const String routeName = '/faq';
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.lightGrey,
      appBar: AppBarApp(
        title: LocaleKeys.popularQuestions.tr(),
      ),
      body: FutureBuilder<FAQModel>(
          future: MiscellaneousApi.getFaq(locale: context.locale),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(
                  color: ColorsPalette.primaryColor,
                ),
              );
            }
            final qA = snapshot.data!;

            if (qA.data == null) {
              return SizedBox.shrink();
            }

            return ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider(
                    color: ColorsPalette.customGrey.withOpacity(.3),
                    indent: 10,
                    endIndent: 10,
                  );
                },
                itemCount: qA.data.keys.toList().length,
                itemBuilder: (context, index) {
                  final questions =
                      qA.data.values.map((e) => e.question).toList();
                  final answers = qA.data.values.map((e) => e.answer).toList();
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ListTileTheme(
                            dense: true,
                            child: ExpansionTile(
                              backgroundColor: ColorsPalette.white,
                              trailing: isExpanded
                                  ? SvgPicture.asset(
                                      'assets/images/expanded.svg',
                                      fit: BoxFit.scaleDown,
                                      width: 10,
                                      height: 10,
                                      color: ColorsPalette.primaryColor,
                                    )
                                  : Helpers.isArabic(context)
                                      ? Transform.rotate(
                                          angle: pi,
                                          child: SvgPicture.asset(
                                            'assets/images/expand.svg',
                                            height: 10.h,
                                            width: 10.w,
                                            fit: BoxFit.scaleDown,
                                          ),
                                        )
                                      : SvgPicture.asset(
                                          'assets/images/expand.svg',
                                          height: 10.h,
                                          fit: BoxFit.scaleDown,
                                          width: 10.w,
                                        ),
                              title:
                              // Text(
                              //   questions[index] ?? '',
                              //   style: TextStyle(
                              //       color: ColorsPalette.primaryColor,
                              //       fontWeight: FontWeight.w600,
                              //       fontFamily: ZainTextStyles.font,
                              //       fontSize: 14.sp),
                              // ),

                              Html(
                                data:  questions[index] ?? '',
                                style: {
                                  "body": Style(
                                    color: ColorsPalette.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: ZainTextStyles.font,
                                    fontSize: FontSize(14.sp),
                                    margin: Margins.zero,
                                    // padding: EdgeInsets.zero,
                                  ),
                                },
                              ),
                              onExpansionChanged: (bool expanded) {
                                setState(() {
                                  isExpanded = expanded;
                                });
                              },
                              initiallyExpanded: isExpanded,
                              children: <Widget>[
                                // Text(
                                //   answers[index] ?? '',
                                //   style: TextStyle(
                                //       color: ColorsPalette.black,
                                //       fontWeight: FontWeight.w400,
                                //       fontFamily: ZainTextStyles.font,
                                //       fontSize: 14.sp),
                                // ),
                                Html(
                                  data: answers[index] ?? '',
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
                              ],
                            ),
                          ),
                        ]),
                  );
                });
          }),
    );
  }
}
