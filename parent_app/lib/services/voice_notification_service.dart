import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoiceNotificationService {
  static final FlutterTts _tts = FlutterTts();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Request notification permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure TTS
    await _configureTTS();

    // Listen to FCM messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Get and save FCM token
    await _saveFCMToken();

    // Subscribe to topics
    await _messaging.subscribeToTopic('parents');
    await _messaging.subscribeToTopic('drivers');
    print('Subscribed to topics');

    _isInitialized = true;
  }

  static Future<void> _configureTTS() async {
    await _tts.setLanguage("en-IN");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  static Future<void> _saveFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        print("FCM TOKEN: $token");
        
        // Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        
        // TODO: Save token to Firestore for the current user
        // This should be called after user authentication
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  static Future<void> saveFCMTokenToFirestore(String userId) async {
    try {
      print('Attempting to save FCM token for user: $userId');
      String? token = await _messaging.getToken();
      if (token != null) {
        print('FCM Token generated: $token');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'fcm_tokens': token});
        print('FCM token successfully saved to Firestore for user: $userId');
      } else {
        print('FCM token is null, cannot save to Firestore');
      }
    } catch (e) {
      print('Error saving FCM token to Firestore: $e');
      print('User ID: $userId');
    }
  }

  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    await _handleForegroundMessage(message);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.notification?.title}');
    
    // Check messageType and handle voice notifications
    String messageType = message.data['messageType'] ?? 'text';
    if (messageType == 'audio' && await _isVoiceNotificationEnabled()) {
      String textToSpeak = message.data['voice_message'] ?? 
                          message.notification?.body ?? 
                          message.notification?.title ?? 
                          'New notification received';
      await speak(textToSpeak);
    }
  }

  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('Message opened app: ${message.notification?.title}');
    // Handle navigation or other actions when notification is tapped
  }

  static Future<void> _speakNotification(RemoteMessage message) async {
    try {
      String textToSpeak = '';
      
      // Priority: Custom voice message > notification body > notification title
      if (message.data.containsKey('voice_message')) {
        textToSpeak = message.data['voice_message'];
      } else if (message.notification?.body != null) {
        textToSpeak = message.notification!.body!;
      } else if (message.notification?.title != null) {
        textToSpeak = message.notification!.title!;
      }

      if (textToSpeak.isNotEmpty) {
        await speak(textToSpeak);
      }
    } catch (e) {
      print('Error speaking notification: $e');
    }
  }

  static Future<void> speak(String text) async {
    try {
      print('TTS attempting to speak: $text');
      await _tts.stop(); // Stop any ongoing speech
      
      // Ensure TTS is configured
      await _configureTTS();
      
      var result = await _tts.speak(text);
      print('TTS speak result: $result');
      print('TTS speaking: $text');
    } catch (e) {
      print('Error in TTS speak: $e');
    }
  }

  static Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  static Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Voice notification preferences
  static Future<bool> _isVoiceNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('voice_notifications_enabled') ?? true;
  }

  static Future<void> setVoiceNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_notifications_enabled', enabled);
  }

  static Future<bool> isVoiceNotificationEnabled() async {
    return await _isVoiceNotificationEnabled();
  }

  // TTS Settings
  static Future<void> setTTSLanguage(String language) async {
    try {
      await _tts.setLanguage(language);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tts_language', language);
    } catch (e) {
      print('Error setting TTS language: $e');
    }
  }

  static Future<void> setTTSSpeechRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('tts_speech_rate', rate);
    } catch (e) {
      print('Error setting TTS speech rate: $e');
    }
  }

  static Future<void> setTTSPitch(double pitch) async {
    try {
      await _tts.setPitch(pitch);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('tts_pitch', pitch);
    } catch (e) {
      print('Error setting TTS pitch: $e');
    }
  }

  static Future<void> loadTTSSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      String language = prefs.getString('tts_language') ?? 'en-IN';
      double speechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;
      double pitch = prefs.getDouble('tts_pitch') ?? 1.0;
      
      await _tts.setLanguage(language);
      await _tts.setSpeechRate(speechRate);
      await _tts.setPitch(pitch);
    } catch (e) {
      print('Error loading TTS settings: $e');
    }
  }

  // Test voice notification
  static Future<void> testVoiceNotification() async {
    await speak("This is a test voice notification for the school bus tracking app.");
  }

  // Send custom voice notification (for testing)
  static Future<void> sendTestNotification(String message) async {
    // This would typically be called from your backend
    // For testing, we can simulate a local notification
    RemoteMessage testMessage = RemoteMessage(
      notification: RemoteNotification(
        title: 'School Bus Alert',
        body: message,
      ),
      data: {
        'voice_message': message,
      },
    );
    
    await _handleForegroundMessage(testMessage);
  }
}