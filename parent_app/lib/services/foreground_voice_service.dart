import 'package:flutter/services.dart';

class ForegroundVoiceService {
  static const MethodChannel _channel = MethodChannel('voice_service');
  
  static Future<void> startService() async {
    try {
      await _channel.invokeMethod('startVoiceService');
      print('✅ Foreground voice service started');
    } catch (e) {
      print('❌ Error starting foreground service: $e');
    }
  }
  
  static Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stopVoiceService');
      print('✅ Foreground voice service stopped');
    } catch (e) {
      print('❌ Error stopping foreground service: $e');
    }
  }
}