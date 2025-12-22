class StopLocation {
  final String name;
  final double latitude;
  final double longitude;

  StopLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory StopLocation.fromMap(Map<String, dynamic> map) {
    return StopLocation(
      name: map['name'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }
}

class RouteModel {
  final String routeId;
  final String routeName;
  final List<StopLocation> stops;
  final String driverId;
  final DateTime date;

  RouteModel({
    required this.routeId,
    required this.routeName,
    required this.stops,
    required this.driverId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'routeName': routeName,
      'stops': stops.map((stop) => stop.toMap()).toList(),
      'driverId': driverId,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory RouteModel.fromMap(Map<String, dynamic> map) {
    return RouteModel(
      routeId: map['routeId'] ?? '',
      routeName: map['routeName'] ?? '',
      stops: (map['stops'] as List<dynamic>? ?? [])
          .where((stop) => stop is Map<String, dynamic>)
          .map((stop) => StopLocation.fromMap(stop as Map<String, dynamic>))
          .toList(),
      driverId: map['driverId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
    );
  }
}