import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _kDarkModeKey = 'theme_dark_mode';

  bool isDarkMode = false;

  ThemeProvider() {
    _loadTheme();
  }

  /// Loads persisted theme preference from SharedPreferences.
  /// Called once on construction — widgets will rebuild via notifyListeners()
  /// once the async read completes.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_kDarkModeKey);
    if (saved != null && saved != isDarkMode) {
      isDarkMode = saved;
      notifyListeners();
    }
  }

  /// Toggles the theme and persists the new value immediately.
  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkModeKey, isDarkMode);
  }
}
