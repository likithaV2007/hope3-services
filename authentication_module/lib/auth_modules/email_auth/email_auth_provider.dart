import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/auth_state.dart';
import '../shared/auth_user.dart';
import 'email_auth_service.dart';

final emailAuthServiceProvider = Provider<EmailAuthService>((ref) {
  return EmailAuthService();
});

class EmailAuthNotifier extends StateNotifier<AuthState> {
  final EmailAuthService _authService;

  EmailAuthNotifier(this._authService) : super(const AuthState()) {
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      }
    });
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.signUpWithEmail(email, password);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.signInWithEmail(email, password);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}

final emailAuthProvider = StateNotifierProvider<EmailAuthNotifier, AuthState>((ref) {
  final authService = ref.read(emailAuthServiceProvider);
  return EmailAuthNotifier(authService);
});