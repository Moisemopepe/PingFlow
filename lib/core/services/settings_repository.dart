import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository extends ChangeNotifier {
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language_code';

  ThemeMode _themeMode = ThemeMode.dark;
  String _languageCode = 'en';

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _themeMode = switch (preferences.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
    final savedLanguage = preferences.getString(_languageKey);
    _languageCode = savedLanguage == 'fr' ? 'fr' : 'en';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeKey, mode.name);
  }

  Future<void> setLanguageCode(String code) async {
    final languageCode = code == 'fr' ? 'fr' : 'en';
    if (_languageCode == languageCode) return;
    _languageCode = languageCode;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, _languageCode);
  }
}
