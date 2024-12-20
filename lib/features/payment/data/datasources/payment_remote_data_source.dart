import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ride_now_app/core/constants/api_routes.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/error/exception.dart';
import 'package:ride_now_app/core/network/app_response.dart';
import 'package:ride_now_app/core/network/network_client.dart';

abstract interface class PaymentRemoteDataSource {
  Future<String> getRidePaymentLink({
    required int rideId,
    required double paymentAmount,
    required int requiredSeats,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final NetworkClient _networkClient;
  final FlutterSecureStorage _flutterSecureStorage;
  PaymentRemoteDataSourceImpl(this._networkClient, this._flutterSecureStorage);
  @override
  Future<String> getRidePaymentLink(
      {required int rideId,
      required double paymentAmount,
      required int requiredSeats}) async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    try {
      final response = await _networkClient
          .invoke("${ApiRoutes.joinRide}/$rideId", RequestType.post, headers: {
        "Authorization": "Bearer $token"
      }, requestBody: {
        "payment_amount": paymentAmount,
        "required_seats": requiredSeats,
      });

      final appResponse = AppResponse.fromJson(response.data);

      if (response.statusCode == 200) {
        return appResponse.data as String;
      } else {
        throw ServerException(appResponse.message);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
