import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ride_now_app/core/constants/api_routes.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/error/exception.dart';
import 'package:ride_now_app/core/network/app_response.dart';
import 'package:ride_now_app/core/network/network_client.dart';
import 'package:ride_now_app/core/secrets/app_secret.dart';
import 'package:ride_now_app/core/utils/round_cost.dart';
import 'package:ride_now_app/features/ride/data/models/auto_complete_prediction_model.dart';
import 'package:ride_now_app/features/ride/data/models/place_auto_complete_api_response_model.dart';
import 'package:ride_now_app/features/ride/data/models/place_details_model.dart';
import 'package:ride_now_app/features/ride/data/models/ride_model.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';

abstract interface class RideRemoteDataSource {
  ///Internal API Call
  Future<List<RideModel>> listAvailableRides({
    required int pages,
  });

  Future<List<RideModel>> searchAvailableRides({
    required PlaceDetails fromPlace,
    PlaceDetails? toPlace,
    required DateTime departureTime,
    required int seats,
  });

  Future<RideModel> createRide({
    required PlaceDetails origin,
    required PlaceDetails destination,
    required DateTime departureTime,
    required double baseCost,
    required int vehicleId,
  });

  Future<RideModel> updateRide({
    required int rideId,
    required PlaceDetails? origin,
    required PlaceDetails? destination,
    required DateTime? departureTime,
    required double? baseCost,
    required int? vehicleId,
  });

  Future<List<RideModel>> getJoinedRides();

  Future<List<RideModel>> getCreatedRides();

  Future<RideModel> fetchRideById({required int rideId});

  ///External API Call (Google Maps / Open Street Maps)
  Future<List<AutoCompletePredictionModel>?> locationAutoCompleteSuggestion(
      {required String query});

  Future<PlaceDetailsModel> geocodingFetchPlaceDetails(
      {required double latitude, required double longitude});

  Future<PlaceDetailsModel> fetchPlaceDetails({required String placeId});

