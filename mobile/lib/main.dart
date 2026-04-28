import 'package:flutter/material.dart';
import 'screens/report_event_screen.dart';
import 'screens/recent_events_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const PulseOpsApp());
}

class PulseOpsApp extends StatelessWidget {
  final ApiService? apiService;

  const PulseOpsApp({super.key, this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse Operations',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: AppShell(apiService: apiService),
    );
  }
}

class AppShell extends StatefulWidget {
  final ApiService? apiService;

  const AppShell({super.key, this.apiService});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ReportEventScreen(apiService: widget.apiService),
      RecentEventsScreen(apiService: widget.apiService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Recent',
          ),
        ],
      ),
    );
  }
}
