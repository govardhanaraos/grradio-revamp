import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _appLocaleKey = 'app_locale';
  static const String _listeningLangKey = 'listening_language';

  Locale _locale = const Locale('en');
  String _listeningLanguage = 'en';

  Locale get currentLocale => _locale;
  String get listeningLanguage => _listeningLanguage;

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

  /// Load previously saved locale and listening language from SharedPreferences on startup.
  Future<void> loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final appLocaleCode = prefs.getString(_appLocaleKey) ?? 'en';
    _locale = Locale(appLocaleCode);
    _listeningLanguage = prefs.getString(_listeningLangKey) ?? 'en';
    notifyListeners();
  }

  /// Change the app locale and persist the choice.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appLocaleKey, locale.languageCode);
  }

  /// Change the listening language and persist the choice.
  Future<void> setListeningLanguage(String languageCode) async {
    if (_listeningLanguage == languageCode) return;
    _listeningLanguage = languageCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_listeningLangKey, languageCode);
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
