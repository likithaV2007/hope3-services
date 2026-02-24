const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Send voice notification
async function sendVoiceNotification(fcmToken) {
  try {
    const message = {
      token: fcmToken,
      data: {
        type: 'voice',
        audio_url: 'https://firebasestorage.googleapis.com/v0/b/school-bus-tracking-fbf78.firebasestorage.app/o/voice_notifications%2Farrive.mpeg?alt=media&token=66d36b9f-55de-4eda-850e-94a6becd764d'
      }
    };

    const response = await admin.messaging().send(message);
    console.log('✅ Voice notification sent:', response);
    return response;
  } catch (error) {
    console.error('❌ Error sending notification:', error);
    throw error;
  }
}

// Example usage
const FCM_TOKEN = 'cgsza9XbTICdnJw46OfLqM:APA91bGtc-2eXdTmTa9j31NFgs1T8_MHuzRY_K_1ojMdfxHIOEBDxuxJhk3CvgDG_1cflkb2VWBcz1bN8FbiT4evNRui8zk--4KqVFBf7iYtJ0i1wZbmTwQ';

sendVoiceNotification(FCM_TOKEN);