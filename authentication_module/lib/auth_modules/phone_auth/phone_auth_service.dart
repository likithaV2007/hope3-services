import 'package:firebase_auth/firebase_auth.dart';
import '../shared/auth_user.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<AuthUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) => 
        user != null ? AuthUser.fromFirebaseUser(user) : null);
  }

  Future<void> signInWithPhone(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<AuthUser> verifyOTP(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return AuthUser.fromFirebaseUser(userCredential.user!);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}