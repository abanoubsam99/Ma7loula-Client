import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:ma7lola/core/services/http/apis/car_api.dart';

import '../model/car_model.dart';

class CarProvider with ChangeNotifier {
  List<UserCars> _cars = [];
  List<UserCars> get cars => [..._cars];

  UserCars? _userSelectedCars;

  set selectedAddress(UserCars car) {
    _userSelectedCars = car;
    notifyListeners();
  }

  UserCars get userSelectedCars => _userSelectedCars ??= _cars.first;

  Future<void> addCar({required int carId, required Locale locale}) async {
    try {
      await CarApi.addCar(carId: carId, locale: locale);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }
  // Future<void> getCars({required Locale locale}) async {
  //   try {
  //     _cars = await CarApi.getCars(locale: locale);
  //     notifyListeners();
  //   } catch (_) {}
  // }

  // Future<void> addNewAddress(Map<String, dynamic> data) async {
  //   try {
  //     await AddressesApi.addNewAddress(data);
  //     await getAddresses();
  //   } catch (_) {}
  // }
}
