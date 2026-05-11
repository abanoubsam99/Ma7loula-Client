import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../core/generated/locale_keys.g.dart';
import '../core/services/http/apis/user_api.dart';
import '../core/services/secure_storage/secure_storage_keys.dart.dart';
import '../core/services/secure_storage/secure_storage_service.dart';
import '../model/user.dart';
import '../view/screens/auth/LoginScreen.dart';

class UserProvider with ChangeNotifier {
  UserModel? user;

  bool get isLoggedIn {
    if (user == null) {
      return false;
    } else {
      if (user?.data?.user?.phone == null /*|| user!.addresses.isEmpty*/) {
        return false;
      } else {
        return true;
      }
    }
  }

  bool get hasSetTheName => user?.data?.user?.phone != null;

  Future<void> login(
      {required String phone,
      required String password,
      required Locale locale}) async {
    try {
      user =
          await UserApi.login(phone: phone, password: password, locale: locale);
      final token = user?.data?.user?.authToken;
      await Future.wait([
        SecureStorageService.instance.writeString(
          key: SecureStorageKeys.token,
          value: token ?? '',
        ),
      ]);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> register(
      {required String phone,
      required String password,
      required String name,
      required String mail,
      required String passwordConfirmation,
      required int otp,
      required Locale locale}) async {
    try {
      user = await UserApi.register(
          phone: phone,
          password: password,
          name: name,
          mail: mail,
          passwordConfirmation: passwordConfirmation,
          otp: otp,
          locale: locale);
      final token = user?.data?.user?.authToken;
      await Future.wait([
        SecureStorageService.instance.writeString(
          key: SecureStorageKeys.token,
          value: token ?? '',
        ),
      ]);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> sentOtp(
      {required String phone,
      required String purpose,
      required Locale locale}) async {
    try {
      await UserApi.sentOtp(phone: phone, locale: locale, purpose: purpose);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> updatePassword(
      {required String password,
      required String currentPassword,
      required String passwordConfirmation,
      required Locale locale}) async {
    try {
      await UserApi.updatePassword(
          currentPassword: currentPassword,
          password: password,
          passwordConfirmation: passwordConfirmation,
          locale: locale);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> updateProfile(
      {required String name,
      required String mail,
      required String phone,
      required Locale locale}) async {
    try {
      final res = await UserApi.updateProfile(
          name: name, mail: mail, phone: phone, locale: locale);
      user = res;
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> updatePhone(
      {required String phone, required int otp, required Locale locale}) async {
    try {
      final res =
          await UserApi.updatePhone(otp: otp, phone: phone, locale: locale);
      user = res;
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> resetPassword(
      {required String? passwordConfirmation,
      required String? password,
      required String? phone,
      required int? otp,
      required Locale locale}) async {
    try {
      await UserApi.resetPassword(
          passwordConfirmation: passwordConfirmation,
          password: password,
          phone: phone,
          otp: otp,
          locale: locale);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp(
      {required String phone,
      required String otp,
      required Locale locale}) async {
    try {
      await UserApi.verifyOtp(phone: phone, otp: otp, locale: locale);
      notifyListeners();
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<String> setLang(int langID) async {
    try {
      final response = await UserApi.setLanguage(langID);

      notifyListeners();
      return response;
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<void> autoLogin(
      {required Locale locale, required BuildContext context}) async {
    try {
      final storedToken = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);

      if (storedToken != null) {
        final response = await UserApi.getUser(locale: locale);
        if (response.data != null) {
          user = response;
        } else {
          await logout();
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return LoginScreen(
              products: [],
              batteries: [],
              tires: [],
              carID: 0,
              fromWinch: false,
              fromCart: false,
              fromCartBatteries: false,
              fromCartTires: false,
              car: null,
            );
          }));
        }

        notifyListeners();
      }
    } catch (error) {
      await logout();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return LoginScreen(
          products: [],
          batteries: [],
          tires: [],
          carID: 0,
          fromWinch: false,
          fromCart: false,
          fromCartBatteries: false,
          fromCartTires: false,
          car: null,
        );
      }));
    }
  }

  Future<void> logout(/*email, fcm*/) async {
    try {
      // await UserApi.logout(email, fcm);
      // await GoogleSignInApi.logout();
      await SecureStorageService.instance.deleteAllData();
      await SecureStorageService.instance.writeBool(
        key: SecureStorageKeys.hasViewedOnboarding,
        value: true,
      );
      //AuthServices().signOut();
      //GoogleSignIn().signOut();

      user = null;
      notifyListeners();
    } catch (error) {
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }
}
