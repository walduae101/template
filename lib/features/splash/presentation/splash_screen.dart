import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajaya/features/authentication/providers/auth_provider.dart';
import 'package:sajaya/core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isInitialized = false;
  bool _animationCompleted = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animationCompleted = true;
        });
        _checkAndNavigate();
      }
    });

    // Set a timeout in case initialization takes too long
    _timeoutTimer = Timer(const Duration(seconds: 6), () {
      debugPrint('⚠️ Splash screen timeout reached');
      _navigateToNextScreen();
    });

    // Initialize app services
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Load app preferences
      await SharedPreferences.getInstance();

      // Add any additional initialization here
      // For example, initialize analytics, load cached data, etc.

      // Simulate some delay for testing
      await Future.delayed(const Duration(milliseconds: 2000));

      setState(() {
        _isInitialized = true;
      });

      _checkAndNavigate();
    } catch (e) {
      debugPrint('❌ Error initializing services: $e');
      // Still navigate even if there's an error
      _navigateToNextScreen();
    }
  }

  void _checkAndNavigate() {
    // Only navigate when both animation is complete and initialization is done
    if (_animationCompleted && _isInitialized) {
      _navigateToNextScreen();
    } else {
      // If initialization is done but animation isn't, start animation
      if (_isInitialized &&
          !_animationCompleted &&
          !_animationController.isAnimating) {
        _animationController.forward();
      }
    }
  }

  void _navigateToNextScreen() {
    // Cancel the timeout if it hasn't triggered yet
    _timeoutTimer?.cancel();

    // Only navigate if the widget is still mounted
    if (mounted) {
      // Check authentication status and navigate accordingly
      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.authenticated) {
        // User is authenticated, navigate to main app
        Navigator.pushReplacementNamed(context, '/app');
      } else {
        // User is not authenticated, navigate to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie globe animation
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    'assets/animations/globe_animation.json',
                    controller: _animationController,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('⚠️ Lottie animation error: $error');
                      return const Icon(
                        Icons.language,
                        size: 100,
                        color: AppColors.primary,
                      );
                    },
                    onLoaded: (composition) {
                      // Configure animation duration based on the actual animation
                      _animationController.duration = composition.duration;

                      // Start the animation immediately instead of waiting for initialization
                      _animationController.forward();
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Image logo
                Image.asset('assets/images/text.png', height: 50),

                const SizedBox(height: 16),

                // Welcome message in English
                Text(
                  "Where Heritage Meets Elegance",
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 8),

                // Welcome message in Arabic
                Text(
                  "حيث يلتقي التراث بالأناقة",
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 40),

                // Loading indicator (without text)
                if (!_animationCompleted || !_isInitialized)
                  CircularProgressIndicator(color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
