import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required DateTime createdAt,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromSupabaseUser(supabase.User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  UserEntity toDomain() {
    return UserEntity(id: id, email: email, createdAt: createdAt);
  }
}
