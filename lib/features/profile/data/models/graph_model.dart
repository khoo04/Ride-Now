import 'package:ride_now_app/features/profile/domain/entities/graph.dart';

class GraphEntryModel extends GraphEntry {
  GraphEntryModel({
    required super.months,
    required super.data,
  });

  factory GraphEntryModel.fromJson(Map<String, dynamic> json) {
    return GraphEntryModel(
      months: json['months'],
      data: GraphDataModel.fromJson(json['graph_data']),
    );
  }
}

class GraphDataModel extends GraphData {
  GraphDataModel({
    required super.credited,
    required super.uncredited,
  });

  factory GraphDataModel.fromJson(Map<String, dynamic> json) {
    return GraphDataModel(
      credited: (json['credited'] as num).toDouble(),
      uncredited: (json['uncredited'] as num).toDouble(),
    );
  }
}
