import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ops/models/rail_service_stop_model.dart';

void main() {
  test('fromJson parses legacy stop payload', () {
    final model = RailServiceStopModel.fromJson({
      'id': 'stop-1',
      'service_id': 'svc-1',
      'station_id': 'st-1',
      'scheduled_arrival': '2026-05-10T07:00:00Z',
      'scheduled_departure': '2026-05-10T07:02:00Z',
      'stop_sequence': 1,
    });

    expect(model.id, 'stop-1');
    expect(model.stationId, 'st-1');
    expect(model.stopSequence, 1);
  });

  test('fromJson parses timeline payload without id/service/station ids', () {
    final model = RailServiceStopModel.fromJson({
      'stop_sequence': 2,
      'station_name': 'Castlebar',
      'station_code': 'CBR',
      'scheduled_arrival': '2026-05-10T07:32:00Z',
      'scheduled_departure': '2026-05-10T07:34:00Z',
    });

    expect(model.id, contains('timeline-2-'));
    expect(model.stationId, isNull);
    expect(model.stationName, 'Castlebar');
    expect(model.stationCode, 'CBR');
    expect(model.stopSequence, 2);
  });
}
