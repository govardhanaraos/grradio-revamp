// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GR Radio';

  @override
  String get tabRadio => 'Radio';

  @override
  String get tabPlayer => 'Player';

  @override
  String get tabDownloads => 'Downloads';

  @override
  String get tabMore => 'More';

  @override
  String get sectionSettings => 'Settings';

  @override
  String get sectionSupport => 'Support';

  @override
  String get settingDarkMode => 'Dark Mode';

  @override
  String get settingDarkModeOnSubtitle => 'Dark theme is on';

  @override
  String get settingDarkModeOffSubtitle => 'Light theme is on';

  @override
  String get settingLanguage => 'Language';

  @override
  String get settingLanguageSubtitle => 'Choose your preferred language';

  @override
  String get settingGoPremium => 'Go Premium (Ad-Free)';

  @override
  String get settingGoPremiumSubtitle =>
      'Unlock all features with a subscription';

  @override
  String get settingNotifications => 'Notifications';

  @override
  String get settingNotificationsSubtitle =>
      'Manage your notification preferences';

  @override
  String get settingHelpSupport => 'Help & Support';

  @override
  String get settingHelpSupportSubtitle => 'Get help and contact support';

  @override
  String get settingRateApp => 'Rate App';

  @override
  String get settingRateAppSubtitle => 'Share your feedback with us';

  @override
  String get settingShareApp => 'Share App';

  @override
  String get settingShareAppSubtitle => 'Share with your friends';

  @override
  String get settingAbout => 'About';

  @override
  String get settingAboutSubtitle => 'App version and information';

  @override
  String get appTagline => 'Your Ultimate Music Companion';

  @override
  String get discoverHeader => 'Discover';

  @override
  String get nowPlaying => 'NOW PLAYING';

  @override
  String get searchStations => 'Search stations...';

  @override
  String noStationsMatch(String query) {
    return 'No stations match \"$query\"';
  }

  @override
  String noLanguageStations(String language) {
    return 'No $language stations found';
  }

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get tryDifferentFilter => 'Try a different search or language filter';

  @override
  String get sectionFavourites => 'Favourites';

  @override
  String get sectionRecentlyPlayed => 'Recently Played';

  @override
  String get sectionForYou => 'For You';

  @override
  String get sectionTrending => 'Trending';

  @override
  String get sectionAllStations => 'All Stations';

  @override
  String get seeAll => 'See all';

  @override
  String get mp3PlayerTitle => 'My Music';

  @override
  String get mp3TabMusic => 'Music';

  @override
  String get mp3TabDownloads => 'Downloads';

  @override
  String get mp3TabRecordings => 'Recordings';

  @override
  String get mp3NoFiles => 'No files found';

  @override
  String get mp3SearchHint => 'Search songs...';

  @override
  String get downloadTitle => 'MP3 Download';

  @override
  String get downloadSearchHint => 'Search for MP3s...';

  @override
  String get downloadSearchAction => 'Search';

  @override
  String get dialogUpdateTitle => 'Update Available';

  @override
  String dialogUpdateContent(String version) {
    return 'A new version ($version) of GR Radio is available. Please update to continue enjoying the best experience.';
  }

  @override
  String get dialogUpdateLater => 'Later';

  @override
  String get dialogUpdateNow => 'Update';

  @override
  String get dialogNoInternet => 'No Internet Connection';

  @override
  String get dialogNoInternetContent =>
      'Please check your internet connection and try again.';

  @override
  String get dialogRetry => 'RETRY';

  @override
  String get languageSelectionTitle => 'Select Language';

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
