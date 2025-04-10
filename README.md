# Air Curtain Management System

A Flutter application for monitoring and controlling air curtains via ESP32 devices. This system enables real-time tracking of temperature data, device status, and remote management capabilities.

## Overview

This application provides a comprehensive management interface for air curtains equipped with ESP32 controllers. The system follows a client-server architecture where ESP32 devices collect sensor data, transmit it to a backend server, and the Flutter app retrieves and displays this information to users.

## Features

- **Role-based Access Control**: Separate interfaces for administrators and clients
- **Real-time Monitoring**: Track indoor/outdoor temperature, power usage, RPM, and device status
- **Remote Control**: Turn devices on/off remotely
- **Device Management**: Add, update, and remove devices
- **User Management**: Add and remove client accounts (admin only)
- **Error Logging**: Built-in error tracking and debugging tools

## System Architecture

```
┌─────────┐    HTTP    ┌──────────┐    HTTP    ┌───────────────┐
│  ESP32  │ ─────────> │ Backend  │ <───────── │ Flutter App   │
│ Devices │            │  Server  │            │ (Admin/Client)│
└─────────┘            └──────────┘            └───────────────┘
```

- **Frontend**: Flutter mobile application
- **Backend**: RESTful API hosted at "mitzvah-software-for-smart-air-curtain.onrender.com"
- **IoT Devices**: ESP32 controllers connected to air curtains

## Monitored Parameters

- Indoor Temperature
- Outdoor Temperature
- Power Usage
- Head Count (people passing through the air curtain)
- RPM (motor speed)
- Device Status (ON/OFF)
- Emergency Status

## Application Structure

```
lib/
├── main.dart                # Application entry point
├── pages/                   # Main screens
│   ├── login.dart           # Authentication screen
│   ├── dashboard.dart       # Main device overview
│   ├── devicedetailpage.dart # Individual device details
│   └── ErrorLogViewer.dart  # Error logs display
├── widgets/                 # Reusable UI components
│   ├── device_card.dart     # Device summary cards
│   ├── app_drawer.dart      # Navigation menu
│   ├── add_device.dart      # Device creation dialog
│   ├── update_device.dart   # Device editing dialog
│   ├── delete_device.dart   # Device removal dialog
│   ├── add_user.dart        # User creation dialog
│   ├── remove_client.dart   # User removal dialog
│   ├── change_password.dart # Password management
│   ├── contact_us.dart      # Support contact dialog
│   └── CustomAppBar.dart    # Application header
└── utils/                   # Helper functions
    └── error_logger.dart    # Error tracking utility
```

## API Endpoints

The application communicates with the backend server through the following endpoints:

### Authentication
- `POST /login` - Authenticate users (admin or client)

### User Management
- `POST /get-name` - Get user details and role

### Device Management
- `POST /device-select` - Get filtered list of devices
- `POST /add-data` - Add a new device
- `POST /find` - Get detailed device information
- `POST /change` - Change device status (ON/OFF)

## User Roles

### Administrator
- View all devices across clients
- Add/update/remove devices
- Add/remove client accounts
- Change device status
- View error logs

### Client
- View only assigned devices
- Change device status
- Update personal information

## Getting Started

### Prerequisites
- Flutter SDK (latest version recommended)
- Android Studio or VS Code with Flutter extensions
- An active internet connection

### Installation
1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Connect a device or start an emulator
4. Run `flutter run` to start the application

### Authentication
- For admin access: Use admin credentials
- For client access: Use client credentials provided by administrator

## Dependencies

- `flutter_staggered_grid_view` - For dashboard layout
- `http` - For API communication
- `shared_preferences` - For local storage
- `path_provider` - For accessing local files

## Future Enhancements

- Historical data visualization with charts
- Push notifications for critical device status changes
- Offline mode support
- Improved data caching
- Enhanced security with token-based authentication
- Device grouping by location or purpose

## Support

For issues or questions, use the in-app contact form or reach out to the system administrator.
 
