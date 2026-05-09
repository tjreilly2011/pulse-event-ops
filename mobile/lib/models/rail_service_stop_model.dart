class RailServiceStopModel {
  final String id;
  final String? serviceId;
  final String? stationId;
  final DateTime? scheduledArrival;
  final DateTime? scheduledDeparture;
  final int stopSequence;

  const RailServiceStopModel({
    required this.id,
    required this.serviceId,
    required this.stationId,
    required this.scheduledArrival,
    required this.scheduledDeparture,
    required this.stopSequence,
  });

  factory RailServiceStopModel.fromJson(Map<String, dynamic> json) =>
      RailServiceStopModel(
        id: json['id'] as String,
        serviceId: json['service_id'] as String?,
        stationId: json['station_id'] as String?,
        scheduledArrival: json['scheduled_arrival'] == null
            ? null
            : DateTime.parse(json['scheduled_arrival'] as String),
        scheduledDeparture: json['scheduled_departure'] == null
            ? null
            : DateTime.parse(json['scheduled_departure'] as String),
        stopSequence: json['stop_sequence'] as int,
      );
}