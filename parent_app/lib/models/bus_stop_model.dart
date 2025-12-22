class BusStopModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final int sequence;
  final String routeId;

  BusStopModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.sequence,
    required this.routeId,
  });

  factory BusStopModel.fromMap(Map<String, dynamic> map) {
    return BusStopModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      sequence: map['sequence'] ?? 0,
      routeId: map['routeId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'sequence': sequence,
      'routeId': routeId,
    };
  }
}