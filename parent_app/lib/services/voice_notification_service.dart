import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_core/firebase_core.dart';

class VoiceNotificationService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Initialize voice notifications
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }
  
  // Handle foreground voice messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message: ${message.data}');
    
    if (message.data['type'] == 'voice' && message.data['audio_url'] != null) {
      await _playVoiceMessage(message.data['audio_url']);
    }
  }
  
  // Play voice message from URL
  static Future<void> _playVoiceMessage(String audioUrl) async {
    try {
      print('Playing audio from: $audioUrl');
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }
  
  // Get FCM token for testing
  static Future<String?> getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }
}

// CRITICAL: Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  print('Background message: ${message.data}');
  
  if (message.data['type'] == 'voice' && message.data['audio_url'] != null) {
    try {
      final player = AudioPlayer();
      await player.setUrl(message.data['audio_url']);
      await player.play();
      print('Background audio played successfully');
    } catch (e) {
      print('Background audio error: $e');
    }
  }
}