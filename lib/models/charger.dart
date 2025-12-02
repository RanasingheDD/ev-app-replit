enum ChargerStatus { available, occupied, outOfService, reserved, charging }

class Charger {
  final String id;
  final String stationId;
  final String connectorType;
  final double maxPowerKw;
  final ChargerStatus status;
  final String? ocppEndpointId;
  final String? qrCode;
  final String? name;
  final int? portNumber;

  Charger({
    required this.id,
    required this.stationId,
    required this.connectorType,
    required this.maxPowerKw,
    required this.status,
    this.ocppEndpointId,
    this.qrCode,
    this.name,
    this.portNumber,
  });

  factory Charger.fromJson(Map<String, dynamic> json) {
    return Charger(
      id: json['id'] as String? ?? '',
      stationId: json['stationId'] as String? ?? '',
      connectorType: json['connectorType'] as String? ?? '',
      maxPowerKw: (json['maxPower_kW'] as num?)?.toDouble() ?? 1.0,
      status: _parseStatus(json['status'] as String? ?? ''),
      ocppEndpointId: json['ocppEndpointId'] as String? ?? '',
      qrCode: json['qrCode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      portNumber: json['portNumber'] as int? ?? 1,
    );
  }

  static ChargerStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return ChargerStatus.available;
      case 'occupied':
        return ChargerStatus.occupied;
      case 'out-of-service':
      case 'outofservice':
        return ChargerStatus.outOfService;
      case 'reserved':
        return ChargerStatus.reserved;
      case 'charging':
        return ChargerStatus.charging;
      default:
        return ChargerStatus.available;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stationId': stationId,
      'connectorType': connectorType,
      'maxPower_kW': maxPowerKw,
      'status': statusString,
      'ocppEndpointId': ocppEndpointId,
      'qrCode': qrCode,
      'name': name,
      'portNumber': portNumber,
    };
  }

  String get statusString {
    switch (status) {
      case ChargerStatus.available:
        return 'available';
      case ChargerStatus.occupied:
        return 'occupied';
      case ChargerStatus.outOfService:
        return 'out-of-service';
      case ChargerStatus.reserved:
        return 'reserved';
      case ChargerStatus.charging:
        return 'charging';
    }
  }

  String get displayName => name ?? 'Port ${portNumber ?? id.substring(0, 4)}';

  String get powerDisplay => '${maxPowerKw.toInt()} kW';

  bool get isAvailable => status == ChargerStatus.available;
}
