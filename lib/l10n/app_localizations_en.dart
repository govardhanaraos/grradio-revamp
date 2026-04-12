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
  String get sleepTimerSheetTitle => 'Sleep timer';

  @override
  String sleepTimerMinutesChip(int minutes) {
    return '$minutes min';
  }

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

  @override
  String get settingWakeMeUp => 'Wake me up';

  @override
  String get settingWakeMeUpSubtitle =>
      'One-time, daily, or weekly radio alarm';

  @override
  String get wakeAlarmTitle => 'Wake me up';

  @override
  String get wakeAlarmHowItWorksTitle => 'How it works';

  @override
  String get wakeAlarmAndroidExplain =>
      'Android can open GR Radio at the scheduled time and start your station, even if the app was closed. One-time alarms use the date you pick; daily and weekly alarms use the clock time (and weekdays for weekly). Allow “Alarms & reminders” (exact alarms) when asked, avoid force-stopping the app, and expect some OEMs to delay alarms if battery saving is aggressive.';

  @override
  String get wakeAlarmIosExplain =>
      'iOS cannot start audio automatically while the app is closed. You get a notification at the chosen time — open it to play the station. Daily and weekly schedules repeat using notifications on those days. Keep notifications allowed for GR Radio.';

  @override
  String get wakeRepeatLabel => 'Repeat';

  @override
  String get wakeRepeatOnce => 'Once';

  @override
  String get wakeRepeatDaily => 'Daily';

  @override
  String get wakeRepeatWeekly => 'Weekly';

  @override
  String get wakeWeekdaysLabel => 'Days';

  @override
  String get wakeAlarmDate => 'Date';

  @override
  String get wakeAlarmTime => 'Time';

  @override
  String get wakeAlarmTimeRepeat => 'Time of day';

  @override
  String get wakeAlarmStation => 'Station';

  @override
  String get wakeAlarmSelectStation => 'Choose a station';

  @override
  String get wakeAlarmSave => 'Save wake-up';

  @override
  String get wakeAlarmClear => 'Clear wake-up';

  @override
  String get wakeAlarmScheduled => 'Wake-up saved.';

  @override
  String get wakeAlarmDisabled => 'Wake-up cleared.';

  @override
  String get wakeAlarmScheduleFailed =>
      'Could not save. Check exact-alarm permission (Android) or notification permission (iOS), date/time, and weekdays for weekly.';

  @override
  String get wakeAlarmPickStation => 'Choose a station first.';

  @override
  String get wakeAlarmPickFuture =>
      'Pick a date and time at least 30 seconds from now.';

  @override
  String get wakeAlarmPickFutureRepeat =>
      'Pick a time at least 30 seconds from now for the next alarm.';

  @override
  String get wakeAlarmNoStations =>
      'No stations loaded yet. Open the Radio tab first, then try again.';

  @override
  String get noInternetStreamingTitle => 'No Internet';

  @override
  String get noInternetStreamingBody =>
      'GR Radio requires an active internet connection to stream music. Please check your settings.';

  @override
  String get buttonRetryUpper => 'RETRY';

  @override
  String get batteryOptimizationTitle => 'Keep Radio Playing';

  @override
  String get batteryOptimizationBody =>
      'To prevent the radio from stopping when your screen is off or during phone calls, please allow the app to run in the background in the next screen.';

  @override
  String get batteryOptimizationLater => 'LATER';

  @override
  String get batteryOptimizationSettings => 'SETTINGS';

  @override
  String get recordingInProgressBadge => 'RECORDING IN PROGRESS';

  @override
  String sleepInHoursOnly(int h) {
    return 'Sleep in ${h}h';
  }

  @override
  String sleepInHoursMinutes(int h, int m) {
    return 'Sleep in ${h}h ${m}m';
  }

  @override
  String sleepInMinutesOnly(int minutes) {
    return 'Sleep in ${minutes}m';
  }

  @override
  String get premiumThankYou => 'Thank you — Premium is active.';

  @override
  String get premiumNoPackages =>
      'No subscription package is currently available.';

  @override
  String paywallCouldNotOpen(String error) {
    return 'Could not open subscriptions: $error';
  }

  @override
  String shareCouldNotOpen(String error) {
    return 'Could not share: $error';
  }

  @override
  String ratingCouldNotOpen(String error) {
    return 'Could not open rating: $error';
  }

  @override
  String get screenFaq => 'FAQ';

  @override
  String get screenTermsOfService => 'Terms of Service';

  @override
  String get screenPrivacyPolicy => 'Privacy Policy';

  @override
  String get screenAbout => 'About';

  @override
  String get screenNotifications => 'Notifications';

  @override
  String get screenFeedback => 'Feedback / Complaint';

  @override
  String get screenContactSupport => 'Contact Support';

  @override
  String get buttonSendEmail => 'Send Email';

  @override
  String get licensesThirdParty => 'Third-Party Licenses';

  @override
  String get languageApplicationLabel => 'Application language';

  @override
  String get languageListeningLabel => 'Listening language';

  @override
  String languageSlotLabel(int index) {
    return 'Language $index';
  }

  @override
  String get premiumMembershipTitle => 'Premium Membership';

  @override
  String get premiumManageDevices => 'Manage Linked Devices';

  @override
  String get premiumActivateNowUpper => 'ACTIVATE NOW';

  @override
  String get premiumActivationSuccess => 'Activation Successful!';

  @override
  String premiumActivateError(String error) {
    return 'Error: $error';
  }

  @override
  String get premiumDeactivatedDevice => 'Premium deactivated for this device.';

  @override
  String premiumUnlinkFailed(String error) {
    return 'Failed to unlink: $error';
  }

  @override
  String get activateRadioProTitle => 'Activate Radio Pro';

  @override
  String get premiumActivatedAdsRemoved => 'Premium Activated! Ads Removed.';

  @override
  String get buttonActivateNow => 'Activate Now';

  @override
  String get miniPlayerHideTooltip => 'Hide mini player';

  @override
  String get radioStreamSubtitleDefault => 'Radio Stream';

  @override
  String shareAppMessage(String appName, String url) {
    return 'Hey! Check out $appName for high-quality radio streaming and premium features. Download it here: $url';
  }

  @override
  String shareAppSubject(String appName) {
    return 'Check out $appName';
  }

  @override
  String copyrightFooter(String year, String appName) {
    return '© $year $appName. All rights reserved.';
  }

  @override
  String get faq1Question => 'How do I find and play a station?';

  @override
  String get faq1Answer =>
      'Open the Radio tab, browse or search the station list, and tap a station to start playback. Use the search field and language filters where available to narrow results.';

  @override
  String get faq2Question => 'Why does playback buffer, pause, or stop?';

  @override
  String get faq2Answer =>
      'Live streaming needs a stable internet connection. Try Wi‑Fi or a stronger signal. On Android, battery optimisation can stop background audio—when prompted, allow the app to run in the background so playback can continue with the screen off.';

  @override
  String get faq3Question => 'How does Premium work?';

  @override
  String get faq3Answer =>
      'Open More → Go Premium to see subscription options processed by Google Play or Apple. Premium may remove ads and unlock extras shown at purchase time. You can restore purchases on a new device when signed in with the same store account. Some flows may also use licence keys or linked devices where offered in the app.';

  @override
  String get faq4Question => 'Can I listen without the internet?';

  @override
  String get faq4Answer =>
      'Live radio streams need an active connection. Items in the Downloads area may play offline depending on how they were obtained and any licensing limits.';

  @override
  String get faq5Question => 'How do recordings work?';

  @override
  String get faq5Answer =>
      'Where recording is available for a live stream, audio is saved to your device storage. Use recordings only for personal, lawful purposes and respect broadcaster and copyright rules in your country.';

  @override
  String get faq6Question => 'What are the sleep timer and Wake me up?';

  @override
  String get faq6Answer =>
      'The sleep timer stops playback after a delay you choose. Wake me up schedules a station to start at a set time where supported; on Android this may require notification or exact-alarm permission.';

  @override
  String get faq7Question => 'How do I favourite a station?';

  @override
  String get faq7Answer =>
      'Tap the heart icon on a station in the list or player. Your favourites appear in a dedicated section on the Radio screen for quick access.';

  @override
  String get faq8Question => 'How do I get help or report a problem?';

  @override
  String get faq8Answer =>
      'Go to More → Help & Support to send feedback or find contact options. You can also email us from the About screen.';

  @override
  String get terms1Title => 'Acceptance of terms';

  @override
  String terms1Body(String appName) {
    return 'By downloading or using $appName, you agree to these Terms of Service. If you do not agree, do not use the app.';
  }

  @override
  String get terms2Title => 'The service';

  @override
  String terms2Body(String appName) {
    return '$appName lets you stream live radio stations, access downloadable audio offered through the app, record streams where the feature is available, use playback tools such as a sleep timer, and receive optional notifications and scheduled playback (including alarms on supported devices). Features may vary by platform or version. We may change, suspend, or discontinue any part of the service where reasonably necessary.';
  }

  @override
  String get terms3Title => 'Premium, purchases, and licences';

  @override
  String get terms3Body =>
      'Subscriptions or one-time purchases may be processed by third parties including your app store and services such as RevenueCat. Some flows may use a licence key or device linking; where that applies, limits (for example the number of linked devices) are shown in the app. Pricing, renewal, cancellation, and refunds follow the store or provider rules. You are responsible for applicable taxes and charges.';

  @override
  String get terms4Title => 'Acceptable use';

  @override
  String terms4Body(String appName) {
    return 'You use $appName only for lawful, personal listening unless otherwise allowed. You must not misuse the app, bypass payment or entitlement checks, attack or overload our or others’ systems, or redistribute streams, downloads, or recordings in a way that infringes copyright or broadcaster terms. You are responsible for mobile data costs and for complying with local laws.';
  }

  @override
  String get terms5Title => 'Third-party stations and content';

  @override
  String terms5Body(String appName) {
    return 'Streams, artwork, track metadata, and downloadable content come from third parties. $appName does not own or control that material. Availability and quality depend on those sources and your connection. We do not guarantee any station or track will always be available.';
  }

  @override
  String get terms6Title => 'Disclaimers and liability';

  @override
  String get terms6Body =>
      'The service is provided as-is without warranties to the fullest extent permitted by law. We are not liable for indirect damages, data charges, outages, lost recordings, or alarm failures. Some regions do not allow certain exclusions; in those cases our liability is limited as the law allows.';

  @override
  String get terms7Title => 'Changes and contact';

  @override
  String terms7Body(String supportEmail) {
    return 'We may update these terms; continued use after the update means you accept the revised terms. For questions, contact us at $supportEmail.';
  }

  @override
  String get privacy1Title => 'Introduction';

  @override
  String privacy1Body(String appName) {
    return 'This Privacy Policy explains how $appName handles information when you use our mobile app. Read it together with our Terms of Service.';
  }

  @override
  String get privacy2Title => 'Information we collect';

  @override
  String get privacy2Body =>
      '• Device and app identifiers may be sent to our backend for configuration, operational logs, fraud prevention, and to support premium or device limits.\n• We may log general usage (for example screens or actions) to improve the product.\n• Purchases: payment is handled by the app store; subscription state may be processed by providers such as RevenueCat—we do not receive your full card number.\n• Ads: when enabled, Google Mobile Ads (AdMob) may use advertising identifiers under Google’s policies.\n• Notifications: if you opt in, Firebase Cloud Messaging may use a push token to deliver messages.\n• Content you create (recordings, downloads) is stored on your device unless you export or share it yourself.';

  @override
  String get privacy3Title => 'How we use information';

  @override
  String privacy3Body(String appName) {
    return 'We use this data to run and improve $appName, deliver premium entitlements, show ads when they are on, send notifications you request, protect the service, and meet legal obligations. We do not sell your personal information for money.';
  }

  @override
  String get privacy4Title => 'Permissions';

  @override
  String get privacy4Body =>
      'The app may ask for internet access, storage or media access (for downloads and recordings), notifications, exact alarms on some Android versions for scheduled playback, and microphone access only if you use speech-related features. You can change many permissions in system settings; denying some may limit features.';

  @override
  String get privacy5Title => 'Third-party services';

  @override
  String get privacy5Body =>
      'We use providers such as Google (including FCM and AdMob where applicable), Apple platform services on iOS, RevenueCat for purchases, and our own backend API. Their practices are described in their policies. Radio streams and downloadable media come from third-party sources outside our control.';

  @override
  String get privacy6Title => 'Retention and security';

  @override
  String get privacy6Body =>
      'We keep server logs only as long as needed for the purposes above and reasonable security. No method of transmission or storage is completely secure; we use safeguards appropriate to the data we handle.';

  @override
  String get privacy7Title => 'Children’s privacy';

  @override
  String privacy7Body(String appName) {
    return '$appName is not aimed at children under the age required in your country for consent without a parent. We do not knowingly collect personal data from young children. Contact us if you believe we have, and we will delete it where the law requires.';
  }

  @override
  String get privacy8Title => 'Contact';

  @override
  String privacy8Body(String supportEmail) {
    return 'Questions about this policy or your data: email $supportEmail. We may update this policy from time to time; the date below shows the latest revision.';
  }

  @override
  String get privacyLastUpdatedFooter => 'Last updated: April 2026';

  @override
  String aboutIntroBody(String appName) {
    return '$appName helps you discover live radio, keep favourites, use downloads where available, and tools like a sleep timer and optional wake-up playback. Premium can reduce ads and add features described at purchase. Thanks for listening!';
  }

  @override
  String aboutVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutLabelDeveloper => 'Developer';

  @override
  String get aboutDeveloperName => 'Govardhana Rao Sugrivugari';

  @override
  String get aboutLabelContact => 'Contact';

  @override
  String get aboutLabelWebsite => 'Website';

  @override
  String get aboutWebsiteDisplay => 'www.grradio.com';

  @override
  String aboutEmailSubject(String appName) {
    return '$appName — support enquiry';
  }

  @override
  String get faqScreenSubtitle =>
      'Answers about stations, Premium, recordings, alarms, and more';

  @override
  String get contactSupportTileSubtitle =>
      'Reach our support team by email or form';

  @override
  String get feedbackFormTileSubtitle =>
      'Report an issue or share a suggestion';
}
