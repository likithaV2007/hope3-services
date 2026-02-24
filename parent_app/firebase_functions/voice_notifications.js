const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Send voice notification with Firebase Storage MP3
exports.sendVoiceNotification = functions.https.onCall(async (data, context) => {
  try {
    const { fcmToken, audioUrl, message } = data;
    
    if (!fcmToken || !audioUrl) {
      throw new functions.https.HttpsError('invalid-argument', 'FCM token and audio URL are required');
    }

    // FCM message with data payload (no notification payload)
    const fcmMessage = {
      token: fcmToken,
      data: {
        type: 'voice',
        audio_url: audioUrl,
        message: message || 'Voice notification'
      }
    };

    const response = await admin.messaging().send(fcmMessage);
    console.log('Voice notification sent successfully:', response);
    
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending voice notification:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send voice notification');
  }
});

// Send voice notification to multiple devices
exports.sendVoiceNotificationToMultiple = functions.https.onCall(async (data, context) => {
  try {
    const { fcmTokens, audioUrl, message } = data;
    
    if (!fcmTokens || !Array.isArray(fcmTokens) || !audioUrl) {
      throw new functions.https.HttpsError('invalid-argument', 'FCM tokens array and audio URL are required');
    }

    const messages = fcmTokens.map(token => ({
      token: token,
      data: {
        type: 'voice',
        audio_url: audioUrl,
        message: message || 'Voice notification'
      }
    }));

    const response = await admin.messaging().sendAll(messages);
    console.log(`Voice notifications sent: ${response.successCount}/${messages.length}`);
    
    return { 
      success: true, 
      successCount: response.successCount,
      failureCount: response.failureCount 
    };
  } catch (error) {
    console.error('Error sending voice notifications:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send voice notifications');
  }
});

// Trigger voice notification for bus arrival (example)
exports.sendBusArrivalVoice = functions.firestore
  .document('buses/{busId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const previousData = change.before.data();
    
    // Check if bus is approaching a stop
    if (newData.status === 'approaching' && previousData.status !== 'approaching') {
      try {
        // Get parent FCM tokens for this bus route
        const parentsSnapshot = await admin.firestore()
          .collection('children')
          .where('busId', '==', context.params.busId)
          .get();
        
        const fcmTokens = [];
        for (const doc of parentsSnapshot.docs) {
          const childData = doc.data();
          const parentDoc = await admin.firestore()
            .collection('users')
            .doc(childData.parentId)
            .get();
          
          if (parentDoc.exists && parentDoc.data().fcmToken) {
            fcmTokens.push(parentDoc.data().fcmToken);
          }
        }
        
        if (fcmTokens.length > 0) {
          // Use pre-uploaded voice message from Firebase Storage
          const audioUrl = 'https://firebasestorage.googleapis.com/v0/b/your-project.appspot.com/o/voice_notifications%2Fbus_arriving.mp3?alt=media';
          
          const messages = fcmTokens.map(token => ({
            token: token,
            data: {
              type: 'voice',
              audio_url: audioUrl,
              message: `Bus ${newData.busNumber} is arriving at your stop in 5 minutes`
            }
          }));

          const response = await admin.messaging().sendAll(messages);
          console.log(`Bus arrival voice notifications sent: ${response.successCount}/${messages.length}`);
        }
      } catch (error) {
        console.error('Error sending bus arrival voice notification:', error);
      }
    }
  });

// Test function to send voice notification
exports.testVoiceNotification = functions.https.onRequest(async (req, res) => {
  try {
    const { fcmToken } = req.body;
    
    if (!fcmToken) {
      return res.status(400).json({ error: 'FCM token is required' });
    }

    // Test with sample Firebase Storage audio
    const audioUrl = 'https://firebasestorage.googleapis.com/v0/b/your-project.appspot.com/o/voice_notifications%2Ftest.mp3?alt=media';
    
    const fcmMessage = {
      token: fcmToken,
      data: {
        type: 'voice',
        audio_url: audioUrl,
        message: 'This is a test voice notification'
      }
    };

    const response = await admin.messaging().send(fcmMessage);
    
    res.json({ 
      success: true, 
      messageId: response,
      audioUrl: audioUrl 
    });
  } catch (error) {
    console.error('Test voice notification error:', error);
    res.status(500).json({ error: 'Failed to send test notification' });
  }
});