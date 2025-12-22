class Alert {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String priority;
  final bool isRead;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.priority,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'priority': priority,
      'isRead': isRead,
    };
  }

  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      priority: map['priority'] ?? 'normal',
      isRead: map['isRead'] ?? false,
    );
  }
}