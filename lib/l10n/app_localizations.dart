import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('ta'),
    Locale('te'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'GR Radio'**
  String get appName;

  /// Bottom nav tab label
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get tabRadio;

  /// Bottom nav tab label
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get tabPlayer;

  /// Bottom nav tab label
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get tabDownloads;

  /// Bottom nav tab label
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// More screen section header
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sectionSettings;

  /// More screen section header
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get sectionSupport;

  /// No description provided for @settingDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingDarkMode;

  /// No description provided for @settingDarkModeOnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dark theme is on'**
  String get settingDarkModeOnSubtitle;

  /// No description provided for @settingDarkModeOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light theme is on'**
  String get settingDarkModeOffSubtitle;

  /// No description provided for @settingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingLanguage;

  /// No description provided for @settingLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get settingLanguageSubtitle;

  /// No description provided for @settingGoPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium (Ad-Free)'**
  String get settingGoPremium;

  /// No description provided for @settingGoPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features with a subscription'**
  String get settingGoPremiumSubtitle;

  /// No description provided for @settingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingNotifications;

  /// No description provided for @settingNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your notification preferences'**
  String get settingNotificationsSubtitle;

  /// No description provided for @settingHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settingHelpSupport;

  /// No description provided for @settingHelpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help and contact support'**
  String get settingHelpSupportSubtitle;

  /// No description provided for @settingRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get settingRateApp;

  /// No description provided for @settingRateAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your feedback with us'**
  String get settingRateAppSubtitle;

  /// No description provided for @settingShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get settingShareApp;

  /// No description provided for @settingShareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share with your friends'**
  String get settingShareAppSubtitle;

  /// No description provided for @settingAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingAbout;

  /// No description provided for @settingAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get settingAboutSubtitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Ultimate Music Companion'**
  String get appTagline;

  /// Radio screen header
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverHeader;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'NOW PLAYING'**
  String get nowPlaying;

  /// No description provided for @searchStations.
  ///
  /// In en, this message translates to:
  /// **'Search stations...'**
  String get searchStations;

  /// No description provided for @noStationsMatch.
  ///
  /// In en, this message translates to:
  /// **'No stations match \"{query}\"'**
  String noStationsMatch(String query);

  /// No description provided for @noLanguageStations.
  ///
  /// In en, this message translates to:
  /// **'No {language} stations found'**
  String noLanguageStations(String language);

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @tryDifferentFilter.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or language filter'**
  String get tryDifferentFilter;

  /// No description provided for @sectionFavourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get sectionFavourites;

  /// No description provided for @sectionRecentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get sectionRecentlyPlayed;

  /// No description provided for @sectionForYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get sectionForYou;

  /// No description provided for @sectionTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get sectionTrending;

  /// No description provided for @sectionAllStations.
  ///
  /// In en, this message translates to:
  /// **'All Stations'**
  String get sectionAllStations;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @mp3PlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'My Music'**
  String get mp3PlayerTitle;

  /// No description provided for @mp3TabMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get mp3TabMusic;

  /// No description provided for @mp3TabDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get mp3TabDownloads;

  /// No description provided for @mp3TabRecordings.
  ///
  /// In en, this message translates to:
  /// **'Recordings'**
  String get mp3TabRecordings;

  /// No description provided for @mp3NoFiles.
  ///
  /// In en, this message translates to:
  /// **'No files found'**
  String get mp3NoFiles;

  /// No description provided for @mp3SearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search songs...'**
  String get mp3SearchHint;

  /// No description provided for @downloadTitle.
  ///
  /// In en, this message translates to:
  /// **'MP3 Download'**
  String get downloadTitle;

  /// No description provided for @downloadSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for MP3s...'**
  String get downloadSearchHint;

  /// No description provided for @downloadSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get downloadSearchAction;

  /// No description provided for @dialogUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get dialogUpdateTitle;

  /// No description provided for @dialogUpdateContent.
  ///
  /// In en, this message translates to:
  /// **'A new version ({version}) of GR Radio is available. Please update to continue enjoying the best experience.'**
  String dialogUpdateContent(String version);

  /// No description provided for @dialogUpdateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get dialogUpdateLater;

  /// No description provided for @dialogUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get dialogUpdateNow;

  /// No description provided for @dialogNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get dialogNoInternet;

  /// No description provided for @dialogNoInternetContent.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get dialogNoInternetContent;

  /// No description provided for @dialogRetry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get dialogRetry;

  /// No description provided for @languageSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageSelectionTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'عربي (Arabic)'**
  String get languageArabic;

  /// No description provided for @languageTelugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు (Telugu)'**
  String get languageTelugu;

  /// No description provided for @languageTamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ் (Tamil)'**
  String get languageTamil;

  /// No description provided for @languageKannada.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ (Kannada)'**
  String get languageKannada;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी (Hindi)'**
  String get languageHindi;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get buttonDelete;

  /// No description provided for @buttonRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get buttonRename;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// No description provided for @buttonOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get buttonOverwrite;

  /// No description provided for @buttonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get buttonTryAgain;

  /// No description provided for @buttonAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get buttonAllow;

  /// No description provided for @buttonOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get buttonOpenSettings;

  /// No description provided for @buttonGrantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get buttonGrantPermission;

  /// No description provided for @mp3DeleteFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete files'**
  String get mp3DeleteFilesTitle;

  /// No description provided for @mp3DeleteFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete file'**
  String get mp3DeleteFileTitle;

  /// No description provided for @mp3DeleteFileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String mp3DeleteFileConfirm(String name);

  /// No description provided for @sleepIn10.
  ///
  /// In en, this message translates to:
  /// **'Sleep in 10 minutes'**
  String get sleepIn10;

  /// No description provided for @sleepIn20.
  ///
  /// In en, this message translates to:
  /// **'Sleep in 20 minutes'**
  String get sleepIn20;

  /// No description provided for @sleepIn30.
  ///
  /// In en, this message translates to:
  /// **'Sleep in 30 minutes'**
  String get sleepIn30;

  /// No description provided for @sleepIn45.
  ///
  /// In en, this message translates to:
  /// **'Sleep in 45 minutes'**
  String get sleepIn45;

  /// No description provided for @sleepIn60.
  ///
  /// In en, this message translates to:
  /// **'Sleep in 60 minutes'**
  String get sleepIn60;

  /// No description provided for @sleepCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel sleep timer'**
  String get sleepCancel;

  /// No description provided for @recordingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Recording name'**
  String get recordingNameHint;

  /// No description provided for @emptyNoMusicTitle.
  ///
  /// In en, this message translates to:
  /// **'No Music Found'**
  String get emptyNoMusicTitle;

  /// No description provided for @emptyNoMusicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your device storage for MP3 files.'**
  String get emptyNoMusicSubtitle;

  /// No description provided for @emptyNoDownloadsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Downloads'**
  String get emptyNoDownloadsTitle;

  /// No description provided for @emptyNoDownloadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Songs you download will appear here.'**
  String get emptyNoDownloadsSubtitle;

  /// No description provided for @emptyNoRecordingsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Recordings'**
  String get emptyNoRecordingsTitle;

  /// No description provided for @emptyNoRecordingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your radio recordings will be saved here.'**
  String get emptyNoRecordingsSubtitle;

  /// No description provided for @searchSongsHint.
  ///
  /// In en, this message translates to:
  /// **'Search songs...'**
  String get searchSongsHint;

  /// No description provided for @searchDownloadsHint.
  ///
  /// In en, this message translates to:
  /// **'Search downloads...'**
  String get searchDownloadsHint;

  /// No description provided for @searchRecordingsHint.
  ///
  /// In en, this message translates to:
  /// **'Search recordings...'**
  String get searchRecordingsHint;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @permissionStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage Permission Required'**
  String get permissionStorageTitle;

  /// No description provided for @permissionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequiredTitle;

  /// No description provided for @downloadCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Download Complete'**
  String get downloadCompleteTitle;

  /// No description provided for @downloadFileLabel.
  ///
  /// In en, this message translates to:
  /// **'File: {name}'**
  String downloadFileLabel(String name);

  /// No description provided for @downloadSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size: {size}'**
  String downloadSizeLabel(String size);

  /// No description provided for @fileExistsTitle.
  ///
  /// In en, this message translates to:
  /// **'File Exists'**
  String get fileExistsTitle;

  /// No description provided for @tabAlbumsFolders.
  ///
  /// In en, this message translates to:
  /// **'Albums/Folders'**
  String get tabAlbumsFolders;

  /// No description provided for @tabIndividualFiles.
  ///
  /// In en, this message translates to:
  /// **'Individual Files'**
  String get tabIndividualFiles;

  /// No description provided for @masstamilanTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest Telugu Albums'**
  String get masstamilanTitle;

  /// No description provided for @stopRecordingBeforeSwitch.
  ///
  /// In en, this message translates to:
  /// **'Stop recording before switching tabs.'**
  String get stopRecordingBeforeSwitch;

  /// No description provided for @mp3DownloadSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Movie name, song, artist.'**
  String get mp3DownloadSearchHint;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get instant help from our AI'**
  String get aiAssistantSubtitle;

  /// No description provided for @aiChatHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get aiChatHint;

  /// No description provided for @aiTyping.
  ///
  /// In en, this message translates to:
  /// **'AI is typing...'**
  String get aiTyping;

  /// No description provided for @aiClearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get aiClearChat;

  /// No description provided for @aiClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear chat history?'**
  String get aiClearConfirm;

  /// No description provided for @aiContactHuman.
  ///
  /// In en, this message translates to:
  /// **'Contact Human Support'**
  String get aiContactHuman;

  /// No description provided for @aiWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m GR Radio\'s AI assistant. How can I help you today?'**
  String get aiWelcome;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'Failed to get response, please try again.'**
  String get aiError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'hi',
    'kn',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
