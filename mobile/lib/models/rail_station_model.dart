class RailStationModel {
  final String id;
  final String name;
  final String code;

  const RailStationModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory RailStationModel.fromJson(Map<String, dynamic> json) =>
      RailStationModel(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
      );
}