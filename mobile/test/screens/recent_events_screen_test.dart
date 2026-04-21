import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ops/models/event_model.dart';
import 'package:pulse_ops/services/api_service.dart';
import 'package:pulse_ops/screens/recent_events_screen.dart';

class FakeApiService extends ApiService {
  final List<EventModel>? events;
  final bool shouldThrow;

  FakeApiService({this.events, this.shouldThrow = false});

  @override
  Future<List<EventModel>> listEvents() async {
    if (shouldThrow) throw Exception('network error');
    return events ?? [];
  }
}

Widget _buildScreen({ApiService? apiService}) {
  return MaterialApp(
    home: RecentEventsScreen(apiService: apiService),
  );
}

final _twoEvents = [
  const EventModel(
    id: 'id-1',
    eventType: 'delay',
    status: 'open',
    title: 'Signal failure',
    createdAt: '2026-04-21T19:58:00Z',
    destinationLocationId: 'station-euston',
  ),
  const EventModel(
    id: 'id-2',
    eventType: 'obstruction',
    status: 'acknowledged',
    title: null,
    createdAt: '2026-04-21T20:10:00Z',
    destinationLocationId: 'station-euston',
  ),
];

void main() {
  testWidgets('1. Loading indicator appears while future is pending',
      (tester) async {
    final completer = Completer<List<EventModel>>();

    // Override listEvents to return a never-completing future
    final slowFake = _SlowFakeApiService(completer.future);

    await tester.pumpWidget(_buildScreen(apiService: slowFake));
    // Don't settle — future is still pending
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Clean up — complete the future so no pending timers remain
    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('2. List renders correct number of tiles from mocked response',
      (tester) async {
    final fake = FakeApiService(events: _twoEvents);
    await tester.pumpWidget(_buildScreen(apiService: fake));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('3. Non-null title is displayed (not eventType)', (tester) async {
    final fake = FakeApiService(events: _twoEvents);
    await tester.pumpWidget(_buildScreen(apiService: fake));
    await tester.pumpAndSettle();

    expect(find.text('Signal failure'), findsOneWidget);
    expect(find.text('delay'), findsNothing);
  });

  testWidgets('4. Null title falls back to eventType', (tester) async {
    final fake = FakeApiService(events: _twoEvents);
    await tester.pumpWidget(_buildScreen(apiService: fake));
    await tester.pumpAndSettle();

    expect(find.text('obstruction'), findsOneWidget);
  });

  testWidgets('5. Error state renders "Failed to load events"', (tester) async {
    final fake = FakeApiService(shouldThrow: true);
    await tester.pumpWidget(_buildScreen(apiService: fake));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load events'), findsOneWidget);
  });
}

class _SlowFakeApiService extends ApiService {
  final Future<List<EventModel>> _future;

  _SlowFakeApiService(this._future);

  @override
  Future<List<EventModel>> listEvents() => _future;
}
