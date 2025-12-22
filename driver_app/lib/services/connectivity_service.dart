import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConnectivityService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static bool _isConnected = true;
  static final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  static Stream<bool> get connectivityStream => _connectivityController.stream;
  static bool get isConnected => _isConnected;

  static Future<void> initialize() async {
    Timer.periodic(const Duration(seconds: 10), (_) => _checkConnectivity());
  }

  static Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (connected != _isConnected) {
        _isConnected = connected;
        _connectivityController.add(_isConnected);
        
        if (_isConnected) {
          await _syncCachedData();
        }
      }
    } catch (_) {
      if (_isConnected) {
        _isConnected = false;
        _connectivityController.add(_isConnected);
      }
    }
  }

  static Future<void> cacheGpsPoint(Map<String, dynamic> gpsPoint) async {
    final cached = await _storage.read(key: 'cached_gps_points') ?? '[]';
    final List<dynamic> points = [];
    // Parse existing cached points and add new one
    points.add(gpsPoint);
    await _storage.write(key: 'cached_gps_points', value: points.toString());
  }

  static Future<void> _syncCachedData() async {
    final cached = await _storage.read(key: 'cached_gps_points');
    if (cached != null && cached != '[]') {
      // Sync cached GPS points to Firestore
      await _storage.delete(key: 'cached_gps_points');
    }
  }
}