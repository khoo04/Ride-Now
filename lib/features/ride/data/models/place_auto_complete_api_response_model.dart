import 'package:ride_now_app/features/ride/data/models/auto_complete_prediction_model.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_auto_complete_api_response.dart';

class PlaceAutoCompleteApiResponseModel extends PlaceAutoCompleteApiResponse {
  PlaceAutoCompleteApiResponseModel({super.predictions, super.status});

  factory PlaceAutoCompleteApiResponseModel.fromJson(
      Map<String, dynamic> json) {
    return PlaceAutoCompleteApiResponseModel(
      status: json['status'] as String?,
      predictions: json['predictions']
          ?.map<AutoCompletePredictionModel>(
              (json) => AutoCompletePredictionModel.fromJson(json))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'PlaceAutoCompleteApiResponseModel(status: $status, predictions: ${predictions?.map((p) => p.toString()).toList()})';
  }
}
