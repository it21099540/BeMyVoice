import 'package:bemyvoice/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:bemyvoice/core/common/widgets/bottom_navbar.dart';
import 'package:bemyvoice/core/common/widgets/loader.dart';
import 'package:bemyvoice/core/constants/auth_constants.dart';
import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:bemyvoice/core/utils/show_snackbar.dart';
import 'package:bemyvoice/features/auth/presentation/pages/login_page.dart';
import 'package:bemyvoice/features/auth/presentation/widgets/auth_desc.dart';
import 'package:bemyvoice/features/auth/presentation/widgets/auth_field.dart';
import 'package:bemyvoice/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bemyvoice/features/auth/presentation/bloc/auth_bloc.dart';

class SignUpPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      );
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: formKey,
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    final user = state
                        .user; // Assuming AuthSuccess provides the user object

                    // Load the signed-up user into AppUserCubit
                    context.read<AppUserCubit>().updateUser(user);

                    // Navigate to the main app (e.g., BottomNavBar or home screen)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavBar(user: user),
                      ),
                    );

                    print('User signed up successfully with ID: ${user.id}');
                  } else if (state is AuthFailure) {
                    ShowSnackBar(context, state.message);
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Loader();
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                          image: AssetImage('assets/images/deaf.png'),
                          height: 100),
                      const SizedBox(height: 10),
                      const Text(
                        'Welcome to',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Be My Voice',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.primaryColor),
                      ),
                      const SizedBox(height: 30),
                      AuthField(hintText: 'Name', controller: nameController),
                      const SizedBox(height: 20),
                      AuthField(hintText: 'Email', controller: emailController),
                      const SizedBox(height: 20),
                      AuthField(
                        hintText: 'Password',
                        controller: passwordController,
                        isObscureText: true,
                      ),
                      const SizedBox(height: 20),
                      AuthField(
                        hintText: 'Confirm Password',
                        controller: confirmPasswordController,
                        isObscureText: true,
                      ),
                      const SizedBox(height: 30),
                      AuthGradientButton(
                        buttonText: 'Create an account',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  AuthSignUp(
                                    name: nameController.text,
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                    confirmPassword:
                                        confirmPasswordController.text.trim(),
                                  ),
                                );
                          }
                        },
                        icon: Icons.login,
                      ),
                      const SizedBox(height: 10),
                      const AuthDescription(
                        text: AuthConstants.signUpDesc,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            LoginPage.route(),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppPalette.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
