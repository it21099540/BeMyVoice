import 'package:bemyvoice/core/error/failures.dart';
import 'package:bemyvoice/core/usecase/usecase.dart';
import 'package:bemyvoice/core/common/entities/user.dart';
import 'package:bemyvoice/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignUp implements UseCase<User, UserSignUpParams> {
  final AuthRepository authRepository;
  const UserSignUp(this.authRepository);

  @override
  Future<Either<Failures, User>> call(UserSignUpParams params) async {
    return await authRepository.signUpWithEmailPassword(
      name: params.name,
      email: params.email,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );
  }
}

class UserSignUpParams {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  UserSignUpParams({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}
