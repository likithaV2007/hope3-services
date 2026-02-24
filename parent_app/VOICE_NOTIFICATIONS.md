# Voice Notifications Implementation

This implementation provides voice notifications that work across all three Flutter app states:

## App States Supported

### 1. Foreground State ✅
- **Full TTS Support**: Uses `flutter_tts` for immediate voice playback
- **Real-time Processing**: Instant voice notifications when app is active
- **Custom Voice Settings**: Configurable speech rate, pitch, and language

### 2. Background State ✅
- **Local Notifications**: Shows notification with voice action button
- **Isolate Communication**: Attempts to communicate with foreground isolate
- **Background Handler**: `_firebaseMessagingBackgroundHandler` processes voice messages

### 3. Terminated State ✅
- **FCM Push Notifications**: Firebase delivers notifications to system
- **Local Notification Actions**: Tap notification to hear voice message
- **System Integration**: Uses Android/iOS notification system

## Implementation Details

### Core Components

1. **VoiceNotificationService** (`lib/services/voice_notification_service.dart`)
   - Handles TTS configuration and playback
   - Manages FCM token registration
   - Processes voice messages in all app states
   - Provides isolate communication for background voice

2. **Enhanced Background Handler** (`lib/main.dart`)
   - Processes voice notifications when app is backgrounded/terminated
   - Calls `VoiceNotificationService.handleBackgroundMessage()`

3. **Test Screen** (`lib/screens/voice_notification_test_screen.dart`)
   - Test voice notifications in all states
   - Configure voice settings
   - Send test notifications

### Key Methods

```dart
// Speak text in foreground
await VoiceNotificationService.speak("Your message");

// Enhanced speak that works in all states
await VoiceNotificationService.speakInAllStates("Your message");

// Handle background/terminated messages
await VoiceNotificationService.handleBackgroundMessage(message);
```

### Firebase Cloud Messaging Setup

Voice notifications require specific FCM payload structure:

```json
{
  "notification": {
    "title": "School Bus Alert",
    "body": "Bus arriving in 5 minutes"
  },
  "data": {
    "messageType": "audio",
    "voice_message": "Attention! Your child's bus will arrive in 5 minutes. Please be ready at the bus stop."
  }
}
```

### Android Configuration

1. **Permissions** (AndroidManifest.xml):
   ```xml
   <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
   <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
   ```

2. **Notification Channel**: 
   - Channel ID: `voice_notifications`
   - Importance: High
   - Sound: Enabled

3. **Drawable Resource**: 
   - `ic_volume_up.xml` for voice notification icon

### iOS Configuration

1. **Info.plist** additions needed:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>background-processing</string>
       <string>remote-notification</string>
   </array>
   ```

## Testing Voice Notifications

### Test All States:

1. **Foreground Test**:
   - Open app → Settings → Test Voice Notifications
   - Tap "Test Foreground Voice"
   - Should hear immediate TTS

2. **Background Test**:
   - Send test notification via app
   - Minimize app (don't close)
   - Should receive notification with voice capability

3. **Terminated Test**:
   - Close app completely
   - Send notification from Firebase Console or backend
   - Should receive system notification
   - Tap notification to hear voice message

### Firebase Console Test Message:

```json
{
  "to": "USER_FCM_TOKEN",
  "notification": {
    "title": "Test Voice Alert",
    "body": "This is a test voice notification"
  },
  "data": {
    "messageType": "audio",
    "voice_message": "This is a test voice notification for the school bus tracking app. Your child's bus is arriving soon."
  }
}
```

## Troubleshooting

### Common Issues:

1. **No Voice in Background/Terminated**:
   - Check device volume settings
   - Verify notification permissions
   - Ensure Do Not Disturb is off

2. **TTS Not Working**:
   - Check device TTS settings
   - Verify language pack installed
   - Test with different speech rates

3. **FCM Token Issues**:
   - Check Firebase project configuration
   - Verify google-services.json/GoogleService-Info.plist
   - Check Firestore security rules

### Debug Commands:

```bash
# Check FCM token
flutter logs | grep "FCM TOKEN"

# Check TTS status
flutter logs | grep "TTS"

# Check notification permissions
flutter logs | grep "permission"
```

## Production Deployment

1. **Firebase Functions**: Deploy `firebase_functions/voice_notifications.js`
2. **Firestore Rules**: Ensure proper security rules for FCM tokens
3. **Testing**: Test on physical devices (voice doesn't work on simulators)
4. **Monitoring**: Monitor FCM delivery reports and TTS errors

## Dependencies Required

```yaml
dependencies:
  firebase_messaging: ^15.0.0
  flutter_tts: ^3.8.0
  flutter_local_notifications: ^17.2.3
  permission_handler: ^11.3.1
  shared_preferences: ^2.3.3
```

The voice notification system is now fully implemented and ready for production use across all app states.