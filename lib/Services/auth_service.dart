import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in using email and password
  Future<User?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  /// Sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  /// Sign in using Google Sign-In with force prompt
Future<User?> signInWithGoogle() async {
  // Ensure previous sessions are cleared
  await signOut();

  final googleUser = await GoogleSignIn(
    scopes: ['email'],
    // Forces the account chooser to show every time
    signInOption: SignInOption.standard,
  ).signIn();

  if (googleUser == null) return null; // User cancelled sign-in

  final googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final userCredential = await _auth.signInWithCredential(credential);
  return userCredential.user;
}

/// Proper Sign out from Firebase and Google
Future<void> signOut() async {
  try {
    await _auth.signOut();

    final googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.disconnect(); // Sever connection
      await googleSignIn.signOut();    // Clear session
    }
  } catch (e) {
    print("🔴 Sign out error: $e");
    rethrow;
  }
}


  /// Check current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
