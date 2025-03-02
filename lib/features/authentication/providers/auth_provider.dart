import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';

// Authentication State
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({this.status = AuthStatus.initial, this.user, this.errorMessage});

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService)
    : super(AuthState(status: AuthStatus.initial)) {
    // Check current authentication state on initialization
    _checkCurrentAuthState();

    // Listen to authentication state changes
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  /// Check current authentication state
  void _checkCurrentAuthState() {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      state = AuthState(status: AuthStatus.authenticated, user: currentUser);
    } else {
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Reset loading state - utility function to unstick UI
  void resetLoadingState() {
    if (state.status == AuthStatus.loading) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      debugPrint('🔄 Loading state manually reset');
    }
  }

  /// Google Sign In
  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage:
              'Google Sign-In Failed. Please check your connection and try again.',
        );
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage:
            'Authentication Error: $e. Please try again or contact support.',
      );
    }
  }

  /// Apple Sign In
  Future<void> signInWithApple({BuildContext? context}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final user = await _authService.signInWithApple(context: context);

      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage:
              'Apple Sign-In Failed. Please check your connection and try again.',
        );
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage:
            'Authentication Error: $e. Please try again or contact support.',
      );
    }
  }

  /// Email/Password Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Sign Up Failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      // Convert Firebase errors to user-friendly messages
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'This email is already registered. Please try logging in.';
          break;
        case 'invalid-email':
          errorMessage = 'Please provide a valid email address.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password sign up is not enabled.';
          break;
        case 'weak-password':
          errorMessage =
              'The password is too weak. Please use at least 6 characters.';
          break;
        default:
          errorMessage = 'Sign up failed: ${e.message}';
      }

      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: errorMessage,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected error occurred. Please try again later.',
      );
      debugPrint('Unexpected error during sign up: $e');
    }
  }

  /// Email/Password Sign In
  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final user = await _authService.signIn(email: email, password: password);

      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Sign In Failed. Please check your credentials.',
        );
      }
    } on FirebaseAuthException catch (e) {
      // Convert Firebase errors to user-friendly messages
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email. Please sign up.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Please provide a valid email address.';
          break;
        case 'user-disabled':
          errorMessage =
              'This account has been disabled. Please contact support.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Too many failed login attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Sign in failed: ${e.message}';
      }

      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: errorMessage,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected error occurred. Please try again later.',
      );
      debugPrint('Unexpected error during sign in: $e');
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      debugPrint('🔑 Starting sign out process');
      state = state.copyWith(status: AuthStatus.loading);

      await _authService.signOut();

      debugPrint('✅ Sign out successful');
      state = AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      debugPrint('❌ Error during sign out: $e');
      // Even if there's an error, we should still set the state to unauthenticated
      // to ensure the UI reflects that the user is logged out
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Error during sign out: $e',
      );
    }
  }

  /// Reset Password
  Future<bool> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }

  /// Verify Phone Number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onError: (errorMessage) {
          state = AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: errorMessage,
          );
        },
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Failed to verify phone number: $e',
      );
      debugPrint('❌ Error verifying phone number: $e');
    }
  }

  /// Sign in with Phone Number
  Future<void> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final user = await _authService.signInWithPhoneNumber(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Phone authentication failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      // Convert Firebase errors to user-friendly messages
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid verification code. Please try again.';
          break;
        case 'invalid-verification-id':
          errorMessage =
              'Invalid verification session. Please restart the verification process.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again later.';
          break;
        default:
          errorMessage = 'Authentication error: ${e.message}';
      }

      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: errorMessage,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected error occurred. Please try again later.',
      );
      debugPrint('❌ Unexpected error during phone sign-in: $e');
    }
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Provider for Firebase Auth state changes stream
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Auth loading state provider
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status == AuthStatus.loading;
});

// Auth error message provider
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.errorMessage;
});

// Auth utilities provider - wrapper for auth functions to simplify UI code
final authUtilsProvider = Provider<AuthUtils>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  final authService = ref.watch(authServiceProvider);
  return AuthUtils(authNotifier, authService);
});

/// Auth utilities class to simplify auth operations in UI
class AuthUtils {
  final AuthNotifier _authNotifier;
  final AuthService _authService;

  AuthUtils(this._authNotifier, this._authService);

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    await _authNotifier.signInWithGoogle();
    return _authService.currentUser;
  }

  /// Sign in with Apple
  Future<User?> signInWithApple({BuildContext? context}) async {
    await _authNotifier.signInWithApple(context: context);
    return _authService.currentUser;
  }

  /// Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    await _authNotifier.signIn(email: email, password: password);
    return _authService.currentUser;
  }

  /// Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _authNotifier.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    return _authService.currentUser;
  }

  /// Sign out
  Future<void> signOut() async {
    await _authNotifier.signOut();
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }
}
