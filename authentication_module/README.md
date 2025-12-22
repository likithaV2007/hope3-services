# Universal Authentication Module

A reusable Flutter authentication module with Firebase integration.

## Features

✅ **Email & Password Authentication**
- Sign up with email/password
- Sign in with email/password
- Password reset via email

✅ **Google Sign-In**
- One-tap Google authentication

✅ **Phone Number Authentication**
- OTP-based phone verification

✅ **Session Management**
- Auto-login with persistent sessions
- Secure logout

✅ **State Management**
- Riverpod-based reactive state
- Loading states and error handling

## Quick Setup

### 1. Add Dependencies
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  google_sign_in: ^6.2.1
  flutter_riverpod: ^2.6.1
  shared_preferences: ^2.3.2
```

### 2. Firebase Configuration
- Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Initialize Firebase in `main()`

### 3. Usage
```dart
import 'auth/auth_module.dart';

// Wrap your app
AuthWrapper(
  authenticatedWidget: HomeScreen(),
  unauthenticatedWidget: LoginScreen(),
)

// Use authentication
final authNotifier = ref.read(authStateProvider.notifier);
await authNotifier.signInWithEmail(email, password);
```

## Module Structure
```
lib/auth/
├── models/
│   ├── auth_user.dart      # User model
│   └── auth_state.dart     # State model
├── services/
│   └── auth_service.dart   # Core auth logic
├── providers/
│   └── auth_provider.dart  # Riverpod providers
├── widgets/
│   ├── auth_wrapper.dart   # Conditional rendering
│   └── login_form.dart     # Login UI
└── auth_module.dart        # Module exports
```

## API Reference

### AuthService
- `signUpWithEmail(email, password)`
- `signInWithEmail(email, password)`
- `signInWithGoogle()`
- `signInWithPhone(phoneNumber, onCodeSent)`
- `verifyOTP(verificationId, smsCode)`
- `sendPasswordResetEmail(email)`
- `signOut()`

### AuthState
- `status`: AuthStatus enum
- `user`: AuthUser model
- `error`: Error message

Ready to plug into any Flutter app!