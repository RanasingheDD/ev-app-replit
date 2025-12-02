enum SessionStatus {
  starting,
  charging,
  stopping,
  completed,
  failed,
  cancelled,
}

class ChargingSession {
  final String id;
  final String? bookingId;
  final String chargerId;
  final String stationId;
  final String userId;
  final String? transactionId;
  final DateTime startTimestamp;
  final DateTime? stopTimestamp;
  final double energyKwh;
  final double? finalCost;
  final SessionStatus status;
  final String? evId;
  final ChargingTelemetry? telemetry;

  ChargingSession({
    required this.id,
    this.bookingId,
    required this.chargerId,
    required this.stationId,
    required this.userId,
    this.transactionId,
    required this.startTimestamp,
    this.stopTimestamp,
    required this.energyKwh,
    this.finalCost,
    required this.status,
    this.evId,
    this.telemetry,
  });

  factory ChargingSession.fromJson(Map<String, dynamic> json) {
    return ChargingSession(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String?,
      chargerId: json['chargerId'] as String,
      stationId: json['stationId'] as String,
      userId: json['userId'] as String,
      transactionId: json['transactionId'] as String?,
      startTimestamp: DateTime.parse(
        json['startTimestamp'] as String,
      ).toLocal(),
      stopTimestamp: json['stopTimestamp'] != null
          ? DateTime.parse(json['stopTimestamp'] as String).toLocal()
          : null,
      energyKwh: (json['energy_kWh'] as num?)?.toDouble() ?? 0,
      finalCost: (json['finalCost'] as num?)?.toDouble(),
      status: _parseStatus(json['status'] as String),
      evId: json['evId'] as String?,
      telemetry: json['telemetry'] != null
          ? ChargingTelemetry.fromJson(
              json['telemetry'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  static SessionStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'starting':
        return SessionStatus.starting;
      case 'charging':
        return SessionStatus.charging;
      case 'stopping':
        return SessionStatus.stopping;
      case 'completed':
        return SessionStatus.completed;
      case 'failed':
        return SessionStatus.failed;
      case 'cancelled':
        return SessionStatus.cancelled;
      default:
        return SessionStatus.charging;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'chargerId': chargerId,
      'stationId': stationId,
      'userId': userId,
      'transactionId': transactionId,
      'startTimestamp': startTimestamp.toIso8601String(),
      'stopTimestamp': stopTimestamp?.toIso8601String(),
      'energy_kWh': energyKwh,
      'finalCost': finalCost,
      'status': statusString,
      'evId': evId,
    };
  }

  String get statusString {
    switch (status) {
      case SessionStatus.starting:
        return 'starting';
      case SessionStatus.charging:
        return 'charging';
      case SessionStatus.stopping:
        return 'stopping';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.failed:
        return 'failed';
      case SessionStatus.cancelled:
        return 'cancelled';
    }
  }

  Duration get duration {
    final end = stopTimestamp ?? DateTime.now();
    return end.difference(startTimestamp);
  }

  String get durationDisplay {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  bool get isActive =>
      status == SessionStatus.starting || status == SessionStatus.charging;

  bool get canStop => status == SessionStatus.charging;
}

class ChargingTelemetry {
  final double currentPowerKw;
  final double energyDeliveredKwh;
  final double voltage;
  final double current;
  final double stateOfCharge;
  final double? estimatedTimeRemaining;
  final double currentCost;
  final DateTime timestamp;

  ChargingTelemetry({
    required this.currentPowerKw,
    required this.energyDeliveredKwh,
    required this.voltage,
    required this.current,
    required this.stateOfCharge,
    this.estimatedTimeRemaining,
    required this.currentCost,
    required this.timestamp,
  });

  factory ChargingTelemetry.fromJson(Map<String, dynamic> json) {
    return ChargingTelemetry(
      currentPowerKw: (json['currentPower_kW'] as num).toDouble(),
      energyDeliveredKwh: (json['energyDelivered_kWh'] as num).toDouble(),
      voltage: (json['voltage'] as num).toDouble(),
      current: (json['current'] as num).toDouble(),
      stateOfCharge: (json['stateOfCharge'] as num).toDouble(),
      estimatedTimeRemaining: (json['estimatedTimeRemaining'] as num?)
          ?.toDouble(),
      currentCost: (json['currentCost'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String get powerDisplay => '${currentPowerKw.toStringAsFixed(1)} kW';
  String get energyDisplay => '${energyDeliveredKwh.toStringAsFixed(2)} kWh';
  String get socDisplay => '${stateOfCharge.toInt()}%';
  String get costDisplay => 'Rs. ${currentCost.toStringAsFixed(2)}';

  String? get timeRemainingDisplay {
    if (estimatedTimeRemaining == null) return null;
    final minutes = estimatedTimeRemaining!.toInt();
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }
}
