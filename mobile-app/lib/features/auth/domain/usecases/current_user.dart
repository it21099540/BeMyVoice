import 'package:bemyvoice/core/error/failures.dart';
import 'package:bemyvoice/core/usecase/usecase.dart';
import 'package:bemyvoice/core/common/entities/user.dart';
import 'package:bemyvoice/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CurrentUser implements UseCase<User, NoParams> {
  final AuthRepository authRepository;
  CurrentUser(this.authRepository);
  @override
  Future<Either<Failures, User>> call(NoParams params) async {
    return await authRepository.currentUser();
  }
}
