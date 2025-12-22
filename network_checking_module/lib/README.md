# Network Checking Module

A reusable Flutter module for checking network connectivity and internet access.

## Features

- Real-time network status monitoring
- Internet connectivity validation
- Easy-to-use widgets and utilities
- Cross-platform support

## Usage

### Basic Network Checking

```dart
import 'package:network_checking_module/network_checking_module.dart';

// Initialize the network checker
final networkChecker = NetworkChecker();
await networkChecker.initialize();

// Check current connection status
bool isConnected = await networkChecker.isConnected();

// Listen to network status changes
networkChecker.statusStream.listen((status) {
  print('Network status: $status');
});
```

### Using NetworkStatusWidget

```dart
NetworkStatusWidget(
  child: YourMainWidget(),
  showBanner: true, // Shows red banner when offline
)
```

### Using NetworkUtils

```dart
// Execute code only when connected
NetworkUtils.executeWithNetworkCheck(
  () => performNetworkOperation(),
  onDisconnected: () => NetworkUtils.showNetworkSnackBar(context),
);

// Wait for connection
await NetworkUtils.waitForConnection();
```

## Installation

Add to your pubspec.yaml:

```yaml
dependencies:
  connectivity_plus: ^6.0.5
  http: ^1.2.2
```

Then copy the network checking module files to your project.