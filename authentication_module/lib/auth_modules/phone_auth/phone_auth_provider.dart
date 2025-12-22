import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/auth_state.dart';
import 'phone_auth_service.dart';

final phoneAuthServiceProvider = Provider<PhoneAuthService>((ref) {
  return PhoneAuthService();
});

class PhoneAuthNotifier extends StateNotifier<AuthState> {
  final PhoneAuthService _authService;
  String? _verificationId;

  PhoneAuthNotifier(this._authService) : super(const AuthState()) {
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      }
    });
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.signInWithPhone(
        phoneNumber,
        (verificationId) {
          _verificationId = verificationId;
          state = state.copyWith(status: AuthStatus.unauthenticated);
        },
        (error) {
          state = state.copyWith(status: AuthStatus.error, error: error);
        },
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> verifyOTP(String smsCode) async {
    if (_verificationId == null) return;
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.verifyOTP(_verificationId!, smsCode);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}

final phoneAuthProvider = StateNotifierProvider<PhoneAuthNotifier, AuthState>((ref) {
  final authService = ref.read(phoneAuthServiceProvider);
  return PhoneAuthNotifier(authService);
});