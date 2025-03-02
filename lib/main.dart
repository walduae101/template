import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sajaya/features/authentication/screens/login_screen.dart';
import 'package:sajaya/features/home/screens/main_app_screen.dart';
import 'package:sajaya/core/di/service_locator.dart';
import 'package:sajaya/core/theme/theme_provider.dart';
import 'package:sajaya/features/splash/presentation/splash_screen.dart';

// Flag to indicate dev environment
final bool isDevMode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    // Continue with the app even if Firebase fails to initialize
  }

  // Initialize service locator
  try {
    setupServiceLocator();
    debugPrint('✅ Service locator initialized successfully');
  } catch (e) {
    debugPrint('❌ Service locator initialization failed: $e');
  }

  runApp(
    // Wrap the app with ProviderScope for Riverpod
    ProviderScope(child: SajayaApp(firebaseInitialized: firebaseInitialized)),
  );
}

class SajayaApp extends ConsumerWidget {
  final bool firebaseInitialized;

  const SajayaApp({super.key, this.firebaseInitialized = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get theme from provider
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Sajaya',
      debugShowCheckedModeBanner: false,
      theme: theme,
      // Localization setup (temporary basic support until locale provider is fixed)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      // Set splash screen as initial route
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/app': (context) => const MainAppScreen(),
        '/error': (context) => const FirebaseErrorScreen(),
      },
      // This onGenerateRoute handles any routes not defined in the routes map
      onGenerateRoute: (settings) {
        debugPrint('⚠️ No route defined for ${settings.name}');
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      },
    );
  }
}

/// Screen shown when Firebase fails to initialize
class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFC9AE5D),
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Firebase Configuration Missing',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The app requires Firebase to function properly. Please ensure Firebase is correctly configured.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Continue to app anyway
                  Navigator.of(context).pushReplacementNamed('/app');
                },
                child: const Text('Continue Anyway'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
