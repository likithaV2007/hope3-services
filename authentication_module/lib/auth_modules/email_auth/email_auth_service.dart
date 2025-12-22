import 'package:firebase_auth/firebase_auth.dart';
import '../shared/auth_user.dart';

class EmailAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<AuthUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) => 
        user != null ? AuthUser.fromFirebaseUser(user) : null);
  }

  Future<AuthUser> signUpWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AuthUser.fromFirebaseUser(credential.user!);
  }

  Future<AuthUser> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AuthUser.fromFirebaseUser(credential.user!);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}