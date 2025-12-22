import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'services/fcm_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Notification Tester',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const NotificationDemo(),
    );
  }
}

class NotificationDemo extends StatefulWidget {
  const NotificationDemo({super.key});

  @override
  State<NotificationDemo> createState() => _NotificationDemoState();
}

class _NotificationDemoState extends State<NotificationDemo> {
  final FCMNotificationService _notificationService = FCMNotificationService();
  String _fcmToken = 'Loading...';
  List<Map<String, dynamic>> _messages = [];
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize(
      onMessageReceived: (message) {
        setState(() {
          _messages.insert(0, {
            'title': message.notification?.title ?? 'No title',
            'body': message.notification?.body ?? 'No body',
            'time': DateTime.now(),
            'type': 'received'
          });
        });
      },
      onMessageOpenedApp: (message) {
        setState(() {
          _messages.insert(0, {
            'title': message.notification?.title ?? 'No title',
            'body': message.notification?.body ?? 'No body',
            'time': DateTime.now(),
            'type': 'opened'
          });
        });
      },
    );
    
    setState(() {
      _fcmToken = _notificationService.fcmToken ?? 'Failed to get token';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('FCM Notification Tester', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTokenCard(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildMessagesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.token, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('FCM Token', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                _fcmToken,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Test Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _notificationService.showLocalNotification(
                      title: 'Test Notification',
                      body: 'This is a local test notification at ${DateTime.now().toString().substring(11, 19)}',
                    ),
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Test Local'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_isSubscribed) {
                        await _notificationService.unsubscribeFromTopic('test_topic');
                        setState(() => _isSubscribed = false);
                      } else {
                        await _notificationService.subscribeToTopic('test_topic');
                        setState(() => _isSubscribed = true);
                      }
                    },
                    icon: Icon(_isSubscribed ? Icons.notifications_off : Icons.notifications_on),
                    label: Text(_isSubscribed ? 'Unsubscribe' : 'Subscribe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSubscribed ? Colors.orange : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _messages.clear());
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Messages'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.message, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('Messages (${_messages.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text('No messages yet', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message['type'] == 'received' ? Colors.blue[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: message['type'] == 'received' ? Colors.blue[200]! : Colors.green[200]!,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    message['type'] == 'received' ? Icons.notifications : Icons.touch_app,
                                    size: 16,
                                    color: message['type'] == 'received' ? Colors.blue : Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    message['type'] == 'received' ? 'Received' : 'Opened',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: message['type'] == 'received' ? Colors.blue : Colors.green,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${message['time'].hour.toString().padLeft(2, '0')}:${message['time'].minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                message['body'],
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}