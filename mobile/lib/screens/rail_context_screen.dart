import 'package:flutter/material.dart';
import '../models/rail_service_model.dart';
import '../services/api_service.dart';

class RailContextScreen extends StatefulWidget {
  final ApiService apiService;

  RailContextScreen({super.key, ApiService? apiService})
      : apiService = apiService ?? ApiService();

  @override
  State<RailContextScreen> createState() => _RailContextScreenState();
}

class _RailContextScreenState extends State<RailContextScreen> {
  late Future<List<RailServiceModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.apiService.listRailServices();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = widget.apiService.listRailServices();
    });
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ON_TIME':
        return Colors.green;
      case 'DELAYED':
        return Colors.amber;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rail Services')),
      body: FutureBuilder<List<RailServiceModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final services = snapshot.data ?? [];
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.train, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('No rail services'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _statusColor(service.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          service.serviceCode,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(service.direction),
                      ],
                    ),
                    subtitle: Text(service.status),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
