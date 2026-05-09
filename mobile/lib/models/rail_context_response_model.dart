import 'event_model.dart';
import 'rail_service_model.dart';
import 'rail_service_stop_model.dart';
import 'rail_station_model.dart';

class RailStaffPresenceModel {
  final String id;
  final String roleLabel;
  final String presenceType;
  final String status;

  const RailStaffPresenceModel({
    required this.id,
    required this.roleLabel,
    required this.presenceType,
    required this.status,
  });

  factory RailStaffPresenceModel.fromJson(Map<String, dynamic> json) {
    return RailStaffPresenceModel(
      id: json['id'] as String,
      roleLabel: json['role_label'] as String? ?? 'Unknown role',
      presenceType: json['presence_type'] as String? ?? 'UNKNOWN',
      status: json['status'] as String? ?? 'UNKNOWN',
    );
  }
}

class RailServiceContextResponseModel {
  final RailServiceModel service;
  final List<RailServiceStopModel> stops;
  final List<RailStaffPresenceModel> staff;
  final String statusDot;
  final int activeEventCount;
  final List<EventModel> activeEvents;

  const RailServiceContextResponseModel({
    required this.service,
    required this.stops,
    required this.staff,
    required this.statusDot,
    required this.activeEventCount,
    required this.activeEvents,
  });

  factory RailServiceContextResponseModel.fromJson(Map<String, dynamic> json) {
    final stops = (json['stops'] as List<dynamic>? ?? const [])
        .map((e) => RailServiceStopModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final staff = (json['staff'] as List<dynamic>? ?? const [])
        .map((e) => RailStaffPresenceModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final activeEvents = (json['active_events'] as List<dynamic>? ?? const [])
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return RailServiceContextResponseModel(
      service: RailServiceModel.fromJson(
        json['service'] as Map<String, dynamic>,
      ),
      stops: stops,
      staff: staff,
      statusDot: json['status_dot'] as String? ?? 'Amber',
      activeEventCount:
          json['active_event_count'] as int? ?? activeEvents.length,
      activeEvents: activeEvents,
    );
  }
}

class RailStationContextResponseModel {
  final RailStationModel station;
  final String status;
  final int activeEventCount;
  final int staffOnDuty;
  final List<EventModel> activeEvents;
  final List<RailStaffPresenceModel> staff;

  const RailStationContextResponseModel({
    required this.station,
    required this.status,
    required this.activeEventCount,
    required this.staffOnDuty,
    required this.activeEvents,
    required this.staff,
  });

  factory RailStationContextResponseModel.fromJson(Map<String, dynamic> json) {
    final activeEvents = (json['active_events'] as List<dynamic>? ?? const [])
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final staff = (json['staff'] as List<dynamic>? ?? const [])
        .map((e) => RailStaffPresenceModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return RailStationContextResponseModel(
      station: RailStationModel.fromJson(
        json['station'] as Map<String, dynamic>,
      ),
      status: json['status'] as String? ?? 'Amber',
      activeEventCount:
          json['active_event_count'] as int? ?? activeEvents.length,
      staffOnDuty: json['staff_on_duty'] as int? ?? 0,
      activeEvents: activeEvents,
      staff: staff,
    );
  }
}
