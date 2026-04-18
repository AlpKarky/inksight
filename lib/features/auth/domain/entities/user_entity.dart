import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// Immutable snapshot of a signed-in user.
@freezed
abstract class UserEntity with _$UserEntity {
  /// Creates a [UserEntity].
  const factory UserEntity({
    required String id,
    required String email,
    required DateTime createdAt,
  }) = _UserEntity;
}
