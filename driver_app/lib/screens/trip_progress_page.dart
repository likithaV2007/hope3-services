import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/app_colors.dart';
import '../services/location_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'alerts_page.dart';
import 'profile_page.dart';

class TripProgressPage extends StatefulWidget {
  final String tripId;
  
  const TripProgressPage({Key? key, required this.tripId}) : super(key: key);

  @override
  State<TripProgressPage> createState() => _TripProgressPageState();
}

class _TripProgressPageState extends State<TripProgressPage> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  final List<Map<String, dynamic>> _stops = [
    {'name': 'Central Station, Platform 4', 'lat': 40.7128, 'lng': -74.0060, 'customer': 'John Doe'},
    {'name': 'Mall Plaza, Gate B', 'lat': 40.7589, 'lng': -73.9851, 'customer': 'Jane Smith'},
    {'name': 'Airport Terminal 2', 'lat': 40.7505, 'lng': -73.9934, 'customer': 'Mike Johnson'},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (mounted) {
      setState(() => _currentPosition = position);
    }
  }

  double _getDistanceToStop(Map<String, dynamic> stop) {
    if (_currentPosition == null) return 0;
    return _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      stop['lat'],
      stop['lng'],
    );
  }

  int _getNextStopIndex() {
    if (_currentPosition == null) return 0;
    double minDistance = double.infinity;
    int nextIndex = 0;
    
    for (int i = 0; i < _stops.length; i++) {
      final distance = _getDistanceToStop(_stops[i]);
      if (distance < minDistance) {
        minDistance = distance;
        nextIndex = i;
      }
    }
    return nextIndex;
  }

  @override
  Widget build(BuildContext context) {
    final nextStopIndex = _getNextStopIndex();
    final nextStop = _stops[nextStopIndex];
    final distanceToNext = _getDistanceToStop(nextStop);
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Route timeline
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Timeline
                        Expanded(
                          child: Stack(
                            children: [
                              // Vertical line
                              Positioned(
                                left: 20,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 2,
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              // Stops
                              ListView.builder(
                                itemCount: _stops.length,
                                itemBuilder: (context, index) {
                                  final stop = _stops[index];
                                  final distance = _getDistanceToStop(stop);
                                  final isNext = index == nextStopIndex;
                                  final isPassed = distance < 50;
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 60),
                                    child: Row(
                                      children: [
                                        // Timeline dot
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isPassed ? AppColors.success : 
                                                   isNext ? AppColors.primary : 
                                                   AppColors.white,
                                            border: Border.all(
                                              color: isPassed ? AppColors.success : 
                                                     isNext ? AppColors.primary : 
                                                     AppColors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            isPassed ? Icons.check : Icons.location_on,
                                            color: isPassed ? AppColors.white : 
                                                   isNext ? AppColors.white : 
                                                   AppColors.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        // Stop info
                                        if (isNext) ...[
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: AppColors.primary),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'NEXT STOP',
                                                    style: TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    stop['name'],
                                                    style: const TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'Distance: ',
                                                        style: TextStyle(color: AppColors.white, fontSize: 14),
                                                      ),
                                                      Text(
                                                        '${(distanceToNext / 1000).toStringAsFixed(1)} km',
                                                        style: const TextStyle(color: AppColors.white, fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'ETA: ',
                                                        style: TextStyle(color: AppColors.white, fontSize: 14),
                                                      ),
                                                      Text(
                                                        '${(distanceToNext / 500).ceil()} mins',
                                                        style: const TextStyle(color: AppColors.white, fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'Customer: ',
                                                        style: TextStyle(color: AppColors.white, fontSize: 14),
                                                      ),
                                                      Text(
                                                        stop['customer'],
                                                        style: const TextStyle(color: AppColors.white, fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ] else ...[
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  stop['name'],
                                                  style: TextStyle(
                                                    color: isPassed ? AppColors.success : AppColors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  stop['customer'],
                                                  style: TextStyle(
                                                    color: isPassed ? AppColors.success.withOpacity(0.7) : AppColors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return; // Already on route
          switch (index) {
            case 0:
              Navigator.pop(context);
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AlertsPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }


}