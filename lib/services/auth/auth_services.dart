import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // New Google Sign-In instance (v7+)
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // Initialize (required in new API)
      await googleSignIn.initialize(
        serverClientId: null, // keep null for Firebase default
      );

      // Start sign-in
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // Get auth tokens
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }
}
