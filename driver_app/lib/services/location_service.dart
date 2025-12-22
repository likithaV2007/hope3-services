import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'trip_service.dart';
import 'connectivity_service.dart';

class LocationService {
  final TripService _tripService = TripService();
  StreamSubscription<Position>? _positionStream;
  String? _currentTripId;

  Future<bool> requestPermissions() async {
    final locationStatus = await Permission.location.request();
    final locationAlwaysStatus = await Permission.locationAlways.request();
    
    return locationStatus.isGranted && locationAlwaysStatus.isGranted;
  }

  Future<void> startTracking(String tripId) async {
    _currentTripId = tripId;
    
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (position.accuracy <= 20 && _currentTripId != null) {
        final gpsPoint = {
          'tripId': _currentTripId!,
          'lat': position.latitude,
          'lng': position.longitude,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        if (ConnectivityService.isConnected) {
          _tripService.addGpsPoint(_currentTripId!, position.latitude, position.longitude);
        } else {
          ConnectivityService.cacheGpsPoint(gpsPoint);
        }
      }
    });
  }

  void stopTracking() {
    _positionStream?.cancel();
    _currentTripId = null;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}