import 'package:flutter/material.dart';
import '../models/rail_service_model.dart';
import '../models/rail_service_stop_model.dart';
import '../models/rail_station_model.dart';
import '../services/api_service.dart';
import '../state/selected_rail_context.dart';

class RailContextScreen extends StatefulWidget {
  final ApiService apiService;
  final SelectedRailContext selectedRailContext;

  RailContextScreen({
    super.key,
    ApiService? apiService,
    required this.selectedRailContext,
  }) : apiService = apiService ?? ApiService();

  @override
  State<RailContextScreen> createState() => _RailContextScreenState();
}

class _RailContextScreenState extends State<RailContextScreen> {
  late Future<_RailContextData> _future;
  final Map<String, List<RailServiceStopModel>> _stopsByServiceId = {};
  String? _selectedServiceId;
  String? _selectedStationId;

  @override
  void initState() {
    super.initState();
    _future = _loadContext();
  }

  Future<_RailContextData> _loadContext() async {
    final results = await Future.wait([
      widget.apiService.listRailServices(),
      widget.apiService.listRailStations(),
    ]);
    final services = results[0] as List<RailServiceModel>;
    final stations = results[1] as List<RailStationModel>;
    final data = _RailContextData(
      services: services,
      stationsById: {for (final station in stations) station.id: station},
    );
    await _applyFallbackIfNeeded(data);
    return data;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadContext();
    });
    await _future;
  }

  bool _isActiveService(RailServiceModel service) {
    final status = service.status.toUpperCase();
    return status == 'ON_TIME' || status == 'DELAYED';
  }

  RailServiceModel _pickFallbackService(List<RailServiceModel> services) {
    return services.firstWhere(
      _isActiveService,
      orElse: () => services.first,
    );
  }

  String? _pickCurrentOrFirstStopStationId(List<RailServiceStopModel> stops) {
    if (stops.isEmpty) return null;

    final orderedStops = [...stops]
      ..sort((a, b) => a.stopSequence.compareTo(b.stopSequence));
    final now = DateTime.now().toUtc();

    for (final stop in orderedStops) {
      final arrival = stop.scheduledArrival?.toUtc();
      final departure = stop.scheduledDeparture?.toUtc();
      if (arrival != null && departure != null) {
        if (!now.isBefore(arrival) && !now.isAfter(departure)) {
          return stop.stationId;
        }
      }
    }

    return orderedStops
        .firstWhere(
          (stop) => stop.stationId != null,
          orElse: () => orderedStops.first,
        )
        .stationId;
  }

  Future<List<RailServiceStopModel>> _stopsForService(String serviceId) async {
    final cached = _stopsByServiceId[serviceId];
    if (cached != null) return cached;
    final stops = await widget.apiService.listServiceStops(serviceId);
    _stopsByServiceId[serviceId] = stops;
    return stops;
  }

  Future<void> _applyFallbackIfNeeded(_RailContextData data) async {
    if (data.services.isEmpty) return;

    if (widget.selectedRailContext.selectedServiceId != null) {
      _selectedServiceId = widget.selectedRailContext.selectedServiceId;
      _selectedStationId = widget.selectedRailContext.selectedStationId;
      await _stopsForService(widget.selectedRailContext.selectedServiceId!);
      return;
    }

    if (widget.selectedRailContext.hasExplicitSelection) return;

    final fallbackService = _pickFallbackService(data.services);
    final stops = await _stopsForService(fallbackService.id);
    final fallbackStationId = _pickCurrentOrFirstStopStationId(stops);
    if (fallbackStationId == null) return;

    final fallbackStation = data.stationsById[fallbackStationId];
    if (fallbackStation == null) return;

    widget.selectedRailContext.applyFallback(
      serviceId: fallbackService.id,
      serviceCode: fallbackService.serviceCode,
      stationId: fallbackStation.id,
      stationName: fallbackStation.name,
    );
    _selectedServiceId = fallbackService.id;
    _selectedStationId = fallbackStation.id;
  }

  Future<void> _onServiceSelected(
    RailServiceModel service,
    _RailContextData data,
  ) async {
    setState(() {
      _selectedServiceId = service.id;
      _selectedStationId = null;
    });
    widget.selectedRailContext.selectService(
      serviceId: service.id,
      serviceCode: service.serviceCode,
    );

    final stops = await _stopsForService(service.id);
    final stationId = _pickCurrentOrFirstStopStationId(stops);
    if (!mounted || stationId == null) return;

    final station = data.stationsById[stationId];
    if (station == null) return;

    setState(() {
      _selectedStationId = station.id;
    });
    widget.selectedRailContext.selectStation(
      stationId: station.id,
      stationName: station.name,
    );
  }

  void _onStationSelected(RailStationModel station) {
    setState(() {
      _selectedStationId = station.id;
    });
    widget.selectedRailContext.selectStation(
      stationId: station.id,
      stationName: station.name,
    );
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
      body: FutureBuilder<_RailContextData>(
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
          final data = snapshot.data;
          final services = data?.services ?? [];
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

          final selectedServiceId =
              _selectedServiceId ?? widget.selectedRailContext.selectedServiceId;
          final selectedStationId =
              _selectedStationId ?? widget.selectedRailContext.selectedStationId;
          final selectedService = services
              .where((service) => service.id == selectedServiceId)
              .cast<RailServiceModel?>()
              .firstOrNull;
          final selectedStops = selectedService == null
              ? const <RailServiceStopModel>[]
              : (_stopsByServiceId[selectedService.id] ??
                  const <RailServiceStopModel>[]);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: [
                for (final service in services)
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      selected: selectedServiceId == service.id,
                      onTap: () => _onServiceSelected(service, data!),
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
                  ),
                if (selectedService != null) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Stations',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (selectedStops.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('No stops for selected service'),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedStops
                            .map((stop) => stop.stationId)
                            .whereType<String>()
                            .map((stationId) => data!.stationsById[stationId])
                            .whereType<RailStationModel>()
                            .map(
                              (station) => ChoiceChip(
                                label: Text('${station.name} (${station.code})'),
                                selected: selectedStationId == station.id,
                                onSelected: (_) => _onStationSelected(station),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RailContextData {
  final List<RailServiceModel> services;
  final Map<String, RailStationModel> stationsById;

  const _RailContextData({
    required this.services,
    required this.stationsById,
  });
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
