import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ops/models/rail_service_model.dart';
import 'package:pulse_ops/models/rail_service_stop_model.dart';
import 'package:pulse_ops/models/rail_station_model.dart';
import 'package:pulse_ops/screens/rail_context_screen.dart';
import 'package:pulse_ops/services/api_service.dart';
import 'package:pulse_ops/state/selected_rail_context.dart';

class _FakeRailApiService extends ApiService {
  final List<RailServiceModel> services;
  final List<RailStationModel> stations;
  final Map<String, List<RailServiceStopModel>> stopsByServiceId;

  _FakeRailApiService({
    required this.services,
    required this.stations,
    required this.stopsByServiceId,
  });

  @override
  Future<List<RailServiceModel>> listRailServices() async => services;

  @override
  Future<List<RailStationModel>> listRailStations() async => stations;

  @override
  Future<List<RailServiceStopModel>> listServiceStops(String serviceId) async {
    return stopsByServiceId[serviceId] ?? [];
  }
}

Widget _buildScreen({
  required ApiService apiService,
  required SelectedRailContext selectedRailContext,
}) {
  return MaterialApp(
    home: RailContextScreen(
      apiService: apiService,
      selectedRailContext: selectedRailContext,
    ),
  );
}

void main() {
  testWidgets('selecting service and station updates shared selected context',
      (tester) async {
    final contextState = SelectedRailContext();
    final api = _FakeRailApiService(
      services: const [
        RailServiceModel(
          id: 'svc-1',
          serviceCode: 'NL-001',
          routeId: null,
          direction: 'southbound',
          status: 'ON_TIME',
        ),
        RailServiceModel(
          id: 'svc-2',
          serviceCode: 'NL-002',
          routeId: null,
          direction: 'northbound',
          status: 'DELAYED',
        ),
      ],
      stations: const [
        RailStationModel(id: 'st-a', name: 'Euston', code: 'EUS'),
        RailStationModel(id: 'st-b', name: 'King\'s Cross', code: 'KGX'),
        RailStationModel(id: 'st-c', name: 'Highbury', code: 'HBI'),
      ],
      stopsByServiceId: {
        'svc-1': [
          RailServiceStopModel(
            id: 'stop-1',
            serviceId: 'svc-1',
            stationId: 'st-a',
            scheduledArrival: DateTime.utc(2026, 1, 1, 10, 0),
            scheduledDeparture: DateTime.utc(2026, 1, 1, 10, 5),
            stopSequence: 1,
          ),
          RailServiceStopModel(
            id: 'stop-2',
            serviceId: 'svc-1',
            stationId: 'st-b',
            scheduledArrival: DateTime.utc(2026, 1, 1, 10, 15),
            scheduledDeparture: DateTime.utc(2026, 1, 1, 10, 20),
            stopSequence: 2,
          ),
        ],
        'svc-2': [
          RailServiceStopModel(
            id: 'stop-3',
            serviceId: 'svc-2',
            stationId: 'st-b',
            scheduledArrival: DateTime.utc(2026, 1, 1, 10, 0),
            scheduledDeparture: DateTime.utc(2026, 1, 1, 10, 5),
            stopSequence: 1,
          ),
          RailServiceStopModel(
            id: 'stop-4',
            serviceId: 'svc-2',
            stationId: 'st-c',
            scheduledArrival: DateTime.utc(2026, 1, 1, 10, 15),
            scheduledDeparture: DateTime.utc(2026, 1, 1, 10, 20),
            stopSequence: 2,
          ),
        ],
      },
    );

    await tester.pumpWidget(
      _buildScreen(apiService: api, selectedRailContext: contextState),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('NL-002'));
    await tester.pumpAndSettle();

    expect(contextState.selectedServiceId, 'svc-2');
    expect(contextState.selectedServiceCode, 'NL-002');

    await tester.tap(find.text('Highbury (HBI)'));
    await tester.pumpAndSettle();

    expect(contextState.selectedStationId, 'st-c');
    expect(contextState.selectedStationName, 'Highbury');
  });

  testWidgets(
      'fallback selection chooses first active service and current stop station',
      (tester) async {
    final now = DateTime.now().toUtc();
    final contextState = SelectedRailContext();
    final api = _FakeRailApiService(
      services: const [
        RailServiceModel(
          id: 'svc-cancelled',
          serviceCode: 'NL-000',
          routeId: null,
          direction: 'southbound',
          status: 'CANCELLED',
        ),
        RailServiceModel(
          id: 'svc-active',
          serviceCode: 'NL-001',
          routeId: null,
          direction: 'southbound',
          status: 'ON_TIME',
        ),
      ],
      stations: const [
        RailStationModel(id: 'st-first', name: 'King\'s Cross', code: 'KGX'),
        RailStationModel(id: 'st-current', name: 'Euston', code: 'EUS'),
      ],
      stopsByServiceId: {
        'svc-active': [
          RailServiceStopModel(
            id: 'stop-first',
            serviceId: 'svc-active',
            stationId: 'st-first',
            scheduledArrival: now.subtract(const Duration(minutes: 20)),
            scheduledDeparture: now.subtract(const Duration(minutes: 10)),
            stopSequence: 1,
          ),
          RailServiceStopModel(
            id: 'stop-current',
            serviceId: 'svc-active',
            stationId: 'st-current',
            scheduledArrival: now.subtract(const Duration(minutes: 3)),
            scheduledDeparture: now.add(const Duration(minutes: 3)),
            stopSequence: 2,
          ),
        ],
      },
    );

    await tester.pumpWidget(
      _buildScreen(apiService: api, selectedRailContext: contextState),
    );
    await tester.pumpAndSettle();

    expect(contextState.selectedServiceId, 'svc-active');
    expect(contextState.selectedServiceCode, 'NL-001');
    expect(contextState.selectedStationId, 'st-current');
    expect(contextState.selectedStationName, 'Euston');
  });
}
