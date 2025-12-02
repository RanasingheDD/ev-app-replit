import '../models/station.dart';
import '../models/charger.dart';
import 'api_service.dart';

class StationService {
  final ApiService _api = ApiService();

  Future<List<Station>> getStations({
    double? lat,
    double? lng,
    double? radius,
    StationFilter? filter,
  }) async {
    final queryParams = <String, String>{};

    if (lat != null) queryParams['lat'] = lat.toString();
    if (lng != null) queryParams['lng'] = lng.toString();
    if (radius != null) queryParams['radius'] = radius.toString();

    if (filter != null) {
      queryParams.addAll(filter.toQueryParams());
    }

    final response = await _api.get('/ev_stations', queryParams: queryParams);
    final stationsJson =
        response['stations'] as List? ?? response['data'] as List? ?? [];
    return stationsJson
        .map((json) => Station.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Station> getStationById(String stationId) async {
    final response = await _api.get('/ev_stations/$stationId');
    return Station.fromJson(response);
  }

  Future<List<Charger>> getStationChargers(String stationId) async {
    final response = await _api.get('/ev_stations/$stationId/chargers');
    final chargersJson =
        response['chargers'] as List? ?? response['data'] as List? ?? [];
    return chargersJson
        .map((json) => Charger.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Charger> getChargerById(String chargerId) async {
    final response = await _api.get('/chargers/$chargerId');
    return Charger.fromJson(response);
  }

  Future<Map<String, dynamic>> scanQrCode(
    String qrCode, {
    String? bookingId,
  }) async {
    final body = <String, dynamic>{'qrCode': qrCode};
    if (bookingId != null) body['bookingId'] = bookingId;

    return await _api.post('/scan', body: body);
  }

  Future<List<Station>> searchStations(String query) async {
    final response = await _api.get(
      '/ev_stations/search',
      queryParams: {'q': query},
    );
    final stationsJson =
        response['stations'] as List? ?? response['data'] as List? ?? [];
    return stationsJson
        .map((json) => Station.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> rateStation(
    String stationId,
    int rating, {
    String? review,
  }) async {
    await _api.post(
      '/ev_stations/$stationId/reviews',
      body: {'rating': rating, 'review': review},
    );
  }

  Future<List<Map<String, dynamic>>> getStationReviews(String stationId) async {
    final response = await _api.get('/ev_stations/$stationId/reviews');
    return List<Map<String, dynamic>>.from(response['reviews'] as List? ?? []);
  }
}
