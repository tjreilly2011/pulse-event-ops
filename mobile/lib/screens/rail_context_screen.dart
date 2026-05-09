import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/rail_context_response_model.dart';
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
  bool _isLoadingContextBlocks = false;
  String? _contextBlocksError;
  RailServiceContextResponseModel? _serviceContext;
  RailStationContextResponseModel? _stationContext;

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
    await _loadSelectedContextBlocks(triggerSetState: false);
    return data;
  }

  Future<void> _refresh() async {
    _stopsByServiceId.clear();
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
    return services.firstWhere(_isActiveService, orElse: () => services.first);
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
    await _loadSelectedContextBlocks();
  }

  Future<void> _onStationSelected(RailStationModel station) async {
    setState(() {
      _selectedStationId = station.id;
    });
    widget.selectedRailContext.selectStation(
      stationId: station.id,
      stationName: station.name,
    );
    await _loadSelectedContextBlocks();
  }

  Future<void> _loadSelectedContextBlocks({bool triggerSetState = true}) async {
    final serviceId =
        _selectedServiceId ?? widget.selectedRailContext.selectedServiceId;
    final stationId =
        _selectedStationId ?? widget.selectedRailContext.selectedStationId;

    if (serviceId == null && stationId == null) {
      if (triggerSetState) {
        setState(() {
          _serviceContext = null;
          _stationContext = null;
          _isLoadingContextBlocks = false;
          _contextBlocksError = null;
        });
      } else {
        _serviceContext = null;
        _stationContext = null;
        _isLoadingContextBlocks = false;
        _contextBlocksError = null;
      }
      return;
    }

    if (triggerSetState) {
      setState(() {
        _isLoadingContextBlocks = true;
        _contextBlocksError = null;
      });
    } else {
      _isLoadingContextBlocks = true;
      _contextBlocksError = null;
    }

    try {
      final results = await Future.wait([
        serviceId == null
            ? Future<RailServiceContextResponseModel?>.value(null)
            : widget.apiService.getServiceContext(serviceId),
        stationId == null
            ? Future<RailStationContextResponseModel?>.value(null)
            : widget.apiService.getStationContext(stationId),
      ]);

      if (!mounted && triggerSetState) return;

      final serviceContext = results[0] as RailServiceContextResponseModel?;
      final stationContext = results[1] as RailStationContextResponseModel?;

      if (triggerSetState) {
        setState(() {
          _serviceContext = serviceContext;
          _stationContext = stationContext;
          _isLoadingContextBlocks = false;
          _contextBlocksError = null;
        });
      } else {
        _serviceContext = serviceContext;
        _stationContext = stationContext;
        _isLoadingContextBlocks = false;
        _contextBlocksError = null;
      }
    } catch (error) {
      if (!mounted && triggerSetState) return;

      if (triggerSetState) {
        setState(() {
          _serviceContext = null;
          _stationContext = null;
          _isLoadingContextBlocks = false;
          _contextBlocksError = error.toString();
        });
      } else {
        _serviceContext = null;
        _stationContext = null;
        _isLoadingContextBlocks = false;
        _contextBlocksError = error.toString();
      }
    }
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

  Color _dotColor(String dot) {
    switch (dot.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'amber':
        return Colors.amber;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildServiceContextCard() {
    final selectedService = _serviceContext?.service;
    if (selectedService == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Service context unavailable for the current selection.'),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        title: Text(
          selectedService.serviceCode,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text('Direction: ${selectedService.direction}'),
            Text('Status: ${_formatLabel(selectedService.status)}'),
          ],
        ),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _dotColor(_serviceContext?.statusDot ?? 'Amber'),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildStationContextCard() {
    final stationContext = _stationContext;
    if (stationContext == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Station context unavailable for the current selection.'),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${stationContext.station.name} (${stationContext.station.code})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _dotColor(stationContext.status),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Status: ${_formatLabel(stationContext.status)}'),
            Text('Active events: ${stationContext.activeEventCount}'),
            Text('Staff on duty: ${stationContext.staffOnDuty}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedEventsSection() {
    final events = _relatedEvents;
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('No active related events.'),
      );
    }

    return Column(
      children: [
        for (final event in events)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              title: Text(event.displayTitle),
              subtitle: Text(
                '${_formatLabel(event.eventType)} · ${_formatLabel(event.status)}',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStaffSummarySection() {
    final serviceStaff =
        _serviceContext?.staff ?? const <RailStaffPresenceModel>[];
    final stationStaff =
        _stationContext?.staff ?? const <RailStaffPresenceModel>[];
    final staff = serviceStaff.isNotEmpty ? serviceStaff : stationStaff;

    if (staff.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('No staff presence reported.'),
      );
    }

    final onDutyCount = staff
        .where((person) => person.status == 'ON_DUTY')
        .length;
    final offDutyCount = staff.length - onDutyCount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('On duty: $onDutyCount'),
            Text('Other status: $offDutyCount'),
            const SizedBox(height: 8),
            for (final person in staff.take(3))
              Text('${person.roleLabel} (${_formatLabel(person.status)})'),
          ],
        ),
      ),
    );
  }

  List<EventModel> get _relatedEvents {
    final serviceEvents = _serviceContext?.activeEvents ?? const <EventModel>[];
    final stationEvents = _stationContext?.activeEvents ?? const <EventModel>[];
    if (serviceEvents.isNotEmpty) return serviceEvents;
    return stationEvents;
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
              _selectedServiceId ??
              widget.selectedRailContext.selectedServiceId;
          final selectedStationId =
              _selectedStationId ??
              widget.selectedRailContext.selectedStationId;
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
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                                label: Text(
                                  '${station.name} (${station.code})',
                                ),
                                selected: selectedStationId == station.id,
                                onSelected: (_) => _onStationSelected(station),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  if (_isLoadingContextBlocks)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_contextBlocksError != null)
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Could not load context details.',
                              style: TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _contextBlocksError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: _loadSelectedContextBlocks,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    _sectionTitle('Selected service'),
                    _buildServiceContextCard(),
                    _sectionTitle('Station context'),
                    _buildStationContextCard(),
                    _sectionTitle('Related events'),
                    _buildRelatedEventsSection(),
                    _sectionTitle('Staff summary'),
                    _buildStaffSummarySection(),
                  ],
                  const SizedBox(height: 16),
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

  const _RailContextData({required this.services, required this.stationsById});
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
