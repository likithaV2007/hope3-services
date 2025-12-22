import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/voice_notification_service.dart';

class NotificationTest {
  static Future<void> testLocalNotification() async {
    try {
      // Test voice notification
      await VoiceNotificationService.testVoiceNotification();
      
      // Test sending a custom notification
      await VoiceNotificationService.sendTestNotification(
        "Test notification: Your child's bus is arriving in 5 minutes!"
      );
      
      print('Test notification sent successfully');
    } catch (e) {
      print('Error testing notification: $e');
    }
  }
  
  static Future<void> checkNotificationPermissions() async {
    try {
      String? token = await NotificationService.getToken();
      if (token != null) {
        print('FCM Token available: ${token.substring(0, 20)}...');
      } else {
        print('FCM Token not available');
      }
    } catch (e) {
      print('Error checking permissions: $e');
    }
  }
  
  static Widget buildTestButton(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => testLocalNotification(),
          child: Text('Test Notification'),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => checkNotificationPermissions(),
          child: Text('Check Permissions'),
        ),
      ],
    );
  }
}