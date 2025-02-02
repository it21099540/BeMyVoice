import 'package:bemyvoice/core/error/exceptions.dart';
import 'package:bemyvoice/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl(this.firebaseAuth, this.firestore);

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with email and password
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw ServerException('User is null');
      }

      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw ServerException('User data not found in Firestore');
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      return UserModel.fromJson({
        'id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'age': (userData['age'] is int)
            ? userData['age']
            : int.tryParse(userData['age']?.toString() ?? '0') ?? 0,
        'address': userData['address'] ?? '',
        'gender': userData['gender'] ?? '',
      });
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Firebase Auth Exception');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      throw ServerException("Passwords do not match.");
    }

    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's profile with the name
      await userCredential.user!.updateDisplayName(name);

      // Optionally, you can reload the user to get updated info
      await userCredential.user!.reload();
      final updatedUser = firebaseAuth.currentUser;

      if (updatedUser == null) {
        throw ServerException('User is null');
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
      await firestore.collection('users').doc(updatedUser.uid).set(userData);

      return UserModel.fromJson(userData);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Firebase Auth Exception');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        return null;
      }

      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw ServerException('User data not found in Firestore');
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      return UserModel.fromJson({
        'id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'age': userData['age'] ?? 0,
        'address': userData['address'] ?? '',
        'gender': userData['gender'] ?? '',
      });
    } catch (e) {
      // Throw a custom exception if fetching user data fails
      throw ServerException('Failed to fetch current user: ${e.toString()}');
    }
  }
}
