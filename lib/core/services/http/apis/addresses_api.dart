// import 'dart:developer';
//
// import 'package:dio/dio.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
//
// import '../../secure_storage/secure_storage_keys.dart.dart';
// import '../../secure_storage/secure_storage_service.dart';
// import '../api_client.dart';
//
// class AddressesApi {
//   static Future<List<Address>> getAddresses({required Locale locale}) async {
//     final token = await SecureStorageService.instance
//         .readString(key: SecureStorageKeys.token);
//
//     try {
//       final response = await ApiClient.instance.dio.get(
//         'addresses',
//         options: Options(headers: {
//           'Authorization': 'Bearer $token',
//           'lang': locale.languageCode,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         if (response.data['data'] != null &&
//             response.data['data']['userCars'] != null) {
//           return (response.data['data']['userCars'] as List)
//               .map((car) => UserCars.fromJson(car))
//               .toList();
//         } else {
//           throw Exception('No user cars found in response data');
//         }
//       } else {
//         throw Exception('Failed to load cars: ${response.statusCode}');
//       }
//     } on DioError catch (dioError) {
//       log('Dio error: ${dioError.message}');
//       throw Exception('Network error: ${dioError.message}');
//     } catch (error) {
//       log('General error: ${error.toString()}');
//       throw Exception('An unexpected error occurred: ${error.toString()}');
//     }
//   }
//
//   static Future<void> addNewAddress(Map<String, dynamic> data) async {
//     try {
//       await ApiClient.instance.dio.post(
//         'addresses',
//         data: data,
//         options: Options(headers: authHeader),
//       );
//     } catch (error) {
//       log(error.toString());
//       throw LocaleKeys.genericErrorMessage.tr();
//     }
//   }
//
//   static Future<void> deleteAddress(int addressId) async {
//     try {
//       await ApiClient.instance.dio.delete(
//         'addresses/$addressId',
//         options: Options(headers: authHeader),
//       );
//     } catch (error) {
//       log(error.toString());
//       throw LocaleKeys.genericErrorMessage.tr();
//     }
//   }
// }
