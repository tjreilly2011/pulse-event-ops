import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class RecentEventsScreen extends StatefulWidget {
  final ApiService apiService;

  RecentEventsScreen({super.key, ApiService? apiService})
      : apiService = apiService ?? ApiService();

  @override
  State<RecentEventsScreen> createState() => _RecentEventsScreenState();
}

class _RecentEventsScreenState extends State<RecentEventsScreen> {
  late Future<List<EventModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = widget.apiService.listEvents();
  }

  Future<void> _refresh() async {
    setState(() {
      _eventsFuture = widget.apiService.listEvents();
    });
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toUpperCase()) {
      case 'CREATED':
        bg = const Color(0xFF0A2342);
        fg = Colors.white;
        break;
      case 'ACKNOWLEDGED':
        bg = const Color(0xFFFFB300);
        fg = Colors.black;
        break;
      case 'IN_PROGRESS':
        bg = Colors.orange;
        fg = Colors.black;
        break;
      case 'RESOLVED':
        bg = Colors.green.shade700;
        fg = Colors.white;
        break;
      case 'CANCELLED':
        bg = Colors.grey.shade600;
        fg = Colors.white;
        break;
      default:
        bg = Colors.grey.shade400;
        fg = Colors.black;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recent Events')),
      body: FutureBuilder<List<EventModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load events'));
          }
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('No events yet'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.displayTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            _statusBadge(event.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${event.destinationLocationId}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        Text(
                          _formatDate(event.createdAt),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
