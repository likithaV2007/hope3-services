import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/voice_notification_service.dart';

class VoiceTestScreen extends StatefulWidget {
  @override
  _VoiceTestScreenState createState() => _VoiceTestScreenState();
}

class _VoiceTestScreenState extends State<VoiceTestScreen> {
  String? _fcmToken;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    setState(() => _isLoading = true);
    final token = await VoiceNotificationService.getFCMToken();
    setState(() {
      _fcmToken = token;
      _isLoading = false;
    });
  }

  void _copyToken() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FCM Token copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Notification Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FCM Token Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FCM Token',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    if (_isLoading)
                      CircularProgressIndicator()
                    else if (_fcmToken != null) ...[
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _fcmToken!,
                          style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _copyToken,
                        icon: Icon(Icons.copy),
                        label: Text('Copy Token'),
                      ),
                    ] else
                      Text('Failed to get FCM token'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Test Instructions
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Instructions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    _buildTestStep('1', 'Upload MP3 to Firebase Storage'),
                    _buildTestStep('2', 'Copy the download URL'),
                    _buildTestStep('3', 'Send FCM message with audio_url'),
                    _buildTestStep('4', 'Test in different app states'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Sample FCM Message
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample FCM Message',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '''{\n  \"to\": \"YOUR_FCM_TOKEN\",\n  \"data\": {\n    \"type\": \"voice\",\n    \"audio_url\": \"https://firebasestorage.googleapis.com/v0/b/your-project.appspot.com/o/voice_notifications%2Fwelcome.mp3?alt=media\"\n  }\n}''',
                        style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Test States
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test These App States',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    _buildTestState('✅ Foreground', 'App is open and visible'),
                    _buildTestState('✅ Background', 'App is minimized'),
                    _buildTestState('✅ Screen Locked', 'Device screen is off'),
                    _buildTestState('⚠️ Terminated', 'App was force-closed (Android only)'),
                    _buildTestState('❌ iOS Background', 'iOS blocks background audio'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestStep(String number, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }

  Widget _buildTestState(String status, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }
}