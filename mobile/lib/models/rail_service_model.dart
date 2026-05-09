class RailServiceModel {
  final String id;
  final String serviceCode;
  final String? routeId;
  final String direction;
  final String status;

  const RailServiceModel({
    required this.id,
    required this.serviceCode,
    this.routeId,
    required this.direction,
    required this.status,
  });

  factory RailServiceModel.fromJson(Map<String, dynamic> json) => RailServiceModel(
        id: json['id'] as String,
        serviceCode: json['service_code'] as String,
        routeId: json['route_id'] as String?,
        direction: json['direction'] as String,
        status: json['status'] as String,
      );
}
