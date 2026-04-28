import 'package:flutter/material.dart';
import '../constants.dart';
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
            return const Center(child: Text('No events yet'));
          }
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event.displayTitle),
                subtitle: Text(
                  '${_formatDate(event.createdAt)}\n$kLocationPlaceholder',
                ),
                isThreeLine: true,
                trailing: Chip(label: Text(event.status)),
              );
            },
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
