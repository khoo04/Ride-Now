import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';

class PlaceAutoCompleteApiResponse {
  final String? status;
  final List<AutoCompletePrediction>? predictions;

  PlaceAutoCompleteApiResponse({this.status, this.predictions});
}
