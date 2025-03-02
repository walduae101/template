import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_provider.dart';

/// Map of translations for quick access
final Map<String, Map<String, String>> _translations = {
  'en': {
    'app_name': 'Sajaya',
    'phone_number': 'Phone Number',
    'please_enter_phone': 'Please enter your phone number',
    'enter_valid_phone': 'Please enter a valid phone number',
    'send_verification_code': 'Send Verification Code',
    'verification_code_sent': 'Verification code has been sent to your phone',
    'verification_code': 'Verification Code',
    'please_enter_code': 'Please enter the verification code',
    'enter_valid_code': 'Please enter a valid verification code',
    'verify_sign_in': 'Verify & Sign In',
    'try_verify_again': 'Try Again',
    'change_phone_number': 'Change Phone Number',
    'or': 'OR',
    'sign_in_with_google': 'Sign in with Google',
    'sign_in_with_apple': 'Sign in with Apple',
    'sign_in_success': 'You have signed in successfully',
    'sign_out': 'Sign Out',
    'welcome': 'Welcome',
    'profile': 'Profile',
    'settings': 'Settings',
    'language': 'Language',
    'home': 'Home',
  },
  'ar': {
    'app_name': 'سجايا',
    'phone_number': 'رقم الهاتف',
    'please_enter_phone': 'يرجى إدخال رقم الهاتف',
    'enter_valid_phone': 'يرجى إدخال رقم هاتف صحيح',
    'send_verification_code': 'إرسال رمز التحقق',
    'verification_code_sent': 'تم إرسال رمز التحقق إلى هاتفك',
    'verification_code': 'رمز التحقق',
    'please_enter_code': 'يرجى إدخال رمز التحقق',
    'enter_valid_code': 'يرجى إدخال رمز تحقق صحيح',
    'verify_sign_in': 'تحقق وتسجيل الدخول',
    'try_verify_again': 'المحاولة مرة أخرى',
    'change_phone_number': 'تغيير رقم الهاتف',
    'or': 'أو',
    'sign_in_with_google': 'تسجيل الدخول باستخدام Google',
    'sign_in_with_apple': 'تسجيل الدخول باستخدام Apple',
    'sign_in_success': 'لقد قمت بتسجيل الدخول بنجاح',
    'sign_out': 'تسجيل الخروج',
    'welcome': 'مرحبا',
    'profile': 'الملف الشخصي',
    'settings': 'الإعدادات',
    'language': 'اللغة',
    'home': 'الرئيسية',
  },
};

/// Extension on BuildContext to provide easy access to translations
extension TranslationExtension on BuildContext {
  /// Get translation for a key based on current locale
  String translate(String key) {
    // Get ProviderContainer
    final container = ProviderScope.containerOf(this);
    // Get current locale
    final locale = container.read(localeProvider);
    final languageCode = locale.languageCode;

    // Return translation if available
    if (_translations.containsKey(languageCode) &&
        _translations[languageCode]!.containsKey(key)) {
      return _translations[languageCode]![key]!;
    }

    // Fallback to English
    if (_translations['en']!.containsKey(key)) {
      return _translations['en']![key]!;
    }

    // Return key as fallback
    return key;
  }
}
