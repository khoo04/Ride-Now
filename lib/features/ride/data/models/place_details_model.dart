import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';

class PlaceDetailsModel extends PlaceDetails {
  PlaceDetailsModel({
    required super.name,
    required super.formattedAddress,
    required super.latitude,
    required super.longitude,
  });

  factory PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> result = json['result'];
    return PlaceDetailsModel(
      name: result['name'] ?? "Unknown location name",
      formattedAddress:
          result["formatted_address"] ?? "Unknown formatted address",
      latitude: result["geometry"]["location"]["lat"] ?? 0,
      longitude: result["geometry"]["location"]["lng"] ?? 0,
    );
  }

  factory PlaceDetailsModel.fromOpenStreetJson(Map<String, dynamic> json) {
    return PlaceDetailsModel(
      name: (json['name'] != null && json['name'].isNotEmpty)
          ? json['name']
          : "Unnamed Place",
      formattedAddress: json["display_name"] ?? "Unknown formatted address",
      latitude: double.tryParse(json["lat"]?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json["lon"]?.toString() ?? '') ?? 0.0,
    );
  }

  factory PlaceDetailsModel.fromApiJson(Map<String, dynamic> json) {
    return PlaceDetailsModel(
      name: (json['name'] != null && json['name'].isNotEmpty)
          ? json['name']
          : "Unnamed Place",
      formattedAddress:
          json["formatted_address"] ?? "Unknown formatted address",
      latitude: double.tryParse(json["latitude"]?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json["longitude"]?.toString() ?? '') ?? 0.0,
    );
  }

  @override
  String toString() {
    return "PlaceDetailsModel(name: $name, formattedAddress: $formattedAddress, latitude: $latitude, longitude: $longitude)";
  }
}
