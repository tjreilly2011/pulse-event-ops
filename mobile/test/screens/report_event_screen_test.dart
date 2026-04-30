import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ops/models/event_model.dart';
import 'package:pulse_ops/services/api_service.dart';
import 'package:pulse_ops/screens/report_event_screen.dart';

class FakeApiService extends ApiService {
  bool shouldThrow;

  FakeApiService({this.shouldThrow = false});

  @override
  Future<EventModel> createEvent({
    required String eventType,
    required String title,
    String? description,
  }) async {
    if (shouldThrow) throw Exception('network error');
    return EventModel(
      id: 'test-id',
      eventType: eventType,
      status: 'open',
      title: title,
      description: description,
      createdAt: '2026-01-01T00:00:00Z',
      destinationLocationId: 'station-euston',
    );
  }
}

class _SlowFakeApiService extends ApiService {
  final Future<EventModel> _future;

  _SlowFakeApiService(this._future);

  @override
  Future<EventModel> createEvent({
    required String eventType,
    required String title,
    String? description,
  }) =>
      _future;
}

Widget _buildScreen({ApiService? apiService}) {
  return MaterialApp(
    home: ReportEventScreen(apiService: apiService),
  );
}

void main() {
  testWidgets('1. Submit button is disabled on initial render', (tester) async {
    await tester.pumpWidget(_buildScreen());

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Send Event'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('2. Tapping a category card enables the submit button',
      (tester) async {
    await tester.pumpWidget(_buildScreen());

    await tester.tap(find.text('Delay'));
    await tester.pump();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Send Event'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
      '3. Successful submit shows "Event sent" snackbar',
      (tester) async {
    final fake = FakeApiService();
    await tester.pumpWidget(_buildScreen(apiService: fake));

    await tester.tap(find.text('Delay'));
    await tester.pump();

    final buttonFinder = find.widgetWithText(ElevatedButton, 'Send Event');
    await tester.ensureVisible(buttonFinder);
    await tester.pump();

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Event sent'), findsOneWidget);
  });

  testWidgets('4. After success, selected category is cleared (button disabled)',
      (tester) async {
    final fake = FakeApiService();
    await tester.pumpWidget(_buildScreen(apiService: fake));

    await tester.tap(find.text('Delay'));
    await tester.pump();

    final buttonFinder = find.widgetWithText(ElevatedButton, 'Send Event');
    await tester.ensureVisible(buttonFinder);
    await tester.pump();

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(buttonFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets('5. Loading spinner appears while submit is in progress',
      (tester) async {
    final completer = Completer<EventModel>();
    final slowFake = _SlowFakeApiService(completer.future);
    await tester.pumpWidget(_buildScreen(apiService: slowFake));

    await tester.tap(find.text('Delay'));
    await tester.pump();

    final buttonFinder = find.widgetWithText(ElevatedButton, 'Send Event');
    await tester.ensureVisible(buttonFinder);
    await tester.pump();

    await tester.tap(buttonFinder);
    await tester.pump(); // one frame — submission started, not yet complete

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(EventModel(
      id: 'test-id',
      eventType: 'delay',
      status: 'open',
      title: 'Delay',
      description: null,
      createdAt: '2026-01-01T00:00:00Z',
      destinationLocationId: 'station-euston',
    ));
    await tester.pumpAndSettle();
  });
}
