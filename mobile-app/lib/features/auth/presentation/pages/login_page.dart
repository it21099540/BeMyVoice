import 'package:bemyvoice/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:bemyvoice/core/common/entities/firebase_auth.dart';
import 'package:bemyvoice/core/common/widgets/bottom_navbar.dart';
import 'package:bemyvoice/core/constants/auth_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bemyvoice/core/utils/show_snackbar.dart';
import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bemyvoice/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bemyvoice/features/auth/presentation/pages/signup_page.dart';
import 'package:bemyvoice/features/auth/presentation/widgets/auth_field.dart';
import 'package:bemyvoice/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:bemyvoice/core/common/widgets/loader.dart';
import 'package:bemyvoice/features/auth/presentation/widgets/auth_desc.dart';
import 'package:bemyvoice/features/auth/presentation/widgets/auth_divider.dart';
import 'package:bemyvoice/features/auth/presentation/widgets/providers_button.dart';

class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginPage(),
      );
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Ensure previous Google sign-in is signed out
      await GoogleSignIn().signOut();

      // Proceed with Google sign-in flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Map firebase_auth.User to your custom User entity
      final customUser = mapFirebaseUserToCustomUser(userCredential.user!);

      // Pass the custom User to your Bloc event
      context
          .read<AuthBloc>()
          .add(AuthLoginWithGoogle(userCredential: customUser));

      // Update display name (optional)
      String name = googleUser.displayName ?? '';
      await userCredential.user!.updateDisplayName(name);

      // Optionally, reload the user to get updated info
      await userCredential.user!.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser == null) {
        throw Exception('User is null after sign-in');
      }

      final userData = {
        'uid': updatedUser.uid,
        'name': updatedUser.displayName ?? '',
        'email': updatedUser.email ?? '',
        'photoURL': updatedUser.photoURL ?? '',
        'age': "",
        'address': "",
        'gender': '',
      };

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.uid)
          .set(userData);

      ShowSnackBar(context, "Signed in successfully");
    } catch (e) {
      // More detailed error handling
      String errorMessage;
      if (e is FirebaseAuthException) {
        errorMessage = "Error: ${e.message}";
      } else {
        errorMessage = "Failed to sign in with Google: $e";
      }
      ShowSnackBar(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ShowSnackBar(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Loader();
                }
                return Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage('assets/images/deaf.png'),
                        height: 100,
                      ),
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
                      AuthField(hintText: 'Email', controller: emailController),
                      const SizedBox(height: 20),
                      AuthField(
                        hintText: 'Password',
                        controller: passwordController,
                        isObscureText: true,
                      ),
                      const SizedBox(height: 30),
                      AuthGradientButton(
                        buttonText: 'Sign In',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  AuthLogin(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  ),
                                );
                          }
                        },
                        icon: Icons.login,
                      ),
                      const SizedBox(height: 30),
                      const AuthDivider(),
                      const SizedBox(height: 30),
                      ProviderButton(
                        icon: FontAwesomeIcons.google,
                        text: 'Sign in with Google',
                        onTap: () => signInWithGoogle(context),
                      ),
                      const SizedBox(height: 10),
                      const AuthDescription(
                        text: AuthConstants.loginDesc,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, SignUpPage.route());
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Don\'t have an account? ',
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(
                                text: 'Sign Up',
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
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
