import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/notification_service.dart';
import '../utils/notification_test.dart';
import 'voice_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _morningAlert = true;
  bool _eveningAlert = true;
  bool _departureAlert = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final morning = await NotificationService.isMorningAlertEnabled();
    final evening = await NotificationService.isEveningAlertEnabled();
    final departure = await NotificationService.isDepartureAlertEnabled();
    
    setState(() {
      _morningAlert = morning;
      _eveningAlert = evening;
      _departureAlert = departure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('Settings', style: TextStyle(color: AppColors.primary, fontSize: 24,fontWeight: FontWeight.bold)),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection(
            'Notifications',
            [
              _buildNavigationTile(
                'Voice Notifications',
                'Configure text-to-speech settings',
                Icons.volume_up,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoiceSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildNavigationTile(
                'Test Notifications',
                'Test if notifications are working properly',
                Icons.notification_important,
                () async {
                  await NotificationTest.testLocalNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Test notification sent!')),
                  );
                },
              ),
              _buildSwitchTile(
                'Morning Arrival Alert',
                'Get notified 5 minutes before bus arrives in the morning',
                _morningAlert,
                (value) async {
                  await NotificationService.setMorningAlert(value);
                  setState(() => _morningAlert = value);
                },
              ),
              _buildSwitchTile(
                'Evening Arrival Alert',
                'Get notified 5 minutes before bus arrives in the evening',
                _eveningAlert,
                (value) async {
                  await NotificationService.setEveningAlert(value);
                  setState(() => _eveningAlert = value);
                },
              ),
              _buildSwitchTile(
                'Departure Alert',
                'Get notified when bus starts from school',
                _departureAlert,
                (value) async {
                  await NotificationService.setDepartureAlert(value);
                  setState(() => _departureAlert = value);
                },
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          _buildSection(
            'About',
            [
              _buildInfoTile('Version', '1.0.0'),
              _buildInfoTile('School', 'Hope Elementary School'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: AppColors.primary, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.grey, fontSize: 14),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: AppColors.primary, fontSize: 16),
      ),
      trailing: Text(
        value,
        style: TextStyle(color: AppColors.grey, fontSize: 14),
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: TextStyle(color: AppColors.primary, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.grey, fontSize: 14),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 16),
      onTap: onTap,
    );
  }
}