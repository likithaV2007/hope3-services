import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  static FlutterTts? _tts;

  static Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFCM();
    await _initializeTTS();
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(settings);
  }

  static Future<void> _initializeFCM() async {
    await FirebaseMessaging.instance.requestPermission();
    
    FirebaseMessaging.onMessage.listen((message) {
      _handleForegroundMessage(message);
    });
  }

  static Future<void> _initializeTTS() async {
    _tts = FlutterTts();
    await _tts?.setLanguage("en-US");
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final voiceText = message.data['voice'];
    if (voiceText != null) {
      // Play voice and skip text notification
      await _tts?.speak(voiceText);
      return;
    }
    // Only show text notification if no voice data
    await _showLocalNotification(message);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    // Only show visual notifications for text messages
    final messageType = message.data['messageType'];
    if (messageType == 'audio') {
      return; // No visual notification for audio messages
    }
    
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    await _localNotifications.show(
      0,
      message.notification?.title ?? 'Bus Update',
      message.notification?.body ?? 'New notification',
      notificationDetails,
    );
  }

  static Future<String?> getFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  static Future<void> saveFCMTokenForUser(String userId) async {
    // Save token logic here
  }
}