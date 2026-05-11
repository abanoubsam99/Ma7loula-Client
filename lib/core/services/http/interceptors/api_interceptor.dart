import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../../secure_storage/secure_storage_keys.dart.dart';
import '../../secure_storage/secure_storage_service.dart';

const authHeader = {
  'Authorization': '',
  'lang': '',
};

class ApiInterceptors extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    /// Attach Token
    if (options.headers.containsKey(authHeader.keys.first)) {
      final token = await SecureStorageService.instance
          .readString(key: SecureStorageKeys.token);

      options.headers[authHeader.keys.first] = 'Bearer $token';
    }

    /// PRINT CURL
    _printCurl(options);

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    log('''
✅ RESPONSE [${response.statusCode}]
URL => ${response.requestOptions.uri}

${const JsonEncoder.withIndent('  ').convert(response.data)}
''');

    super.onResponse(response, handler);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    log('''
❌ ERROR [${err.response?.statusCode}]
URL => ${err.requestOptions.uri}

${err.response?.data}
''');

    super.onError(err, handler);
  }

  void _printCurl(RequestOptions options) {
    try {
      final curl = StringBuffer();

      curl.write('curl');

      /// METHOD
      curl.write(' -X ${options.method}');

      /// HEADERS
      options.headers.forEach((key, value) {
        curl.write(" -H '$key: $value'");
      });

      /// BODY
      if (options.data != null) {
        if (options.data is FormData) {
          final formData = options.data as FormData;

          for (final field in formData.fields) {
            curl.write(" -F '${field.key}=${field.value}'");
          }

          for (final file in formData.files) {
            curl.write(
              " -F '${file.key}=@${file.value.filename}'",
            );
          }
        } else {
          curl.write(
            " -d '${jsonEncode(options.data)}'",
          );
        }
      }

      /// URL
      curl.write(" '${options.uri}'");

      log('''
╔══════════════════════════════════════════
🚀 CURL REQUEST
╚══════════════════════════════════════════

$curl

''');
    } catch (e) {
      log('CURL LOGGER ERROR => $e');
    }
  }
}