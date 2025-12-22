import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alert_model.dart';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Alert>> getDriverAlerts() {
    final driverId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return _firestore
        .collection('alerts')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
      final alerts = snapshot.docs.map((doc) => Alert.fromMap(doc.data())).toList();
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return alerts;
    });
  }

  Future<void> markAsRead(String alertId) async {
    await _firestore.collection('alerts').doc(alertId).update({'isRead': true});
  }
}