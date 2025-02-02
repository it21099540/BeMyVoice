import 'package:bemyvoice/core/common/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.gender,
    required super.address,
    required super.age,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['name'] ?? '',
      gender: map['gender'] ?? '',
      address: map['address'] ?? '',
      age: map['age'] is int
          ? map['age']
          : int.tryParse(map['age']?.toString() ?? '0') ??
              0, // Handle age as int
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? gender,
    String? age,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      age: age as int? ?? this.age,
    );
  }
}
