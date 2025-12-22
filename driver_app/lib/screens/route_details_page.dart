import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';
import '../services/places_service.dart';
import '../constants/app_colors.dart';

class RouteDetailsPage extends StatefulWidget {
  final String driverId;
  
  const RouteDetailsPage({Key? key, required this.driverId}) : super(key: key);

  @override
  State<RouteDetailsPage> createState() => _RouteDetailsPageState();
}

class _RouteDetailsPageState extends State<RouteDetailsPage> {
  final RouteService _routeService = RouteService();
  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final List<StopLocation> _stops = [];
  bool _isLoading = false;
  bool _showSearch = false;
  bool _hasExistingRoute = false;
  RouteModel? _existingRoute;
  
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default to San Francisco
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkExistingRoute();
  }

  Future<void> _checkExistingRoute() async {
    final existingRoute = await _routeService.getTodayRoute(widget.driverId);
    if (existingRoute != null) {
      setState(() {
        _hasExistingRoute = true;
        _existingRoute = existingRoute;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final location = await PlacesService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _initialPosition = CameraPosition(
          target: location,
          zoom: 14,
        );
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(location));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Route Details'),
        automaticallyImplyLeading: false,
        actions: [
          if (!_hasExistingRoute)
            IconButton(
              onPressed: () => setState(() => _showSearch = !_showSearch),
              icon: Icon(_showSearch ? Icons.close : Icons.search),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_hasExistingRoute)
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Route Already Set for Today',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Route: ${_existingRoute?.routeName ?? "Unknown"}'),
                  Text('Stops: ${_existingRoute?.stops.length ?? 0}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/driver-home'),
                          child: const Text('Use Existing Route'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _hasExistingRoute = false),
                          child: const Text('Update Route'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          if (!_hasExistingRoute)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _routeNameController,
                decoration: const InputDecoration(
                  labelText: 'Route Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.route),
                ),
              ),
            ),
          
          if (!_hasExistingRoute && _showSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: _searchController,
                googleAPIKey: "AIzaSyBvOkBu-wLrHwKFHFxvYVyiDnKfvzFbE2c", // Replace with your actual API key
                inputDecoration: const InputDecoration(
                  hintText: 'Search for a location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                debounceTime: 800,
                countries: ["us"],
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (Prediction prediction) {
                  _addStopFromSearch(prediction);
                },
                itemClick: (Prediction prediction) {
                  _searchController.text = prediction.description ?? "";
                },
              ),
            ),
          
          if (!_hasExistingRoute)
            Expanded(
              child: GoogleMap(
                initialCameraPosition: _initialPosition,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                onTap: _addStopFromTap,
              ),
            ),
          
          if (!_hasExistingRoute)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Stops Added: ${_stops.length}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  
                  if (_stops.isNotEmpty)
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _stops.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text(_stops[index].name),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeStop(index),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveRouteDetails,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: AppColors.white)
                          : const Text('Continue to Home'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: !_hasExistingRoute ? FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.my_location, color: AppColors.white),
      ) : null,
    );
  }

  void _addStopFromTap(LatLng position) {
    final stopName = 'Stop ${_stops.length + 1}';
    _addStop(stopName, position.latitude, position.longitude);
  }

  void _addStopFromSearch(Prediction prediction) {
    if (prediction.lat != null && prediction.lng != null) {
      _addStop(
        prediction.description ?? 'Unknown Location',
        double.parse(prediction.lat!),
        double.parse(prediction.lng!),
      );
      setState(() => _showSearch = false);
      _searchController.clear();
    }
  }

  void _addStop(String name, double lat, double lng) {
    final stop = StopLocation(name: name, latitude: lat, longitude: lng);
    
    setState(() {
      _stops.add(stop);
      _markers.add(
        Marker(
          markerId: MarkerId('stop_${_stops.length}'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name),
        ),
      );
    });
  }

  void _removeStop(int index) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'stop_${index + 1}');
      _stops.removeAt(index);
      
      // Update marker IDs
      _markers.clear();
      for (int i = 0; i < _stops.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('stop_${i + 1}'),
            position: LatLng(_stops[i].latitude, _stops[i].longitude),
            infoWindow: InfoWindow(title: _stops[i].name),
          ),
        );
      }
    });
  }

  Future<void> _saveRouteDetails() async {
    if (_routeNameController.text.trim().isEmpty) {
      _showError('Please enter a route name');
      return;
    }

    if (_stops.isEmpty) {
      _showError('Please add at least one stop');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final route = RouteModel(
        routeId: '${widget.driverId}_${DateTime.now().millisecondsSinceEpoch}',
        routeName: _routeNameController.text.trim(),
        stops: _stops,
        driverId: widget.driverId,
        date: DateTime.now(),
      );

      await _routeService.saveRouteDetails(route);
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/driver-home');
      }
    } catch (e) {
      _showError('Failed to save route details: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}