enum TripState { IDLE, TRIP_MORNING, TRIP_EVENING }

class Trip {
  final String id;
  final String driverId;
  final TripState state;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<Map<String, dynamic>> gpsPoints;

  Trip({
    required this.id,
    required this.driverId,
    required this.state,
    this.startTime,
    this.endTime,
    this.gpsPoints = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'state': state.name,
      'startTime': startTime?.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'gpsPoints': gpsPoints,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      driverId: map['driverId'] ?? '',
      state: TripState.values.firstWhere((e) => e.name == map['state']),
      startTime: map['startTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endTime']) : null,
      gpsPoints: List<Map<String, dynamic>>.from(map['gpsPoints'] ?? []),
    );
  }
}