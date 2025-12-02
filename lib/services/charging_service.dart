import '../models/charging_session.dart';
import 'api_service.dart';

class ChargingService {
  final ApiService _api = ApiService();

  Future<ChargingSession> startCharging({
    required String bookingId,
    required String chargerId,
  }) async {
    final response = await _api.post('/charging/start', body: {
      'bookingId': bookingId,
      'chargerId': chargerId,
    });

    return ChargingSession.fromJson(response);
  }

  Future<ChargingSession> stopCharging({String? sessionId, String? chargerId}) async {
    final body = <String, dynamic>{};
    if (sessionId != null) body['sessionId'] = sessionId;
    if (chargerId != null) body['chargerId'] = chargerId;

    final response = await _api.post('/charging/stop', body: body);
    return ChargingSession.fromJson(response);
  }

  Future<ChargingSession> getSessionStatus(String sessionId) async {
    final response = await _api.get('/charging/$sessionId/status');
    return ChargingSession.fromJson(response);
  }

  Future<ChargingTelemetry> getSessionTelemetry(String sessionId) async {
    final response = await _api.get('/charging/$sessionId/telemetry');
    return ChargingTelemetry.fromJson(response);
  }

  Future<ChargingSession?> getActiveSession() async {
    try {
      final response = await _api.get('/charging/active');
      if (response['session'] != null) {
        return ChargingSession.fromJson(response['session'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<ChargingSession>> getSessionHistory({int? limit, int? offset}) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _api.get('/charging/history', queryParams: queryParams);
    final sessionsJson = response['sessions'] as List? ?? response['data'] as List? ?? [];
    return sessionsJson.map((json) => ChargingSession.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> emergencyStop(String sessionId) async {
    return await _api.post('/charging/$sessionId/emergency-stop');
  }
}
