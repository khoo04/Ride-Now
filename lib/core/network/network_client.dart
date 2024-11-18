import 'package:dio/dio.dart';
import 'package:ride_now_app/core/error/exception.dart';

class NetworkClient {
  final Dio _dio;
  NetworkClient(this._dio);

  Future<Response> invoke(String url, RequestType requestType,
      {Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers,
      Object? requestBody}) async {
    Response response;
    try {
      switch (requestType) {
        case RequestType.get:
          response = await _dio.get(
            url,
            data: requestBody,
            queryParameters: queryParameters,
            options: Options(
              validateStatus: (_) => true,
              responseType: ResponseType.json,
              headers: headers,
            ),
          );
        case RequestType.post:
          response = await _dio.post(
            url,
            queryParameters: queryParameters,
            data: requestBody,
            options: Options(
              validateStatus: (_) => true,
              responseType: ResponseType.json,
              headers: headers,
            ),
          );
        case RequestType.put:
          response = await _dio.put(
            url,
            queryParameters: queryParameters,
            data: requestBody,
            options: Options(
              validateStatus: (_) => true,
              responseType: ResponseType.json,
              headers: headers,
            ),
          );
        case RequestType.delete:
          response = await _dio.delete(
            url,
            queryParameters: queryParameters,
            data: requestBody,
            options: Options(
              validateStatus: (_) => true,
              responseType: ResponseType.json,
              headers: headers,
            ),
          );
        case RequestType.patch:
          response = await _dio.patch(
            url,
            queryParameters: queryParameters,
            data: requestBody,
            options: Options(
              validateStatus: (_) => true,
              responseType: ResponseType.json,
              headers: headers,
            ),
          );
      }
      return response;
    } on DioException {
      rethrow;
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}

enum RequestType { get, post, put, delete, patch }
