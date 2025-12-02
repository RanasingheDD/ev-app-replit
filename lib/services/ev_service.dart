import '../models/ev.dart';
import 'api_service.dart';

class EVService {
  final ApiService _api = ApiService();

  Future<List<EV>> getUserEVs() async {
    final response = await _api.get('/users/evs');

    print("RAW RESPONSE: $response");

    final evs = response['evs'];

    if (evs is List) {
      return evs
          .map((item) => EV.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<EV> addEV({
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
    final response = await _api.post(
      '/users/evs',
      body: {
        'make': make,
        'model': model,
        'year': year,
        'batteryKwh': batteryKwh,
        'maxChargeKw': maxChargeKw,
        'connectorTypes': connectorTypes,
        'vin': vin,
        'licensePlate': licensePlate,
        'nickname': nickname,
        'createdAt': "2025-11-29T16:40:00Z",
      },
    );

    // Extract EV from: { "evs": [ {...} ] }
    final evs = response['evs'];

    if (evs is List && evs.isNotEmpty) {
      return EV.fromJson(evs.first);
    }

    throw Exception("Invalid EV response: $response");
  }

  Future<EV> updateEV(
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
    final body = <String, dynamic>{};
    if (make != null) body['make'] = make;
    if (model != null) body['model'] = model;
    if (year != null) body['year'] = year;
    if (batteryKwh != null) body['batteryKwh'] = batteryKwh;
    if (maxChargeKw != null) body['maxChargeKw'] = maxChargeKw;
    if (connectorTypes != null) body['connectorTypes'] = connectorTypes;
    if (vin != null) body['vin'] = vin;
    if (licensePlate != null) body['licensePlate'] = licensePlate;
    if (nickname != null) body['nickname'] = nickname;

    final response = await _api.put('/users/evs/$evId', body: body);
    return EV.fromJson(response);
  }

  Future<void> deleteEV(String evId) async {
    await _api.delete('/users/evs/$evId');
  }

  Future<EV> getEVById(String evId) async {
    final response = await _api.get('/users/evs/$evId');
    return EV.fromJson(response);
  }
}
