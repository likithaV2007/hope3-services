class ChildModel {
  final String id;
  final String name;
  final String grade;
  final String? photoUrl;
  final String busRouteId;
  final String pickupStopId;
  final String dropStopId;
  final String parentId;

  ChildModel({
    required this.id,
    required this.name,
    required this.grade,
    this.photoUrl,
    required this.busRouteId,
    required this.pickupStopId,
    required this.dropStopId,
    required this.parentId,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      grade: map['grade'] ?? '',
      photoUrl: map['photoUrl'],
      busRouteId: map['busRouteId'] ?? '',
      pickupStopId: map['pickupStopId'] ?? '',
      dropStopId: map['dropStopId'] ?? '',
      parentId: map['parentId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'photoUrl': photoUrl,
      'busRouteId': busRouteId,
      'pickupStopId': pickupStopId,
      'dropStopId': dropStopId,
      'parentId': parentId,
    };
  }
}