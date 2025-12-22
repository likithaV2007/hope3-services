import '../services/voice_notification_service.dart';

class VoiceNotificationTest {
  // Test messages for different scenarios
  static const Map<String, String> testMessages = {
    'arrival_5min': 'The school van is 5 minutes away from your home. Please get ready.',
    'arrival_1km': 'The school van is one kilometer away from your home.',
    'at_stop': 'The school van has arrived at your bus stop.',
    'departure': 'The school van has departed from school and is on its way.',
    'delay': 'The school van is running 10 minutes late due to traffic.',
    'emergency': 'Emergency alert: Please contact the school immediately.',
  };

  // Send test notification for different scenarios
  static Future<void> sendTestNotification(String scenario) async {
    if (testMessages.containsKey(scenario)) {
      await VoiceNotificationService.sendTestNotification(
        testMessages[scenario]!
      );
    }
  }

  // Test all scenarios
  static Future<void> testAllScenarios() async {
    for (String scenario in testMessages.keys) {
      print('Testing scenario: $scenario');
      await sendTestNotification(scenario);
      await Future.delayed(Duration(seconds: 3)); // Wait between tests
    }
  }

  // Quick test for basic functionality
  static Future<void> quickTest() async {
    await VoiceNotificationService.testVoiceNotification();
  }

  // Test with custom message
  static Future<void> testCustomMessage(String message) async {
    await VoiceNotificationService.sendTestNotification(message);
  }
}