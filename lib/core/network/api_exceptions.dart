import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  factory ApiException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Connection timed out. Please check your internet connection.',
          dioError.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final status = dioError.response?.statusCode;
        if (status == 401) {
          return ApiException(
            'Invalid or missing TMDB API Key. Please check your .env configuration.',
            401,
          );
        } else if (status == 404) {
          return ApiException('Requested resource not found.', 404);
        } else if (status != null && status >= 500) {
          return ApiException(
            'TMDB server error. Please try again later.',
            status,
          );
        }
        final message = dioError.response?.data is Map
            ? dioError.response?.data['status_message'] as String? ??
                  'An error occurred'
            : 'Received invalid status code: $status';
        return ApiException(message, status);
      case DioExceptionType.connectionError:
        return ApiException(
          'No internet connection. Please check your network and try again.',
        );
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled.');
      default:
        return ApiException('An unexpected network error occurred.');
    }
  }

  @override
  String toString() => message;
}
