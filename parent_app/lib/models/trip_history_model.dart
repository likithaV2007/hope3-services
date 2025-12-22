class TripHistoryModel {
  final String id;
  final String childId;
  final String busId;
  final DateTime date;
  final String tripType; // 'morning' or 'evening'
  final DateTime? startTime;
  final DateTime? endTime;
  final bool wasOnTime;
  final String? notes;

  TripHistoryModel({
    required this.id,
    required this.childId,
    required this.busId,
    required this.date,
    required this.tripType,
    this.startTime,
    this.endTime,
    required this.wasOnTime,
    this.notes,
  });

  factory TripHistoryModel.fromMap(Map<String, dynamic> map) {
    return TripHistoryModel(
      id: map['id'] ?? '',
      childId: map['childId'] ?? '',
      busId: map['busId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      tripType: map['tripType'] ?? '',
      startTime: map['startTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['startTime'])
          : null,
      endTime: map['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      wasOnTime: map['wasOnTime'] ?? true,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'busId': busId,
      'date': date.millisecondsSinceEpoch,
      'tripType': tripType,
      'startTime': startTime?.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'wasOnTime': wasOnTime,
      'notes': notes,
    };
  }
}