import 'package:flutter/material.dart';

import '../core/services/http/apis/start_up_slides_api.dart';
import '../model/start_up_slides.dart';

class StartUpSlidesProvider with ChangeNotifier {
  late SliderData _startUpSlides;
  SliderData get startUpSlides => _startUpSlides;

  Future<void> getStartUpSlides({required Locale locale}) async {
    try {
      _startUpSlides = await StartUpSlidesApi.getStartUpSlides(locale: locale);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
