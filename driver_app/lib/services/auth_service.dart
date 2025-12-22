import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<List<GoogleSignInAccount>> getGoogleAccounts() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return [];
      
      return [account];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> signInWithGoogleAccount(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return await _checkUserRole(userCredential.user!);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<UserModel?> _checkUserRole(User user) async {
    try {
      print('Checking role for email: ${user.email}');
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      
      print('Query result: ${querySnapshot.docs.length} documents found');
      
      if (querySnapshot.docs.isEmpty) {
        await signOut();
        throw 'User not found in database. Please contact admin to register as a driver.';
      }

      final userData = UserModel.fromMap(querySnapshot.docs.first.data());
      print('User role: ${userData.role}');
      
      if (userData.role.toLowerCase() != 'driver') {
        await signOut();
        throw 'Access denied. Only drivers can use this app.';
      }

      print('Driver authentication successful');
      return userData;
    } catch (e) {
      print('Role check error: $e');
      await signOut();
      throw e.toString();
    }
  }
}