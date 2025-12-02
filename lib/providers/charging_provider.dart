import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/charging_session.dart';
import '../services/charging_service.dart';

class ChargingProvider extends ChangeNotifier {
  final ChargingService _chargingService = ChargingService();

  ChargingSession? _activeSession;
  ChargingTelemetry? _telemetry;
  List<ChargingSession> _sessionHistory = [];
  bool _isLoading = false;
  String? _error;
  Timer? _telemetryTimer;

  ChargingSession? get activeSession => _activeSession;
  ChargingTelemetry? get telemetry => _telemetry;
  List<ChargingSession> get sessionHistory => _sessionHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveSession => _activeSession != null && _activeSession!.isActive;

  Future<void> checkActiveSession() async {
    try {
      _activeSession = await _chargingService.getActiveSession();
      if (_activeSession != null && _activeSession!.isActive) {
        _startTelemetryPolling();
      }
      notifyListeners();
    } catch (e) {
      _activeSession = null;
    }
  }

  Future<ChargingSession?> startCharging({
    required String bookingId,
    required String chargerId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeSession = await _chargingService.startCharging(
        bookingId: bookingId,
        chargerId: chargerId,
      );
      _startTelemetryPolling();
      _isLoading = false;
      notifyListeners();
      return _activeSession;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<ChargingSession?> stopCharging() async {
    if (_activeSession == null) return null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stopTelemetryPolling();
      final session = await _chargingService.stopCharging(sessionId: _activeSession!.id);
      _activeSession = session;
      _sessionHistory.insert(0, session);
      _isLoading = false;
      notifyListeners();
      return session;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> emergencyStop() async {
    if (_activeSession == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stopTelemetryPolling();
      await _chargingService.emergencyStop(_activeSession!.id);
      await refreshSessionStatus();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshSessionStatus() async {
    if (_activeSession == null) return;

    try {
      _activeSession = await _chargingService.getSessionStatus(_activeSession!.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshTelemetry() async {
    if (_activeSession == null) return;

    try {
      _telemetry = await _chargingService.getSessionTelemetry(_activeSession!.id);
      notifyListeners();
    } catch (e) {
      // Telemetry refresh failure is not critical
    }
  }

  void _startTelemetryPolling() {
    _stopTelemetryPolling();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      refreshTelemetry();
      refreshSessionStatus();
    });
  }

  void _stopTelemetryPolling() {
    _telemetryTimer?.cancel();
    _telemetryTimer = null;
  }

  Future<void> loadSessionHistory({int? limit}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessionHistory = await _chargingService.getSessionHistory(limit: limit);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ChargingSession?> getSessionById(String sessionId) async {
    try {
      return await _chargingService.getSessionStatus(sessionId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearActiveSession() {
    _stopTelemetryPolling();
    _activeSession = null;
    _telemetry = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTelemetryPolling();
    super.dispose();
  }
}
