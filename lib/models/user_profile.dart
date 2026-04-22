import '../constants/profile_avatars.dart';

class UserProfile {
  final String uid;
  final String name;
  final String avatar;
  final int age;
  final int balance;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.avatar,
    required this.age,
    required this.balance,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      name: (data['name'] as String?)?.trim() ?? '',
      avatar: ProfileAvatars.sanitize((data['avatar'] as String?)?.trim()),
      age: (data['age'] as num?)?.toInt() ?? 0,
      balance: (data['balance'] as num?)?.toInt() ?? 0,
      email: (data['email'] as String?)?.trim() ?? '',
      phone: (data['phone'] as String?)?.trim() ?? '',
      createdAt:
          DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(data['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatar': avatar,
      'age': age,
      'balance': balance,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
