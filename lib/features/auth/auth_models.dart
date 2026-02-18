import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final String? address;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.role = 'user',
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [uid, email, name, role, phone, address];
}

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    super.role = 'user',
    super.phone,
    super.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      role: json['role'] ?? 'user',
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'address': address,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? address,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
