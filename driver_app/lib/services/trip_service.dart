import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/trip_model.dart';

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Stream<Trip?> getCurrentTrip(String driverId) {
    return _firestore
        .collection('trips')
        .where('driverId', isEqualTo: driverId)
        .where('state', whereIn: ['TRIP_MORNING', 'TRIP_EVENING'])
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Trip.fromMap(snapshot.docs.first.data());
    });
  }

  Future<String> startTrip(String driverId, TripState tripType) async {
    final tripId = DateTime.now().millisecondsSinceEpoch.toString();
    final trip = Trip(
      id: tripId,
      driverId: driverId,
      state: tripType,
      startTime: DateTime.now(),
    );
    
    await _firestore.collection('trips').doc(trip.id).set(trip.toMap());
    await _storage.write(key: 'current_trip_id', value: trip.id);
    return tripId;
  }

  Future<void> endTrip(String tripId) async {
    await _firestore.collection('trips').doc(tripId).update({
      'state': 'IDLE',
      'endTime': DateTime.now().millisecondsSinceEpoch,
    });
    await _storage.delete(key: 'current_trip_id');
  }

  Future<void> addGpsPoint(String tripId, double lat, double lng) async {
    final gpsPoint = {
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'gpsPoints': FieldValue.arrayUnion([gpsPoint])
      });
    } catch (e) {
      // If document doesn't exist, create it first
      await _firestore.collection('trips').doc(tripId).set({
        'gpsPoints': [gpsPoint]
      }, SetOptions(merge: true));
    }
  }
}