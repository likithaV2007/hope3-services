import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_model.dart';
import '../models/bus_stop_model.dart';
import '../models/route_model.dart';

class BusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _busLocationSubscription;

  Stream<BusModel?> getBusLocation(String busId) {
    return _firestore
        .collection('buses')
        .doc(busId)
        .snapshots()
        .map((doc) => doc.exists ? BusModel.fromMap(doc.data()!) : null);
  }

  Future<List<BusStopModel>> getRouteStops(String routeId) async {
    final snapshot = await _firestore
        .collection('busStops')
        .where('routeId', isEqualTo: routeId)
        .orderBy('sequence')
        .get();
    
    return snapshot.docs
        .map((doc) => BusStopModel.fromMap(doc.data()))
        .toList();
  }

  Future<RouteModel?> getRoute(String routeId) async {
    final doc = await _firestore.collection('routes').doc(routeId).get();
    return doc.exists ? RouteModel.fromMap(doc.data()!) : null;
  }

  Future<BusStopModel?> getBusStop(String stopId) async {
    final doc = await _firestore.collection('busStops').doc(stopId).get();
    return doc.exists ? BusStopModel.fromMap(doc.data()!) : null;
  }

  void dispose() {
    _busLocationSubscription?.cancel();
  }
}