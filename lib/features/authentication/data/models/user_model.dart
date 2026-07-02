import 'package:field_track/features/authentication/domain/entities/user_entity.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: (json['full_name'] ?? json['name']) as String,
        role: json['role'] as String?,
      );

  final String id;
  final String email;
  final String fullName;
  final String? role;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        if (role != null) 'role': role,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        fullName: fullName,
        role: role,
      );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        email: entity.email,
        fullName: entity.fullName,
        role: entity.role,
      );
}
