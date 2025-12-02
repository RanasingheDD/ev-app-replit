import 'package:flutter/foundation.dart';
import '../models/ev.dart';
import '../services/ev_service.dart';

class EVProvider extends ChangeNotifier {
  final EVService _evService = EVService();

  List<EV> _evs = [];
  EV? _selectedEv;
  bool _isLoading = false;
  String? _error;

  List<EV> get evs => _evs;
  EV? get selectedEv => _selectedEv;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasEVs => _evs.isNotEmpty;

  Future<void> loadEVs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _evs = await _evService.getUserEVs();
      if (_evs.isNotEmpty && _selectedEv == null) {
        _selectedEv = _evs.first;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addEV({
    required String make,
    required String model,
    int? year,
    required double batteryKwh,
    required double maxChargeKw,
    required List<String> connectorTypes,
    String? vin,
    String? licensePlate,
    String? nickname,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ev = await _evService.addEV(
        make: make,
        model: model,
        year: year,
        batteryKwh: batteryKwh,
        maxChargeKw: maxChargeKw,
        connectorTypes: connectorTypes,
        vin: vin,
        licensePlate: licensePlate,
        nickname: nickname,
      );
      _evs.add(ev);
      if (_evs.length == 1) {
        _selectedEv = ev;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEV(
    String evId, {
    String? make,
    String? model,
    int? year,
    double? batteryKwh,
    double? maxChargeKw,
    List<String>? connectorTypes,
    String? vin,
    String? licensePlate,
    String? nickname,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEv = await _evService.updateEV(
        evId,
        make: make,
        model: model,
        year: year,
        batteryKwh: batteryKwh,
        maxChargeKw: maxChargeKw,
        connectorTypes: connectorTypes,
        vin: vin,
        licensePlate: licensePlate,
        nickname: nickname,
      );

      final index = _evs.indexWhere((ev) => ev.id == evId);
      if (index >= 0) {
        _evs[index] = updatedEv;
      }

      if (_selectedEv?.id == evId) {
        _selectedEv = updatedEv;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEV(String evId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _evService.deleteEV(evId);
      _evs.removeWhere((ev) => ev.id == evId);

      if (_selectedEv?.id == evId) {
        _selectedEv = _evs.isNotEmpty ? _evs.first : null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectEV(EV ev) {
    _selectedEv = ev;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
