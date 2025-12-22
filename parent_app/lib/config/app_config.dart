class AppConfig {
  static const String googleMapsApiKey = 'AIzaSyBm6zQSyJrNplHLEmccg-Ks9_uT364DRng';
  static const String schoolName = 'Hope Elementary School';
  static const String appVersion = '1.0.0';
  
  // Update intervals
  static const Duration busLocationUpdateInterval = Duration(seconds: 15);
  static const Duration etaUpdateInterval = Duration(seconds: 30);
  
  // Notification timing
  static const Duration notificationAdvanceTime = Duration(minutes: 5);
  
  // Cache settings
  static const Duration cacheValidDuration = Duration(days: 7);
  
  // Geofencing
  static const double arrivalGeofenceRadius = 100.0; // meters
}