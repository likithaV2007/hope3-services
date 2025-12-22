class UserModel {
  final String uid;
  final String email;
  final String role;
  final String name;
  final String phone;
  final int id;
  final String schoolId;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    required this.phone,
    required this.id,
    required this.schoolId,
    required this.isOnline,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      schoolId: map['school_id']?.toString() ?? '',
      isOnline: map['is_online'] == true,
    );
  }
}