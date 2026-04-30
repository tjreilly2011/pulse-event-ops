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
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0A2342),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFB300),
          onSecondary: Colors.black,
          surface: Color(0xFFF5F7FA),
          onSurface: Color(0xFF1A1A2E),
          error: Color(0xFFD32F2F),
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A2342),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFFFFB300),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
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
