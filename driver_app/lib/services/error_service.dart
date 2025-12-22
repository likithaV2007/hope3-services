import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> logError(String error, String stackTrace) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      await _firestore.collection('error_logs').add({
        'userId': userId,
        'error': error,
        'stackTrace': stackTrace,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'platform': 'flutter',
      });
    } catch (e) {
      // Silent fail for error logging
    }
  }
}