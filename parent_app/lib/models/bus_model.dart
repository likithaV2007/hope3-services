class BusModel {
  final String id;
  final String number;
  final String driverName;
  final String driverPhone;
  final String routeId;
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime lastUpdate;
  final bool isActive;

  BusModel({
    required this.id,
    required this.number,
    required this.driverName,
    required this.driverPhone,
    required this.routeId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.lastUpdate,
    required this.isActive,
  });

  factory BusModel.fromMap(Map<String, dynamic> map) {
    return BusModel(
      id: map['id'] ?? '',
      number: map['number'] ?? '',
      driverName: map['driverName'] ?? '',
      driverPhone: map['driverPhone'] ?? '',
      routeId: map['routeId'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      speed: (map['speed'] ?? 0.0).toDouble(),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(map['lastUpdate'] ?? 0),
      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'routeId': routeId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'lastUpdate': lastUpdate.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }
}