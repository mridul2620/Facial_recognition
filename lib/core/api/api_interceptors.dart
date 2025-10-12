import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌──────────────────────────────────────────────────');
      print('│ REQUEST: ${options.method} ${options.path}');
      print('│ Headers: ${options.headers}');
      print('│ Query Parameters: ${options.queryParameters}');
      if (options.data != null) {
        if (options.data is FormData) {
          print('│ Body: [FormData with ${(options.data as FormData).fields.length} fields]');
        } else {
          print('│ Body: ${options.data}');
        }
      }
      print('└──────────────────────────────────────────────────');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌──────────────────────────────────────────────────');
      print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
      print('│ Data: ${response.data}');
      print('└──────────────────────────────────────────────────');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌──────────────────────────────────────────────────');
      print('│ ERROR: ${err.requestOptions.method} ${err.requestOptions.path}');
      print('│ Status Code: ${err.response?.statusCode}');
      print('│ Error: ${err.message}');
      print('│ Response: ${err.response?.data}');
      print('└──────────────────────────────────────────────────');
    }
    super.onError(err, handler);
  }
}