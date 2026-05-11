import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../model/start_up_slides.dart';
import '../../../generated/locale_keys.g.dart';
import '../api_client.dart';
import '../api_endpoints.dart';

class StartUpSlidesApi {
  static Future<SliderData> getStartUpSlides({required Locale locale}) async {
    try {
      final response = await ApiClient.instance.dio.get(
        startUpSlidesEndPoint,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'lang': locale.languageCode,
          'App': 'client'
        }),
      );

      return SliderData.fromJson(response.data);
    } catch (error) {
      log(error.toString());
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }
}
