import 'package:flutter/material.dart';
import 'network_checking_module.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const NetworkStatusWidget(
        child: NetworkMonitorHome(),
      ),
    );
  }
}

class NetworkMonitorHome extends StatefulWidget {
  const NetworkMonitorHome({super.key});

  @override
  State<NetworkMonitorHome> createState() => _NetworkMonitorHomeState();
}

class _NetworkMonitorHomeState extends State<NetworkMonitorHome>
    with TickerProviderStateMixin {
  final NetworkChecker _networkChecker = NetworkChecker();
  NetworkStatus _status = NetworkStatus.unknown;
  bool _isChecking = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _initializeNetwork();
  }

  void _initializeNetwork() async {
    await _networkChecker.initialize();
    setState(() {
      _status = _networkChecker.currentStatus;
    });

    _networkChecker.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
      }
    });
  }

  void _testConnection() async {
    setState(() {
      _isChecking = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    final isConnected = await _networkChecker.isConnected();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isConnected ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(isConnected ? 'Connection successful!' : 'No internet connection'),
          ],
        ),
        backgroundColor: isConnected ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.disconnected:
        return Colors.red;
      case NetworkStatus.unknown:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case NetworkStatus.connected:
        return Icons.wifi;
      case NetworkStatus.disconnected:
        return Icons.wifi_off;
      case NetworkStatus.unknown:
        return Icons.help_outline;
    }
  }

  String _getStatusText() {
    switch (_status) {
      case NetworkStatus.connected:
        return 'Connected';
      case NetworkStatus.disconnected:
        return 'Disconnected';
      case NetworkStatus.unknown:
        return 'Checking...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Network Monitor'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor().withOpacity(0.1),
                          border: Border.all(
                            color: _getStatusColor().withOpacity(
                              _status == NetworkStatus.unknown
                                  ? 0.3 + (0.7 * _pulseController.value)
                                  : 1.0,
                            ),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          _getStatusIcon(),
                          size: 48,
                          color: _getStatusColor(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _status == NetworkStatus.connected
                        ? 'Internet access available'
                        : _status == NetworkStatus.disconnected
                            ? 'No internet connection'
                            : 'Checking connection status...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isChecking ? null : _testConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isChecking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Test Connection',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}