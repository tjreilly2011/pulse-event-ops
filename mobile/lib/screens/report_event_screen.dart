import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/api_service.dart';

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

  ReportEventScreen({super.key, ApiService? apiService})
      : apiService = apiService ?? ApiService();

  @override
  State<ReportEventScreen> createState() => _ReportEventScreenState();
}

class _ReportEventScreenState extends State<ReportEventScreen> {
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
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              kLocationPlaceholder,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
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
                childAspectRatio: 1.4,
                children: _categories.map((cat) {
                  final type = cat['type'] as String;
                  final label = cat['label'] as String;
                  final icon = cat['icon'] as IconData;
                  final isSelected = _selectedType == type;
                  return Card(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).cardColor,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedType = type;
                          _selectedLabel = label;
                        });
                      },
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon),
                            const SizedBox(height: 4),
                            Text(label),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              _selectedLabel != null
                  ? Text('Selected: $_selectedLabel')
                  : const SizedBox(height: 24),
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
                  child: const Text('Send Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
