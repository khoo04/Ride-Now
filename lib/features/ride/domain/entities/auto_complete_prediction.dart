import 'package:ride_now_app/features/ride/domain/entities/structured_formatting.dart';

class AutoCompletePrediction {
  /// [description] contains the human-readable name for the returned result. For establishment results, this is usually
  /// the business name.
  final String? description;

  /// [structuredFormatting] provides pre-formatted text that can be shown in your autocomplete results
  final StructuredFormatting? structuredFormatting;

  /// [placeId] is a textual identifier that uniquely identifies a place. To retrieve information about the place,
  /// pass this identifier in the placeId field of a Places API request. For more information about place IDs.
  final String? placeId;

  /// [reference] contains reference.
  final String? reference;

  AutoCompletePrediction({
    this.description,
    this.structuredFormatting,
    this.placeId,
    this.reference,
  });
}
