class EV {
  final String id;
  final String userId;
  final String make;
  final String model;
  final int? year;
  final double batteryKwh;
  final double maxChargeKw;
  final List<String> connectorTypes;
  final String? vin;
  final String? licensePlate;
  final String? nickname;
  final DateTime createdAt;

  EV({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    this.year,
    required this.batteryKwh,
    required this.maxChargeKw,
    required this.connectorTypes,
    this.vin,
    this.licensePlate,
    this.nickname,
    required this.createdAt,
  });

  factory EV.fromJson(Map<String, dynamic> json) {
    return EV(
      id: json['id'] as String? ?? "0",
      userId: json['userId'] as String? ?? "0",
      make: json['make'] as String? ?? "0",
      model: json['model'] as String? ?? "0",
      year: json['year'] as int?,
      batteryKwh: (json['batteryKwh'] as num?)?.toDouble() ?? 1.0,
      maxChargeKw: (json['maxChargeKw'] as num?)?.toDouble() ?? 1.0,
      connectorTypes: List<String>.from(json['connectorTypes'] as List),
      vin: json['vin'] as String? ?? "0",
      licensePlate: json['licensePlate'] as String? ?? "0",
      nickname: json['nickname'] as String? ?? "0",
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
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
    };
  }

  String get displayName => nickname ?? '$make $model';

  String get connectorTypesDisplay => connectorTypes.join(', ');

  EV copyWith({
    String? id,
    String? userId,
    String? make,
    String? model,
    int? year,
    double? batteryKwh,
    double? maxChargeKw,
    List<String>? connectorTypes,
    String? vin,
    String? licensePlate,
    String? nickname,
    DateTime? createdAt,
  }) {
    return EV(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      batteryKwh: batteryKwh ?? this.batteryKwh,
      maxChargeKw: maxChargeKw ?? this.maxChargeKw,
      connectorTypes: connectorTypes ?? this.connectorTypes,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class EVMake {
  final String name;
  final List<String> models;

  EVMake({required this.name, required this.models});
}

final List<EVMake> popularEVMakes = [
  EVMake(
    name: 'Tesla',
    models: ['Model 3', 'Model Y', 'Model S', 'Model X', 'Cybertruck'],
  ),
  EVMake(name: 'Nissan', models: ['Leaf', 'Ariya']),
  EVMake(name: 'BMW', models: ['i3', 'i4', 'iX', 'iX3']),
  EVMake(name: 'Mercedes-Benz', models: ['EQS', 'EQE', 'EQC', 'EQA', 'EQB']),
  EVMake(name: 'Audi', models: ['e-tron', 'e-tron GT', 'Q4 e-tron']),
  EVMake(name: 'Hyundai', models: ['Ioniq 5', 'Ioniq 6', 'Kona Electric']),
  EVMake(name: 'Kia', models: ['EV6', 'EV9', 'Niro EV']),
  EVMake(name: 'Volkswagen', models: ['ID.3', 'ID.4', 'ID.5', 'ID.Buzz']),
  EVMake(name: 'Porsche', models: ['Taycan', 'Taycan Cross Turismo']),
  EVMake(name: 'Ford', models: ['Mustang Mach-E', 'F-150 Lightning']),
  EVMake(name: 'Chevrolet', models: ['Bolt EV', 'Bolt EUV', 'Equinox EV']),
  EVMake(name: 'Rivian', models: ['R1T', 'R1S']),
  EVMake(name: 'BYD', models: ['Atto 3', 'Han', 'Tang', 'Seal']),
  EVMake(name: 'MG', models: ['ZS EV', 'MG4', 'Marvel R']),
  EVMake(name: 'Polestar', models: ['Polestar 2', 'Polestar 3']),
  EVMake(name: 'Other', models: ['Other']),
];
