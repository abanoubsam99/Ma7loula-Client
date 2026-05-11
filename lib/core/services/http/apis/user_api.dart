import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola/model/otp_model.dart';
import 'package:ma7lola/model/user.dart';

import '../../../generated/locale_keys.g.dart';
import '../../../utils/helpers.dart';
import '../../secure_storage/secure_storage_keys.dart.dart';
import '../../secure_storage/secure_storage_service.dart';
import '../api_client.dart';
import '../api_endpoints.dart';
import '../interceptors/api_interceptor.dart';
import 'exceptions/api_exception.dart';

class UserApi {
  static Future<UserModel> login(
      {required String? phone,
      required String? password,
      required Locale locale}) async {
    try {
      // Validate inputs before sending to API
      if (phone == null || phone.isEmpty) {
        throw ApiException(LocaleKeys.fieldRequired.tr());
      }
      if (password == null || password.isEmpty) {
        throw ApiException(LocaleKeys.fieldRequired.tr());
      }
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final response = await ApiClient.instance.dio.post(loginEndPoint,
          data: {
           "phone": phone,
            "password": password,
            "fcm_token": fcmToken,
            // "device_id": "",
            "platform":Platform.isAndroid?"Android":"IOS"
          },
          options: Options(headers: {
            'lang': locale.languageCode,
          }));

      if (response.data == null) {
        throw ApiException(LocaleKeys.genericErrorMessage.tr());
      }
        
      return UserModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        rethrow;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<UserModel> register(
      {required String phone,
      required String password,
      required String name,
      required String mail,
      required String passwordConfirmation,
      required int otp,
      required Locale locale}) async {
    try {
      final response = await ApiClient.instance.dio.post(registerEndPoint,
          data: {
            "name": name,
            "email": mail,
            "phone": phone,
            "password": password,
            "password_confirmation": passwordConfirmation,
            "otp": otp
          },
          options: Options(headers: {
            'lang': locale.languageCode,
          }));

      return UserModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        rethrow;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      throw LocaleKeys.genericErrorMessage.tr();
    }
  }

  static Future<OtpModel> sentOtp(
      {required String? phone,
      required Locale locale,
      required String purpose}) async {
    try {
      final response = await ApiClient.instance.dio.post(otpEndPoint,
          data: {"phone": phone, "purpose": purpose},
          options: Options(headers: {
            'lang': locale.languageCode,
          }));

      return OtpModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<OtpModel> updatePassword(
      {required String? currentPassword,
      required String? password,
      required String? passwordConfirmation,
      required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(updatePasswordEndPoint,
          data: {
            "current_password": currentPassword,
            "password": password,
            "password_confirmation": passwordConfirmation
          },
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return OtpModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<UserModel> updateProfile(
      {required String? name,
      required String? mail,
      required String? phone,
      required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(updateProfileEndPoint,
          data: {"name": name, "email": mail, "phone": phone},
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return UserModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<UserModel> updatePhone(
      {required String? phone,
      required int? otp,
      required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(updatePhoneEndPoint,
          data: {"phone": phone, "otp": otp},
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return UserModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<OtpModel> resetPassword(
      {required String? passwordConfirmation,
      required String? password,
      required String? phone,
      required int? otp,
      required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(resetPasswordEndPoint,
          data: {
            "phone": phone,
            "password": password,
            "password_confirmation": passwordConfirmation,
            "otp": otp
          },
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return OtpModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<void> verifyOtp(
      {required String? phone,
      required String? otp,
      required Locale locale}) async {
    try {
      /*final response =*/ await ApiClient.instance.dio.post(verifyOtpEndPoint,
          data: {"phone": phone, "otp": otp},
          options: Options(headers: {
            'lang': locale.languageCode,
          }));

      // return OtpModel.fromJson(response.data);
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422 ||
          error.response!.statusCode == 400) {
        final errorMsg = error.response!.data['message'] as String;
        throw ApiException(errorMsg);
      } else {
        Helpers.debugDioError(error as DioError);
        log(error.toString());
        var tagsJson = jsonDecode(error.response!.data['message'].toString());
        throw tagsJson;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }

  static Future<String> setLanguage(int langID) async {
    try {
      final response = await ApiClient.instance.dio.post(
        '/$langID',
        options: Options(headers: authHeader),
      );

      return response.data;
    } on DioError catch (error) {
      Helpers.debugDioError(error);

      if (error.response!.statusCode == 422) {
        final errors = error.response!.data['error'] as List;
        throw ApiException(errors.join('\n'));
      } else {
        rethrow;
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  static Future<UserModel> getUser({required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);

      final response = await ApiClient.instance.dio.get(getProfileEndPoint,
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return UserModel.fromJson(response.data);
    } catch (error) {
      Helpers.debugDioError(error as DioError);
      log(error.toString());
      var tagsJson = jsonDecode(error.response!.data['message'].toString());
      throw tagsJson;
    }
  }
}
