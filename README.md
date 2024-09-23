# SafeGuard - Police Public Safety Application

SafeGuard is a mobile application designed to enhance public safety by allowing users to send real-time location-based emergency alerts to the nearest police officer. The app utilizes GPS and Geocoding APIs for accurate location tracking and Firebase for secure data storage and synchronization. Built using Dart and Flutter, the app provides cross-platform functionality for Android and iOS devices.

## Features

- **Emergency Alerts**: Users can send emergency alerts to the nearest police officer with real-time location updates.
- **Real-time GPS Tracking**: The app fetches and updates the user's latitude and longitude every 3 seconds for live location tracking.
- **Geocoding API Integration**: Converts GPS coordinates into readable addresses, including street, area, and city names.
- **Firebase Firestore**: Securely stores user data, including location history and emergency alert details.
- **Cross-Platform**: Built using Dart for both Android and iOS support.

## Technologies Used

- **Dart**: Programming language for building the mobile application.
- **Flutter**: Framework used to create a cross-platform app.
- **Geolocator Package**: Fetches real-time GPS location.
- **Firebase Firestore**: NoSQL database for storing user and alert data.
- **Geocoding API**: Converts GPS coordinates to readable location details.
- **Firebase Authentication (Optional)**: Secure user authentication and authorization.
