import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ops/models/rail_service_model.dart';

void main() {
  group('RailServiceModel', () {
    test('fromJson maps all fields correctly', () {
      final json = {
        'id': 'svc-001',
        'service_code': '1A23',
        'route_id': 'route-42',
        'direction': 'northbound',
        'status': 'ON_TIME',
      };

      final model = RailServiceModel.fromJson(json);

      expect(model.id, 'svc-001');
      expect(model.serviceCode, '1A23');
      expect(model.routeId, 'route-42');
      expect(model.direction, 'northbound');
      expect(model.status, 'ON_TIME');
    });

    test('fromJson with null routeId sets routeId to null', () {
      final json = {
        'id': 'svc-002',
        'service_code': '2B34',
        'route_id': null,
        'direction': 'southbound',
        'status': 'DELAYED',
      };

      final model = RailServiceModel.fromJson(json);

      expect(model.routeId, isNull);
      expect(model.status, 'DELAYED');
    });
  });
}
