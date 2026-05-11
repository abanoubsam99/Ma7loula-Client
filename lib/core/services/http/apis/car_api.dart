import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola/core/services/http/api_endpoints.dart';

import '../../../../model/add_car_model_response.dart' as m;
import '../../../../model/car_model.dart';
import '../../../../model/local_car.dart';
import '../../../utils/helpers.dart';
import '../../secure_storage/secure_storage_keys.dart.dart';
import '../../secure_storage/secure_storage_service.dart';
import '../api_client.dart';
import 'exceptions/api_exception.dart';

class CarApi {
  static Future<List<UserCars>> getCars({required Locale locale}) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);

    try {
      final response = await ApiClient.instance.dio.get(
        carsEndPoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      if (response.statusCode == 200) {
        if (response.data['data'] != null &&
            response.data['data']['userCars'] != null) {
          return (response.data['data']['userCars'] as List)
              .map((car) => UserCars.fromJson(car))
              .toList();
        } else {
          throw Exception('No user cars found in response data');
        }
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } on DioError catch (dioError) {
      log('Dio error: ${dioError.message}');
      throw Exception('Network error: ${dioError.message}');
    } catch (error) {
      log('General error: ${error.toString()}');
      throw Exception('An unexpected error occurred: ${error.toString()}');
    }
  }

  static Future<LocalCarModel> getCarById(
      {required Locale locale, required int carId}) async {
    try {
      final response = await ApiClient.instance.dio.get(
        carByIdEndPoint,
        data: {"car_id": carId},
        options: Options(headers: {
          'lang': locale.languageCode,
        }),
      );

      if (response.statusCode == 200) {
        return LocalCarModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } on DioError catch (dioError) {
      log('Dio error: ${dioError.message}');
      throw Exception('Network error: ${dioError.message}');
    } catch (error) {
      log('General error: ${error.toString()}');
      throw Exception('An unexpected error occurred: ${error.toString()}');
    }
  }

  static Future<m.AddCarModelResponse> addCar(
      {required int? carId, required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      final response = await ApiClient.instance.dio.post(addCarEndPoint,
          data: {"car_id": carId, "is_default": true},
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));

      return m.AddCarModelResponse.fromJson(response.data);
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

  static Future<void> deleteCar(
      {required int carId, required Locale locale}) async {
    try {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);
      await ApiClient.instance.dio.delete(deleteCarEndPoint,
          data: {"user_car_id": carId},
          options: Options(headers: {
            'lang': locale.languageCode,
            'Authorization': 'Bearer $token',
          }));
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

  static Future<void> setCarDefault({
    required Locale locale,
    required int carId,
  }) async {
    final token = await SecureStorageService.instance
        .readString(key: SecureStorageKeys.token);
    try {
      await ApiClient.instance.dio.post(
        setCarDefaultEndPoint,
        data: {"user_car_id": carId},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'lang': locale.languageCode,
        }),
      );

      // Helpers.logDioResponse(response);
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
}
