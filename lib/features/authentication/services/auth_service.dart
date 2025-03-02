import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart' show BuildContext;
import 'auth_service_apple.dart';

class AuthService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('🔍 Starting Google Sign-In Process');

      // Initialize Google Sign-In with proper scopes
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Attempt to sign in silently first (if user previously signed in)
      GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();

      // If silent sign-in fails, try interactive sign-in
      if (googleUser == null) {
        debugPrint('🔍 Silent sign-in failed, trying interactive sign-in');
        googleUser = await googleSignIn.signIn();
      }

      // Check if user cancelled sign-in
      if (googleUser == null) {
        debugPrint('❌ User cancelled Google Sign-In');
        return null;
      }

      debugPrint('✅ Google Sign-In successful: ${googleUser.email}');

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Store user data
      if (userCredential.user != null) {
        await _storeUserData(userCredential.user!);
      }

      return userCredential.user;
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_failed') {
        debugPrint('❌ Google Sign-In Failed with error code: ${e.code}');
        debugPrint('Error details: ${e.message}');
      } else {
        debugPrint('❌ Platform Exception: ${e.code}');
        debugPrint('Message: ${e.message}');
      }
      return null;
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      return null;
    }
  }

  /// Store user data in Firestore
  Future<void> _storeUserData(User user) async {
    try {
      debugPrint('💾 Storing user data in Firestore');

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ User data stored successfully');
    } catch (e) {
      debugPrint('❌ Failed to store user data: $e');
      // Don't rethrow as this should not break the auth flow
    }
  }

  /// Email and Password Sign Up
  Future<User?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      debugPrint('🔑 Starting Email/Password Sign Up: $email');

      if (kIsWeb) {
        debugPrint('🌐 Running on web platform for email sign-up');

        // For web platform, ensure proper persistence handling
        await _auth.setPersistence(Persistence.LOCAL);
        debugPrint('🌐 Web auth persistence set to LOCAL for sign-up');
      }

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      debugPrint('✅ Account created successfully for: $email');

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        debugPrint('👤 Setting display name: $displayName');
        await userCredential.user?.updateDisplayName(displayName);
      }

      // Additional verification for web platform
      if (kIsWeb && userCredential.user != null) {
        debugPrint('🌐 Web sign-up successful - verifying user details');
        debugPrint('🌐 User ID: ${userCredential.user!.uid}');

        // Wait a moment to ensure Firebase updates properly
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Save user to Firestore
      if (userCredential.user != null) {
        await _storeUserData(userCredential.user!);
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign Up Error: ${e.code}');
      debugPrint('Error message: ${e.message}');

      // Log more details for web-specific issues
      if (kIsWeb) {
        debugPrint('🌐 Web-specific sign-up error details:');
        debugPrint('Error code: ${e.code}');
        debugPrint('Error message: ${e.message}');
        debugPrint('Email: $email');

        // Check for specific web authentication issues
        if (e.code == 'network-request-failed') {
          debugPrint(
            '🌐 Web network request failed - check CORS and firewall settings',
          );
        } else if (e.code == 'web-context-canceled') {
          debugPrint('🌐 Web authentication context was canceled');
        }
      }

      rethrow; // Rethrow to handle specific errors in the provider
    } catch (e) {
      debugPrint('❌ Unexpected error during sign up: $e');
      if (kIsWeb) {
        debugPrint('🌐 Web-specific general error during sign-up');
      }
      rethrow;
    }
  }

  /// Email and Password Sign In
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔑 Starting Email/Password Sign In: $email');

      if (kIsWeb) {
        debugPrint('🌐 Running on web platform for email sign-in');

        // For web platform, ensure proper persistence handling
        await _auth.setPersistence(Persistence.LOCAL);
        debugPrint('🌐 Web auth persistence set to LOCAL');
      }

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      debugPrint('✅ Sign in successful for: $email');

      // Additional check for web authentication
      if (kIsWeb && userCredential.user != null) {
        debugPrint('🌐 Web authentication verified successfully');
        debugPrint(
          '🌐 User email verified: ${userCredential.user!.emailVerified}',
        );
        debugPrint('🌐 User ID: ${userCredential.user!.uid}');
      }

      // Update last login in Firestore
      if (userCredential.user != null) {
        await _storeUserData(userCredential.user!);
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign In Error: ${e.code}');
      debugPrint('Error message: ${e.message}');

      // Log more details for web-specific issues
      if (kIsWeb) {
        debugPrint('🌐 Web-specific sign-in error details:');
        debugPrint('Error code: ${e.code}');
        debugPrint('Error message: ${e.message}');
        debugPrint('Email: $email');

        // Check for specific web authentication issues
        if (e.code == 'network-request-failed') {
          debugPrint(
            '🌐 Web network request failed - check CORS and firewall settings',
          );
        } else if (e.code == 'web-context-canceled') {
          debugPrint('🌐 Web authentication context was canceled');
        }
      }

      rethrow; // Rethrow to handle specific errors in the provider
    } catch (e) {
      debugPrint('❌ Unexpected error during sign in: $e');
      if (kIsWeb) {
        debugPrint('🌐 Web-specific general error during sign-in');
      }
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // First sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      // Then sign out from Firebase
      await _auth.signOut();

      debugPrint('✅ Successfully signed out');
    } catch (e) {
      debugPrint('❌ Error during sign out: $e');
      rethrow;
    }
  }

  /// Reset Password
  Future<bool> resetPassword(String email) async {
    try {
      debugPrint('🔄 Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password Reset Error: ${e.code}');
      debugPrint('Error message: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error during password reset: $e');
      return false;
    }
  }

  /// Apple Sign-In
  Future<User?> signInWithApple({BuildContext? context}) async {
    try {
      debugPrint('🍎 Starting Apple Sign-In Process');

      // Use our AppleAuthImplementation for improved in-app authentication
      final appleAuth = AppleAuthImplementation();
      final user = await appleAuth.signInWithApple(context: context);

      // Store user data in Firestore
      if (user != null) {
        debugPrint('💾 Storing user data in Firestore');
        await _storeUserData(user);
        debugPrint('✅ User data stored successfully');
      }

      return user;
    } catch (e) {
      debugPrint('❌ Apple Sign-In error: $e');
      return null;
    }
  }

  /// Verify phone number and send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      debugPrint('📱 Starting phone authentication for: $phoneNumber');

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          debugPrint('✅ Auto-verification completed for: $phoneNumber');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Phone verification failed: ${e.code}');
          debugPrint('Error message: ${e.message}');
          onError(e.message ?? 'Verification failed. Please try again.');
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('📤 Verification code sent to: $phoneNumber');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏱️ Auto retrieval timeout for: $phoneNumber');
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      debugPrint('❌ Unexpected error during phone verification: $e');
      onError('Unexpected error occurred. Please try again later.');
    }
  }

  /// Sign in with phone number using the verification ID and SMS code
  Future<User?> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      debugPrint('🔑 Signing in with phone verification code');

      // Create a PhoneAuthCredential with the verification ID and SMS code
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      debugPrint('✅ Phone authentication successful');

      // Store user data in Firestore
      if (userCredential.user != null) {
        await _storeUserData(userCredential.user!);
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Phone sign-in error: ${e.code}');
      debugPrint('Error message: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error during phone sign-in: $e');
      rethrow;
    }
  }
}
