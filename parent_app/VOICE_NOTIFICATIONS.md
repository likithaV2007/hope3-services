# Voice Notifications Implementation

## Overview
This module converts Firebase Cloud Messaging (FCM) notifications to voice announcements using Text-to-Speech (TTS) technology.

## Features Implemented

### ✅ Step 6: Request Notification Permission
- Automatically requests FCM permissions for alert, badge, and sound
- Implemented in `VoiceNotificationService.initialize()`

### ✅ Step 7: Get FCM Token
- Retrieves and stores FCM token
- Saves token to SharedPreferences and Firestore
- Token is displayed in Voice Settings screen for testing

### ✅ Step 8: Setup Text-to-Speech Engine
- Configures FlutterTts with:
  - Language: "en-IN" (configurable)
  - Speech Rate: 0.5 (adjustable)
  - Pitch: 1.0 (adjustable)
  - Volume: 1.0

### ✅ Step 9: Listen to Firebase Messages
- Listens to `FirebaseMessaging.onMessage` for foreground notifications
- Automatically converts notification body to speech
- Supports custom voice messages via `voice_message` data field

### ✅ Step 10: Send Notifications
- Ready to receive notifications from Firebase Console
- Test functionality available in Voice Settings screen

## Files Created/Modified

### New Files:
1. `lib/services/voice_notification_service.dart` - Main voice notification service
2. `lib/screens/voice_settings_screen.dart` - Settings UI for voice notifications
3. `lib/utils/voice_notification_test.dart` - Test utilities
4. `VOICE_NOTIFICATIONS.md` - This documentation

### Modified Files:
1. `lib/services/notification_service.dart` - Integrated with voice service
2. `lib/screens/settings_screen.dart` - Added voice settings navigation
3. `lib/main.dart` - Added FCM token saving after authentication
4. `pubspec.yaml` - Updated Firebase dependencies and added flutter_tts

## Usage Instructions

### For Testing:
1. Open the app and navigate to Settings → Voice Notifications
2. Enable voice notifications
3. Adjust speech rate and pitch as needed
4. Use "Test Voice Notification" button
5. Use "Test Bus Alert" for realistic scenario
6. Copy FCM token for Firebase Console testing

### For Firebase Console Testing:
1. Go to Firebase Console → Cloud Messaging → Send message
2. Set Title: "School Van Alert"
3. Set Body: "The school van is one kilometer away from your home"
4. Target: Single Device
5. Paste FCM token from the app
6. Send notification

### For Custom Voice Messages:
Send notification with additional data field:
```json
{
  "notification": {
    "title": "School Bus Alert",
    "body": "Bus approaching"
  },
  "data": {
    "voice_message": "The school van is 5 minutes away from your home. Please get ready."
  }
}
```

## Configuration Options

### Voice Settings:
- **Enable/Disable**: Toggle voice notifications on/off
- **Language**: English (India), English (US), Hindi
- **Speech Rate**: 0.1 to 1.0 (adjustable slider)
- **Pitch**: 0.5 to 2.0 (adjustable slider)

### Notification Preferences:
- Settings are saved to SharedPreferences
- Persist across app restarts
- Can be customized per user

## Technical Implementation

### FCM Integration:
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (message.notification?.body != null) {
    VoiceNotificationService.speak(message.notification!.body!);
  }
});
```

### TTS Configuration:
```dart
await _tts.setLanguage("en-IN");
await _tts.setSpeechRate(0.5);
await _tts.setPitch(1.0);
await _tts.speak(text);
```

### Token Management:
```dart
String? token = await FirebaseMessaging.instance.getToken();
// Save to Firestore for backend notifications
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update({'fcmToken': token});
```

## Testing Scenarios

The app includes predefined test messages for:
- **arrival_5min**: 5-minute arrival warning
- **arrival_1km**: 1-kilometer distance alert
- **at_stop**: Bus arrival notification
- **departure**: Departure from school
- **delay**: Traffic delay alert
- **emergency**: Emergency notifications

## Security & Privacy

- FCM tokens are securely stored
- Voice notifications respect user preferences
- No sensitive data in voice messages
- COPPA compliant implementation

## Troubleshooting

### Common Issues:
1. **No voice output**: Check device volume and TTS settings
2. **Token not received**: Ensure Firebase configuration is correct
3. **Notifications not speaking**: Verify voice notifications are enabled

### Debug Information:
- FCM token is displayed in Voice Settings
- Console logs show notification receipt
- Test buttons verify TTS functionality

## Future Enhancements

- Multi-language support expansion
- Custom voice selection
- Quiet hours configuration
- Voice message templates
- Offline TTS caching