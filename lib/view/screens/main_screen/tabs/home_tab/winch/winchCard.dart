import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';

class WinchCard extends StatelessWidget {
  final String imageUrl;
  final String time;
  final String vendorName;
  final String carNum;

  final VoidCallback accept;
  final VoidCallback reject;

  const WinchCard({
    super.key,
    required this.imageUrl,
    required this.vendorName,
    required this.time,
    required this.carNum,
    required this.accept,
    required this.reject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width,
      // margin: UtilValues.paddinglrt8,
      // padding: UtilValues.padding8,
      decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: UtilValues.borderRadius10,
          border: Border.all(color: ColorsPalette.border2)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                AssetsManager.userPic,
                width: MediaQuery.of(context).size.width * .25,
                fit: BoxFit.fill,
              ),
            ),
          ),
          UtilValues.gap12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UtilValues.gap8,
              SizedBox(
                height: 20,
                width: MediaQuery.of(context).size.width * .57,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vendorName,
                      style: const TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: ZainTextStyles.font),
                    ),
                    Spacer(),
                    Text(
                      carNum,
                      style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: ZainTextStyles.font),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .5,
                child: Text(
                  time,
                  maxLines: 1,
                  style: const TextStyle(
                      color: ColorsPalette.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 15),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .6,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: accept,
                          style: ButtonStyle(
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                TextStyle(
                                  fontSize: 14.sp,
                                ),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: ColorsPalette.primaryColor),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  ColorsPalette.primaryColor)),
                          child: Text(
                            LocaleKeys.accept.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: ColorsPalette.lightGrey,
                                fontFamily: ZainTextStyles.font),
                            //maxLines: 3,
                          )),
                    ),
                    UtilValues.gap8,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: reject,
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(
                                fontSize: 14.sp,
                                fontFamily: ZainTextStyles.font),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side:
                                  const BorderSide(color: ColorsPalette.black),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              ColorsPalette.lightGrey),
                        ),
                        child: Text(
                          LocaleKeys.reject.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: ColorsPalette.black,
                              fontFamily: ZainTextStyles.font),
                          //maxLines: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
