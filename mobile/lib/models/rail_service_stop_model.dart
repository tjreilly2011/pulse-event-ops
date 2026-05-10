class RailServiceStopModel {
  final String id;
  final String? serviceId;
  final String? stationId;
  final String? stationName;
  final String? stationCode;
  final DateTime? scheduledArrival;
  final DateTime? scheduledDeparture;
  final int stopSequence;

  const RailServiceStopModel({
    required this.id,
    required this.serviceId,
    required this.stationId,
    this.stationName,
    this.stationCode,
    required this.scheduledArrival,
    required this.scheduledDeparture,
    required this.stopSequence,
  });

  factory RailServiceStopModel.fromJson(Map<String, dynamic> json) =>
      RailServiceStopModel(
      id: (json['id'] as String?) ??
        'timeline-${(json['stop_sequence'] as num?)?.toInt() ?? 0}-${json['station_code'] ?? json['station_name'] ?? 'unknown'}',
        serviceId: json['service_id'] as String?,
        stationId: json['station_id'] as String?,
      stationName: json['station_name'] as String?,
      stationCode: json['station_code'] as String?,
        scheduledArrival: json['scheduled_arrival'] == null
            ? null
            : DateTime.parse(json['scheduled_arrival'] as String),
        scheduledDeparture: json['scheduled_departure'] == null
            ? null
            : DateTime.parse(json['scheduled_departure'] as String),
      stopSequence: (json['stop_sequence'] as num).toInt(),
      );
}