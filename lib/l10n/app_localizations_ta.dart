// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'GR ரேடியோ';

  @override
  String get tabRadio => 'ரேடியோ';

  @override
  String get tabPlayer => 'பிளேயர்';

  @override
  String get tabDownloads => 'பதிவிறக்கங்கள்';

  @override
  String get tabMore => 'மேலும்';

  @override
  String get sectionSettings => 'அமைப்புகள்';

  @override
  String get sectionSupport => 'ஆதரவு';

  @override
  String get settingDarkMode => 'இருள் பயன்முறை';

  @override
  String get settingDarkModeOnSubtitle => 'இருண்ட தீம் இயக்கத்தில் உள்ளது';

  @override
  String get settingDarkModeOffSubtitle => 'ஒளி தீம் இயக்கத்தில் உள்ளது';

  @override
  String get settingLanguage => 'மொழி';

  @override
  String get settingLanguageSubtitle =>
      'உங்கள் விருப்பமான மொழியைத் தேர்ந்தெடுங்கள்';

  @override
  String get settingGoPremium =>
      'பிரீமியத்திற்கு செல்லுங்கள் (விளம்பரங்கள் இல்லாமல்)';

  @override
  String get settingGoPremiumSubtitle =>
      'சந்தாவுடன் அனைத்து அம்சங்களையும் திறக்கவும்';

  @override
  String get settingNotifications => 'அறிவிப்புகள்';

  @override
  String get settingNotificationsSubtitle =>
      'உங்கள் அறிவிப்பு விருப்பங்களை நிர்வகிக்கவும்';

  @override
  String get settingHelpSupport => 'உதவி & ஆதரவு';

  @override
  String get settingHelpSupportSubtitle =>
      'உதவி பெறுங்கள் மற்றும் ஆதரவைத் தொடர்பு கொள்ளுங்கள்';

  @override
  String get settingRateApp => 'ஆப்பை மதிப்பிடுங்கள்';

  @override
  String get settingRateAppSubtitle => 'உங்கள் கருத்தை எங்களுடன் பகிருங்கள்';

  @override
  String get settingShareApp => 'ஆப்பை பகிருங்கள்';

  @override
  String get settingShareAppSubtitle => 'உங்கள் நண்பர்களுடன் பகிருங்கள்';

  @override
  String get settingAbout => 'பற்றி';

  @override
  String get settingAboutSubtitle => 'ஆப் பதிப்பு மற்றும் தகவல்';

  @override
  String get appTagline => 'உங்கள் இசை தோழன்';

  @override
  String get discoverHeader => 'கண்டுபிடி';

  @override
  String get nowPlaying => 'இப்போது இயங்குகிறது';

  @override
  String get searchStations => 'நிலையங்களைத் தேடுங்கள்...';

  @override
  String noStationsMatch(String query) {
    return '\"$query\" க்கு பொருந்தும் நிலையங்கள் இல்லை';
  }

  @override
  String noLanguageStations(String language) {
    return '$language நிலையங்கள் கிடைக்கவில்லை';
  }

  @override
  String get clearFilters => 'வடிகட்டிகளை அழிக்கவும்';

  @override
  String get tryDifferentFilter =>
      'வேறு தேடல் அல்லது மொழி வடிகட்டியை முயற்சிக்கவும்';

  @override
  String get sectionFavourites => 'பிடித்தவை';

  @override
  String get sectionRecentlyPlayed => 'சமீபத்தில் இயக்கியவை';

  @override
  String get sectionForYou => 'உங்களுக்காக';

  @override
  String get sectionTrending => 'டிரெண்டிங்';

  @override
  String get sectionAllStations => 'அனைத்து நிலையங்கள்';

  @override
  String get seeAll => 'அனைத்தையும் பார்க்கவும்';

  @override
  String get mp3PlayerTitle => 'என் இசை';

  @override
  String get mp3TabMusic => 'இசை';

  @override
  String get mp3TabDownloads => 'பதிவிறக்கங்கள்';

  @override
  String get mp3TabRecordings => 'பதிவுகள்';

  @override
  String get mp3NoFiles => 'கோப்புகள் கிடைக்கவில்லை';

  @override
  String get mp3SearchHint => 'பாடல்களைத் தேடுங்கள்...';

  @override
  String get downloadTitle => 'MP3 பதிவிறக்கம்';

  @override
  String get downloadSearchHint => 'MP3களைத் தேடுங்கள்...';

  @override
  String get downloadSearchAction => 'தேடு';

  @override
  String get dialogUpdateTitle => 'புதுப்பிப்பு கிடைக்கிறது';

  @override
  String dialogUpdateContent(String version) {
    return 'GR ரேடியோவின் புதிய பதிப்பு ($version) கிடைக்கிறது. சிறந்த அனுபவத்திற்கு புதுப்பிக்கவும்.';
  }

  @override
  String get dialogUpdateLater => 'பின்னர்';

  @override
  String get dialogUpdateNow => 'புதுப்பிக்கவும்';

  @override
  String get dialogNoInternet => 'இணைய இணைப்பு இல்லை';

  @override
  String get dialogNoInternetContent =>
      'உங்கள் இணைய இணைப்பை சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get dialogRetry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get languageSelectionTitle => 'மொழியைத் தேர்ந்தெடுங்கள்';

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
