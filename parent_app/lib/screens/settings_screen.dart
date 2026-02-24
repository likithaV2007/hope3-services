import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/app_colors.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _morningAlerts = true;
  bool _eveningAlerts = true;
  bool _departureAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _morningAlerts = true;
      _eveningAlerts = true;
      _departureAlerts = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications, color: AppColors.primary),
                  title: Text('Test Notification'),
                  subtitle: Text('Send a test notification'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    FlutterTts tts = FlutterTts();
                    await tts.setLanguage("en-US");
                    await tts.speak("Test voice notification - Bus arriving in 5 minutes");
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Notification Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: Text('Morning Alerts'),
                  subtitle: Text('Get notified about morning bus schedules'),
                  value: _morningAlerts,
                  onChanged: (value) async {
                    setState(() => _morningAlerts = value);
                  },
                ),
                SwitchListTile(
                  title: Text('Evening Alerts'),
                  subtitle: Text('Get notified about evening bus schedules'),
                  value: _eveningAlerts,
                  onChanged: (value) async {
                    setState(() => _eveningAlerts = value);
                  },
                ),
                SwitchListTile(
                  title: Text('Departure Alerts'),
                  subtitle: Text('Get notified when bus is departing'),
                  value: _departureAlerts,
                  onChanged: (value) async {
                    setState(() => _departureAlerts = value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}