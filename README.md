# Flutter Application Template

A complete Flutter application template with ready-to-use features for quick project setup. This template includes authentication, theming, localization, and other common app features.

## Features

- 📱 Cross-platform support (iOS, Android, Web)
- 🔐 Authentication (Email, Google Sign-In)
- 🌓 Light/Dark theme support
- 🌍 Internationalization (English & Arabic)
- 📊 Firebase integration
- 🏗️ Feature-based folder structure
- 🧩 Riverpod state management

## Requirements

- Flutter SDK (latest stable version)
- Dart SDK (latest stable)
- Android Studio / VS Code
- JDK 21 (C:\Program Files\Eclipse Adoptium\jdk-21.0.6.7-hotspot)
- Git
- Firebase CLI (optional, for Firebase setup)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/walduae101/template.git your_project_name
cd your_project_name
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Update Package Name

For a new project, you'll want to update the package name:

#### Android:
- Open `android/app/build.gradle.kts`
- Change `namespace` and `applicationId` 
- Update package references in `android/app/src/main/kotlin`

#### iOS:
- Open `ios/Runner.xcodeproj/project.pbxproj`
- Update `PRODUCT_BUNDLE_IDENTIFIER`

### 4. Firebase Setup (Optional)

If you want to use Firebase:

1. Create a new Firebase project
2. Add Android & iOS apps with your new package names
3. Download configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
4. Update `firebase.json` if needed

### 5. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── core/              # Core functionality
│   ├── config/        # App configuration
│   ├── di/            # Dependency injection
│   ├── localization/  # Localization services
│   ├── theme/         # App theming
│   └── widgets/       # Common widgets
├── features/          # App features
│   ├── authentication/# Authentication feature
│   ├── home/          # Home screens
│   └── splash/        # Splash screen
└── main.dart          # App entry point
```

## Customization

### Theme

Modify theme settings in `lib/core/theme/`:
- `app_colors.dart` - Color definitions
- `app_theme.dart` - Theme data
- `app_typography.dart` - Text styles

### Localization

- Add/edit translations in `assets/lang/en.json` and `assets/lang/ar.json`
- Access translations via the extension methods in `lib/core/localization/`

## Troubleshooting

### Common Issues

1. **Gradle Build Failures**
   - Try running: `flutter clean` then `flutter pub get`
   
2. **Firebase Integration**
   - Ensure config files are in the correct locations
   - Check that package names match your Firebase project

3. **Large File Handling**
   - The `.gitignore` is configured to exclude binary and large files

## License

This template is available for free use. Please provide attribution if possible.

---

Created and maintained by walduae101. 