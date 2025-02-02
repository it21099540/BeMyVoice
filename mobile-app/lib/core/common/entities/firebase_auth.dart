import 'package:bemyvoice/core/common/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

User mapFirebaseUserToCustomUser(firebase_auth.User firebaseUser) {
  return User(
    id: firebaseUser.uid,
    email: firebaseUser.email ?? '',
    displayName: firebaseUser.displayName ??
        'Anonymous', // Provide a default value if null
    profileImage: firebaseUser.photoURL, // Mapping profile image if available
    age: null, // Set null or use logic to assign if available elsewhere
    address: null, // Set null or add logic if needed
    gender: null, // Set null or add logic if needed
  );
}
