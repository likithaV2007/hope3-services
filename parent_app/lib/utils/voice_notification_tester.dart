import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoiceNotificationTester {
  // Test voice notification - sends FCM message with voice data
  static Future<void> sendTestVoiceNotification() async {
    try {
      // Get current FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        print('No FCM token available');
        return;
      }

      // Simulate sending voice notification (normally done from your server)
      print('Sending voice notification to token: ${token.substring(0, 20)}...');
      
      // For testing, we'll trigger a local notification with voice data
      await FirebaseMessaging.instance.sendMessage(
        to: token,
        data: {
          'messageType': 'audio',
          'voice_message': 'Your school bus is arriving in 5 minutes. Please be ready at the bus stop.',
          'title': 'Bus Arrival Alert',
          'body': 'Bus arriving in 5 minutes'
        },
      );
      
      print('Voice notification sent successfully');
    } catch (e) {
      print('Error sending voice notification: $e');
    }
  }

  // Alternative method using RemoteMessage simulation
  static Future<void> simulateVoiceMessage() async {
    try {
      // Create a simulated RemoteMessage with voice data
      final Map<String, dynamic> messageData = {
        'messageType': 'audio',
        'voice_message': 'Test voice notification: Your bus is 3 minutes away!',
        'title': 'Bus Alert',
        'body': 'Bus approaching'
      };

      // Trigger the native service directly
      print('Simulating voice message with data: $messageData');
      
      // This would normally be handled by MyFirebaseMessagingService
      // For testing, we can call the service directly
      
    } catch (e) {
      print('Error simulating voice message: $e');
    }
  }
}