  Future<double> getPriceSuggestionByDistance({
    required PlaceDetails fromPlace,
    required PlaceDetails toPlace,
    required double fuelConsumptions,
  });
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
    } catch (e) {
      throw ServerException(e.toString());
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

  @override
  Future<PlaceDetailsModel> fetchPlaceDetails({required String placeId}) async {
    try {
      final response = await _networkClient.invoke(
        ApiRoutes.placeDetailsApiRoute,
        RequestType.get,
        queryParameters: {
          "place_id": placeId,
          "fields": "formatted_address,name,geometry",
          "key": AppSecret.mapAPIKey,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        return PlaceDetailsModel.fromJson(response.data);
      } else {
        throw const ServerException(Constants.placeDetailsAPIError);
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
  Future<PlaceDetailsModel> geocodingFetchPlaceDetails(
      {required double latitude, required double longitude}) async {
    try {
      final response = await _networkClient.invoke(
        ApiRoutes.geocodingApiRoute,
        RequestType.get,
        queryParameters: {
          "lat": latitude,
          "lon": longitude,
          "format": "jsonv2",
        },
      );

      if (response.statusCode == 200) {
        return PlaceDetailsModel.fromOpenStreetJson(response.data);
      } else {
        throw const ServerException(Constants.geocodingAPIError);
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

  @override
  Future<List<RideModel>> searchAvailableRides({
    required PlaceDetails fromPlace,
    PlaceDetails? toPlace,
    required DateTime departureTime,
    required int seats,
  }) async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    try {
      Map<String, dynamic> query = {
        "origin_name": fromPlace.name,
        "origin_formatted_address": fromPlace.formattedAddress,
        "departure_time":
            DateFormat('yyyy-MM-dd HH:mm:00').format(departureTime),
        "seats": seats,
      };

      if (toPlace != null) {
        query.addAll({
          "destination_name": toPlace.name,
          "destination_formatted_address": toPlace.formattedAddress,
        });
      }

      final response = await _networkClient.invoke(
        ApiRoutes.searchRide,
        RequestType.get,
        queryParameters: query,
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
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RideModel> fetchRideById({required int rideId}) async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    try {
      final response = await _networkClient.invoke(
        "${ApiRoutes.rideDetails}/$rideId",
        RequestType.get,
        headers: {"Authorization": "Bearer $token"},
      );

      final appResponse = AppResponse.fromJson(response.data);

      if (response.statusCode == 200) {
        return RideModel.fromJson(appResponse.data);
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

  @override
  Future<double> getPriceSuggestionByDistance({
    required PlaceDetails fromPlace,
    required PlaceDetails toPlace,
    required double fuelConsumptions,
  }) async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    try {
      final response = await _networkClient
          .invoke(ApiRoutes.distanceBetweenTwoPoint, RequestType.get, headers: {
        "Authorization": "Bearer $token"
      }, queryParameters: {
        "origins": "${fromPlace.latitude},${fromPlace.longitude}",
        "destinations": "${toPlace.latitude},${toPlace.longitude}",
        "key": AppSecret.mapAPIKey,
      });

      if (response.statusCode == 200) {
        final rows = response.data["rows"] as List<dynamic>;
        final elements = rows.first["elements"] as List<dynamic>;
        final distanceInMeter =
            (elements.first["distance"]["value"] as num).toDouble();
        final estimatedTimeInSeconds =
            (elements.first["duration"]["value"] as num).toDouble();
        final distanceInKm = distanceInMeter / 1000;
        final estimatedTimeInMinutes = estimatedTimeInSeconds / 60;

        /// Assume fuel price is RM2.05 - Ron 95
        /// Assume fuel consumption unit is km/l
        /// Fare base cost in RM 5
        ///
        final fuelConsumed = distanceInKm / fuelConsumptions;
        final totalCost = Constants.fareBaseCost +
            (fuelConsumed * Constants.fuelPricePerLiter) +
            (distanceInKm * Constants.baseCostPerKm) +
            (estimatedTimeInMinutes * Constants.costPerMinuteConsumed);
        return roundToNearestFiveCents(totalCost);
      } else {
        throw const ServerException(
            "Error occured in getting price suggestion");
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

  @override
  Future<RideModel> createRide({
    required PlaceDetails origin,
    required PlaceDetails destination,
    required DateTime departureTime,
    required double baseCost,
    required int vehicleId,
  }) async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    try {
      final response = await _networkClient
          .invoke(ApiRoutes.ride, RequestType.post, headers: {
        "Authorization": "Bearer $token"
      }, requestBody: {
        "origin_name": origin.name,
        "origin_formatted_address": origin.formattedAddress,
        "origin_latitude": origin.latitude,
        "origin_longitude": origin.longitude,
        "destination_name": destination.name,
        "destination_formatted_address": destination.formattedAddress,
        "destination_latitude": destination.latitude,
        "destination_longitude": destination.longitude,
        "departure_time":
            DateFormat('yyyy-MM-dd HH:mm:00').format(departureTime),
        "base_cost": baseCost,
        "vehicle_id": vehicleId,
      });

      final appResponse = AppResponse.fromJson(response.data);

      if (response.statusCode == 200) {
        return RideModel.fromJson(appResponse.data);
      } else {
        throw ServerValidatorException.fromJson(response.data);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerValidatorException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RideModel> updateRide({
    required int rideId,
    required PlaceDetails? origin,
    required PlaceDetails? destination,
    required DateTime? departureTime,
    required double? baseCost,
    required int? vehicleId,
  }) async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    Map<String, dynamic> body = {};
    if (origin != null) {
      body.addAll({
        "origin_name": origin.name,
        "origin_formatted_address": origin.formattedAddress,
        "origin_latitude": origin.latitude,
        "origin_longitude": origin.longitude,
      });
    }

    if (destination != null) {
      body.addAll({
        "destination_name": destination.name,
        "destination_formatted_address": destination.formattedAddress,
        "destination_latitude": destination.latitude,
        "destination_longitude": destination.longitude,
      });
    }

    if (departureTime != null) {
      body.addAll({
        "departure_time":
            DateFormat('yyyy-MM-dd HH:mm:00').format(departureTime)
      });
    }

    if (baseCost != null) {
      body.addAll({
        "base_cost": baseCost,
      });
    }

    if (vehicleId != null) {
      body.addAll({
        "vehicle_id": vehicleId,
      });
    }

    try {
      final response = await _networkClient.invoke(
          "${ApiRoutes.ride}/$rideId", RequestType.put,
          headers: {"Authorization": "Bearer $token"}, requestBody: body);

      final appResponse = AppResponse.fromJson(response.data);

      if (response.statusCode == 200) {
        return RideModel.fromJson(appResponse.data);
      } else {
        throw ServerValidatorException.fromJson(response.data);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerValidatorException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<RideModel>> getCreatedRides() async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    try {
      final response = await _networkClient.invoke(
          ApiRoutes.createdRides, RequestType.get,
          headers: {"Authorization": "Bearer $token"});

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
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<RideModel>> getJoinedRides() async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    try {
      final response = await _networkClient.invoke(
          ApiRoutes.joinedRides, RequestType.get,
          headers: {"Authorization": "Bearer $token"});

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
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
