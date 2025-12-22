# FCM Notification Module

A comprehensive Flutter Firebase Cloud Messaging (FCM) notification module that provides easy-to-use notification functionality for your Flutter applications.

## Features

- 🔔 **Push Notifications**: Receive and handle FCM push notifications
- 📱 **Local Notifications**: Show local notifications when app is in foreground
- 🎯 **Topic Subscription**: Subscribe/unsubscribe to notification topics
- 🔧 **Easy Integration**: Simple singleton service for easy usage
- 📋 **Token Management**: Automatic FCM token handling and refresh
- 🎨 **Customizable**: Configurable notification appearance and behavior

## Setup

### 1. Firebase Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Flutter app to the Firebase project
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place the files in their respective platform directories
5. Update `firebase_options.dart` with your Firebase configuration

### 2. Dependencies

The module includes these dependencies:
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  flutter_local_notifications: ^18.0.1
```

### 3. Platform Setup

#### Android
- Permissions are automatically added to AndroidManifest.xml
- No additional setup required

#### iOS
- Add notification capabilities in Xcode
- Configure APNs certificates in Firebase Console

## Usage

### Basic Implementation

```dart
import 'package:fcm_notification_module/fcm_notification_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FCMNotificationService _notificationService = FCMNotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize(
      onMessageReceived: (message) {
        print('Received: ${message.notification?.title}');
      },
      onMessageOpenedApp: (message) {
        print('Opened: ${message.notification?.title}');
        // Handle navigation or actions
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}
```

### Available Methods

#### Initialize Service
```dart
await FCMNotificationService().initialize(
  onMessageReceived: (RemoteMessage message) {
    // Handle foreground messages
  },
  onMessageOpenedApp: (RemoteMessage message) {
    // Handle notification taps
  },
);
```

#### Get FCM Token
```dart
String? token = FCMNotificationService().fcmToken;
// or refresh token
String? newToken = await FCMNotificationService().refreshToken();
```

#### Topic Subscription
```dart
// Subscribe to topic
await FCMNotificationService().subscribeToTopic('news');

// Unsubscribe from topic
await FCMNotificationService().unsubscribeFromTopic('news');
```

#### Local Notifications
```dart
// Show local notification
await FCMNotificationService().showLocalNotification(
  title: 'Local Notification',
  body: 'This is a local notification',
  data: {'key': 'value'},
);

// Clear notifications
await FCMNotificationService().clearAllNotifications();
await FCMNotificationService().clearNotification(notificationId);
```

## Configuration

### Custom Firebase Options

Update `firebase_options.dart` with your project configuration:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-android-api-key',
  appId: 'your-android-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'your-project-id',
  storageBucket: 'your-project-id.appspot.com',
);
```

### Notification Channels (Android)

The module creates a default notification channel. You can customize it by modifying the `AndroidNotificationDetails` in the service.

## Testing

1. Use the demo app to test functionality
2. Send test messages from Firebase Console
3. Use the "Test Local" button to verify local notifications
4. Subscribe to topics and send topic-based messages

## Troubleshooting

### Common Issues

1. **No FCM Token**: Ensure Firebase is properly configured and app has internet permission
2. **Notifications not showing**: Check notification permissions and channel settings
3. **Background notifications**: Verify background message handler is registered

### Debug Mode

The service includes debug prints when `kDebugMode` is true. Check console for detailed logs.

## License

This project is licensed under the MIT License.