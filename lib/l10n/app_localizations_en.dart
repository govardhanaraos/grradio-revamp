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

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDelete => 'DELETE';

  @override
  String get buttonRename => 'Rename';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonOverwrite => 'Overwrite';

  @override
  String get buttonTryAgain => 'Try Again';

  @override
  String get buttonAllow => 'Allow';

  @override
  String get buttonOpenSettings => 'Open Settings';

  @override
  String get buttonGrantPermission => 'Grant Permission';

  @override
  String get mp3DeleteFilesTitle => 'Delete files';

  @override
  String get mp3DeleteFileTitle => 'Delete file';

  @override
  String mp3DeleteFileConfirm(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get sleepIn10 => 'Sleep in 10 minutes';

  @override
  String get sleepIn20 => 'Sleep in 20 minutes';

  @override
  String get sleepIn30 => 'Sleep in 30 minutes';

  @override
  String get sleepIn45 => 'Sleep in 45 minutes';

  @override
  String get sleepIn60 => 'Sleep in 60 minutes';

  @override
  String get sleepCancel => 'Cancel sleep timer';

  @override
  String get recordingNameHint => 'Recording name';

  @override
  String get emptyNoMusicTitle => 'No Music Found';

  @override
  String get emptyNoMusicSubtitle => 'Check your device storage for MP3 files.';

  @override
  String get emptyNoDownloadsTitle => 'No Downloads';

  @override
  String get emptyNoDownloadsSubtitle => 'Songs you download will appear here.';

  @override
  String get emptyNoRecordingsTitle => 'No Recordings';

  @override
  String get emptyNoRecordingsSubtitle =>
      'Your radio recordings will be saved here.';

  @override
  String get searchSongsHint => 'Search songs...';

  @override
  String get searchDownloadsHint => 'Search downloads...';

  @override
  String get searchRecordingsHint => 'Search recordings...';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get permissionStorageTitle => 'Storage Permission Required';

  @override
  String get permissionRequiredTitle => 'Permission Required';

  @override
  String get downloadCompleteTitle => 'Download Complete';

  @override
  String downloadFileLabel(String name) {
    return 'File: $name';
  }

  @override
  String downloadSizeLabel(String size) {
    return 'Size: $size';
  }

  @override
  String get fileExistsTitle => 'File Exists';

  @override
  String get tabAlbumsFolders => 'Albums/Folders';

  @override
  String get tabIndividualFiles => 'Individual Files';

  @override
  String get masstamilanTitle => 'Latest Telugu Albums';

  @override
  String get stopRecordingBeforeSwitch =>
      'Stop recording before switching tabs.';

  @override
  String get mp3DownloadSearchHint => 'Movie name, song, artist.';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get aiAssistantSubtitle => 'Get instant help from our AI';

  @override
  String get aiChatHint => 'Type a message...';

  @override
  String get aiTyping => 'AI is typing...';

  @override
  String get aiClearChat => 'Clear Chat';

  @override
  String get aiClearConfirm => 'Are you sure you want to clear chat history?';

  @override
  String get aiContactHuman => 'Contact Human Support';

  @override
  String get aiWelcome =>
      'Hi! I\'m GR Radio\'s AI assistant. How can I help you today?';

  @override
  String get aiError => 'Failed to get response, please try again.';
}
