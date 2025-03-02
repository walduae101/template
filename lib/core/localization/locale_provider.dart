import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing locale preference
const String _localeKey = 'app_locale';

/// State notifier for locale management
class LocaleNotifier extends StateNotifier<Locale> {
  // Default to English
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  /// Load saved locale from preferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);

      if (savedLocale != null) {
        state = Locale(savedLocale);
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }

  /// Save locale to preferences
  Future<void> _saveLocale(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Toggle between supported locales (currently just English and Arabic)
  void toggleLocale() {
    final newLocale =
        state.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    state = newLocale;
    _saveLocale(newLocale.languageCode);
  }

  /// Set specific locale
  void setLocale(Locale locale) {
    state = locale;
    _saveLocale(locale.languageCode);
  }
}

/// Provider for locale state
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
