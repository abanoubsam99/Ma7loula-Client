import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/core/utils/util_values.dart';
import 'package:sizer/sizer.dart';

import 'chat_message.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onTap;

  ChatMessageItem({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Align(
        alignment: (message.isSender) ? Alignment.topRight : Alignment.topLeft,
        child: message.isSentByBot
            ? Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: (message.isSender)
                      ? ColorsPalette.con
                      : ColorsPalette.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (message.time != null)
                      Text(
                        message.time ?? '',
                        style: TextStyle(
                            color: ColorsPalette.default3,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: ZainTextStyles.font),
                      ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      child: Text(
                        message.message,
                        // maxLines: 1,
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: ZainTextStyles.font),
                      ),
                    ),
                  ],
                ),
              )
            : InkWell(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                      color: ColorsPalette.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: message.isSender
                          ? Border()
                          : Border.all(
                              color: (message.isSender)
                                  ? ColorsPalette.primaryColor
                                  : ColorsPalette.border)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .7,
                        child: Text(
                          message.message,
                          // maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: ZainTextStyles.font),
                        ),
                      ),
                      UtilValues.gap8,
                      if (!message.isSender)
                        SvgPicture.asset(
                          AssetsManager.angleLeftSmall,
                          color: message.isSender
                              ? ColorsPalette.primaryColor
                              : ColorsPalette.black,
                        )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
