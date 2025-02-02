import 'package:bemyvoice/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:bemyvoice/core/theme/theme.dart';
import 'package:bemyvoice/core/common/widgets/bottom_navbar.dart';
import 'package:bemyvoice/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bemyvoice/features/auth/presentation/pages/login_page.dart';
import 'package:bemyvoice/features/video_upload/data/video_repository_impl.dart';
import 'package:bemyvoice/features/video_upload/presentation/bloc/video_upload_cubit.dart';
import 'package:bemyvoice/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  try {
    await dotenv.load(fileName: 'lib/config/.env');

    print('Dotenv loaded successfully: ${dotenv.env}');
  } catch (e) {
    print('Failed to load .env file: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AppUserCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => VideoUploadCubit(VideoRepositoryImpl()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeMode,
      title: 'Be My Voice',
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) {
          return state is AppUserLoggedIn;
        },
        builder: (context, isLoggedIn) {
          if (isLoggedIn) {
            final user =
                (context.read<AppUserCubit>().state as AppUserLoggedIn).user;
            return BottomNavBar(user: user);
          }
          return const LoginPage();
        },
      ),
    );
  }
}
