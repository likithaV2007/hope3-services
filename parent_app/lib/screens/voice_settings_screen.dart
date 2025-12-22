import 'package:flutter/material.dart';
import '../services/voice_notification_service.dart';
import '../constants/app_colors.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({Key? key}) : super(key: key);

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  bool _voiceNotificationsEnabled = true;
  double _speechRate = 0.5;
  double _pitch = 1.0;
  String _selectedLanguage = 'en-IN';

  final List<Map<String, String>> _languages = [
    {'code': 'en-IN', 'name': 'English (India)'},
    {'code': 'en-US', 'name': 'English (US)'},
    {'code': 'hi-IN', 'name': 'Hindi'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await VoiceNotificationService.isVoiceNotificationEnabled();
    setState(() {
      _voiceNotificationsEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Notifications'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Notifications',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Enable Voice Notifications'),
                      subtitle: const Text('Convert notifications to speech'),
                      value: _voiceNotificationsEnabled,
                      onChanged: (value) async {
                        setState(() {
                          _voiceNotificationsEnabled = value;
                        });
                        await VoiceNotificationService.setVoiceNotificationEnabled(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_voiceNotificationsEnabled) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Language Selection
                      Text(
                        'Language',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _languages.map((lang) {
                          return DropdownMenuItem(
                            value: lang['code'],
                            child: Text(lang['name']!),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            setState(() {
                              _selectedLanguage = value;
                            });
                            await VoiceNotificationService.setTTSLanguage(value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Speech Rate
                      Text(
                        'Speech Rate: ${_speechRate.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        value: _speechRate,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        onChanged: (value) {
                          setState(() {
                            _speechRate = value;
                          });
                        },
                        onChangeEnd: (value) async {
                          await VoiceNotificationService.setTTSSpeechRate(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Pitch
                      Text(
                        'Pitch: ${_pitch.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        value: _pitch,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        onChanged: (value) {
                          setState(() {
                            _pitch = value;
                          });
                        },
                        onChangeEnd: (value) async {
                          await VoiceNotificationService.setTTSPitch(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Test Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await VoiceNotificationService.testVoiceNotification();
                  },
                  child: const Text('Test Voice Notification'),
                ),
              ),
              const SizedBox(height: 8),
              
              // Test Custom Message
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await VoiceNotificationService.sendTestNotification(
                      'The school van is one kilometer away from your home'
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                  ),
                  child: const Text('Test Bus Alert'),
                ),
              ),
            ],
            const SizedBox(height: 24),
            
            // FCM Token Display (for testing)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FCM Token (for testing)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<String?>(
                      future: VoiceNotificationService.getFCMToken(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SelectableText(
                            snapshot.data!,
                            style: const TextStyle(fontSize: 12),
                          );
                        }
                        return const Text('Loading token...');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}