import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/voice_notification_service.dart';

class AutoVoiceNotificationTester {
  
  // Test automatic voice notification with Firebase Storage MP3
  static Future<void> testAutoVoice() async {
    print('🎯 Testing Firebase Storage Voice Notifications...');
    
    // Get FCM token
    final token = await VoiceNotificationService.getFCMToken();
    if (token == null) {
      print('❌ Failed to get FCM token');
      return;
    }
    
    // Sample FCM message for Firebase Storage audio
    final testMessage = {
      "to": token,
      "data": {
        "type": "voice",
        "audio_url": "https://firebasestorage.googleapis.com/v0/b/your-project.appspot.com/o/voice_notifications%2Fwelcome.mp3?alt=media"
      }
    };
    
    print('\n📤 Send this FCM message:');
    print('POST https://fcm.googleapis.com/fcm/send');
    print('Headers:');
    print('  Content-Type: application/json');
    print('  Authorization: key=YOUR_SERVER_KEY');
    print('\nBody:');
    print(testMessage.toString());
    
    print('\n🧪 Expected Results:');
    print('✅ App Open: Audio plays immediately');
    print('✅ App Background: Audio plays automatically');
    print('✅ Screen Locked: Audio plays automatically');
    print('⚠️ App Terminated: May work on Android');
    print('❌ iOS Background: Blocked by Apple');
    
    print('\n🔧 Setup Steps:');
    print('1. Upload MP3 to Firebase Storage: voice_notifications/welcome.mp3');
    print('2. Make storage publicly readable (for testing)');
    print('3. Copy the download URL');
    print('4. Replace audio_url in the FCM message above');
    print('5. Send FCM message using your server key');
  }
  
  // Get FCM token for testing
  static Future<String?> getFCMToken() async {
    return await VoiceNotificationService.getFCMToken();
  }
  
  // Test with sample Firebase Storage URL
  static void printSampleStorageSetup() {
    print('\n🔥 Firebase Storage Setup:');
    print('1. Go to Firebase Console > Storage');
    print('2. Create folder: voice_notifications/');
    print('3. Upload: welcome.mp3');
    print('4. Set rules (for testing):');
    print('   rules_version = "2";');
    print('   service firebase.storage {');
    print('     match /b/{bucket}/o {');
    print('       match /{allPaths=**} {');
    print('         allow read;');
    print('       }');
    print('     }');
    print('   }');
    print('5. Copy download URL from uploaded file');
  }
}