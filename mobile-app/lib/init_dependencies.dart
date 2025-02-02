import 'package:bemyvoice/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:bemyvoice/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bemyvoice/features/auth/data/repository/auth_repository_impl.dart';
import 'package:bemyvoice/features/auth/domain/repository/auth_repository.dart';
import 'package:bemyvoice/features/auth/domain/usecases/current_user.dart';
import 'package:bemyvoice/features/auth/domain/usecases/user_login.dart';
import 'package:bemyvoice/features/auth/domain/usecases/user_sign_up.dart';
import 'package:bemyvoice/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bemyvoice/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  final firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  serviceLocator.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  serviceLocator.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);

  serviceLocator.registerLazySingleton(() => firebaseApp);

  //core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
}

void _initAuth() {
  //Datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    //Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
      ),
    )
    //UseCases
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )
    //Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}
