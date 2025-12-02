import '../models/booking.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _api = ApiService();

  Future<BookingQuote> getBookingQuote({
    required String chargerId,
    required String stationId,
    required DateTime startAt,
    required DateTime endAt,
    String? evId,
  }) async {
    final response = await _api.post(
      '/bookings/quote',
      body: {
        'chargerId': chargerId,
        'stationId': stationId,
        'startAt': startAt.toUtc().toIso8601String(),
        'endAt': endAt.toUtc().toIso8601String(),
        'evId': evId,
      },
    );

    print(startAt);
    print(startAt.toUtc().toIso8601String());
    return BookingQuote.fromJson(response);
  }

  Future<Booking> createBooking({
    required String chargerId,
    required String stationId,
    required DateTime startAt,
    required DateTime endAt,
    required String paymentIntentId,
    String? evId,
  }) async {
    final response = await _api.post(
      '/bookings',
      body: {
        'chargerId': chargerId,
        'stationId': stationId,
        'startAt': startAt.toUtc().toIso8601String(),
        'endAt': endAt.toUtc().toIso8601String(),
        'paymentIntentId': paymentIntentId,
        'evId': evId,
      },
    );

    return Booking.fromJson(response);
  }

  Future<Booking> getBookingById(String bookingId) async {
    final response = await _api.get('/bookings/$bookingId');
    return Booking.fromJson(response);
  }

  Future<List<Booking>> getUserBookings({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final response = await _api.get('/bookings', queryParams: queryParams);
    final bookingsJson =
        response['bookings'] as List? ?? response['data'] as List? ?? [];
    return bookingsJson
        .map((json) => Booking.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Booking>> getUpcomingBookings() async {
    return getUserBookings(status: 'upcoming');
  }

  Future<List<Booking>> getPastBookings() async {
    return getUserBookings(status: 'past');
  }

  Future<Booking> cancelBooking(String bookingId, {String? reason}) async {
    final response = await _api.post(
      '/bookings/$bookingId/cancel',
      body: {'reason': reason},
    );

    return Booking.fromJson(response);
  }

  Future<Map<String, dynamic>> checkAvailability({
    required String chargerId,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    return await _api.post(
      '/bookings/check-availability',
      body: {
        'chargerId': chargerId,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAvailableSlots({
    required String chargerId,
    required DateTime date,
    int? durationMinutes,
  }) async {
    final response = await _api.get(
      '/bookings/available-slots',
      queryParams: {
        'chargerId': chargerId,
        'date': date.toIso8601String().split('T')[0],
        if (durationMinutes != null) 'duration': durationMinutes.toString(),
      },
    );

    return List<Map<String, dynamic>>.from(response['slots'] as List? ?? []);
  }
}
