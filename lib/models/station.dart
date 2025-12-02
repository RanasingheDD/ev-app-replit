import 'charger.dart';
import 'tariff.dart';

class Station {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String address;
  final String? operatorId;
  final String? operatorName;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final List<String> supportsConnectors;
  final List<TariffRule> tariffRules;
  final List<Charger> chargers;
  final String? description;
  final String? phoneNumber;
  final Map<String, String>? operatingHours;
  final List<String> amenities;
  final bool isOpen;
  final double? distance;

  Station({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    this.operatorId,
    this.operatorName,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.supportsConnectors,
    required this.tariffRules,
    required this.chargers,
    this.description,
    this.phoneNumber,
    this.operatingHours,
    required this.amenities,
    required this.isOpen,
    this.distance,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 1.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 1.0,
      address: json['address'] as String? ?? '',
      operatorId: json['operatorId'] as String? ?? '',
      operatorName: json['operatorName'] as String? ?? '',
      images: List<String>.from(json['images'] as List? ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      supportsConnectors: List<String>.from(
        json['supportsConnectors'] as List? ?? [],
      ),
      tariffRules:
          (json['tariffRules'] as List?)
              ?.map((e) => TariffRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      chargers:
          (json['chargers'] as List?)
              ?.map((e) => Charger.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      description: json['description'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      operatingHours: json['operatingHours'] != null
          ? Map<String, String>.from(json['operatingHours'] as Map)
          : null,
      amenities: List<String>.from(json['amenities'] as List? ?? []),
      isOpen: json['isOpen'] as bool? ?? true,
      distance: (json['distance'] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'address': address,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'supportsConnectors': supportsConnectors,
      'tariffRules': tariffRules.map((e) => e.toJson()).toList(),
      'chargers': chargers.map((e) => e.toJson()).toList(),
      'description': description,
      'phoneNumber': phoneNumber,
      'operatingHours': operatingHours,
      'amenities': amenities,
      'isOpen': isOpen,
      'distance': distance,
    };
  }

  int get availableChargerCount =>
      chargers.where((c) => c.status == ChargerStatus.available).length;

  int get totalChargerCount => chargers.length;

  double get maxPower {
    if (chargers.isEmpty) return 0;
    return chargers.map((c) => c.maxPowerKw).reduce((a, b) => a > b ? a : b);
  }

  String get priceDisplay {
    if (tariffRules.isEmpty) return 'Contact for pricing';
    final firstRule = tariffRules.first;
    return firstRule.displayPrice;
  }

  String get distanceDisplay {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).round()} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }
}

class StationFilter {
  final List<String>? connectorTypes;
  final double? minPower;
  final double? maxPrice;
  final double? maxDistance;
  final bool? availableOnly;
  final String? operatorId;
  final String? sortBy;

  StationFilter({
    this.connectorTypes,
    this.minPower,
    this.maxPrice,
    this.maxDistance,
    this.availableOnly,
    this.operatorId,
    this.sortBy,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (connectorTypes != null && connectorTypes!.isNotEmpty) {
      params['connector'] = connectorTypes!.join(',');
    }
    if (minPower != null) {
      params['minPower'] = minPower.toString();
    }
    if (maxPrice != null) {
      params['maxPrice'] = maxPrice.toString();
    }
    if (maxDistance != null) {
      params['radius'] = maxDistance.toString();
    }
    if (availableOnly == true) {
      params['available'] = 'true';
    }
    if (operatorId != null) {
      params['operator'] = operatorId!;
    }
    if (sortBy != null) {
      params['sortBy'] = sortBy!;
    }
    return params;
  }

  StationFilter copyWith({
    List<String>? connectorTypes,
    double? minPower,
    double? maxPrice,
    double? maxDistance,
    bool? availableOnly,
    String? operatorId,
    String? sortBy,
  }) {
    return StationFilter(
      connectorTypes: connectorTypes ?? this.connectorTypes,
      minPower: minPower ?? this.minPower,
      maxPrice: maxPrice ?? this.maxPrice,
      maxDistance: maxDistance ?? this.maxDistance,
      availableOnly: availableOnly ?? this.availableOnly,
      operatorId: operatorId ?? this.operatorId,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
