import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bus_model.dart';
import '../models/child_model.dart';
import '../models/bus_stop_model.dart';

class OfflineService {
  static const String _busDataKey = 'cached_bus_data';
  static const String _childrenKey = 'cached_children';
  static const String _stopsKey = 'cached_stops';
  static const String _lastUpdateKey = 'last_update';

  static Future<void> cacheBusData(BusModel bus) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_busDataKey, json.encode(bus.toMap()));
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<BusModel?> getCachedBusData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_busDataKey);
    if (data != null) {
      return BusModel.fromMap(json.decode(data));
    }
    return null;
  }

  static Future<void> cacheChildren(List<ChildModel> children) async {
    final prefs = await SharedPreferences.getInstance();
    final data = children.map((child) => child.toMap()).toList();
    await prefs.setString(_childrenKey, json.encode(data));
  }

  static Future<List<ChildModel>> getCachedChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_childrenKey);
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      return decoded.map((item) => ChildModel.fromMap(item)).toList();
    }
    return [];
  }

  static Future<void> cacheStops(List<BusStopModel> stops) async {
    final prefs = await SharedPreferences.getInstance();
    final data = stops.map((stop) => stop.toMap()).toList();
    await prefs.setString(_stopsKey, json.encode(data));
  }

  static Future<List<BusStopModel>> getCachedStops() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_stopsKey);
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      return decoded.map((item) => BusStopModel.fromMap(item)).toList();
    }
    return [];
  }

  static Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);
    if (lastUpdate == null) return false;
    
    final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdate;
    const maxAge = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds
    
    return cacheAge < maxAge;
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_busDataKey);
    await prefs.remove(_childrenKey);
    await prefs.remove(_stopsKey);
    await prefs.remove(_lastUpdateKey);
  }
}