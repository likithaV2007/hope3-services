import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

enum NetworkStatus { connected, disconnected, unknown }

class NetworkChecker {
  static final NetworkChecker _instance = NetworkChecker._internal();
  factory NetworkChecker() => _instance;
  NetworkChecker._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _statusController = StreamController<NetworkStatus>.broadcast();
  
  NetworkStatus _currentStatus = NetworkStatus.unknown;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<NetworkStatus> get statusStream => _statusController.stream;
  NetworkStatus get currentStatus => _currentStatus;

  Future<void> initialize() async {
    _currentStatus = await checkConnection();
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    final status = await checkConnection();
    if (status != _currentStatus) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }

  Future<NetworkStatus> checkConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      
      if (connectivityResults.contains(ConnectivityResult.none)) {
        return NetworkStatus.disconnected;
      }

      return await _hasInternetAccess() ? NetworkStatus.connected : NetworkStatus.disconnected;
    } catch (e) {
      return NetworkStatus.unknown;
    }
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'Cache-Control': 'no-cache'},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isConnected() async {
    final status = await checkConnection();
    return status == NetworkStatus.connected;
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}