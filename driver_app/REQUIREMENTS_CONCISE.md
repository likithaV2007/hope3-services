# Driver App - Requirements Specification

## App Type
School bus driver management system with real-time GPS tracking and route management.

## Core Entities

### User (Driver)
```
- uid: string (Firebase Auth ID)
- email: string
- role: string (driver)
- name: string
- phone: string
- id: int (driver ID)
- schoolId: string
- isOnline: boolean
```

### Trip
```
- id: string
- driverId: string
- state: enum [IDLE, TRIP_MORNING, TRIP_EVENING]
- startTime: DateTime?
- endTime: DateTime?
- gpsPoints: array [{lat, lng, timestamp}]
```

### Route (Daily)
```
- routeId: string
- routeName: string
- stops: array [StopLocation]
- driverId: string
- date: DateTime
```

### StopLocation
```
- name: string
- latitude: double
- longitude: double
```

### Alert
```
- id: string
- title: string
- message: string
- timestamp: DateTime
- priority: string
- isRead: boolean
```

## User Flows

### 1. Authentication Flow
```
START → Google Sign-In → Multiple Accounts? → Select Account → Firebase Auth → Route Details Check → Home
```
- Google OAuth integration
- Multi-account selection support
- Secure token storage

### 2. Daily Route Setup Flow
```
Login → Check Today's Route → Exists? → Use/Update → Not Exists? → Create Route → Add Stops → Save → Home
```
- Mandatory daily route collection
- Google Places autocomplete search
- Map tap to add stops
- Visual stop markers on map
- Edit/remove stops before saving

### 3. Trip Management Flow
```
Home → Select Trip Type (Morning/Evening) → Start Trip → GPS Tracking Active → End Trip → Save Data
```
- Two trip types: Morning and Evening
- Single active trip at a time
- GPS tracking every 3 seconds during trip
- Real-time location updates to Firestore

### 4. Navigation Structure
```
Bottom Nav: [Home, Trip Progress, Alerts, Profile]
```

## Features by Screen

### Sign-In Page
- Google Sign-In button
- Multi-account selection dialog
- Loading states
- Error handling

### Route Details Page
- Check existing route for today
- Option to use existing or update
- Route name input
- Google Places search integration
- Interactive map with markers
- Tap map to add stops
- Stop list with remove option
- Current location button
- Save and continue

### Driver Home Page
- Google Maps view with driver location
- Start Morning Trip button
- Start Evening Trip button
- End Trip button (when active)
- GPS tracking status indicator
- Real-time location marker
- Connectivity banner
- Bottom navigation

### Trip Progress Page
- Active trip details
- GPS tracking visualization
- Trip duration
- Stop information

### Alerts Page
- Alert list with priority
- Read/unread status
- Timestamp display
- Mark as read functionality

### Profile Page
- Driver information display
- School association
- Online status
- Sign out option

## Technical Requirements

### Firebase Services
- **Firestore Collections:**
  - `users` - driver profiles
  - `trips` - trip records with GPS points
  - `daily_routes` - daily route configurations
  - `alerts` - notifications and alerts

- **Authentication:** Firebase Auth + Google Sign-In
- **Cloud Messaging:** Push notifications

### Location Services
- GPS tracking every 3 seconds during active trips
- High accuracy mode
- Background location updates
- Permission handling (location, notification)

### Data Storage
- Flutter Secure Storage for sensitive data
- Local caching for offline support
- Real-time Firestore sync

### Maps Integration
- Google Maps Flutter plugin
- Google Places API for location search
- Marker management
- Camera controls

## Business Rules

1. **Route Management:**
   - One route per driver per day
   - Route must be set before starting trips
   - Can update route same day

2. **Trip Management:**
   - Only one active trip at a time
   - Must end current trip before starting new one
   - GPS points stored only during active trips
   - Trip states: IDLE (no trip), TRIP_MORNING, TRIP_EVENING

3. **GPS Tracking:**
   - Activated only during active trips
   - 3-second interval updates
   - Stored as array in trip document
   - Format: {lat, lng, timestamp}

4. **Authentication:**
   - Google Sign-In required
   - Multi-account support
   - Role must be "driver"
   - School association required

## Key Behaviors

### Connectivity Handling
- Display connectivity banner when offline
- Queue data when offline
- Sync when connection restored
- Visual feedback for connection status

### Error Handling
- User-friendly error messages
- Snackbar notifications
- Loading states for async operations
- Graceful degradation

### Performance
- Efficient GPS tracking
- Optimized map rendering
- Minimal battery drain
- Background processing for location

## Dependencies
```yaml
firebase_core: ^3.8.0
firebase_auth: ^5.3.3
google_sign_in: ^6.2.2
cloud_firestore: ^5.5.0
flutter_secure_storage: ^9.2.2
geolocator: ^10.1.1
permission_handler: ^11.3.1
firebase_messaging: ^15.1.4
flutter_local_notifications: ^17.2.3
google_maps_flutter: ^2.9.0
google_places_flutter: (for autocomplete)
```

## API Keys Required
- Google Maps API key
- Google Places API key
- Firebase configuration (google-services.json)

## Platform Support
- Android (primary)
- iOS (primary)
- Web, Windows, macOS, Linux (configured but not primary)

---
**Version:** 1.0 | **Format:** AI-Optimized Specification