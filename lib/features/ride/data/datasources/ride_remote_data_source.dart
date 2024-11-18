import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ride_now_app/core/constants/api_routes.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/error/exception.dart';
import 'package:ride_now_app/core/network/app_response.dart';
import 'package:ride_now_app/core/network/network_client.dart';
import 'package:ride_now_app/core/secrets/app_secret.dart';
import 'package:ride_now_app/features/ride/data/models/auto_complete_prediction_model.dart';
import 'package:ride_now_app/features/ride/data/models/place_auto_complete_api_response_model.dart';
import 'package:ride_now_app/features/ride/data/models/ride_model.dart';

abstract interface class RideRemoteDataSource {
  Future<List<RideModel>> listAvailableRides({
    required int pages,
  });

  Future<List<AutoCompletePredictionModel>?> locationAutoCompleteSuggestion(
      {required String query});
}

class RideRemoteDataSourceImpl implements RideRemoteDataSource {
  final NetworkClient _networkClient;
  final FlutterSecureStorage _flutterSecureStorage;
  RideRemoteDataSourceImpl(this._networkClient, this._flutterSecureStorage);
  @override
  Future<List<RideModel>> listAvailableRides({required pages}) async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    try {
      final response = await _networkClient.invoke(
        ApiRoutes.ride,
        RequestType.get,
        queryParameters: {
          "page": pages,
        },
        headers: {"Authorization": "Bearer $token"},
      );

      final appResponse = AppResponse.fromJson(response.data);

      if (response.statusCode == 200) {
        return (appResponse.data as List)
            .map((data) => RideModel.fromJson(data))
            .toList();
      } else {
        throw ServerException(appResponse.message);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<AutoCompletePredictionModel>?> locationAutoCompleteSuggestion(
      {required String query}) async {
    try {
      final response = await _networkClient.invoke(
        ApiRoutes.autoCompleteApiRoute,
        RequestType.get,
        queryParameters: {
          "input": query,
          "components": "country:my",
          "key": AppSecret.mapAPIKey,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse =
            PlaceAutoCompleteApiResponseModel.fromJson(response.data);

        return apiResponse.predictions
            ?.map((prediction) => prediction as AutoCompletePredictionModel)
            .toList();
      } else {
        throw const ServerException("Unable to fetch search suggestion");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerException catch (e) {
      throw ServerException(e.message);
    }
  }
}
