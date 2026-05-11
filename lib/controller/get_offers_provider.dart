import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';

import '../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../core/services/secure_storage/secure_storage_service.dart';
import '../model/winch_offers_model.dart';

class GetWinchOffersProvider extends ChangeNotifier {
  Timer? timer;
  Timer? timerEm;
  List<Wokers> listRequests = [];
  List<Wokers> listEmergency = [];

  void closeTimer() {
    timer?.cancel();
    timerEm?.cancel();
    timer = null;
    timerEm = null;
    listRequests = [];
    listEmergency = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void startTimerRequestLiveTutors({
    required Locale locale,
    required int orderId,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    if (token == null) return;

    closeTimer();

    timer = Timer.periodic(const Duration(seconds: 4), (_) async {
      /* final offers =*/
      await getPendingRequest(locale: locale, orderId: orderId);

      // if (offers?.isEmpty ?? true) {
      //   closeTimer();
      // }
    });
  }

  Future<List<Wokers>?> getPendingRequest({
    required Locale locale,
    required int orderId,
  }) async {
    try {
      final offers =
          await MiscellaneousApi.getOffers(locale: locale, orderId: orderId);

      listRequests = offers.data?.wokers ?? [];
      notifyListeners();
      return listRequests;
    } catch (error) {
      listRequests = [];
      notifyListeners();
      return listRequests;
    }
  }

  void startTimerEmergency({
    required Locale locale,
    required int orderId,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    if (token == null) return;

    closeTimer();

    timerEm = Timer.periodic(const Duration(seconds: 4), (_) async {
      /* final offers =*/
      await getPendingEmergency(locale: locale, orderId: orderId);

      // if (offers?.isEmpty ?? true) {
      //   closeTimer();
      // }
    });
  }

  Future<List<Wokers>?> getPendingEmergency({
    required Locale locale,
    required int orderId,
  }) async {
    try {
      final offers = await MiscellaneousApi.getEmergencyOffers(
          locale: locale, orderId: orderId);

      listEmergency = offers.data?.wokers ?? [];
      notifyListeners();
      return listEmergency;
    } catch (error) {
      listEmergency = [];
      notifyListeners();
      return listEmergency;
    }
  }
}
