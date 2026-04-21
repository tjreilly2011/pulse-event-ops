import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ops/models/event_model.dart';

void main() {
  group('EventModel', () {
    test('fromJson maps all fields correctly', () {
      final json = {
        'id': 'abc-123',
        'event_type': 'delay',
        'status': 'open',
        'title': 'Train delayed',
        'description': 'Signal failure at junction',
        'created_at': '2026-04-21T10:00:00Z',
        'destination_location_id': 'loc-456',
      };

      final model = EventModel.fromJson(json);

      expect(model.id, 'abc-123');
      expect(model.eventType, 'delay');
      expect(model.status, 'open');
      expect(model.title, 'Train delayed');
      expect(model.description, 'Signal failure at junction');
      expect(model.createdAt, '2026-04-21T10:00:00Z');
      expect(model.destinationLocationId, 'loc-456');
    });

    test('fromJson with null title — displayTitle returns eventType', () {
      final json = {
        'id': 'abc-123',
        'event_type': 'delay',
        'status': 'open',
        'title': null,
        'description': null,
        'created_at': '2026-04-21T10:00:00Z',
        'destination_location_id': 'loc-456',
      };

      final model = EventModel.fromJson(json);

      expect(model.title, isNull);
      expect(model.displayTitle, 'delay');
    });

    test('fromJson with title present — displayTitle returns title', () {
      final json = {
        'id': 'abc-123',
        'event_type': 'delay',
        'status': 'open',
        'title': 'Train delayed',
        'description': null,
        'created_at': '2026-04-21T10:00:00Z',
        'destination_location_id': 'loc-456',
      };

      final model = EventModel.fromJson(json);

      expect(model.displayTitle, 'Train delayed');
    });
  });
}
