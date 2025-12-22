# School Bus Tracking App - Complete Requirements Prompt

Build a Flutter parent-facing school bus tracking app with the following specifications:

## Core Features

### 1. Child Management
- **Multiple Children Support**: Parents can have multiple children on different buses
- **Admin-Managed**: School administrators add/manage children, parents have view-only access
- **Child Information Display**: Name, grade, photo, bus route, pickup/drop stops, emergency contacts
- **Child Selection**: Allow parents to select and focus on specific child for tracking

### 2. Live Bus Tracking
- **Map Provider**: Google Maps integration
- **Real-time Updates**: Bus location updates every 15 seconds when active
- **Route Display**: Show full bus route with all stops + current bus location
- **Bus Information**: Display driver name, bus number, current speed
- **ETA Calculation**: Real-time ETA to child's stop using Google Maps API with traffic data
- **Offline Handling**: Show last known location with "Connection Lost" indicator

### 3. Push Notifications
- **Service**: Firebase Cloud Messaging
- **Morning Alert**: "Bus will arrive in 5 mins" notification
- **Evening Alert**: "Bus will arrive in 5 mins" notification  
- **Departure Alert**: "Bus started from school" notification
- **Configurable**: Parents can enable/disable each notification type
- **Smart Timing**: Use real-time location + traffic for accurate timing

### 4. Trip History (Optional)
- **Duration**: Current school year data (September to June)
- **Missed Bus Tracking**: Log when child not at stop or bus >10 mins late
- **Format**: Text summaries with basic route info (no maps for performance)
- **Historical Data**: View previous tracking sessions

## Technical Architecture

### Backend & Data
- **Backend**: Firebase (Firestore + Cloud Functions)
- **Authentication**: Firebase Auth with phone/email login
- **Real-time Data**: Firestore real-time listeners for live tracking
- **Offline Support**: Cache last 7 days of data, show cached info when offline

### Platform & Design
- **Target Platforms**: Cross-platform (iOS + Android)
- **Design System**: Material 3 with dark theme
- **Color Scheme**: Use existing dark theme colors (darkBackground: #1A1B2E, cardBackground: #2D3748, primaryBlue: #4299E1)
- **Performance**: Optimized for real-time updates and battery efficiency

### Data Models Required
```dart
// Child: id, name, grade, photoUrl, busRouteId, pickupStopId, dropStopId, parentId
// Bus: id, number, driverName, driverPhone, routeId, latitude, longitude, speed, lastUpdate, isActive  
// BusStop: id, name, latitude, longitude, address, sequence, routeId
// Parent: id, name, email, phone, children[]
// Route: id, name, schoolId, stops[], activeHours
```

### Business Logic
- **Bus Stops**: Fixed stops per route, managed by school admin
- **School Calendar**: Integration to show "No Service Today" during holidays
- **Multi-tenant**: Single school per app instance
- **Update Frequency**: 15-second intervals for active buses only
- **Geofencing**: Trigger notifications when bus approaches stops

## Key User Flows

1. **Parent Login** → View Children List → Select Child → See Live Bus Location
2. **Morning Routine**: Receive notification → Open app → Check ETA → Track bus arrival
3. **Evening Pickup**: Get departure notification → Track bus from school → Receive arrival alert
4. **History Review**: Access trip history → View missed bus incidents → Check patterns

## Performance Requirements
- **Battery Optimization**: Efficient location tracking, pause updates when app backgrounded
- **Network Efficiency**: Minimal data usage, compress location updates
- **Offline Resilience**: 7-day cache, graceful degradation without internet
- **Real-time Responsiveness**: <2 second update latency for critical notifications

## Security & Privacy
- **Data Protection**: Encrypt sensitive child information
- **Location Privacy**: Only show bus location to authorized parents
- **Authentication**: Secure parent verification through school system
- **COPPA Compliance**: Protect children's data according to regulations

Build this as a production-ready Flutter app with clean architecture, proper error handling, and comprehensive testing.