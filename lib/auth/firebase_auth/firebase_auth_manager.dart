import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';

import '/backend/backend.dart';
import 'anonymous_auth.dart';
import 'apple_auth.dart';
import 'email_auth.dart';
import 'firebase_user_provider.dart';
import 'google_auth.dart';
import 'jwt_token_auth.dart';
import 'github_auth.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/auth_error_dialog.dart';
import '/flutter_flow/flutter_flow_util.dart';

export '../base_auth_user_provider.dart';

class FirebasePhoneAuthManager extends ChangeNotifier {
  bool? _triggerOnCodeSent;
  FirebaseAuthException? phoneAuthError;
  // Set when using phone verification (after phone number is provided).
  String? phoneAuthVerificationCode;
  // Set when using phone sign in in web mode (ignored otherwise).
  ConfirmationResult? webPhoneAuthConfirmationResult;
  // Used for handling verification codes for phone sign in.
  void Function(BuildContext)? _onCodeSent;

  bool get triggerOnCodeSent => _triggerOnCodeSent ?? false;
  set triggerOnCodeSent(bool val) => _triggerOnCodeSent = val;

  void Function(BuildContext) get onCodeSent =>
      _onCodeSent == null ? (_) {} : _onCodeSent!;
  set onCodeSent(void Function(BuildContext) func) => _onCodeSent = func;

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}

