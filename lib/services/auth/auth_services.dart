import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // 🔥 Web Client ID from Google Cloud (Web Application)
  static const String _webClientId =
      '921185889614-hm2ctm2r400ms7204orvgrd2o07mmnna.apps.googleusercontent.com';

  // ✅ NEW GoogleSignIn v7+ style (same as your Firebase example)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // ✅ Initialize Google Sign-In (NEW API STYLE)
      await _googleSignIn.initialize(
        serverClientId: _webClientId, // keep null for Firebase default
      );

      // ✅ Start sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        return null; // user cancelled
      }

      // ✅ Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Missing ID Token';
      }

      // ✅ Send token to Supabase (NOT Firebase)
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        // accessToken: accessToken,
      );

      return response;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;
}
