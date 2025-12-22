# School Bus Tracking App

A Flutter parent-facing school bus tracking app with real-time location tracking, notifications, and trip history.

## Features

- **Real-time Bus Tracking**: Live GPS tracking with 15-second updates
- **Multiple Children Support**: Track multiple children on different buses
- **Smart Notifications**: 5-minute arrival alerts and departure notifications
- **Trip History**: View past trips and missed bus incidents
- **Offline Support**: 7-day data cache for offline viewing
- **Dark Theme**: Material 3 design with custom dark theme

## Setup Instructions

### 1. Firebase Configuration
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication, Firestore, and Cloud Messaging
3. Download `google-services.json` and place in `android/app/`
4. Download `GoogleService-Info.plist` and place in `ios/Runner/`

### 2. Google Maps Setup
1. Get Google Maps API key from [Google Cloud Console](https://console.cloud.google.com)
2. Enable Maps SDK for Android/iOS and Directions API
3. Replace `YOUR_GOOGLE_MAPS_API_KEY` in:
   - `android/app/src/main/AndroidManifest.xml`
   - `lib/services/eta_service.dart`
   - `lib/config/app_config.dart`

### 3. Dependencies
```bash
flutter pub get
```

### 4. Run the App
```bash
flutter run
```

## Data Structure

The app expects the following Firestore collections:

- `children`: Child profiles with bus route assignments
- `buses`: Real-time bus location and status
- `busStops`: Fixed bus stop locations
- `routes`: Bus route definitions
- `users`: Parent authentication data
- `tripHistory`: Historical trip data

## Architecture

- **State Management**: Provider pattern
- **Backend**: Firebase (Firestore + Cloud Functions)
- **Maps**: Google Maps Flutter
- **Notifications**: Firebase Cloud Messaging
- **Offline**: SharedPreferences caching

## Security

- Firebase Security Rules restrict data access to authorized parents
- Location data is encrypted and access-controlled
- COPPA compliant data handling for children's information
