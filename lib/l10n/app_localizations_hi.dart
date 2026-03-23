// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'GR रेडियो';

  @override
  String get tabRadio => 'रेडियो';

  @override
  String get tabPlayer => 'प्लेयर';

  @override
  String get tabDownloads => 'डाउनलोड';

  @override
  String get tabMore => 'अधिक';

  @override
  String get sectionSettings => 'सेटिंग्स';

  @override
  String get sectionSupport => 'सहायता';

  @override
  String get settingDarkMode => 'डार्क मोड';

  @override
  String get settingDarkModeOnSubtitle => 'डार्क थीम चालू है';

  @override
  String get settingDarkModeOffSubtitle => 'लाइट थीम चालू है';

  @override
  String get settingLanguage => 'भाषा';

  @override
  String get settingLanguageSubtitle => 'अपनी पसंदीदा भाषा चुनें';

  @override
  String get settingGoPremium => 'प्रीमियम लें (बिना विज्ञापन के)';

  @override
  String get settingGoPremiumSubtitle =>
      'सदस्यता के साथ सभी सुविधाएं अनलॉक करें';

  @override
  String get settingNotifications => 'सूचनाएं';

  @override
  String get settingNotificationsSubtitle =>
      'अपनी सूचना प्राथमिकताएं प्रबंधित करें';

  @override
  String get settingHelpSupport => 'सहायता और समर्थन';

  @override
  String get settingHelpSupportSubtitle =>
      'सहायता प्राप्त करें और समर्थन से संपर्क करें';

  @override
  String get settingRateApp => 'ऐप रेट करें';

  @override
  String get settingRateAppSubtitle => 'हमारे साथ अपनी प्रतिक्रिया साझा करें';

  @override
  String get settingShareApp => 'ऐप शेयर करें';

  @override
  String get settingShareAppSubtitle => 'अपने दोस्तों के साथ शेयर करें';

  @override
  String get settingAbout => 'के बारे में';

  @override
  String get settingAboutSubtitle => 'ऐप संस्करण और जानकारी';

  @override
  String get appTagline => 'आपका अंतिम संगीत साथी';

  @override
  String get discoverHeader => 'खोजें';

  @override
  String get nowPlaying => 'अभी बज रहा है';

  @override
  String get searchStations => 'स्टेशन खोजें...';

  @override
  String noStationsMatch(String query) {
    return '\"$query\" से कोई स्टेशन मेल नहीं खाता';
  }

  @override
  String noLanguageStations(String language) {
    return '$language स्टेशन नहीं मिले';
  }

  @override
  String get clearFilters => 'फ़िल्टर साफ़ करें';

  @override
  String get tryDifferentFilter => 'कोई अलग खोज या भाषा फ़िल्टर आज़माएं';

  @override
  String get sectionFavourites => 'पसंदीदा';

  @override
  String get sectionRecentlyPlayed => 'हाल ही में चला';

  @override
  String get sectionForYou => 'आपके लिए';

  @override
  String get sectionTrending => 'ट्रेंडिंग';

  @override
  String get sectionAllStations => 'सभी स्टेशन';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get mp3PlayerTitle => 'मेरा संगीत';

  @override
  String get mp3TabMusic => 'संगीत';

  @override
  String get mp3TabDownloads => 'डाउनलोड';

  @override
  String get mp3TabRecordings => 'रिकॉर्डिंग';

  @override
  String get mp3NoFiles => 'कोई फ़ाइल नहीं मिली';

  @override
  String get mp3SearchHint => 'गाने खोजें...';

  @override
  String get downloadTitle => 'MP3 डाउनलोड';

  @override
  String get downloadSearchHint => 'MP3 खोजें...';

  @override
  String get downloadSearchAction => 'खोजें';

  @override
  String get dialogUpdateTitle => 'अपडेट उपलब्ध है';

  @override
  String dialogUpdateContent(String version) {
    return 'GR रेडियो का नया संस्करण ($version) उपलब्ध है। कृपया अपडेट करें।';
  }

  @override
  String get dialogUpdateLater => 'बाद में';

  @override
  String get dialogUpdateNow => 'अपडेट करें';

  @override
  String get dialogNoInternet => 'इंटरनेट कनेक्शन नहीं है';

  @override
  String get dialogNoInternetContent =>
      'कृपया अपना इंटरनेट कनेक्शन जांचें और फिर से प्रयास करें।';

  @override
  String get dialogRetry => 'पुनः प्रयास करें';

  @override
  String get languageSelectionTitle => 'भाषा चुनें';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'عربي (Arabic)';

  @override
  String get languageTelugu => 'తెలుగు (Telugu)';

  @override
  String get languageTamil => 'தமிழ் (Tamil)';

  @override
  String get languageKannada => 'ಕನ್ನಡ (Kannada)';

  @override
  String get languageHindi => 'हिन्दी (Hindi)';
}
