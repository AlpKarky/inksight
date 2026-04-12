import 'package:inksight/core/errors/failures.dart';
import 'package:inksight/core/errors/result.dart';
import 'package:inksight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inksight/features/auth/domain/entities/user_entity.dart';
import 'package:inksight/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final AuthRemoteDataSource _dataSource;

  @override
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _dataSource.signIn(
        email: email,
        password: password,
      );
      return Success(userModel.toDomain());
    } on AppFailure catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _dataSource.signUp(
        email: email,
        password: password,
      );
      return Success(userModel.toDomain());
    } on AppFailure catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Success(null);
    } on AppFailure catch (e) {
      return Failure(e);
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _dataSource.authStateChanges
        .map((userModel) => userModel?.toDomain());
  }

  @override
  UserEntity? get currentUser => _dataSource.currentUser?.toDomain();
}
