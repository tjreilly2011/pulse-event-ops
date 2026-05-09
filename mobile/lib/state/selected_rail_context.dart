import 'package:flutter/foundation.dart';

class SelectedRailContext extends ChangeNotifier {
  String? selectedServiceId;
  String? selectedServiceCode;
  String? selectedStationId;
  String? selectedStationName;

  bool _hasExplicitSelection = false;

  bool get hasExplicitSelection => _hasExplicitSelection;

  void selectService({
    required String serviceId,
    required String serviceCode,
    bool explicit = true,
  }) {
    selectedServiceId = serviceId;
    selectedServiceCode = serviceCode;
    if (explicit) {
      _hasExplicitSelection = true;
    }
    notifyListeners();
  }

  void selectStation({
    required String stationId,
    required String stationName,
    bool explicit = true,
  }) {
    selectedStationId = stationId;
    selectedStationName = stationName;
    if (explicit) {
      _hasExplicitSelection = true;
    }
    notifyListeners();
  }

  void applyFallback({
    required String serviceId,
    required String serviceCode,
    required String stationId,
    required String stationName,
  }) {
    if (_hasExplicitSelection) return;
    selectedServiceId = serviceId;
    selectedServiceCode = serviceCode;
    selectedStationId = stationId;
    selectedStationName = stationName;
    notifyListeners();
  }
}