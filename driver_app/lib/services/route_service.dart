import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_model.dart';

class RouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveRouteDetails(RouteModel route) async {
    await _firestore
        .collection('daily_routes')
        .doc('${route.driverId}_${_getDateString(route.date)}')
        .set(route.toMap());
  }

  Future<RouteModel?> getTodayRoute(String driverId) async {
    final today = DateTime.now();
    final docId = '${driverId}_${_getDateString(today)}';
    
    final doc = await _firestore
        .collection('daily_routes')
        .doc(docId)
        .get();
    
    if (doc.exists) {
      return RouteModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<bool> hasRouteForToday(String driverId) async {
    final route = await getTodayRoute(driverId);
    return route != null;
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}