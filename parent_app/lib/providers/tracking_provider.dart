import 'dart:async';
import 'package:flutter/material.dart';
import '../models/child_model.dart';
import '../models/bus_model.dart';
import '../models/bus_stop_model.dart';
import '../models/trip_history_model.dart';
import '../services/bus_service.dart';
import '../services/child_service.dart';
import '../services/eta_service.dart';
import '../services/offline_service.dart';

class TrackingProvider extends ChangeNotifier {
  final BusService _busService = BusService();

  
  List<ChildModel> _children = [];
  ChildModel? _selectedChild;
  BusModel? _currentBus;
  List<BusStopModel> _routeStops = [];
  BusStopModel? _pickupStop;
  BusStopModel? _dropStop;
  Duration? _eta;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _busSubscription;
  Timer? _etaTimer;
  List<TripHistoryModel> _tripHistory = [];

  // Getters
  List<ChildModel> get children => _children;
  ChildModel? get selectedChild => _selectedChild;
  BusModel? get currentBus => _currentBus;
  List<BusStopModel> get routeStops => _routeStops;
  BusStopModel? get pickupStop => _pickupStop;
  BusStopModel? get dropStop => _dropStop;
  Duration? get eta => _eta;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TripHistoryModel> get tripHistory => _tripHistory;

  Future<void> loadChildren(String parentId) async {
    _setLoading(true);
    try {
      // Mock data for testing
      _children = [
        ChildModel(
          id: 'child1',
          name: 'Sarah Khan',
          grade: '5',
          photoUrl: null,
          busRouteId: 'route1',
          pickupStopId: 'stop1',
          dropStopId: 'stop2',
          parentId: parentId,
        ),
        ChildModel(
          id: 'child2',
          name: 'Ahmed Khan',
          grade: '3',
          photoUrl: null,
          busRouteId: 'route1',
          pickupStopId: 'stop1',
          dropStopId: 'stop2',
          parentId: parentId,
        ),
      ];
      
      if (_children.isNotEmpty && _selectedChild == null) {
        await selectChild(_children.first);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load children: $e';
    }
    _setLoading(false);
  }

  Future<void> selectChild(ChildModel child) async {
    _selectedChild = child;
    await _loadChildTrackingData();
    notifyListeners();
  }

  Future<void> _loadChildTrackingData() async {
    if (_selectedChild == null) return;

    try {
      // Mock route stops data
      _routeStops = [
        BusStopModel(
          id: 'stop1',
          name: 'Main Gate',
          latitude: 37.7749,
          longitude: -122.4194,
          address: 'Main Gate Street',
          sequence: 1,
          routeId: 'route1',
        ),
        BusStopModel(
          id: 'stop2',
          name: 'School Entrance',
          latitude: 37.7849,
          longitude: -122.4094,
          address: 'School Street',
          sequence: 2,
          routeId: 'route1',
        ),
      ];
      
      // Mock pickup and drop stops
      _pickupStop = BusStopModel(
        id: 'stop1',
        name: 'Main Gate',
        latitude: 37.7749,
        longitude: -122.4194,
        address: 'Main Gate Street',
        sequence: 1,
        routeId: 'route1',
      );
      _dropStop = BusStopModel(
        id: 'stop2',
        name: 'School Entrance',
        latitude: 37.7849,
        longitude: -122.4094,
        address: 'School Street',
        sequence: 2,
        routeId: 'route1',
      );
      
      // Start listening to bus location
      _startBusTracking();
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load tracking data: $e';
    }
    notifyListeners();
  }

  void _startBusTracking() {
    _busSubscription?.cancel();
    _etaTimer?.cancel();

    if (_selectedChild == null) return;

    // Mock bus data
    _currentBus = BusModel(
      id: 'bus1',
      number: 'B-101',
      routeId: 'route1',
      driverName: 'Mr. Ahmed',
      driverPhone: '+92300123456',
      latitude: 37.7649,
      longitude: -122.4294,
      speed: 45.0,
      isActive: true,
      lastUpdate: DateTime.now(),
    );
    _calculateETA();
    notifyListeners();

    // Update ETA every 30 seconds
    _etaTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (_currentBus != null && _currentBus!.isActive) {
        _calculateETA();
      }
    });
  }

  Future<void> _calculateETA() async {
    if (_currentBus == null || _pickupStop == null) return;

    try {
      _eta = await ETAService.calculateETA(
        busLat: _currentBus!.latitude,
        busLng: _currentBus!.longitude,
        stopLat: _pickupStop!.latitude,
        stopLng: _pickupStop!.longitude,
      );
      notifyListeners();
    } catch (e) {
      print('ETA calculation error: $e');
    }
  }

  Future<void> loadTripHistory(String parentId) async {
    _setLoading(true);
    try {
      // Mock trip history data for now
      _tripHistory = [
        TripHistoryModel(
          id: '1',
          childId: _selectedChild?.id ?? '',
          busId: 'bus1',
          date: DateTime.now().subtract(Duration(days: 1)),
          tripType: 'morning',
          startTime: DateTime.now().subtract(Duration(days: 1, hours: 2)),
          endTime: DateTime.now().subtract(Duration(days: 1, hours: 1)),
          wasOnTime: true,
          notes: 'Successful trip',
        ),
      ];
      _error = null;
    } catch (e) {
      _error = 'Failed to load trip history: $e';
    }
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _busSubscription?.cancel();
    _etaTimer?.cancel();
    _busService.dispose();
    super.dispose();
  }
}