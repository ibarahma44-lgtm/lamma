import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _googleSignIn = GoogleSignIn(
  scopes: ['profile', 'email'],
);

Future<UserCredential?> googleSignInFunc() async {
  try {
    if (kIsWeb) {
      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    }

    // Sign out first to ensure a clean state
    await signOutWithGoogle().catchError((_) => null);

    // Attempt to sign in with Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google sign in was cancelled by the user',
      );
    }

    // Get the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    if (googleAuth.idToken == null) {
      throw FirebaseAuthException(
        code: 'no-id-token',
        message: 'No ID token received from Google',
      );
    }

    // Create a credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    // Sign in with Firebase
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } on FirebaseAuthException catch (e) {
    print('Firebase Auth Error: ${e.code} - ${e.message}');
    rethrow;
  } catch (e) {
    print('Google Sign In Error: $e');
    throw FirebaseAuthException(
      code: 'google-sign-in-failed',
      message: 'Failed to sign in with Google: $e',
    );
  }
}

Future<void> signOutWithGoogle() async {
  try {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    print('Error signing out: $e');
    rethrow;
  }
}
