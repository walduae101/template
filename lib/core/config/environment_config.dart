/// Configuration class that holds environment-specific settings
class EnvironmentConfig {
  /// API base URL
  static const String apiBaseUrl = 'https://api.sajaya.com';

  /// Firebase configuration values
  static const String firebaseProjectId = 'sajaya-2c801';
  static const String firebaseAppId = '1:123456789012:web:abcdef1234567890';
  static const String firebaseApiKey = 'your-firebase-api-key';

  /// Apple Sign In configuration
  static const String appleServiceId = '3DD956ET5V.com.easylife.sajaya';
  static const String appleRedirectUrl =
      'https://sajaya-2c801.firebaseapp.com/__/auth/handler';

  /// Google Maps API Key
  static const String googleMapsApiKey = 'your-google-maps-api-key';

  /// App constants
  static const String appName = 'Sajaya';
  static const String appVersion = '1.0.0';

  /// Feature flags
  static const bool enableCrashReporting = true;
  static const bool enableAnalytics = true;
  static const bool enableAppleSignIn = true;
}
