class UserModel {
  final String uid;
  final String email;
  final String role;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['documentId'] ?? map['id']?.toString() ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      isActive: map['is_online'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'isActive': isActive,
    };
  }
}