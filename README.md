# Sajaya

A Flutter application for Sajaya.

## Getting Started

This project is a Flutter application that uses Firebase for authentication and data storage.

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 3.7.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Firebase project setup

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/sajaya.git
   ```

2. Navigate to the project directory:
   ```
   cd sajaya
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Project Structure

- `assets/` - Contains all static assets like images, icons, animations, and language files
  - `animations/` - Lottie animation files
  - `icons/` - App icons and other icon assets
  - `images/` - Images and logos
  - `lang/` - Localization JSON files

- `lib/` - Contains all Dart source code
  - `main.dart` - Entry point of the application

## Features

- Firebase Authentication (Email/Password, Google Sign-In, Apple Sign-In)
- Firestore Database
- Multi-language support
- Google Maps integration
- Responsive UI design

## Dependencies

The project uses several key dependencies:
- `firebase_core` and `firebase_auth` for authentication
- `cloud_firestore` for database
- `flutter_riverpod` for state management
- `flutter_svg` for SVG rendering
- `google_fonts` for typography
- `google_maps_flutter` for maps
- `lottie` for animations

For a complete list of dependencies, see the `pubspec.yaml` file.

## License

This project is proprietary and confidential.

## Contact

For any inquiries, please contact [your-email@example.com](mailto:your-email@example.com). 