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

  /// No description provided for @sleepTimerSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimerSheetTitle;

  /// No description provided for @sleepTimerMinutesChip.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String sleepTimerMinutesChip(int minutes);

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

  /// More screen — radio alarm clock
  ///
  /// In en, this message translates to:
  /// **'Wake me up'**
  String get settingWakeMeUp;

  /// No description provided for @settingWakeMeUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One-time, daily, or weekly radio alarm'**
  String get settingWakeMeUpSubtitle;

  /// No description provided for @wakeAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Wake me up'**
  String get wakeAlarmTitle;

  /// No description provided for @wakeAlarmHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get wakeAlarmHowItWorksTitle;

  /// No description provided for @wakeAlarmAndroidExplain.
  ///
  /// In en, this message translates to:
  /// **'Android can open GR Radio at the scheduled time and start your station, even if the app was closed. One-time alarms use the date you pick; daily and weekly alarms use the clock time (and weekdays for weekly). Allow “Alarms & reminders” (exact alarms) when asked, avoid force-stopping the app, and expect some OEMs to delay alarms if battery saving is aggressive.'**
  String get wakeAlarmAndroidExplain;

  /// No description provided for @wakeAlarmIosExplain.
  ///
  /// In en, this message translates to:
  /// **'iOS cannot start audio automatically while the app is closed. You get a notification at the chosen time — open it to play the station. Daily and weekly schedules repeat using notifications on those days. Keep notifications allowed for GR Radio.'**
  String get wakeAlarmIosExplain;

  /// No description provided for @wakeRepeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get wakeRepeatLabel;

  /// No description provided for @wakeRepeatOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get wakeRepeatOnce;

  /// No description provided for @wakeRepeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get wakeRepeatDaily;

  /// No description provided for @wakeRepeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get wakeRepeatWeekly;

  /// No description provided for @wakeWeekdaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get wakeWeekdaysLabel;

  /// No description provided for @wakeAlarmDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get wakeAlarmDate;

  /// No description provided for @wakeAlarmTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get wakeAlarmTime;

  /// No description provided for @wakeAlarmTimeRepeat.
  ///
  /// In en, this message translates to:
  /// **'Time of day'**
  String get wakeAlarmTimeRepeat;

  /// No description provided for @wakeAlarmStation.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get wakeAlarmStation;

  /// No description provided for @wakeAlarmSelectStation.
  ///
  /// In en, this message translates to:
  /// **'Choose a station'**
  String get wakeAlarmSelectStation;

  /// No description provided for @wakeAlarmSave.
  ///
  /// In en, this message translates to:
  /// **'Save wake-up'**
  String get wakeAlarmSave;

  /// No description provided for @wakeAlarmClear.
  ///
  /// In en, this message translates to:
  /// **'Clear wake-up'**
  String get wakeAlarmClear;

  /// No description provided for @wakeAlarmScheduled.
  ///
  /// In en, this message translates to:
  /// **'Wake-up saved.'**
  String get wakeAlarmScheduled;

  /// No description provided for @wakeAlarmDisabled.
  ///
  /// In en, this message translates to:
  /// **'Wake-up cleared.'**
  String get wakeAlarmDisabled;

  /// No description provided for @wakeAlarmScheduleFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check exact-alarm permission (Android) or notification permission (iOS), date/time, and weekdays for weekly.'**
  String get wakeAlarmScheduleFailed;

  /// No description provided for @wakeAlarmPickStation.
  ///
  /// In en, this message translates to:
  /// **'Choose a station first.'**
  String get wakeAlarmPickStation;

  /// No description provided for @wakeAlarmPickFuture.
  ///
  /// In en, this message translates to:
  /// **'Pick a date and time at least 30 seconds from now.'**
  String get wakeAlarmPickFuture;

  /// No description provided for @wakeAlarmPickFutureRepeat.
  ///
  /// In en, this message translates to:
  /// **'Pick a time at least 30 seconds from now for the next alarm.'**
  String get wakeAlarmPickFutureRepeat;

  /// No description provided for @wakeAlarmNoStations.
  ///
  /// In en, this message translates to:
  /// **'No stations loaded yet. Open the Radio tab first, then try again.'**
  String get wakeAlarmNoStations;

  /// No description provided for @noInternetStreamingTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet'**
  String get noInternetStreamingTitle;

  /// No description provided for @noInternetStreamingBody.
  ///
  /// In en, this message translates to:
  /// **'GR Radio requires an active internet connection to stream music. Please check your settings.'**
  String get noInternetStreamingBody;

  /// No description provided for @buttonRetryUpper.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get buttonRetryUpper;

  /// No description provided for @batteryOptimizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep Radio Playing'**
  String get batteryOptimizationTitle;

  /// No description provided for @batteryOptimizationBody.
  ///
  /// In en, this message translates to:
  /// **'To prevent the radio from stopping when your screen is off or during phone calls, please allow the app to run in the background in the next screen.'**
  String get batteryOptimizationBody;

  /// No description provided for @batteryOptimizationLater.
  ///
  /// In en, this message translates to:
  /// **'LATER'**
  String get batteryOptimizationLater;

  /// No description provided for @batteryOptimizationSettings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get batteryOptimizationSettings;

  /// No description provided for @recordingInProgressBadge.
  ///
  /// In en, this message translates to:
  /// **'RECORDING IN PROGRESS'**
  String get recordingInProgressBadge;

  /// No description provided for @sleepInHoursOnly.
  ///
  /// In en, this message translates to:
  /// **'Sleep in {h}h'**
  String sleepInHoursOnly(int h);

  /// No description provided for @sleepInHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'Sleep in {h}h {m}m'**
  String sleepInHoursMinutes(int h, int m);

  /// No description provided for @sleepInMinutesOnly.
  ///
  /// In en, this message translates to:
  /// **'Sleep in {minutes}m'**
  String sleepInMinutesOnly(int minutes);

  /// No description provided for @premiumThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you — Premium is active.'**
  String get premiumThankYou;

  /// No description provided for @premiumNoPackages.
  ///
  /// In en, this message translates to:
  /// **'No subscription package is currently available.'**
  String get premiumNoPackages;

  /// No description provided for @paywallCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open subscriptions: {error}'**
  String paywallCouldNotOpen(String error);

  /// No description provided for @shareCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not share: {error}'**
  String shareCouldNotOpen(String error);

  /// No description provided for @ratingCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open rating: {error}'**
  String ratingCouldNotOpen(String error);

  /// No description provided for @screenFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get screenFaq;

  /// No description provided for @screenTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get screenTermsOfService;

  /// No description provided for @screenPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get screenPrivacyPolicy;

  /// No description provided for @screenAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get screenAbout;

  /// No description provided for @screenNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get screenNotifications;

  /// No description provided for @screenFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback / Complaint'**
  String get screenFeedback;

  /// No description provided for @screenContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get screenContactSupport;

  /// No description provided for @buttonSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get buttonSendEmail;

  /// No description provided for @licensesThirdParty.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Licenses'**
  String get licensesThirdParty;

  /// No description provided for @languageApplicationLabel.
  ///
  /// In en, this message translates to:
  /// **'Application language'**
  String get languageApplicationLabel;

  /// No description provided for @languageListeningLabel.
  ///
  /// In en, this message translates to:
  /// **'Listening language'**
  String get languageListeningLabel;

  /// No description provided for @languageSlotLabel.
  ///
  /// In en, this message translates to:
  /// **'Language {index}'**
  String languageSlotLabel(int index);

  /// No description provided for @premiumMembershipTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Membership'**
  String get premiumMembershipTitle;

  /// No description provided for @premiumManageDevices.
  ///
  /// In en, this message translates to:
  /// **'Manage Linked Devices'**
  String get premiumManageDevices;

  /// No description provided for @premiumActivateNowUpper.
  ///
  /// In en, this message translates to:
  /// **'ACTIVATE NOW'**
  String get premiumActivateNowUpper;

  /// No description provided for @premiumActivationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Activation Successful!'**
  String get premiumActivationSuccess;

  /// No description provided for @premiumActivateError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String premiumActivateError(String error);

  /// No description provided for @premiumDeactivatedDevice.
  ///
  /// In en, this message translates to:
  /// **'Premium deactivated for this device.'**
  String get premiumDeactivatedDevice;

  /// No description provided for @premiumUnlinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlink: {error}'**
  String premiumUnlinkFailed(String error);

  /// No description provided for @activateRadioProTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate Radio Pro'**
  String get activateRadioProTitle;

  /// No description provided for @premiumActivatedAdsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Premium Activated! Ads Removed.'**
  String get premiumActivatedAdsRemoved;

  /// No description provided for @buttonActivateNow.
  ///
  /// In en, this message translates to:
  /// **'Activate Now'**
  String get buttonActivateNow;

  /// No description provided for @miniPlayerHideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide mini player'**
  String get miniPlayerHideTooltip;

  /// No description provided for @radioStreamSubtitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Radio Stream'**
  String get radioStreamSubtitleDefault;

  /// No description provided for @shareAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Hey! Check out {appName} for high-quality radio streaming and premium features. Download it here: {url}'**
  String shareAppMessage(String appName, String url);

  /// No description provided for @shareAppSubject.
  ///
  /// In en, this message translates to:
  /// **'Check out {appName}'**
  String shareAppSubject(String appName);

  /// No description provided for @copyrightFooter.
  ///
  /// In en, this message translates to:
  /// **'© {year} {appName}. All rights reserved.'**
  String copyrightFooter(String year, String appName);

  /// No description provided for @faq1Question.
  ///
  /// In en, this message translates to:
  /// **'How do I find and play a station?'**
  String get faq1Question;

  /// No description provided for @faq1Answer.
  ///
  /// In en, this message translates to:
  /// **'Open the Radio tab, browse or search the station list, and tap a station to start playback. Use the search field and language filters where available to narrow results.'**
  String get faq1Answer;

  /// No description provided for @faq2Question.
  ///
  /// In en, this message translates to:
  /// **'Why does playback buffer, pause, or stop?'**
  String get faq2Question;

  /// No description provided for @faq2Answer.
  ///
  /// In en, this message translates to:
  /// **'Live streaming needs a stable internet connection. Try Wi‑Fi or a stronger signal. On Android, battery optimisation can stop background audio—when prompted, allow the app to run in the background so playback can continue with the screen off.'**
  String get faq2Answer;

  /// No description provided for @faq3Question.
  ///
  /// In en, this message translates to:
  /// **'How does Premium work?'**
  String get faq3Question;

  /// No description provided for @faq3Answer.
  ///
  /// In en, this message translates to:
  /// **'Open More → Go Premium to see subscription options processed by Google Play or Apple. Premium may remove ads and unlock extras shown at purchase time. You can restore purchases on a new device when signed in with the same store account. Some flows may also use licence keys or linked devices where offered in the app.'**
  String get faq3Answer;

  /// No description provided for @faq4Question.
  ///
  /// In en, this message translates to:
  /// **'Can I listen without the internet?'**
  String get faq4Question;

  /// No description provided for @faq4Answer.
  ///
  /// In en, this message translates to:
  /// **'Live radio streams need an active connection. Items in the Downloads area may play offline depending on how they were obtained and any licensing limits.'**
  String get faq4Answer;

  /// No description provided for @faq5Question.
  ///
  /// In en, this message translates to:
  /// **'How do recordings work?'**
  String get faq5Question;

  /// No description provided for @faq5Answer.
  ///
  /// In en, this message translates to:
  /// **'Where recording is available for a live stream, audio is saved to your device storage. Use recordings only for personal, lawful purposes and respect broadcaster and copyright rules in your country.'**
  String get faq5Answer;

  /// No description provided for @faq6Question.
  ///
  /// In en, this message translates to:
  /// **'What are the sleep timer and Wake me up?'**
  String get faq6Question;

  /// No description provided for @faq6Answer.
  ///
  /// In en, this message translates to:
  /// **'The sleep timer stops playback after a delay you choose. Wake me up schedules a station to start at a set time where supported; on Android this may require notification or exact-alarm permission.'**
  String get faq6Answer;

  /// No description provided for @faq7Question.
  ///
  /// In en, this message translates to:
  /// **'How do I favourite a station?'**
  String get faq7Question;

  /// No description provided for @faq7Answer.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on a station in the list or player. Your favourites appear in a dedicated section on the Radio screen for quick access.'**
  String get faq7Answer;

  /// No description provided for @faq8Question.
  ///
  /// In en, this message translates to:
  /// **'How do I get help or report a problem?'**
  String get faq8Question;

  /// No description provided for @faq8Answer.
  ///
  /// In en, this message translates to:
  /// **'Go to More → Help & Support to send feedback or find contact options. You can also email us from the About screen.'**
  String get faq8Answer;

  /// No description provided for @terms1Title.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of terms'**
  String get terms1Title;

  /// No description provided for @terms1Body.
  ///
  /// In en, this message translates to:
  /// **'By downloading or using {appName}, you agree to these Terms of Service. If you do not agree, do not use the app.'**
  String terms1Body(String appName);

  /// No description provided for @terms2Title.
  ///
  /// In en, this message translates to:
  /// **'The service'**
  String get terms2Title;

  /// No description provided for @terms2Body.
  ///
  /// In en, this message translates to:
  /// **'{appName} lets you stream live radio stations, access downloadable audio offered through the app, record streams where the feature is available, use playback tools such as a sleep timer, and receive optional notifications and scheduled playback (including alarms on supported devices). Features may vary by platform or version. We may change, suspend, or discontinue any part of the service where reasonably necessary.'**
  String terms2Body(String appName);

  /// No description provided for @terms3Title.
  ///
  /// In en, this message translates to:
  /// **'Premium, purchases, and licences'**
  String get terms3Title;

  /// No description provided for @terms3Body.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions or one-time purchases may be processed by third parties including your app store and services such as RevenueCat. Some flows may use a licence key or device linking; where that applies, limits (for example the number of linked devices) are shown in the app. Pricing, renewal, cancellation, and refunds follow the store or provider rules. You are responsible for applicable taxes and charges.'**
  String get terms3Body;

  /// No description provided for @terms4Title.
  ///
  /// In en, this message translates to:
  /// **'Acceptable use'**
  String get terms4Title;

  /// No description provided for @terms4Body.
  ///
  /// In en, this message translates to:
  /// **'You use {appName} only for lawful, personal listening unless otherwise allowed. You must not misuse the app, bypass payment or entitlement checks, attack or overload our or others’ systems, or redistribute streams, downloads, or recordings in a way that infringes copyright or broadcaster terms. You are responsible for mobile data costs and for complying with local laws.'**
  String terms4Body(String appName);

  /// No description provided for @terms5Title.
  ///
  /// In en, this message translates to:
  /// **'Third-party stations and content'**
  String get terms5Title;

  /// No description provided for @terms5Body.
  ///
  /// In en, this message translates to:
  /// **'Streams, artwork, track metadata, and downloadable content come from third parties. {appName} does not own or control that material. Availability and quality depend on those sources and your connection. We do not guarantee any station or track will always be available.'**
  String terms5Body(String appName);

  /// No description provided for @terms6Title.
  ///
  /// In en, this message translates to:
  /// **'Disclaimers and liability'**
  String get terms6Title;

  /// No description provided for @terms6Body.
  ///
  /// In en, this message translates to:
  /// **'The service is provided as-is without warranties to the fullest extent permitted by law. We are not liable for indirect damages, data charges, outages, lost recordings, or alarm failures. Some regions do not allow certain exclusions; in those cases our liability is limited as the law allows.'**
  String get terms6Body;

  /// No description provided for @terms7Title.
  ///
  /// In en, this message translates to:
  /// **'Changes and contact'**
  String get terms7Title;

  /// No description provided for @terms7Body.
  ///
  /// In en, this message translates to:
  /// **'We may update these terms; continued use after the update means you accept the revised terms. For questions, contact us at {supportEmail}.'**
  String terms7Body(String supportEmail);

  /// No description provided for @privacy1Title.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get privacy1Title;

  /// No description provided for @privacy1Body.
  ///
  /// In en, this message translates to:
  /// **'This Privacy Policy explains how {appName} handles information when you use our mobile app. Read it together with our Terms of Service.'**
  String privacy1Body(String appName);

  /// No description provided for @privacy2Title.
  ///
  /// In en, this message translates to:
  /// **'Information we collect'**
  String get privacy2Title;

  /// No description provided for @privacy2Body.
  ///
  /// In en, this message translates to:
  /// **'• Device and app identifiers may be sent to our backend for configuration, operational logs, fraud prevention, and to support premium or device limits.\n• We may log general usage (for example screens or actions) to improve the product.\n• Purchases: payment is handled by the app store; subscription state may be processed by providers such as RevenueCat—we do not receive your full card number.\n• Ads: when enabled, Google Mobile Ads (AdMob) may use advertising identifiers under Google’s policies.\n• Notifications: if you opt in, Firebase Cloud Messaging may use a push token to deliver messages.\n• Content you create (recordings, downloads) is stored on your device unless you export or share it yourself.'**
  String get privacy2Body;

  /// No description provided for @privacy3Title.
  ///
  /// In en, this message translates to:
  /// **'How we use information'**
  String get privacy3Title;

  /// No description provided for @privacy3Body.
  ///
  /// In en, this message translates to:
  /// **'We use this data to run and improve {appName}, deliver premium entitlements, show ads when they are on, send notifications you request, protect the service, and meet legal obligations. We do not sell your personal information for money.'**
  String privacy3Body(String appName);

  /// No description provided for @privacy4Title.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get privacy4Title;

  /// No description provided for @privacy4Body.
  ///
  /// In en, this message translates to:
  /// **'The app may ask for internet access, storage or media access (for downloads and recordings), notifications, exact alarms on some Android versions for scheduled playback, and microphone access only if you use speech-related features. You can change many permissions in system settings; denying some may limit features.'**
  String get privacy4Body;

  /// No description provided for @privacy5Title.
  ///
  /// In en, this message translates to:
  /// **'Third-party services'**
  String get privacy5Title;

  /// No description provided for @privacy5Body.
  ///
  /// In en, this message translates to:
  /// **'We use providers such as Google (including FCM and AdMob where applicable), Apple platform services on iOS, RevenueCat for purchases, and our own backend API. Their practices are described in their policies. Radio streams and downloadable media come from third-party sources outside our control.'**
  String get privacy5Body;

  /// No description provided for @privacy6Title.
  ///
  /// In en, this message translates to:
  /// **'Retention and security'**
  String get privacy6Title;

  /// No description provided for @privacy6Body.
  ///
  /// In en, this message translates to:
  /// **'We keep server logs only as long as needed for the purposes above and reasonable security. No method of transmission or storage is completely secure; we use safeguards appropriate to the data we handle.'**
  String get privacy6Body;

  /// No description provided for @privacy7Title.
  ///
  /// In en, this message translates to:
  /// **'Children’s privacy'**
  String get privacy7Title;

  /// No description provided for @privacy7Body.
  ///
  /// In en, this message translates to:
  /// **'{appName} is not aimed at children under the age required in your country for consent without a parent. We do not knowingly collect personal data from young children. Contact us if you believe we have, and we will delete it where the law requires.'**
  String privacy7Body(String appName);

  /// No description provided for @privacy8Title.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacy8Title;

  /// No description provided for @privacy8Body.
  ///
  /// In en, this message translates to:
  /// **'Questions about this policy or your data: email {supportEmail}. We may update this policy from time to time; the date below shows the latest revision.'**
  String privacy8Body(String supportEmail);

  /// No description provided for @privacyLastUpdatedFooter.
  ///
  /// In en, this message translates to:
  /// **'Last updated: April 2026'**
  String get privacyLastUpdatedFooter;

  /// No description provided for @aboutIntroBody.
  ///
  /// In en, this message translates to:
  /// **'{appName} helps you discover live radio, keep favourites, use downloads where available, and tools like a sleep timer and optional wake-up playback. Premium can reduce ads and add features described at purchase. Thanks for listening!'**
  String aboutIntroBody(String appName);

  /// No description provided for @aboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersionLabel(String version);

  /// No description provided for @aboutLabelDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get aboutLabelDeveloper;

  /// No description provided for @aboutDeveloperName.
  ///
  /// In en, this message translates to:
  /// **'Govardhana Rao Sugrivugari'**
  String get aboutDeveloperName;

  /// No description provided for @aboutLabelContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get aboutLabelContact;

  /// No description provided for @aboutLabelWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutLabelWebsite;

  /// No description provided for @aboutWebsiteDisplay.
  ///
  /// In en, this message translates to:
  /// **'www.grradio.com'**
  String get aboutWebsiteDisplay;

  /// No description provided for @aboutEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'{appName} — support enquiry'**
  String aboutEmailSubject(String appName);

  /// No description provided for @faqScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answers about stations, Premium, recordings, alarms, and more'**
  String get faqScreenSubtitle;

  /// No description provided for @contactSupportTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reach our support team by email or form'**
  String get contactSupportTileSubtitle;

  /// No description provided for @feedbackFormTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report an issue or share a suggestion'**
  String get feedbackFormTileSubtitle;
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
