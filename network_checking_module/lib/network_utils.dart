import 'dart:async';
import 'package:flutter/material.dart';
import 'network_checker.dart';

class NetworkUtils {
  static final NetworkChecker _networkChecker = NetworkChecker();

  static Future<bool> executeWithNetworkCheck(
    VoidCallback onConnected, {
    VoidCallback? onDisconnected,
    String? offlineMessage,
  }) async {
    final isConnected = await _networkChecker.isConnected();
    
    if (isConnected) {
      onConnected();
      return true;
    } else {
      if (onDisconnected != null) {
        onDisconnected();
      }
      return false;
    }
  }

  static void showNetworkSnackBar(BuildContext context, {String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'No internet connection'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<void> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    final completer = Completer<void>();
    late StreamSubscription subscription;
    
    subscription = _networkChecker.statusStream.listen((status) {
      if (status == NetworkStatus.connected) {
        subscription.cancel();
        completer.complete();
      }
    });

    Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError('Network connection timeout');
      }
    });

    return completer.future;
  }
}