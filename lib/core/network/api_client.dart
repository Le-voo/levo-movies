import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_constants.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({Dio? customDio}) {
    _dio =
        customDio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 12),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final apiKey = dotenv.env['TMDB_API_KEY']?.trim();
          final accessToken = dotenv.env['TMDB_ACCESS_TOKEN']?.trim();

          // Prefer v4 Access Token if provided, otherwise fallback to v3 API Key in query params
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          } else if (apiKey != null && apiKey.isNotEmpty) {
            options.queryParameters['api_key'] = apiKey;
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final customException = ApiException.fromDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: customException,
              message: customException.message,
            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(e.message ?? 'Unknown network error occurred');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