class FirebaseAuthManager extends AuthManager
    with
        EmailSignInManager,
        GoogleSignInManager,
        AppleSignInManager,
        AnonymousSignInManager,
        JwtSignInManager,
        GithubSignInManager,
        PhoneSignInManager {
  // Set when using phone verification (after phone number is provided).
  String? _phoneAuthVerificationCode;
  // Set when using phone sign in in web mode (ignored otherwise).
  ConfirmationResult? _webPhoneAuthConfirmationResult;
  FirebasePhoneAuthManager phoneAuthManager = FirebasePhoneAuthManager();

  @override
  Future signOut() {
    return FirebaseAuth.instance.signOut();
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      if (!loggedIn) {
        print('Error: delete user attempted with no logged in user!');
        return;
      }
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showDialog(
          context: context,
          builder: (dialogContext) => AuthErrorDialog(
            title: 'Recent Login Required',
            message:
                'Too long since most recent sign in. Sign in again before deleting your account.',
          ),
        );
      }
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update email attempted with no logged in user!');
        return;
      }
      await currentUser?.updateEmail(email);
      await updateUserDocument(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showDialog(
          context: context,
          builder: (dialogContext) => AuthErrorDialog(
            title: 'Recent Login Required',
            message:
                'Too long since most recent sign in. Sign in again before updating your email.',
          ),
        );
      }
    }
  }

  @override
  Future updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update password attempted with no logged in user!');
        return;
      }
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showDialog(
          context: context,
          builder: (dialogContext) => AuthErrorDialog(
            title: 'Recent Login Required',
            message:
                'Too long since most recent sign in. Sign in again before updating your password.',
          ),
        );
      }
    }
  }

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (dialogContext) => AuthErrorDialog(
          title: 'Email Sent',
          message: 'Password reset email has been sent to your email address.',
          icon: Icons.email_outlined,
          iconColor: FlutterFlowTheme.of(context).secondary,
          iconBackgroundColor: Color(0xFFE6F5FF),
          titleColor: FlutterFlowTheme.of(context).primary,
        ),
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (dialogContext) => AuthErrorDialog(
          title: 'Error',
          message: 'Failed to send password reset email: ${e.message}',
        ),
      );
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailSignInFunc(email, password),
        'EMAIL',
      );

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailCreateAccountFunc(email, password),
        'EMAIL',
      );

  @override
  Future<BaseAuthUser?> signInAnonymously(
    BuildContext context,
  ) =>
      _signInOrCreateAccount(context, anonymousSignInFunc, 'ANONYMOUS');

  @override
  Future<BaseAuthUser?> signInWithApple(BuildContext context) =>
      _signInOrCreateAccount(context, appleSignIn, 'APPLE');

  @override
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) async {
    try {
      final user =
          await _signInOrCreateAccount(context, googleSignInFunc, 'GOOGLE');
      if (user != null) {
        // Ensure user data is properly saved
        if (user is LammaFirebaseUser) {
          await maybeCreateUser(user.user!);

          // Check if user needs to complete profile
          if (user.displayName == null || user.displayName!.isEmpty) {
            // Navigate to profile creation page
            context.pushNamed('auth_2_create_profile');
          } else {
            // Navigate to home page
            context.pushNamed('home');
          }
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      String title = 'Error';
      String message = 'An error occurred during Google sign in.';
      IconData icon = Icons.error_outline_rounded;
      Color? iconColor;
      Color? iconBackgroundColor;

      switch (e.code) {
        case 'account-exists-with-different-credential':
          title = 'Account Exists';
          message =
              'An account already exists with the same email address but different sign-in credentials. Please sign in using the original method.';
          break;
        case 'invalid-credential':
          title = 'Invalid Credentials';
          message =
              'The Google sign in credentials are invalid. Please try again.';
          break;
        case 'operation-not-allowed':
          title = 'Operation Not Allowed';
          message = 'Google sign in is not enabled. Please contact support.';
          break;
        case 'user-disabled':
          title = 'Account Disabled';
          message = 'This account has been disabled. Please contact support.';
          break;
        case 'user-not-found':
          title = 'Account Not Found';
          message =
              'No account found with these credentials. Please try again.';
          break;
        case 'wrong-password':
          title = 'Invalid Credentials';
          message = 'The sign in credentials are invalid. Please try again.';
          break;
        case 'invalid-verification-code':
          title = 'Invalid Code';
          message = 'The verification code is invalid. Please try again.';
          break;
        case 'invalid-verification-id':
          title = 'Invalid Verification';
          message = 'The verification ID is invalid. Please try again.';
          break;
        case 'sign-in-cancelled':
          title = 'Sign In Cancelled';
          message = 'The sign in process was cancelled. Please try again.';
          break;
        case 'no-id-token':
          title = 'Authentication Error';
          message =
              'Failed to get authentication token from Google. Please try again.';
          break;
        case 'google-sign-in-failed':
          title = 'Google Sign In Failed';
          message = 'Failed to sign in with Google. Please try again.';
          break;
      }

      showDialog(
        context: context,
        builder: (dialogContext) => AuthErrorDialog(
          title: title,
          message: message,
          icon: icon,
          iconColor: iconColor,
          iconBackgroundColor: iconBackgroundColor,
        ),
      );
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> signInWithGithub(BuildContext context) =>
      _signInOrCreateAccount(context, githubSignInFunc, 'GITHUB');

  @override
  Future<BaseAuthUser?> signInWithJwtToken(
    BuildContext context,
    String jwtToken,
  ) =>
      _signInOrCreateAccount(context, () => jwtTokenSignIn(jwtToken), 'JWT');

  void handlePhoneAuthStateChanges(BuildContext context) {
    phoneAuthManager.addListener(() {
      if (!context.mounted) {
        return;
      }

      if (phoneAuthManager.triggerOnCodeSent) {
        phoneAuthManager.onCodeSent(context);
        phoneAuthManager
            .update(() => phoneAuthManager.triggerOnCodeSent = false);
      } else if (phoneAuthManager.phoneAuthError != null) {
        final e = phoneAuthManager.phoneAuthError!;
        showDialog(
          context: context,
          builder: (dialogContext) => AuthErrorDialog(
            title: 'Phone Authentication Error',
            message:
                e.message ?? 'An error occurred during phone authentication.',
          ),
        );
        phoneAuthManager.update(() => phoneAuthManager.phoneAuthError = null);
      }
    });
  }

  @override
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  }) async {
    phoneAuthManager.update(() => phoneAuthManager.onCodeSent = onCodeSent);
    if (kIsWeb) {
      phoneAuthManager.webPhoneAuthConfirmationResult =
          await FirebaseAuth.instance.signInWithPhoneNumber(phoneNumber);
      phoneAuthManager.update(() => phoneAuthManager.triggerOnCodeSent = true);
      return;
    }
    final completer = Completer<bool>();
    // If you'd like auto-verification, without the user having to enter the SMS
    // code manually. Follow these instructions:
    // * For Android: https://firebase.google.com/docs/auth/android/phone-auth?authuser=0#enable-app-verification (SafetyNet set up)
    // * For iOS: https://firebase.google.com/docs/auth/ios/phone-auth?authuser=0#start-receiving-silent-notifications
    // * Finally modify verificationCompleted below as instructed.
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout:
          Duration(seconds: 0), // Skips Android's default auto-verification
      verificationCompleted: (phoneAuthCredential) async {
        await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
        phoneAuthManager.update(() {
          phoneAuthManager.triggerOnCodeSent = false;
          phoneAuthManager.phoneAuthError = null;
        });
        // If you've implemented auto-verification, navigate to home page or
        // onboarding page here manually. Uncomment the lines below and replace
        // DestinationPage() with the desired widget.
        // await Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => DestinationPage()),
        // );
      },
      verificationFailed: (e) {
        phoneAuthManager.update(() {
          phoneAuthManager.triggerOnCodeSent = false;
          phoneAuthManager.phoneAuthError = e;
        });
        completer.complete(false);
      },
      codeSent: (verificationId, _) {
        phoneAuthManager.update(() {
          phoneAuthManager.phoneAuthVerificationCode = verificationId;
          phoneAuthManager.triggerOnCodeSent = true;
          phoneAuthManager.phoneAuthError = null;
        });
        completer.complete(true);
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  @override
  Future verifySmsCode({
    required BuildContext context,
    required String smsCode,
  }) {
    if (kIsWeb) {
      return _signInOrCreateAccount(
        context,
        () => phoneAuthManager.webPhoneAuthConfirmationResult!.confirm(smsCode),
        'PHONE',
      );
    } else {
      final authCredential = PhoneAuthProvider.credential(
        verificationId: phoneAuthManager.phoneAuthVerificationCode!,
        smsCode: smsCode,
      );
      return _signInOrCreateAccount(
        context,
        () => FirebaseAuth.instance.signInWithCredential(authCredential),
        'PHONE',
      );
    }
  }

  /// Tries to sign in or create an account using Firebase Auth.
  /// Returns the User object if sign in was successful.
  Future<BaseAuthUser?> _signInOrCreateAccount(
    BuildContext context,
    Future<UserCredential?> Function() signInFunc,
    String authProvider,
  ) async {
    try {
      final userCredential = await signInFunc();
      if (userCredential?.user != null) {
        await maybeCreateUser(userCredential!.user!);
      }
      return userCredential == null
          ? null
          : LammaFirebaseUser.fromUserCredential(userCredential);
    } on FirebaseAuthException catch (e) {
      String title = 'Error';
      String message = 'An error occurred during authentication.';
      IconData icon = Icons.error_outline_rounded;
      Color? iconColor;
      Color? iconBackgroundColor;

      switch (e.code) {
        case 'user-not-found':
        case 'invalid-email':
          title = 'Email Not Found';
          message =
              'The email address you entered is not registered. Please check and try again.';
          break;
        case 'wrong-password':
          title = 'Incorrect Password';
          message = 'The password you entered is incorrect. Please try again.';
          break;
        case 'user-disabled':
          title = 'Account Disabled';
          message =
              'This account has been disabled. Please contact support for help.';
          break;
        case 'too-many-requests':
          title = 'Too Many Attempts';
          message =
              'Access to this account has been temporarily disabled due to many failed login attempts. Please try again later or reset your password.';
          break;
        case 'email-already-in-use':
          title = 'Email Already in Use';
          message =
              'This email address is already registered. Please try signing in or use a different email.';
          break;
        case 'weak-password':
          title = 'Weak Password';
          message =
              'The password you entered is too weak. Please use a stronger password.';
          break;
        case 'INVALID_LOGIN_CREDENTIALS':
          title = 'Invalid Credentials';
          message =
              'The email or password you entered is incorrect. Please try again.';
          break;
        default:
          title = 'Authentication Error';
          message = e.message ?? 'An unknown error occurred. Please try again.';
      }

      showDialog(
        context: context,
        builder: (dialogContext) => AuthErrorDialog(
          title: title,
          message: message,
          icon: icon,
          iconColor: iconColor,
          iconBackgroundColor: iconBackgroundColor,
        ),
      );
      return null;
    }
  }

  Future<void> maybeCreateUser(User user) async {
    try {
      final userDoc = await UsersRecord.collection.doc(user.uid).get();
      if (!userDoc.exists) {
        // Create new user document
        await UsersRecord.collection.doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoURL,
          'phoneNumber': user.phoneNumber,
          'createdTime': FieldValue.serverTimestamp(),
          'lastSignInTime': FieldValue.serverTimestamp(),
        });
      } else {
        // Update last sign in time
        await UsersRecord.collection.doc(user.uid).update({
          'lastSignInTime': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error creating/updating user document: $e');
    }
  }
}
