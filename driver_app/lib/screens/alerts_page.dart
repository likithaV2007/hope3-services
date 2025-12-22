import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../models/alert_model.dart';
import 'trip_progress_page.dart';
import 'profile_page.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AlertService alertService = AlertService();
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          final alerts = [
            Alert(
              id: '1',
              title: 'Route Change Alert',
              message: 'Your route has been updated due to traffic conditions. Please check the new route.',
              priority: 'high',
              timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
              isRead: false,
            ),
            Alert(
              id: '2',
              title: 'Student Pickup Reminder',
              message: 'Student pickup at Maple Street in 10 minutes. Please arrive on time.',
              priority: 'medium',
              timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
              isRead: false,
            ),
            Alert(
              id: '3',
              title: 'Weather Advisory',
              message: 'Heavy rain expected. Drive carefully and maintain safe following distance.',
              priority: 'medium',
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              isRead: true,
            ),
            Alert(
              id: '4',
              title: 'Vehicle Maintenance',
              message: 'Your vehicle is due for maintenance check. Please schedule an appointment.',
              priority: 'low',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              isRead: true,
            ),
            Alert(
              id: '5',
              title: 'Emergency Contact Update',
              message: 'Please update your emergency contact information in the profile section.',
              priority: 'low',
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              isRead: false,
            ),
          ];
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: alert.priority == 'high' ? Colors.red : 
                           alert.priority == 'medium' ? Colors.orange : 
                           AppColors.primary,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          alert.priority == 'high' ? Icons.warning : 
                          alert.priority == 'medium' ? Icons.info : 
                          Icons.notifications,
                          color: alert.priority == 'high' ? Colors.red : 
                                 alert.priority == 'medium' ? Colors.orange : 
                                 AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alert.title,
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!alert.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alert.message,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(alert.timestamp),
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return; // Already on alerts
          switch (index) {
            case 0:
              Navigator.popUntil(context, (route) => route.isFirst);
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TripProgressPage(tripId: '')),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }
  
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}