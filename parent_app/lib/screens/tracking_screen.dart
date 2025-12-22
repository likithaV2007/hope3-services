import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/tracking_provider.dart';
import '../constants/app_colors.dart';

import '../widgets/child_selector.dart';
import '../widgets/bus_info_card.dart';

class TrackingScreen extends StatefulWidget {
  final String parentId;

  const TrackingScreen({super.key, required this.parentId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingProvider>().loadChildren(widget.parentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('Bus Tracking', style: TextStyle(color: AppColors.primary, fontSize: 24,fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Consumer<TrackingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 64),
                  SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: TextStyle(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadChildren(widget.parentId),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.children.isEmpty) {
            return Center(
              child: Text(
                'No children found',
                style: TextStyle(color: AppColors.primary, fontSize: 18),
              ),
            );
          }

          return Column(
            children: [
              // Child selector
              ChildSelector(
                children: provider.children,
                selectedChild: provider.selectedChild,
                onChildSelected: (child) => provider.selectChild(child),
              ),
              
              // Bus info card
              if (provider.selectedChild != null) BusInfoCard(),
              
              // Map
              Expanded(
                child: _buildMap(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap(TrackingProvider provider) {
    _updateMapMarkers(provider);

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _fitMapToMarkers(provider);
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(37.7749, -122.4194), // Default to SF
        zoom: 12,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      style: _lightMapStyle,
    );
  }

  void _updateMapMarkers(TrackingProvider provider) {
    _markers.clear();
    _polylines.clear();

    // Add bus marker
    if (provider.currentBus != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('bus'),
          position: LatLng(
            provider.currentBus!.latitude,
            provider.currentBus!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Bus ${provider.currentBus!.number}',
            snippet: 'Driver: ${provider.currentBus!.driverName}',
          ),
        ),
      );
    }

    // Add pickup stop marker
    if (provider.pickupStop != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('pickup'),
          position: LatLng(
            provider.pickupStop!.latitude,
            provider.pickupStop!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Pickup Stop',
            snippet: provider.pickupStop!.name,
          ),
        ),
      );
    }

    // Add route stops
    for (int i = 0; i < provider.routeStops.length; i++) {
      final stop = provider.routeStops[i];
      _markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: LatLng(stop.latitude, stop.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: 'Stop ${stop.sequence}',
          ),
        ),
      );
    }

    // Add route polyline
    if (provider.routeStops.length > 1) {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: provider.routeStops
              .map((stop) => LatLng(stop.latitude, stop.longitude))
              .toList(),
          color: AppColors.primary,
          width: 3,
        ),
      );
    }
  }

  void _fitMapToMarkers(TrackingProvider provider) {
    if (_mapController == null || _markers.isEmpty) return;

    final bounds = _calculateBounds(_markers);
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (final marker in markers) {
      minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
      maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  static const String _lightMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#616161"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#f5f5f5"}]
    }
  ]
  ''';
}