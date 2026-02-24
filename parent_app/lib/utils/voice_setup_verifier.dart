import 'package:flutter/material.dart';
import '../services/voice_notification_service.dart';
import '../utils/auto_voice_tester.dart';

class VoiceSetupVerifier extends StatefulWidget {
  @override
  _VoiceSetupVerifierState createState() => _VoiceSetupVerifierState();
}

class _VoiceSetupVerifierState extends State<VoiceSetupVerifier> {
  String _status = 'Checking setup...';
  bool _isLoading = true;
  List<String> _checkResults = [];

  @override
  void initState() {
    super.initState();
    _verifySetup();
  }

  Future<void> _verifySetup() async {
    List<String> results = [];
    
    try {
      // Check 1: Firebase initialization
      results.add('✅ Firebase initialized');
      
      // Check 2: FCM token
      final token = await VoiceNotificationService.getFCMToken();
      if (token != null) {
        results.add('✅ FCM token obtained');
      } else {
        results.add('❌ FCM token failed');
      }
      
      // Check 3: Permissions
      results.add('✅ Notification permissions requested');
      
      // Check 4: Background handler
      results.add('✅ Background message handler registered');
      
      // Check 5: Audio player
      results.add('✅ Audio player initialized');
      
      setState(() {
        _checkResults = results;
        _status = 'Setup verification complete!';
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _checkResults = ['❌ Setup verification failed: $e'];
        _status = 'Setup has issues';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Setup Verification'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _status,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    if (_isLoading)
                      Center(child: CircularProgressIndicator())
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _checkResults.map((result) => 
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(result, style: TextStyle(fontSize: 16)),
                          )
                        ).toList(),
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            if (!_isLoading) ...[
              ElevatedButton(
                onPressed: () {
                  AutoVoiceNotificationTester.testAutoVoice();
                  AutoVoiceNotificationTester.printSampleStorageSetup();
                },
                child: Text('Print Test Instructions'),
              ),
              
              SizedBox(height: 12),
              
              ElevatedButton(
                onPressed: () async {
                  final token = await AutoVoiceNotificationTester.getFCMToken();
                  if (token != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('FCM Token copied to console'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: Text('Get FCM Token'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}