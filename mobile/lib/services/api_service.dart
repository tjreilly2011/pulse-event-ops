import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/event_model.dart';
import '../models/rail_service_model.dart';
import '../models/rail_service_stop_model.dart';
import '../models/rail_station_model.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<EventModel> createEvent({
    required String eventType,
    required String title,
    String? description,
    String? railServiceId,
    String? railStationId,
  }) async {
    final uri = Uri.parse('$kApiBaseUrl/events');
    final body = jsonEncode({
      'event_type': eventType,
      'title': title,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (railServiceId != null && railServiceId.isNotEmpty)
        'rail_service_id': railServiceId,
      if (railStationId != null && railStationId.isNotEmpty)
        'rail_station_id': railStationId,
      'created_by': kCreatedByStub,
      'destination_location_id': kLocationPlaceholder,
    });
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create event: ${response.statusCode}');
    }
    return EventModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<EventModel>> listEvents() async {
    final uri = Uri.parse('$kApiBaseUrl/events');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load events: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RailServiceModel>> listRailServices() async {
    final uri = Uri.parse('$kApiBaseUrl/rail/services');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load rail services: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => RailServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RailStationModel>> listRailStations() async {
    final uri = Uri.parse('$kApiBaseUrl/rail/stations');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load rail stations: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => RailStationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RailServiceStopModel>> listServiceStops(String serviceId) async {
    final uri = Uri.parse('$kApiBaseUrl/rail/services/$serviceId/stops');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load service stops for $serviceId: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => RailServiceStopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
