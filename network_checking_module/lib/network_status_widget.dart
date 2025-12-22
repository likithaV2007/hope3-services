import 'package:flutter/material.dart';
import 'network_checker.dart';

class NetworkStatusWidget extends StatefulWidget {
  final Widget child;
  final Widget? offlineWidget;
  final bool showBanner;

  const NetworkStatusWidget({
    super.key,
    required this.child,
    this.offlineWidget,
    this.showBanner = true,
  });

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  final NetworkChecker _networkChecker = NetworkChecker();
  NetworkStatus _status = NetworkStatus.unknown;

  @override
  void initState() {
    super.initState();
    _initializeNetworkChecker();
  }

  void _initializeNetworkChecker() async {
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

  @override
  Widget build(BuildContext context) {
    if (_status == NetworkStatus.disconnected) {
      if (widget.offlineWidget != null) {
        return widget.offlineWidget!;
      }
      
      if (widget.showBanner) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red,
              child: const Text(
                'No Internet Connection',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: widget.child),
          ],
        );
      }
    }

    return widget.child;
  }

  @override
  void dispose() {
    _networkChecker.dispose();
    super.dispose();
  }
}