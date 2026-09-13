# Lamma

A Flutter application for family management and coordination.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter](https://flutter.dev/docs/get-started/install) (stable channel)
- [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
- [Git](https://git-scm.com/downloads)

## Getting Started

1. Clone the repository:
```bash
git clone <repository-url>
cd lamma
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Firebase:
- Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Enable Authentication, Cloud Firestore, and Storage
- Download and place the configuration files:
  - For Android: Place `google-services.json` in `android/app/`
  - For iOS: Place `GoogleService-Info.plist` in `ios/Runner/`
  - For web: Configuration is already set in `lib/firebase_options.dart`

4. Run the app:
```bash
flutter run
```

## Features

- Family Management
- Event Planning
- Games Dashboard
- Chore Management
- Family Information Sharing

## Project Structure

```
lib/
├── account_profile_creation/   # Account creation flows
├── auth/                      # Authentication logic
├── backend/                   # Backend services
├── components/               # Reusable UI components
├── family_creation/          # Family setup flows
├── family_dashboard/         # Family dashboard screens
├── family_information/       # Family information screens
├── game/                     # Game logic
├── games_dashboard/          # Games dashboard screens
├── home/                     # Home screen
├── services/                 # App services
└── wheel_of_chores/         # Chore management feature
```

## Development

- This project uses Flutter stable channel
- Dependencies are managed in `pubspec.yaml`
- Firebase configuration is in `lib/firebase_options.dart`
- State management is handled with Provider

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Contributing

1. Create a new branch for your feature
2. Make your changes
3. Test thoroughly
4. Create a pull request

## License

This project is proprietary and confidential.
