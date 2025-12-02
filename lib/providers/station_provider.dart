import 'package:flutter/foundation.dart';
import '../models/station.dart';
import '../models/charger.dart';
import '../services/station_service.dart';

class StationProvider extends ChangeNotifier {
  final StationService _stationService = StationService();

  List<Station> _stations = [];
  Station? _selectedStation;
  List<Charger> _chargers = [];
  bool _isLoading = false;
  String? _error;
  StationFilter _filter = StationFilter();

  List<Station> get stations => _stations;
  Station? get selectedStation => _selectedStation;
  List<Charger> get chargers => _chargers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  StationFilter get filter => _filter;

  Future<void> loadStations({
    double? lat,
    double? lng,
    double? radius,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stations = await _stationService.getStations(
        lat: lat,
        lng: lng,
        radius: radius,
        filter: _filter,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStationById(String stationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedStation = await _stationService.getStationById(stationId);
      _chargers = _selectedStation?.chargers ?? [];
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadChargers(String stationId) async {
    try {
      _chargers = await _stationService.getStationChargers(stationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setFilter(StationFilter newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  void clearFilter() {
    _filter = StationFilter();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> scanQrCode(String qrCode, {String? bookingId}) async {
    try {
      return await _stationService.scanQrCode(qrCode, bookingId: bookingId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> searchStations(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stations = await _stationService.searchStations(query);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSelection() {
    _selectedStation = null;
    _chargers = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
