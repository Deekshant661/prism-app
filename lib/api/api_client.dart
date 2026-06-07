import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppError {
  final String message;
  final int? statusCode;
  const AppError({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static ApiClient? _instance;
  late final Dio dio;

  ApiClient._() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => debugPrint('[API] $o'),
      ));
    }

    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        final message = _extractMessage(error);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: AppError(
            message: message,
            statusCode: error.response?.statusCode,
          ),
          type: error.type,
          response: error.response,
        ));
      },
    ));
  }

  factory ApiClient() {
    _instance ??= ApiClient._();
    return _instance!;
  }

  String _extractMessage(DioException error) {
    if (error.response?.data is Map) {
      final detail = (error.response!.data as Map)['detail'];
      if (detail is String) return detail;
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Check your network.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.connectionError:
        return 'Cannot connect to server. Is the backend running?';
      default:
        return error.message ?? 'An unexpected error occurred.';
    }
  }
}

/// Global accessor
final api = ApiClient().dio;
