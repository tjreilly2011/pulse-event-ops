import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ops/main.dart';
import 'package:pulse_ops/models/event_model.dart';
import 'package:pulse_ops/services/api_service.dart';

class _FakeApiService extends ApiService {
  @override
  Future<List<EventModel>> listEvents() async => [];

  @override
  Future<EventModel> createEvent({
    required String eventType,
    required String title,
    String? description,
  }) async {
    throw UnimplementedError('Not used in smoke test');
  }
}

void main() {
  testWidgets('App launches and shows Report screen by default', (tester) async {
    await tester.pumpWidget(PulseOpsApp(apiService: _FakeApiService()));
    await tester.pump();
    // Should see the BottomNavigationBar
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    // Report tab should be visible
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Recent'), findsOneWidget);
    // The Report screen's AppBar title should be present
    expect(find.text('Pulse Operations'), findsOneWidget);
  });
}
