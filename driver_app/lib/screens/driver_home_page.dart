import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/trip_service.dart';
import '../services/location_service.dart';
import '../models/trip_model.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/bottom_nav_bar.dart';
import 'trip_progress_page.dart';
import 'alerts_page.dart';
import 'profile_page.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({Key? key}) : super(key: key);

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final TripService _tripService = TripService();
  final LocationService _locationService = LocationService();
  final String _driverId = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _isLoading = false;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _getCurrentLocation();
  }

  Future<void> _requestPermissions() async {
    await _locationService.requestPermissions();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (mounted && position != null) {
        setState(() {
          _currentPosition = position;
          _markers = {
            Marker(
              markerId: const MarkerId('driver'),
              position: LatLng(position.latitude, position.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          };
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    } catch (e) {
      print('Location error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: AppColors.primary),
        actions: const [
          Icon(Icons.notifications_outlined, color: AppColors.primary),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: StreamBuilder<Trip?>(
              stream: _tripService.getCurrentTrip(_driverId),
              builder: (context, snapshot) {
                final currentTrip = snapshot.data;
                final isOnTrip = currentTrip != null;
                
                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition != null 
                            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                            : const LatLng(37.7749, -122.4194),
                        zoom: 15,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      zoomControlsEnabled: false,
                      compassEnabled: true,
                      trafficEnabled: false,
                      buildingsEnabled: true,
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.white),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                if (!isOnTrip) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTripCard(
                                          'Start\nMorning Trip',
                                          Icons.wb_sunny_rounded,
                                          () => _startTrip(TripState.TRIP_MORNING),
                                          [Color(0xFFFFD700), Color(0xFFFFA500)], // Gold Gradient
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildTripCard(
                                          'Start\nEvening Trip',
                                          Icons.nights_stay_rounded,
                                          () => _startTrip(TripState.TRIP_EVENING),
                                          [Color(0xFF483D8B), Color(0xFF0F52BA)], // Indigo/Sapphire Gradient
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  _buildEndTripCard(() => _endTrip(currentTrip.id)),
                                ],
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (isOnTrip) ...[
                            GestureDetector(
                              onTap: _getCurrentLocation,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                  border: Border.all(color: AppColors.primary, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.my_location,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.success.withOpacity(0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, color: AppColors.success, size: 8),
                                  SizedBox(width: 8),
                                  Text(
                                    'GPS TRACKING ACTIVE',
                                    style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sending location every 3s',
                              style: TextStyle(color: AppColors.black, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Accuracy: High',
                              style: TextStyle(color: AppColors.black, fontSize: 12),
                            ),
                            const SizedBox(height: 20),
                          ],
                          const SizedBox(height: 40),
                          const Text(
                            'Trip Dashboard',
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return; // Already on home
          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TripProgressPage(tripId: '')),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildTripCard(String text, IconData icon, VoidCallback onPressed, List<Color> gradientColors) {
    return GestureDetector(
      onTap: _isLoading ? null : onPressed,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndTripCard(VoidCallback onPressed) {
    return GestureDetector(
      onTap: _isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.5), width: 2),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.stop_circle_outlined, color: AppColors.error),
              SizedBox(width: 12),
              Text(
                'End Current Trip',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<void> _startTrip(TripState tripType) async {
    setState(() => _isLoading = true);
    try {
      final tripId = await _tripService.startTrip(_driverId, tripType);
      await _locationService.startTracking(tripId);
    } catch (e) {
      _showError('Failed to start trip: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _endTrip(String tripId) async {
    setState(() => _isLoading = true);
    try {
      await _tripService.endTrip(tripId);
      _locationService.stopTracking();
    } catch (e) {
      _showError('Failed to end trip: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}