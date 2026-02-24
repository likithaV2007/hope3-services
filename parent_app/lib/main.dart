import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'screens/sign_in_screen.dart';
import 'screens/unauthorized_screen.dart';
import 'screens/main_navigation.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/voice_notification_service.dart';
import 'models/user_model.dart';
import 'providers/tracking_provider.dart';

// Background message handler - MUST be top-level function
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  // Call the voice notification background handler
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  
  // Initialize voice notifications
  await VoiceNotificationService.initialize();
  await NotificationService.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
      ],
      child: MaterialApp(
        title: 'School Bus Tracker',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.black,
          ),
          scaffoldBackgroundColor: AppColors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.black,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            color: AppColors.cardBackground,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: AppColors.black),
            bodyMedium: TextStyle(color: AppColors.black),
            titleLarge: TextStyle(color: AppColors.black),
            titleMedium: TextStyle(color: AppColors.black),
            headlineLarge: TextStyle(color: AppColors.black),
            headlineMedium: TextStyle(color: AppColors.black),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        home: TestButton(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }
        
        if (snapshot.hasData) {
          return FutureBuilder<UserModel?>(
            future: AuthService().getUserRole(snapshot.data!.email!),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: AppColors.white,
                  body: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              
              if (userSnapshot.hasError) {
                print('Error loading user data: ${userSnapshot.error}');
                return UnauthorizedScreen();
              }
              
              if (userSnapshot.hasData) {
                final user = userSnapshot.data!;
                print('User role: ${user.role}');
                if (user.role == 'parent') {
                  // Save FCM token for this user
                  NotificationService.saveFCMTokenForUser(user.uid);
                  return MainNavigation(parentId: user.uid);
                }
              }
              
              return UnauthorizedScreen();
            },
          );
        }
        
        return SignInScreen();
      },
    );
  }
}

// Test button to bypass authentication
class TestButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Access')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainNavigation(parentId: 'test_user'),
              ),
            );
          },
          child: Text('Enter App (Test Mode)'),
        ),
      ),
    );
  }
}