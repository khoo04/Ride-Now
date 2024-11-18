import 'package:ride_now_app/features/ride/domain/entities/structured_formatting.dart';

class StructuredFormattingModel extends StructuredFormatting {
  StructuredFormattingModel({
    required super.mainText,
    required super.secondaryText,
  });

  factory StructuredFormattingModel.fromJson(Map<String, dynamic> json) {
    return StructuredFormattingModel(
      mainText: json['main_text'] as String?,
      secondaryText: json['secondary_text'] as String?,
    );
  }

  @override
  String toString() {
    return 'StructuredFormattingModel(mainText: $mainText, secondaryText: $secondaryText)';
  }
}
