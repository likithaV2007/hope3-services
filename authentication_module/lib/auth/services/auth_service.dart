import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '272880556104-5kiqlkjp70jnugu2sjui3hsosdptbgb7.apps.googleusercontent.com',
  );

  Stream<AuthUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) => 
        user != null ? AuthUser.fromFirebaseUser(user) : null);
  }

  Future<AuthUser?> signUpWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email, password: password);
    return credential.user != null ? AuthUser.fromFirebaseUser(credential.user!) : null;
  }

  Future<AuthUser?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email, password: password);
    return credential.user != null ? AuthUser.fromFirebaseUser(credential.user!) : null;
  }

  Future<AuthUser?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Clear any cached account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user != null ? AuthUser.fromFirebaseUser(userCredential.user!) : null;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> signInWithPhone(String phoneNumber, Function(String) onCodeSent) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<AuthUser?> verifyOTP(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId, smsCode: smsCode);
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user != null ? AuthUser.fromFirebaseUser(userCredential.user!) : null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}