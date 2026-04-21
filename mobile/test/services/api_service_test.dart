import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pulse_ops/models/event_model.dart';
import 'package:pulse_ops/services/api_service.dart';

void main() {
  const singleEventJson = {
    'id': 'evt-001',
    'event_type': 'delay',
    'status': 'open',
    'title': 'Train delayed',
    'description': 'Signal failure',
    'created_at': '2024-01-01T10:00:00Z',
    'destination_location_id': 'station-euston',
  };

  group('ApiService.createEvent', () {
    test('returns EventModel on 201 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(singleEventJson), 201);
      });

      final service = ApiService(client: mockClient);
      final result = await service.createEvent(
        eventType: 'delay',
        title: 'Train delayed',
        description: 'Signal failure',
      );

      expect(result, isA<EventModel>());
      expect(result.id, 'evt-001');
      expect(result.eventType, 'delay');
      expect(result.title, 'Train delayed');
    });

    test('throws Exception on non-201 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Bad Request', 400);
      });

      final service = ApiService(client: mockClient);

      expect(
        () => service.createEvent(eventType: 'delay', title: 'Train delayed'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ApiService.listEvents', () {
    test('returns List<EventModel> of length 2 on 200 response', () async {
      final twoEvents = [
        singleEventJson,
        {
          'id': 'evt-002',
          'event_type': 'incident',
          'status': 'open',
          'title': 'Platform blocked',
          'description': null,
          'created_at': '2024-01-01T11:00:00Z',
          'destination_location_id': 'station-euston',
        },
      ];

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(twoEvents), 200);
      });

      final service = ApiService(client: mockClient);
      final result = await service.listEvents();

      expect(result, isA<List<EventModel>>());
      expect(result.length, 2);
      expect(result[0].id, 'evt-001');
      expect(result[1].id, 'evt-002');
    });

    test('throws Exception on non-200 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = ApiService(client: mockClient);

      expect(
        () => service.listEvents(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
