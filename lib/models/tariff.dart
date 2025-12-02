enum TariffType { perKwh, perMinute, flatFee, flatPlusKwh }

class TariffRule {
  final String id;
  final TariffType type;
  final double price;
  final double? flatFee;
  final String currency;
  final String? description;
  final String? connectorType;
  final double? minPowerKw;
  final double? maxPowerKw;
  final TimeRange? peakHours;
  final double? peakMultiplier;

  TariffRule({
    required this.id,
    required this.type,
    required this.price,
    this.flatFee,
    required this.currency,
    this.description,
    this.connectorType,
    this.minPowerKw,
    this.maxPowerKw,
    this.peakHours,
    this.peakMultiplier,
  });

  factory TariffRule.fromJson(Map<String, dynamic> json) {
    return TariffRule(
      id: json['id'] as String? ?? '',
      type: _parseType(json['type'] as String? ?? ''),
      price: (json['price'] as num?)?.toDouble() ?? 1.0,
      flatFee: (json['flatFee'] as num?)?.toDouble() ?? 1.0,
      currency: json['currency'] as String? ?? 'LKR',
      description: json['description'] as String? ?? '',
      connectorType: json['connectorType'] as String? ?? '',
      minPowerKw: (json['minPower_kW'] as num?)?.toDouble() ?? 1.0,
      maxPowerKw: (json['maxPower_kW'] as num?)?.toDouble() ?? 1.0,
      peakHours: json['peakHours'] != null
          ? TimeRange.fromJson(json['peakHours'] as Map<String, dynamic>)
          : null,
      peakMultiplier: (json['peakMultiplier'] as num?)?.toDouble() ?? 1.0,
    );
  }

  static TariffType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'per_kwh':
      case 'perkwh':
        return TariffType.perKwh;
      case 'per_minute':
      case 'perminute':
        return TariffType.perMinute;
      case 'flat_fee':
      case 'flatfee':
        return TariffType.flatFee;
      case 'flat_plus_kwh':
      case 'flatpluskwh':
        return TariffType.flatPlusKwh;
      default:
        return TariffType.perKwh;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': typeString,
      'price': price,
      'flatFee': flatFee,
      'currency': currency,
      'description': description,
      'connectorType': connectorType,
      'minPower_kW': minPowerKw,
      'maxPower_kW': maxPowerKw,
      'peakHours': peakHours?.toJson(),
      'peakMultiplier': peakMultiplier,
    };
  }

  String get typeString {
    switch (type) {
      case TariffType.perKwh:
        return 'per_kwh';
      case TariffType.perMinute:
        return 'per_minute';
      case TariffType.flatFee:
        return 'flat_fee';
      case TariffType.flatPlusKwh:
        return 'flat_plus_kwh';
    }
  }

  String get displayPrice {
    switch (type) {
      case TariffType.perKwh:
        return 'Rs. ${price.toStringAsFixed(2)}/kWh';
      case TariffType.perMinute:
        return 'Rs. ${price.toStringAsFixed(2)}/min';
      case TariffType.flatFee:
        return 'Rs. ${price.toStringAsFixed(2)} flat';
      case TariffType.flatPlusKwh:
        return 'Rs. ${flatFee?.toStringAsFixed(2) ?? 0} + ${price.toStringAsFixed(2)}/kWh';
    }
  }

  double calculateCost({double? energyKwh, int? durationMinutes}) {
    switch (type) {
      case TariffType.perKwh:
        return price * (energyKwh ?? 0);
      case TariffType.perMinute:
        return price * (durationMinutes ?? 0);
      case TariffType.flatFee:
        return price;
      case TariffType.flatPlusKwh:
        return (flatFee ?? 0) + (price * (energyKwh ?? 0));
    }
  }
}

class TimeRange {
  final int startHour;
  final int endHour;

  TimeRange({required this.startHour, required this.endHour});

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      startHour: json['startHour'] as int,
      endHour: json['endHour'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'startHour': startHour, 'endHour': endHour};
  }

  bool isWithinRange(DateTime time) {
    final hour = time.hour;
    if (startHour < endHour) {
      return hour >= startHour && hour < endHour;
    } else {
      return hour >= startHour || hour < endHour;
    }
  }
}
