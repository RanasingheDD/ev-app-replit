import 'charger.dart';
import 'station.dart';

enum BookingStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
  expired,
  noShow,
}

class Booking {
  final String id;
  final String userId;
  final String chargerId;
  final String stationId;
  final DateTime startAt;
  final DateTime endAt;
  final BookingStatus status;
  final String? paymentId;
  final double estimatedCost;
  final double? finalCost;
  final String? qrCode;
  final String? evId;
  final DateTime createdAt;
  final Station? station;
  final Charger? charger;

  Booking({
    required this.id,
    required this.userId,
    required this.chargerId,
    required this.stationId,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.paymentId,
    required this.estimatedCost,
    this.finalCost,
    this.qrCode,
    this.evId,
    required this.createdAt,
    this.station,
    this.charger,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String? ?? "",
      userId: json['userId'] as String? ?? "",
      chargerId: json['chargerId'] as String? ?? "",
      stationId: json['stationId'] as String? ?? "",
      startAt: DateTime.parse(json['startAt'] as String).toLocal(),
      endAt: DateTime.parse(json['endAt'] as String).toLocal(),
      status: _parseStatus(json['status'] as String),
      paymentId: json['paymentId'] as String? ?? "No Id",
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      finalCost: (json['finalCost'] as num?)?.toDouble(),
      qrCode: json['qrCode'] as String? ?? "No-QR",
      evId: json['evId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      station: json['station'] != null
          ? Station.fromJson(json['station'] as Map<String, dynamic>)
          : null,
      charger: json['charger'] != null
          ? Charger.fromJson(json['charger'] as Map<String, dynamic>)
          : null,
    );
  }

  static BookingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'active':
        return BookingStatus.active;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'expired':
        return BookingStatus.expired;
      case 'no_show':
      case 'noshow':
        return BookingStatus.noShow;
      default:
        return BookingStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'chargerId': chargerId,
      'stationId': stationId,
      'startAt': startAt.toUtc().toIso8601String(),
      'endAt': endAt.toUtc().toIso8601String(),
      'status': statusString,
      'paymentId': paymentId,
      'estimatedCost': estimatedCost,
      'finalCost': finalCost,
      'qrCode': qrCode,
      'evId': evId,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  String get statusString {
    switch (status) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.active:
        return 'active';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.expired:
        return 'expired';
      case BookingStatus.noShow:
        return 'no_show';
    }
  }

  Duration get duration => endAt.difference(startAt);

  String get durationDisplay {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  bool get canCancel =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  bool get canStartCharging =>
      status == BookingStatus.confirmed &&
      DateTime.now().isAfter(startAt.subtract(const Duration(minutes: 15)));

  bool get isUpcoming =>
      (status == BookingStatus.pending || status == BookingStatus.confirmed) &&
      startAt.isAfter(DateTime.now());

  bool get isPast =>
      status == BookingStatus.completed ||
      status == BookingStatus.cancelled ||
      status == BookingStatus.expired ||
      status == BookingStatus.noShow;
}

class BookingQuote {
  final String chargerId;
  final String stationId;
  final DateTime startAt;
  final DateTime endAt;
  final double estimatedEnergy;
  final double estimatedCost;
  final String currency;
  final bool available;
  final String? unavailableReason;

  BookingQuote({
    required this.chargerId,
    required this.stationId,
    required this.startAt,
    required this.endAt,
    required this.estimatedEnergy,
    required this.estimatedCost,
    required this.currency,
    required this.available,
    this.unavailableReason,
  });

  factory BookingQuote.fromJson(Map<String, dynamic> json) {
    return BookingQuote(
      chargerId: json['chargerId'] as String,
      stationId: json['stationId'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      estimatedEnergy: (json['estimatedEnergy'] as num).toDouble(),
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'LKR',
      available: json['available'] as bool? ?? true,
      unavailableReason: json['unavailableReason'] as String? ?? "",
    );
  }
}
