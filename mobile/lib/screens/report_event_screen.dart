import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/api_service.dart';
import '../state/selected_rail_context.dart';

const _categories = [
  {'label': 'Delay', 'type': 'delay', 'icon': Icons.train},
  {'label': 'Overcrowding', 'type': 'overcrowding', 'icon': Icons.groups},
  {
    'label': 'Assistance',
    'type': 'passenger_assistance',
    'icon': Icons.accessible
  },
  {'label': 'Safety', 'type': 'safety_security', 'icon': Icons.security},
];

class ReportEventScreen extends StatefulWidget {
  final ApiService apiService;
  final SelectedRailContext? selectedRailContext;

  ReportEventScreen({
    super.key,
    ApiService? apiService,
    this.selectedRailContext,
  }) : apiService = apiService ?? ApiService();

  @override
  State<ReportEventScreen> createState() => _ReportEventScreenState();
}

class _ReportEventScreenState extends State<ReportEventScreen> {
  String _locationLabel() {
    final contextState = widget.selectedRailContext;
    if (contextState == null) return kLocationPlaceholder;
    final serviceCode = contextState.selectedServiceCode;
    final stationName = contextState.selectedStationName;
    if (serviceCode != null && stationName != null) {
      return '$serviceCode • $stationName';
    }
    if (serviceCode != null) {
      return serviceCode;
    }
    if (stationName != null) {
      return stationName;
    }
    return kLocationPlaceholder;
  }

  String? _selectedType;
  String? _selectedLabel;
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_selectedType == null) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.apiService.createEvent(
        eventType: _selectedType!,
        title: _selectedLabel!,
        description: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event sent')),
        );
        setState(() {
          _selectedType = null;
          _selectedLabel = null;
          _noteController.clear();
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send event')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse Operations'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: widget.selectedRailContext == null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _locationLabel(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                )
              : AnimatedBuilder(
                  animation: widget.selectedRailContext!,
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _locationLabel(),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    );
                  },
                ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: _categories.map((cat) {
                  final type = cat['type'] as String;
                  final label = cat['label'] as String;
                  final icon = cat['icon'] as IconData;
                  final isSelected = _selectedType == type;
                  final primary = Theme.of(context).colorScheme.primary;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = type;
                        _selectedLabel = label;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primary.withValues(alpha: 0.08)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected ? primary : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon,
                                size: 36,
                                color: isSelected
                                    ? primary
                                    : Colors.grey.shade600),
                            const SizedBox(height: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 13,
                                color: isSelected
                                    ? primary
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Optional note',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_selectedType == null || _isSubmitting) ? null : _onSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2),
                        )
                      : const Text('Send Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
