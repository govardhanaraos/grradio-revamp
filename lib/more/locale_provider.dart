import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'app_locale';

  Locale _locale = const Locale('en');

  Locale get currentLocale => _locale;

  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'ar':
        return 'عربي (Arabic)';
      case 'te':
        return 'తెలుగు (Telugu)';
      case 'ta':
        return 'தமிழ் (Tamil)';
      case 'kn':
        return 'ಕನ್ನಡ (Kannada)';
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'en':
      default:
        return 'English';
    }
  }

  /// Load previously saved locale from SharedPreferences on startup.
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  /// Change the app locale and persist the choice.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  /// The list of locales supported by the app.
  static const List<SupportedLanguage> supportedLanguages = [
    SupportedLanguage(locale: Locale('en'), nativeName: 'English'),
    SupportedLanguage(locale: Locale('ar'), nativeName: 'عربي (Arabic)'),
    SupportedLanguage(locale: Locale('te'), nativeName: 'తెలుగు (Telugu)'),
    SupportedLanguage(locale: Locale('ta'), nativeName: 'தமிழ் (Tamil)'),
    SupportedLanguage(locale: Locale('kn'), nativeName: 'ಕನ್ನಡ (Kannada)'),
    SupportedLanguage(locale: Locale('hi'), nativeName: 'हिन्दी (Hindi)'),
  ];
}

class SupportedLanguage {
  final Locale locale;
  final String nativeName;
  const SupportedLanguage({required this.locale, required this.nativeName});
}
