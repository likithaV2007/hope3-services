import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'voice_notification_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    // Request notification permissions first
    await _requestPermissions();
    
    // Initialize local notifications with proper channel setup
    await _initializeLocalNotifications();
    
    // Initialize voice notification service (includes FCM setup)
    await VoiceNotificationService.initialize();
    
    // Single listener for all messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }
  
  static Future<void> _requestPermissions() async {
    // Request Firebase messaging permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('User granted permission: ${settings.authorizationStatus}');
    
    // For Android 13+ (API 33+), request notification permission
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      print('Android notification permission: $status');
    }
  }
  
  static Future<void> _initializeLocalNotifications() async {
    // Android initialization with notification channel
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }
  
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'school_bus_alerts',
      'School Bus Alerts',
      description: 'Notifications for school bus tracking and alerts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle notification tap
  }

  static Future<String?> getToken() async {
    return await VoiceNotificationService.getFCMToken();
  }

  static Future<void> saveFCMTokenForUser(String userId) async {
    await VoiceNotificationService.saveFCMTokenToFirestore(userId);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    String messageType = message.data['messageType'] ?? 'text';
    print('Message Type: $messageType');
    
    if (messageType == 'audio') {
      // Handle as voice message
      _showVoiceNotification(message.notification?.title, message.notification?.body);
    } else {
      _showTextNotification(message.notification?.title, message.notification?.body);
    }
  }
  
  static Future<void> _showVoiceNotification(String? title, String? body) async {
    String textToSpeak = body ?? title ?? 'New voice notification';
    await VoiceNotificationService.speak(textToSpeak);
  }
  
  static Future<void> _showTextNotification(String? title, String? body) async {
    await _showLocalNotification(title ?? 'School Bus Alert', body ?? 'New notification received', false);
  }
  


  static void _handleMessageOpenedApp(RemoteMessage message) {
    // Handle notification tap when app is in background
    print('Message opened app: ${message.notification?.title}');
  }

  static Future<void> _showLocalNotification(String title, String body, bool isVoice) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'school_bus_alerts',
      'School Bus Alerts',
      channelDescription: 'Notifications for school bus tracking and alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: isVoice ? '@drawable/ic_volume_up' : '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<bool> isMorningAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('morning_alert') ?? true;
  }

  static Future<bool> isEveningAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('evening_alert') ?? true;
  }

  static Future<bool> isDepartureAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('departure_alert') ?? true;
  }

  static Future<void> setMorningAlert(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('morning_alert', enabled);
  }

  static Future<void> setEveningAlert(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('evening_alert', enabled);
  }

  static Future<void> setDepartureAlert(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('departure_alert', enabled);
  }
}