import 'package:bemyvoice/core/error/exceptions.dart';
import 'package:bemyvoice/core/error/failures.dart';
import 'package:bemyvoice/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bemyvoice/core/common/entities/user.dart';
import 'package:bemyvoice/features/auth/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fpdart/src/either.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  const AuthRepositoryImpl(this.authRemoteDataSource);

  @override
  Future<Either<Failures, User>> currentUser() async {
    try {
      final user = await authRemoteDataSource.getCurrentUser();
      if (user == null) {
        return left(Failures("User not logged in!"));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, User>> loginWithEmailPassword(
      {required String email, required String password}) async {
    return _getUser(
      () async => await authRemoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failures, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return _getUser(
      () async => await authRemoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );
  }

  Future<Either<Failures, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      final user = await fn();

      return right(user);
    } on fb.FirebaseAuthException catch (e) {
      return left(Failures(e.message ?? "An error occurred"));
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }
}
