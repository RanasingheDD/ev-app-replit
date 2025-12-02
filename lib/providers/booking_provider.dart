import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<Booking> _bookings = [];
  List<Booking> _upcomingBookings = [];
  Booking? _selectedBooking;
  BookingQuote? _currentQuote;
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  List<Booking> get upcomingBookings => _upcomingBookings;
  Booking? get selectedBooking => _selectedBooking;
  BookingQuote? get currentQuote => _currentQuote;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _bookingService.getUserBookings();
      _upcomingBookings = _bookings.where((b) => b.isUpcoming).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUpcomingBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _upcomingBookings = await _bookingService.getUpcomingBookings();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<BookingQuote?> getQuote({
    required String chargerId,
    required String stationId,
    required DateTime startAt,
    required DateTime endAt,
    String? evId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentQuote = await _bookingService.getBookingQuote(
        chargerId: chargerId,
        stationId: stationId,
        startAt: startAt,
        endAt: endAt,
        evId: evId,
      );
      _isLoading = false;
      notifyListeners();
      return _currentQuote;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Booking?> createBooking({
    required String chargerId,
    required String stationId,
    required DateTime startAt,
    required DateTime endAt,
    required String paymentIntentId,
    String? evId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final booking = await _bookingService.createBooking(
        chargerId: chargerId,
        stationId: stationId,
        startAt: startAt,
        endAt: endAt,
        paymentIntentId: paymentIntentId,
        evId: evId,
      );
      _bookings.insert(0, booking);
      _upcomingBookings.insert(0, booking);
      _selectedBooking = booking;
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadBookingById(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedBooking = await _bookingService.getBookingById(bookingId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cancelledBooking = await _bookingService.cancelBooking(
        bookingId,
        reason: reason,
      );

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index >= 0) {
        _bookings[index] = cancelledBooking;
      }

      _upcomingBookings.removeWhere((b) => b.id == bookingId);

      if (_selectedBooking?.id == bookingId) {
        _selectedBooking = cancelledBooking;
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

  void clearQuote() {
    _currentQuote = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedBooking = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
