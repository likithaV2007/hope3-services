import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class ETAService {
  static const String _apiKey = 'AIzaSyBm6zQSyJrNplHLEmccg-Ks9_uT364DRng';

  static Future<Duration?> calculateETA({
    required double busLat,
    required double busLng,
    required double stopLat,
    required double stopLng,
  }) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$busLat,$busLng'
        '&destination=$stopLat,$stopLng'
        '&departure_time=now'
        '&traffic_model=best_guess'
        '&key=$_apiKey'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          final durationInTraffic = leg['duration_in_traffic'] ?? leg['duration'];
          
          return Duration(seconds: durationInTraffic['value']);
        }
      }
    } catch (e) {
      print('Error calculating ETA: $e');
    }
    
    // Fallback: calculate straight-line distance and estimate
    final distance = Geolocator.distanceBetween(busLat, busLng, stopLat, stopLng);
    final estimatedMinutes = (distance / 500).ceil(); // Assume 30 km/h average speed
    return Duration(minutes: estimatedMinutes);
  }

  static String formatETA(Duration eta) {
    if (eta.inMinutes < 1) {
      return 'Arriving now';
    } else if (eta.inMinutes == 1) {
      return '1 minute';
    } else {
      return '${eta.inMinutes} minutes';
    }
  }
}