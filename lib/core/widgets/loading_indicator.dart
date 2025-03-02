import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A custom loading indicator that uses Lottie animation
class LoadingIndicator extends StatelessWidget {
  /// The size of the loading indicator
  final double size;

  /// Whether to show the background overlay
  final bool showBackground;

  /// Default constructor for the LoadingIndicator
  const LoadingIndicator({
    super.key,
    this.size = 100.0,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget loadingAnimation = Lottie.asset(
      'assets/animations/globe_animation.json',
      height: size,
      width: size,
      repeat: true,
      animate: true,
      fit: BoxFit.contain,
    );

    if (!showBackground) {
      return loadingAnimation;
    }

    // If showBackground is true, add a background overlay
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 128.0, // 0.5 * 255
      ),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.black.withValues(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 26.0, // 0.1 * 255
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [loadingAnimation],
          ),
        ),
      ),
    );
  }
}

/// A full screen loading indicator for processes that block the UI
class FullScreenLoading extends StatelessWidget {
  /// The message to display under the loading indicator
  final String? message;

  /// Default constructor for FullScreenLoading
  const FullScreenLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingIndicator(size: 120),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
