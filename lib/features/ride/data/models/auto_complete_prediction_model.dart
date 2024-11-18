import 'package:ride_now_app/features/ride/data/models/structured_formatting_model.dart';
import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';

class AutoCompletePredictionModel extends AutoCompletePrediction {
  AutoCompletePredictionModel({
    super.description,
    super.structuredFormatting,
    super.placeId,
    super.reference,
  });

  factory AutoCompletePredictionModel.fromJson(Map<String, dynamic> json) {
    return AutoCompletePredictionModel(
      description: json['description'] as String?,
      placeId: json['place_id'] as String?,
      reference: json['reference'] as String?,
      structuredFormatting: json['structured_formatting'] != null
          ? StructuredFormattingModel.fromJson(json['structured_formatting'])
          : null,
    );
  }
  

  @override
  String toString() {
    return 'AutoCompletePredictionModel(description: $description, placeId: $placeId, reference: $reference, structuredFormatting: ${structuredFormatting.toString()})';
  }
}
