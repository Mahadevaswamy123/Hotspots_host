import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://staging.chamberofsecrets.8club.co/v1/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<Response<dynamic>> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) async {
    return _dio.get(endpoint, queryParameters: queryParameters);
  }
}

final apiClient = ApiClient();
