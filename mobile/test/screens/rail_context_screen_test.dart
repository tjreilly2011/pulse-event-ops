import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ops/models/rail_context_response_model.dart';
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
  final Map<String, RailServiceContextResponseModel?> serviceContexts;
  final Map<String, RailStationContextResponseModel?> stationContexts;
  final bool throwContextError;

  _FakeRailApiService({
    required this.services,
    required this.stations,
    required this.stopsByServiceId,
    this.serviceContexts = const {},
    this.stationContexts = const {},
    this.throwContextError = false,
  });

  @override
  Future<List<RailServiceModel>> listRailServices() async => services;

  @override
  Future<List<RailStationModel>> listRailStations() async => stations;

  @override
  Future<List<RailServiceStopModel>> listServiceStops(String serviceId) async {
    return stopsByServiceId[serviceId] ?? [];
  }

  @override
  Future<RailServiceContextResponseModel?> getServiceContext(
    String serviceId,
  ) async {
    if (throwContextError) {
      throw Exception('service context failed');
    }
    return serviceContexts[serviceId];
  }

  @override
  Future<RailStationContextResponseModel?> getStationContext(
    String stationId,
  ) async {
    if (throwContextError) {
      throw Exception('station context failed');
    }
    return stationContexts[stationId];
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
  RailServiceContextResponseModel buildServiceContext({
    required String serviceId,
    required String stationId,
    required String statusDot,
    required List<Map<String, dynamic>> events,
    required List<Map<String, dynamic>> staff,
  }) {
    return RailServiceContextResponseModel.fromJson({
      'service': {
        'id': serviceId,
        'service_code': 'NL-001',
        'route_id': null,
        'direction': 'southbound',
        'status': 'ON_TIME',
      },
      'stops': [
        {
          'id': 'stop-1',
          'service_id': serviceId,
          'station_id': stationId,
          'scheduled_arrival': '2026-01-01T10:00:00Z',
          'scheduled_departure': '2026-01-01T10:05:00Z',
          'stop_sequence': 1,
        },
      ],
      'staff': staff,
      'status_dot': statusDot,
      'active_event_count': events.length,
      'active_events': events,
    });
  }

  RailStationContextResponseModel buildStationContext({
    required String stationId,
    required List<Map<String, dynamic>> events,
    required List<Map<String, dynamic>> staff,
  }) {
    return RailStationContextResponseModel.fromJson({
      'station': {'id': stationId, 'name': 'Euston', 'code': 'EUS'},
      'status': 'Amber',
      'active_event_count': events.length,
      'staff_on_duty': staff
          .where((person) => person['status'] == 'ON_DUTY')
          .length,
      'active_events': events,
      'staff': staff,
    });
  }

  final defaultEvents = [
    {
      'id': 'evt-1',
      'event_type': 'delay',
      'status': 'created',
      'title': 'Signal delay',
      'description': 'Northbound impacted',
      'created_at': '2026-01-01T10:00:00Z',
      'destination_location_id': 'EUS',
    },
  ];

  final defaultStaff = [
    {
      'id': 'staff-1',
      'role_label': 'Conductor',
      'presence_type': 'ON_TRAIN',
      'status': 'ON_DUTY',
    },
  ];

  testWidgets('selecting service and station updates shared selected context', (
    tester,
  ) async {
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
      serviceContexts: {
        'svc-1': buildServiceContext(
          serviceId: 'svc-1',
          stationId: 'st-a',
          statusDot: 'Green',
          events: defaultEvents,
          staff: defaultStaff,
        ),
        'svc-2': buildServiceContext(
          serviceId: 'svc-2',
          stationId: 'st-b',
          statusDot: 'Amber',
          events: defaultEvents,
          staff: defaultStaff,
        ),
      },
      stationContexts: {
        'st-a': buildStationContext(
          stationId: 'st-a',
          events: defaultEvents,
          staff: defaultStaff,
        ),
        'st-b': buildStationContext(
          stationId: 'st-b',
          events: defaultEvents,
          staff: defaultStaff,
        ),
        'st-c': buildStationContext(
          stationId: 'st-c',
          events: defaultEvents,
          staff: defaultStaff,
        ),
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

    await tester.tap(find.text('Highbury (HBI)').first);
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
        serviceContexts: {
          'svc-active': buildServiceContext(
            serviceId: 'svc-active',
            stationId: 'st-current',
            statusDot: 'Green',
            events: defaultEvents,
            staff: defaultStaff,
          ),
        },
        stationContexts: {
          'st-current': buildStationContext(
            stationId: 'st-current',
            events: defaultEvents,
            staff: defaultStaff,
          ),
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
    },
  );

  testWidgets(
    'service card shows origin destination and selected current station',
    (tester) async {
      final now = DateTime.now().toUtc();
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
        ],
        stations: const [
          RailStationModel(id: 'st-a', name: 'Westport', code: 'WPT'),
          RailStationModel(id: 'st-b', name: 'Athlone', code: 'ATL'),
          RailStationModel(id: 'st-c', name: 'Heuston', code: 'HST'),
        ],
        stopsByServiceId: {
          'svc-1': [
            RailServiceStopModel(
              id: 'stop-1',
              serviceId: 'svc-1',
              stationId: 'st-a',
              scheduledArrival: now.subtract(const Duration(minutes: 20)),
              scheduledDeparture: now.subtract(const Duration(minutes: 18)),
              stopSequence: 1,
            ),
            RailServiceStopModel(
              id: 'stop-2',
              serviceId: 'svc-1',
              stationId: 'st-b',
              scheduledArrival: now.subtract(const Duration(minutes: 2)),
              scheduledDeparture: now.add(const Duration(minutes: 2)),
              stopSequence: 2,
            ),
            RailServiceStopModel(
              id: 'stop-3',
              serviceId: 'svc-1',
              stationId: 'st-c',
              scheduledArrival: now.add(const Duration(minutes: 20)),
              scheduledDeparture: now.add(const Duration(minutes: 23)),
              stopSequence: 3,
            ),
          ],
        },
        serviceContexts: {
          'svc-1': buildServiceContext(
            serviceId: 'svc-1',
            stationId: 'st-b',
            statusDot: 'Green',
            events: defaultEvents,
            staff: defaultStaff,
          ),
        },
        stationContexts: {
          'st-b': buildStationContext(
            stationId: 'st-b',
            events: defaultEvents,
            staff: defaultStaff,
          ),
        },
      );

      await tester.pumpWidget(
        _buildScreen(apiService: api, selectedRailContext: contextState),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Selected service'), 200);

      expect(find.text('Origin: Westport (WPT)'), findsOneWidget);
      expect(find.text('Destination: Heuston (HST)'), findsOneWidget);
      expect(find.text('Selected/current: Athlone (ATL)'), findsOneWidget);
    },
  );

  testWidgets('next few stops are visible by default', (tester) async {
    final now = DateTime.now().toUtc();
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
      ],
      stations: const [
        RailStationModel(id: 'st-a', name: 'A', code: 'A'),
        RailStationModel(id: 'st-b', name: 'B', code: 'B'),
        RailStationModel(id: 'st-c', name: 'C', code: 'C'),
        RailStationModel(id: 'st-d', name: 'D', code: 'D'),
        RailStationModel(id: 'st-e', name: 'E', code: 'E'),
      ],
      stopsByServiceId: {
        'svc-1': [
          RailServiceStopModel(
            id: 'stop-1',
            serviceId: 'svc-1',
            stationId: 'st-a',
            scheduledArrival: now.subtract(const Duration(minutes: 20)),
            scheduledDeparture: now.subtract(const Duration(minutes: 18)),
            stopSequence: 1,
          ),
          RailServiceStopModel(
            id: 'stop-2',
            serviceId: 'svc-1',
            stationId: 'st-b',
            scheduledArrival: now.subtract(const Duration(minutes: 2)),
            scheduledDeparture: now.add(const Duration(minutes: 2)),
            stopSequence: 2,
          ),
          RailServiceStopModel(
            id: 'stop-3',
            serviceId: 'svc-1',
            stationId: 'st-c',
            scheduledArrival: now.add(const Duration(minutes: 8)),
            scheduledDeparture: now.add(const Duration(minutes: 10)),
            stopSequence: 3,
          ),
          RailServiceStopModel(
            id: 'stop-4',
            serviceId: 'svc-1',
            stationId: 'st-d',
            scheduledArrival: now.add(const Duration(minutes: 18)),
            scheduledDeparture: now.add(const Duration(minutes: 20)),
            stopSequence: 4,
          ),
          RailServiceStopModel(
            id: 'stop-5',
            serviceId: 'svc-1',
            stationId: 'st-e',
            scheduledArrival: now.add(const Duration(minutes: 28)),
            scheduledDeparture: now.add(const Duration(minutes: 30)),
            stopSequence: 5,
          ),
        ],
      },
      serviceContexts: {
        'svc-1': buildServiceContext(
          serviceId: 'svc-1',
          stationId: 'st-b',
          statusDot: 'Green',
          events: defaultEvents,
          staff: defaultStaff,
        ),
      },
      stationContexts: {
        'st-b': buildStationContext(
          stationId: 'st-b',
          events: defaultEvents,
          staff: defaultStaff,
        ),
      },
    );

    await tester.pumpWidget(
      _buildScreen(apiService: api, selectedRailContext: contextState),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Next stops'), 200);

    expect(find.text('B (B)'), findsWidgets);
    expect(find.text('C (C)'), findsWidgets);
    expect(find.text('D (D)'), findsWidgets);
    expect(find.text('E (E)'), findsNothing);
  });

  testWidgets('full stop list expands and collapses', (tester) async {
    final now = DateTime.now().toUtc();
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
      ],
      stations: const [
        RailStationModel(id: 'st-a', name: 'A', code: 'A'),
        RailStationModel(id: 'st-b', name: 'B', code: 'B'),
        RailStationModel(id: 'st-c', name: 'C', code: 'C'),
        RailStationModel(id: 'st-d', name: 'D', code: 'D'),
      ],
      stopsByServiceId: {
        'svc-1': [
          RailServiceStopModel(
            id: 'stop-1',
            serviceId: 'svc-1',
            stationId: 'st-a',
            scheduledArrival: now.subtract(const Duration(minutes: 20)),
            scheduledDeparture: now.subtract(const Duration(minutes: 18)),
            stopSequence: 1,
          ),
          RailServiceStopModel(
            id: 'stop-2',
            serviceId: 'svc-1',
            stationId: 'st-b',
            scheduledArrival: now.subtract(const Duration(minutes: 2)),
            scheduledDeparture: now.add(const Duration(minutes: 2)),
            stopSequence: 2,
          ),
          RailServiceStopModel(
            id: 'stop-3',
            serviceId: 'svc-1',
            stationId: 'st-c',
            scheduledArrival: now.add(const Duration(minutes: 8)),
            scheduledDeparture: now.add(const Duration(minutes: 10)),
            stopSequence: 3,
          ),
          RailServiceStopModel(
            id: 'stop-4',
            serviceId: 'svc-1',
            stationId: 'st-d',
            scheduledArrival: now.add(const Duration(minutes: 18)),
            scheduledDeparture: now.add(const Duration(minutes: 20)),
            stopSequence: 4,
          ),
        ],
      },
      serviceContexts: {
        'svc-1': buildServiceContext(
          serviceId: 'svc-1',
          stationId: 'st-b',
          statusDot: 'Green',
          events: defaultEvents,
          staff: defaultStaff,
        ),
      },
      stationContexts: {
        'st-b': buildStationContext(
          stationId: 'st-b',
          events: defaultEvents,
          staff: defaultStaff,
        ),
      },
    );

    await tester.pumpWidget(
      _buildScreen(apiService: api, selectedRailContext: contextState),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Full stop list'), 200);

    expect(find.text('4.'), findsNothing);

    await tester.tap(find.text('Full stop list'));
    await tester.pumpAndSettle();
    expect(find.text('4.'), findsOneWidget);
    expect(find.text('D (D)'), findsWidgets);

    await tester.tap(find.text('Full stop list'));
    await tester.pumpAndSettle();
    expect(find.text('4.'), findsNothing);
  });

  testWidgets(
    'switching services rebinds station context for timeline-style stops',
    (tester) async {
      final contextState = SelectedRailContext();
      final api = _FakeRailApiService(
        services: const [
          RailServiceModel(
            id: 'svc-ie',
            serviceCode: 'IE-WPT-HST-001',
            routeId: null,
            direction: 'eastbound',
            status: 'ON_TIME',
          ),
          RailServiceModel(
            id: 'svc-gb',
            serviceCode: 'GB-WAT-KGN-001',
            routeId: null,
            direction: 'outbound',
            status: 'ON_TIME',
          ),
        ],
        stations: const [
          RailStationModel(id: 'st-wpt', name: 'Westport', code: 'WPT'),
          RailStationModel(
            id: 'st-wat',
            name: 'London Waterloo',
            code: 'WAT',
          ),
        ],
        stopsByServiceId: {
          'svc-ie': [
            RailServiceStopModel(
              id: 'timeline-1-WPT',
              serviceId: null,
              stationId: null,
              stationName: 'Westport',
              stationCode: 'WPT',
              scheduledArrival: DateTime.utc(2026, 1, 1, 10, 0),
              scheduledDeparture: DateTime.utc(2026, 1, 1, 10, 2),
              stopSequence: 1,
            ),
          ],
          'svc-gb': [
            RailServiceStopModel(
              id: 'timeline-1-WAT',
              serviceId: null,
              stationId: null,
              stationName: 'London Waterloo',
              stationCode: 'WAT',
              scheduledArrival: DateTime.utc(2026, 1, 1, 11, 0),
              scheduledDeparture: DateTime.utc(2026, 1, 1, 11, 2),
              stopSequence: 1,
            ),
          ],
        },
        serviceContexts: {
          'svc-ie': buildServiceContext(
            serviceId: 'svc-ie',
            stationId: 'st-wpt',
            statusDot: 'Green',
            events: defaultEvents,
            staff: defaultStaff,
          ),
          'svc-gb': buildServiceContext(
            serviceId: 'svc-gb',
            stationId: 'st-wat',
            statusDot: 'Green',
            events: defaultEvents,
            staff: defaultStaff,
          ),
        },
        stationContexts: {
          'st-wpt': buildStationContext(
            stationId: 'st-wpt',
            events: defaultEvents,
            staff: defaultStaff,
          ),
          'st-wat': RailStationContextResponseModel.fromJson({
            'station': {
              'id': 'st-wat',
              'name': 'London Waterloo',
              'code': 'WAT',
            },
            'status': 'Amber',
            'active_event_count': 0,
            'staff_on_duty': 1,
            'active_events': const [],
            'staff': defaultStaff,
          }),
        },
      );

      await tester.pumpWidget(
        _buildScreen(apiService: api, selectedRailContext: contextState),
      );
      await tester.pumpAndSettle();

      expect(contextState.selectedStationId, 'st-wpt');

      await tester.tap(find.text('GB-WAT-KGN-001').first);
      await tester.pumpAndSettle();

      expect(contextState.selectedServiceId, 'svc-gb');
      expect(contextState.selectedStationId, 'st-wat');
      expect(find.text('London Waterloo (WAT)'), findsWidgets);
    },
  );

  testWidgets(
    'renders service card, station context, related events and staff summary blocks',
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
        ],
        stations: const [
          RailStationModel(id: 'st-a', name: 'Euston', code: 'EUS'),
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
          ],
        },
        serviceContexts: {
          'svc-1': buildServiceContext(
            serviceId: 'svc-1',
            stationId: 'st-a',
            statusDot: 'Green',
            events: defaultEvents,
            staff: defaultStaff,
          ),
        },
        stationContexts: {
          'st-a': buildStationContext(
            stationId: 'st-a',
            events: defaultEvents,
            staff: defaultStaff,
          ),
        },
      );

      await tester.pumpWidget(
        _buildScreen(apiService: api, selectedRailContext: contextState),
      );
      await tester.pumpAndSettle();

      expect(find.text('Selected service'), findsOneWidget);
      expect(find.text('NL-001'), findsWidgets);
      expect(find.text('Origin: Euston (EUS)'), findsOneWidget);
      expect(find.text('Destination: Euston (EUS)'), findsOneWidget);
      expect(find.text('Selected/current: Euston (EUS)'), findsOneWidget);
      expect(find.text('Direction: southbound'), findsOneWidget);
      expect(find.text('Status: On Time'), findsWidgets);

      await tester.scrollUntilVisible(find.text('Staff summary'), 200);

      expect(find.text('Station context'), findsOneWidget);
      expect(find.text('Euston (EUS)'), findsWidgets);
      expect(find.text('Active events: 1'), findsOneWidget);
      expect(find.text('Staff on duty: 1'), findsOneWidget);

      expect(find.text('Related events'), findsOneWidget);
      expect(find.text('Signal delay'), findsOneWidget);

      expect(find.text('Staff summary'), findsOneWidget);
      expect(find.text('On duty: 1'), findsOneWidget);
      expect(find.text('Other status: 0'), findsOneWidget);
    },
  );

  testWidgets('shows empty states when related events and staff are absent', (
    tester,
  ) async {
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
      ],
      stations: const [
        RailStationModel(id: 'st-a', name: 'Euston', code: 'EUS'),
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
        ],
      },
      serviceContexts: {
        'svc-1': buildServiceContext(
          serviceId: 'svc-1',
          stationId: 'st-a',
          statusDot: 'Green',
          events: const [],
          staff: const [],
        ),
      },
      stationContexts: {
        'st-a': buildStationContext(
          stationId: 'st-a',
          events: const [],
          staff: const [],
        ),
      },
    );

    await tester.pumpWidget(
      _buildScreen(apiService: api, selectedRailContext: contextState),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Staff summary'), 200);

    expect(find.text('No active related events.'), findsOneWidget);
  });

  testWidgets('shows context error state and retry action', (tester) async {
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
      ],
      stations: const [
        RailStationModel(id: 'st-a', name: 'Euston', code: 'EUS'),
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
        ],
      },
      throwContextError: true,
    );

    await tester.pumpWidget(
      _buildScreen(apiService: api, selectedRailContext: contextState),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Could not load context details.'),
      200,
    );

    expect(find.text('Could not load context details.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
