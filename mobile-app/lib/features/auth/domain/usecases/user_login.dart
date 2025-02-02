import 'package:bemyvoice/core/error/failures.dart';
import 'package:bemyvoice/core/usecase/usecase.dart';
import 'package:bemyvoice/core/common/entities/user.dart';
import 'package:bemyvoice/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLogin implements UseCase<User, UserLoginParams> {
  final AuthRepository authRepository;
  const UserLogin(this.authRepository);
  @override
  Future<Either<Failures, User>> call(UserLoginParams params) async {
    return authRepository.loginWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class UserLoginParams {
  final String email;
  final String password;

  UserLoginParams({required this.email, required this.password});
}
