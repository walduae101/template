import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/main_app_screen.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/localization/translation_extension.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isVerificationSent = false;
  String? _verificationId;
  bool _isLoading = false;

  // Sajaya brand colors
  static const Color goldBackground = Color(0xFFC9AE5D);
  static const Color darkRedText = Color(0xFF3F0707);

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Get branded button style
  ButtonStyle get sajayaButtonStyle => OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(50),
    backgroundColor: goldBackground,
    foregroundColor: darkRedText,
    elevation: 2,
    shadowColor: Colors.black.withValues(
      red: 0,
      green: 0,
      blue: 0,
      alpha: 77.0, // 0.3 * 255 = 76.5 ≈ 77
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
  );

  // Add a helper method for navigating after async operations
  void _safeNavigate(String route) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(route);
      }
    });
  }

  // Add a helper method for showing snackbars after async operations
  void _safeShowSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: backgroundColor),
        );
      }
    });
  }

  // Add a helper method for showing dialogs
  void _safeShowDialog({required Widget Function(BuildContext) builder}) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: builder,
        );
      }
    });
  }

  // Add a helper method for closing dialogs
  void _safeCloseDialog() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  // Handle phone authentication - refactored
  void _handlePhoneAuth() async {
    if (_formKey.currentState!.validate()) {
      if (!_isVerificationSent) {
        // Sending OTP
        final phoneNumber = "+971${_phoneController.text.trim()}";
        setState(() {
          _isVerificationSent = true;
        });

        try {
          await ref
              .read(authProvider.notifier)
              .verifyPhoneNumber(
                phoneNumber: phoneNumber,
                onCodeSent: (verificationId) {
                  if (!mounted) return;

                  setState(() {
                    _verificationId = verificationId;
                  });

                  _safeShowSnackBar(context.translate('otp_sent'));
                },
              );
        } catch (e) {
          if (!mounted) return;

          setState(() {
            _isVerificationSent = false;
          });

          _safeShowSnackBar("${context.translate('error')}: $e");
        }
      } else {
        // Verifying OTP
        try {
          await ref
              .read(authProvider.notifier)
              .signInWithPhoneNumber(
                verificationId: _verificationId!,
                smsCode: _otpController.text.trim(),
              );

          if (!mounted) return;

          // Check authentication result
          final authState = ref.read(authProvider);
          if (authState.status == AuthStatus.authenticated) {
            _safeNavigate('/app');
          } else {
            _safeShowSnackBar(context.translate('invalid_otp'));
          }
        } catch (e) {
          if (!mounted) return;
          _safeShowSnackBar("${context.translate('error')}: $e");
        }
      }
    }
  }

  // Handle Google Sign In - refactored
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final user = await ref.read(authUtilsProvider).signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        _safeNavigate('/app');
      } else {
        _safeShowSnackBar(context.translate('login_failed'));
      }
    } catch (e) {
      if (!mounted) return;
      _safeShowSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Handle Apple Login - refactored
  void _handleAppleLogin() async {
    // Show loading dialog
    _safeShowDialog(
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(authProvider.notifier).signInWithApple(context: context);

      if (!mounted) return;

      // Close loading dialog
      _safeCloseDialog();

      // Check if authentication was successful
      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.authenticated) {
        debugPrint('✅ Apple Sign-In successful, navigating to main app');

        // Use WidgetsBinding to ensure we navigate after the current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainAppScreen()),
            );
          }
        });
      } else if (authState.errorMessage != null) {
        // Show error message
        _safeShowSnackBar(authState.errorMessage!, backgroundColor: Colors.red);
      }
    } catch (e) {
      debugPrint('❌ Error during Apple login flow: $e');

      if (!mounted) return;

      // Close loading dialog
      _safeCloseDialog();

      // Show generic error
      _safeShowSnackBar(
        'An error occurred during Apple Sign-In. Please try again.',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final locale = ref.watch(localeProvider);
    final isRTL = locale.languageCode == 'ar';
    final screenSize = MediaQuery.of(context).size;
    final bool isWideScreen = screenSize.width > 600;

    // Reset loading state after widget builds if we're stuck in loading state
    // but verification has been sent (helps prevent UI getting stuck)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.status == AuthStatus.loading && _isVerificationSent) {
        // Only force reset if we've been stuck for too long
        if (mounted && authState.errorMessage == null) {
          // Force a refresh after 10 seconds if still loading
          Future.delayed(const Duration(seconds: 10), () {
            if (mounted && authState.status == AuthStatus.loading) {
              ref.read(authProvider.notifier).resetLoadingState();
            }
          });
        }
      }
    });

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.black.withValues(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 77.0, // 0.3 * 255 = 76.5 ≈ 77
          ),
          title: Text(
            context.translate('login_screen_title'),
            style: theme.textTheme.titleLarge,
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Language switcher in top-right corner (or top-left in RTL)
              Positioned(
                top: 16,
                right: isRTL ? null : 16,
                left: isRTL ? 16 : null,
                child: _buildLanguageSwitcher(context),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWideScreen ? screenSize.width * 0.1 : 24.0,
                    vertical: 24.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Column(
                          children: [
                            // App Icon
                            Image.asset(
                              'assets/icons/app_icon.png',
                              width: isWideScreen ? 150 : 120,
                              height: isWideScreen ? 150 : 120,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 16),

                            // Text logo
                            Image.asset(
                              'assets/images/text.png',
                              height: isWideScreen ? 50 : 40,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Phone number input - handles RTL automatically via Directionality
                        TextFormField(
                          controller: _phoneController,
                          enabled: !_isVerificationSent,
                          decoration: InputDecoration(
                            prefixIcon:
                                isRTL ? null : const Icon(Icons.phone_android),
                            suffixIcon:
                                isRTL ? const Icon(Icons.phone_android) : null,
                            labelText: context.translate('phone_number'),
                            hintText: '971XXXXXXXXX',
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignLabelWithHint: true,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.translate('please_enter_phone');
                            }
                            // Basic validation for phone number format
                            final phoneRegex = RegExp(r'^\d{1,3}\d{9,10}$');
                            if (!phoneRegex.hasMatch(value)) {
                              return context.translate('enter_valid_phone');
                            }
                            return null;
                          },
                        ),

                        if (!_isVerificationSent) ...[
                          const SizedBox(height: 24),
                          // Phone Auth Button - Send Code
                          OutlinedButton.icon(
                            icon: Icon(
                              Icons.phone_android,
                              size: 24,
                              color: darkRedText,
                            ),
                            label: Text(
                              context.translate('send_verification_code'),
                            ),
                            onPressed:
                                authState.status == AuthStatus.loading
                                    ? null
                                    : _handlePhoneAuth,
                            style: sajayaButtonStyle,
                          ),
                        ],

                        if (_isVerificationSent) ...[
                          const SizedBox(height: 16),

                          // Info text when code is sent
                          Text(
                            context.translate('verification_code_sent'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // OTP input field when verification is sent
                          TextFormField(
                            controller: _otpController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              labelText: context.translate('verification_code'),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              hintText: '123456',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.translate('please_enter_code');
                              }
                              if (value.length < 4 || value.length > 8) {
                                return context.translate('enter_valid_code');
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Verify Code Button - Submit Code
                          ElevatedButton(
                            onPressed:
                                authState.status == AuthStatus.loading
                                    ? null
                                    : _handlePhoneAuth,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: goldBackground,
                              foregroundColor: darkRedText,
                              elevation: 2,
                              shadowColor: Colors.black.withValues(
                                red: 0,
                                green: 0,
                                blue: 0,
                                alpha: 77.0, // 0.3 * 255
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            child:
                                authState.status == AuthStatus.loading
                                    ? SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: Lottie.asset(
                                        'assets/animations/globe_animation.json',
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                    : Text(context.translate('verify_sign_in')),
                          ),

                          // Force verification button when loading state gets stuck
                          if (authState.status == AuthStatus.loading) ...[
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () {
                                // Force reset loading state and retry verification
                                ref
                                    .read(authProvider.notifier)
                                    .resetLoadingState();
                                _handlePhoneAuth();
                              },
                              icon: Icon(Icons.refresh, color: darkRedText),
                              label: Text(
                                context.translate('try_verify_again'),
                                style: TextStyle(color: darkRedText),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: goldBackground.withValues(
                                  red: goldBackground.r,
                                  green: goldBackground.g,
                                  blue: goldBackground.b,
                                  alpha: 77.0, // 0.3 * 255
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),

                          // Edit phone number button
                          TextButton(
                            onPressed:
                                authState.status == AuthStatus.loading
                                    ? null
                                    : () {
                                      setState(() {
                                        _isVerificationSent = false;
                                        _otpController.clear();
                                      });
                                    },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              context.translate('change_phone_number'),
                              style: TextStyle(color: darkRedText),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: theme.colorScheme.outline),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                context.translate('or'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: theme.colorScheme.outline),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Google Sign-In Button
                        _buildAuthButton(
                          icon: SvgPicture.asset(
                            'assets/images/google_icon.svg',
                            width: 24,
                            height: 24,
                          ),
                          label: context.translate('sign_in_with_google'),
                          onPressed:
                              authState.status == AuthStatus.loading
                                  ? null
                                  : _handleGoogleSignIn,
                          isRTL: isRTL,
                        ),
                        const SizedBox(height: 16),

                        // Apple Sign-In Button
                        _buildAuthButton(
                          icon: Icon(Icons.apple, size: 24, color: darkRedText),
                          label: context.translate('sign_in_with_apple'),
                          onPressed:
                              authState.status == AuthStatus.loading
                                  ? null
                                  : _handleAppleLogin,
                          isRTL: isRTL,
                        ),
                        const SizedBox(height: 16),

                        // Error Message
                        if (authState.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              authState.errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton:
            _isLoading ? const CircularProgressIndicator() : null,
      ),
    );
  }

  // Build language switcher widget
  Widget _buildLanguageSwitcher(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    // For responsive design
    final screenSize = MediaQuery.of(context).size;
    final bool isWideScreen = screenSize.width > 600;
    final double fontSize = isWideScreen ? 16 : 14;
    final double iconSize = isWideScreen ? 24 : 20;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        // For RTL language, swap the icon and label position
        icon:
            isArabic && !isWideScreen
                ? Text(
                  'English',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                    color: darkRedText,
                  ),
                )
                : Icon(Icons.language, size: iconSize, color: darkRedText),
        label:
            isArabic && !isWideScreen
                ? Icon(Icons.language, size: iconSize, color: darkRedText)
                : Text(
                  isArabic ? 'English' : 'العربية',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                    color: darkRedText,
                  ),
                ),
        onPressed: () {
          final notifier = ref.read(localeProvider.notifier);
          notifier.toggleLocale();
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? 16 : 12,
            vertical: isWideScreen ? 12 : 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: goldBackground,
          elevation: 2,
          shadowColor: Colors.black.withValues(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 77.0, // 0.3 * 255
          ),
        ),
      ),
    );
  }

  // Helper method to build auth buttons with proper RTL support
  Widget _buildAuthButton({
    required Widget icon,
    required String label,
    required Function()? onPressed,
    required bool isRTL,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: goldBackground,
        foregroundColor: darkRedText,
        elevation: 2,
        shadowColor: Colors.black.withValues(
          red: 0,
          green: 0,
          blue: 0,
          alpha: 77.0, // 0.3 * 255
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      child: Stack(
        children: [
          // Icon on the left (LTR) or right (RTL)
          Positioned(
            left: isRTL ? null : 16,
            right: isRTL ? 16 : null,
            top: 0,
            bottom: 0,
            child: Center(child: icon),
          ),
          // Centered text
          Center(child: Text(label)),
        ],
      ),
    );
  }
}
