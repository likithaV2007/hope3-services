class RouteModel {
  final String id;
  final String name;
  final String schoolId;
  final List<String> stops;
  final Map<String, String> activeHours; // morning/evening times

  RouteModel({
    required this.id,
    required this.name,
    required this.schoolId,
    required this.stops,
    required this.activeHours,
  });

  factory RouteModel.fromMap(Map<String, dynamic> map) {
    return RouteModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      schoolId: map['schoolId'] ?? '',
      stops: List<String>.from(map['stops'] ?? []),
      activeHours: Map<String, String>.from(map['activeHours'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'schoolId': schoolId,
      'stops': stops,
      'activeHours': activeHours,
    };
  }
}