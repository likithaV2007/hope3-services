import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/auth_state.dart';
import 'google_auth_service.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

class GoogleAuthNotifier extends StateNotifier<AuthState> {
  final GoogleAuthService _authService;

  GoogleAuthNotifier(this._authService) : super(const AuthState()) {
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}

final googleAuthProvider = StateNotifierProvider<GoogleAuthNotifier, AuthState>((ref) {
  final authService = ref.read(googleAuthServiceProvider);
  return GoogleAuthNotifier(authService);
});