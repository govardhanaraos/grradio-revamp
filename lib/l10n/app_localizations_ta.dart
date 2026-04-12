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

  @override
  String get buttonCancel => 'ரத்துசெய்';

  @override
  String get buttonDelete => 'நீக்கு';

  @override
  String get buttonRename => 'மறுபெயரிடு';

  @override
  String get buttonOk => 'சரி';

  @override
  String get buttonOverwrite => 'மேலெழுது';

  @override
  String get buttonTryAgain => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get buttonAllow => 'அனுமதி';

  @override
  String get buttonOpenSettings => 'அமைப்புகளை திற';

  @override
  String get buttonGrantPermission => 'அனுமதி வழங்கவும்';

  @override
  String get mp3DeleteFilesTitle => 'கோப்புகளை நீக்கு';

  @override
  String get mp3DeleteFileTitle => 'கோப்பை நீக்கு';

  @override
  String mp3DeleteFileConfirm(String name) {
    return '\"$name\" ஐ நீக்கவா? இதை மீட்டெடுக்க முடியாது.';
  }

  @override
  String get sleepIn10 => '10 நிமிடங்களில் தூக்கம்';

  @override
  String get sleepIn20 => '20 நிமிடங்களில் தூக்கம்';

  @override
  String get sleepIn30 => '30 நிமிடங்களில் தூக்கம்';

  @override
  String get sleepIn45 => '45 நிமிடங்களில் தூக்கம்';

  @override
  String get sleepIn60 => '60 நிமிடங்களில் தூக்கம்';

  @override
  String get sleepCancel => 'தூக்கம் டைமரை ரத்து செய்';

  @override
  String get sleepTimerSheetTitle => 'தூக்க டைமர்';

  @override
  String sleepTimerMinutesChip(int minutes) {
    return '$minutes நிமி';
  }

  @override
  String get recordingNameHint => 'பதிவு பெயர்';

  @override
  String get emptyNoMusicTitle => 'இசை கிடைக்கவில்லை';

  @override
  String get emptyNoMusicSubtitle =>
      'MP3 கோப்புகளுக்கு உங்கள் சாதன சேமிப்பை சரிபார்க்கவும்.';

  @override
  String get emptyNoDownloadsTitle => 'பதிவிறக்கங்கள் இல்லை';

  @override
  String get emptyNoDownloadsSubtitle =>
      'நீங்கள் பதிவிறக்கும் பாடல்கள் இங்கே தோன்றும்.';

  @override
  String get emptyNoRecordingsTitle => 'பதிவுகள் இல்லை';

  @override
  String get emptyNoRecordingsSubtitle =>
      'உங்கள் ரேடியோ பதிவுகள் இங்கே சேமிக்கப்படும்.';

  @override
  String get searchSongsHint => 'பாடல்களைத் தேடுங்கள்...';

  @override
  String get searchDownloadsHint => 'பதிவிறக்கங்களைத் தேடுங்கள்...';

  @override
  String get searchRecordingsHint => 'பதிவுகளைத் தேடுங்கள்...';

  @override
  String get deleteLabel => 'நீக்கு';

  @override
  String get permissionStorageTitle => 'சேமிப்பக அனுமதி தேவை';

  @override
  String get permissionRequiredTitle => 'அனுமதி தேவை';

  @override
  String get downloadCompleteTitle => 'பதிவிறக்கம் முடிந்தது';

  @override
  String downloadFileLabel(String name) {
    return 'கோப்பு: $name';
  }

  @override
  String downloadSizeLabel(String size) {
    return 'அளவு: $size';
  }

  @override
  String get fileExistsTitle => 'கோப்பு உள்ளது';

  @override
  String get tabAlbumsFolders => 'ஆல்பங்கள்/கோப்புறைகள்';

  @override
  String get tabIndividualFiles => 'தனிப்பட்ட கோப்புகள்';

  @override
  String get masstamilanTitle => 'சமீபத்திய தெலுங்கு ஆல்பங்கள்';

  @override
  String get stopRecordingBeforeSwitch =>
      'தாவல்களை மாற்றுவதற்கு முன் பதிவை நிறுத்துங்கள்.';

  @override
  String get mp3DownloadSearchHint => 'திரைப்பட பெயர், பாடல், கலைஞர்.';

  @override
  String get aiAssistant => 'செயற்கை நுண்ணறிவு உதவியாளர்';

  @override
  String get aiAssistantSubtitle =>
      'எங்கள் AI இலிருந்து உடனடி உதவியைப் பெறுங்கள்';

  @override
  String get aiChatHint => 'ஒரு செய்தியை தட்டச்சு செய்க...';

  @override
  String get aiTyping => 'AI தட்டச்சு செய்கிறது...';

  @override
  String get aiClearChat => 'அரட்டையை அழி';

  @override
  String get aiClearConfirm =>
      'அரட்டை வரலாற்றை அழிக்க நிச்சயமாக விரும்புகிறீர்களா?';

  @override
  String get aiContactHuman => 'மனித ஆதரவைத் தொடர்புகொள்ளவும்';

  @override
  String get aiWelcome =>
      'வணக்கம்! நான் ஜி.ஆர் ரேடியோவின் AI உதவியாளர். நான் உங்களுக்கு எப்படி உதவ முடியும்?';

  @override
  String get aiError => 'பதிலைப் பெறுவதில் தோல்வி, மீண்டும் முயற்சிக்கவும்.';

  @override
  String get settingWakeMeUp => 'எழுப்புங்கள்';

  @override
  String get settingWakeMeUpSubtitle =>
      'ஒருமுறை, தினசரி அல்லது வாராந்திர வானொலி அலாரம்';

  @override
  String get wakeAlarmTitle => 'எழுப்புங்கள்';

  @override
  String get wakeAlarmHowItWorksTitle => 'இது எவ்வாறு செயல்படுகிறது';

  @override
  String get wakeAlarmAndroidExplain =>
      'Android திட்டமிட்ட நேரத்தில் GR Radio ஐத் திறந்து உங்கள் நிலையத்தை இயக்க முடியும், பயன்பாடு மூடப்பட்டிருந்தாலும். ஒருமுறை அலாரங்கள் நீங்கள் தேர்ந்தெடுக்கும் தேதியைப் பயன்படுத்துகின்றன; தினசரி மற்றும் வாராந்திரம் கடிகார நேரத்தை (வாராந்திரத்திற்கு தேர்ந்தெடுக்கப்பட்ட நாட்கள்). கேட்கும்போது \"அலாரங்கள் & நினைவூட்டல்கள்\" (துல்லியமான அலாரங்கள்) அனுமதியை வழங்குங்கள், பயன்பாட்டை கட்டாயமாக நிறுத்த வேண்டாம், மற்றும் சில தொலைபேசிகளில் மின்கலச் சேமிப்பு தாமதத்தை ஏற்படுத்தலாம்.';

  @override
  String get wakeAlarmIosExplain =>
      'பயன்பாடு மூடப்பட்டிருக்கும்போது iOS ஆடியோவை தானாகத் தொடங்க அனுமதிக்காது. தேர்ந்தெடுக்கப்பட்ட நேரத்தில் அறிவிப்பு வரும் — நிலையத்தை இயக்க அதைத் திறக்கவும். தினசரி மற்றும் வாராந்திர அட்டவணைகள் அந்த நாட்களில் அறிவிப்புகள் மூலம் மீண்டும் நிகழ்கின்றன. GR Radio க்கு அறிவிப்புகளை இயக்கிய நிலையில் வைக்கவும்.';

  @override
  String get wakeRepeatLabel => 'மீண்டும்';

  @override
  String get wakeRepeatOnce => 'ஒருமுறை';

  @override
  String get wakeRepeatDaily => 'தினமும்';

  @override
  String get wakeRepeatWeekly => 'வாராந்திரம்';

  @override
  String get wakeWeekdaysLabel => 'நாட்கள்';

  @override
  String get wakeAlarmDate => 'தேதி';

  @override
  String get wakeAlarmTime => 'நேரம்';

  @override
  String get wakeAlarmTimeRepeat => 'நாளின் நேரம்';

  @override
  String get wakeAlarmStation => 'நிலையம்';

  @override
  String get wakeAlarmSelectStation => 'நிலையத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get wakeAlarmSave => 'எழுப்பலைச் சேமி';

  @override
  String get wakeAlarmClear => 'எழுப்பலை நீக்கு';

  @override
  String get wakeAlarmScheduled => 'எழுப்பல் சேமிக்கப்பட்டது.';

  @override
  String get wakeAlarmDisabled => 'எழுப்பல் நீக்கப்பட்டது.';

  @override
  String get wakeAlarmScheduleFailed =>
      'சேமிக்க முடியவில்லை. Android இல் துல்லியமான-அலாரம் அனுமதி அல்லது iOS இல் அறிவிப்பு அனுமதி, தேதி/நேரம் மற்றும் வாராந்திரத்திற்கு நாட்களைச் சரிபார்க்கவும்.';

  @override
  String get wakeAlarmPickStation => 'முதலில் நிலையத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get wakeAlarmPickFuture =>
      'இப்போதிருந்து குறைந்தது 30 வினாடிகளுக்குப் பிறகு தேதி மற்றும் நேரத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get wakeAlarmPickFutureRepeat =>
      'அடுத்த அலாரத்திற்கு இப்போதிருந்து குறைந்தது 30 வினாடிகளுக்குப் பிறகு நேரத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get wakeAlarmNoStations =>
      'இன்னும் நிலையங்கள் ஏற்றப்படவில்லை. முதலில் வானொலி தாவலைத் திறந்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get noInternetStreamingTitle => 'இணையம் இல்லை';

  @override
  String get noInternetStreamingBody =>
      'இசையை ஸ்ட்ரீம் செய்ய GR Radio க்கு செயலில் இணைய இணைப்பு தேவை. அமைப்புகளைச் சரிபார்க்கவும்.';

  @override
  String get buttonRetryUpper => 'மீண்டும் முயற்சி';

  @override
  String get batteryOptimizationTitle => 'வானொலி இயங்கட்டும்';

  @override
  String get batteryOptimizationBody =>
      'திரை அணைக்கப்படும்போது அல்லது அழைப்புகளின் போது வானொலி நின்றுவிடாமல் இருக்க, அடுத்த திரையில் பயன்பாட்டை பின்னணியில் இயங்க அனுமதிக்கவும்.';

  @override
  String get batteryOptimizationLater => 'பின்னர்';

  @override
  String get batteryOptimizationSettings => 'அமைப்புகள்';

  @override
  String get recordingInProgressBadge => 'பதிவு நடக்கிறது';

  @override
  String sleepInHoursOnly(int h) {
    return '$h மணிநேரத்தில் தூக்கம்';
  }

  @override
  String sleepInHoursMinutes(int h, int m) {
    return '$h ம $m நிமிடத்தில் தூக்கம்';
  }

  @override
  String sleepInMinutesOnly(int minutes) {
    return '$minutes நிமிடத்தில் தூக்கம்';
  }

  @override
  String get premiumThankYou => 'நன்றி — பிரீமியம் செயலில் உள்ளது.';

  @override
  String get premiumNoPackages => 'தற்போது சந்தா தொகுப்பு எதுவும் இல்லை.';

  @override
  String paywallCouldNotOpen(String error) {
    return 'சந்தாக்களைத் திறக்க முடியவில்லை: $error';
  }

  @override
  String shareCouldNotOpen(String error) {
    return 'பகிர முடியவில்லை: $error';
  }

  @override
  String ratingCouldNotOpen(String error) {
    return 'மதிப்பீட்டைத் திறக்க முடியவில்லை: $error';
  }

  @override
  String get screenFaq => 'அடிக்கடி கேட்கப்படும் கேள்விகள்';

  @override
  String get screenTermsOfService => 'சேவை விதிமுறைகள்';

  @override
  String get screenPrivacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get screenAbout => 'பற்றி';

  @override
  String get screenNotifications => 'அறிவிப்புகள்';

  @override
  String get screenFeedback => 'கருத்து / புகார்';

  @override
  String get screenContactSupport => 'ஆதரவைத் தொடர்புகொள்ளவும்';

  @override
  String get buttonSendEmail => 'மின்னஞ்சல் அனுப்பு';

  @override
  String get licensesThirdParty => 'மூன்றாம் தரப்பு உரிமங்கள்';

  @override
  String get languageApplicationLabel => 'பயன்பாட்டு மொழி';

  @override
  String get languageListeningLabel => 'கேட்கும் மொழி';

  @override
  String languageSlotLabel(int index) {
    return 'மொழி $index';
  }

  @override
  String get premiumMembershipTitle => 'பிரீமியம் உறுப்பினர்';

  @override
  String get premiumManageDevices => 'இணைக்கப்பட்ட சாதனங்களை நிர்வகி';

  @override
  String get premiumActivateNowUpper => 'இப்போது செயல்படுத்து';

  @override
  String get premiumActivationSuccess => 'செயல்படுத்தல் வெற்றி!';

  @override
  String premiumActivateError(String error) {
    return 'பிழை: $error';
  }

  @override
  String get premiumDeactivatedDevice =>
      'இந்தச் சாதனத்திற்கு பிரீமியம் முடக்கப்பட்டது.';

  @override
  String premiumUnlinkFailed(String error) {
    return 'இணைப்பை நீக்க முடியவில்லை: $error';
  }

  @override
  String get activateRadioProTitle => 'Radio Pro செயல்படுத்து';

  @override
  String get premiumActivatedAdsRemoved =>
      'பிரீமியம் செயலில்! விளம்பரங்கள் நீக்கப்பட்டன.';

  @override
  String get buttonActivateNow => 'இப்போது செயல்படுத்து';

  @override
  String get miniPlayerHideTooltip => 'சிறிய பிளேயரை மறை';

  @override
  String get radioStreamSubtitleDefault => 'வானொலி ஸ்ட்ரீம்';

  @override
  String shareAppMessage(String appName, String url) {
    return 'ஹே! உயர்தர வானொலி ஸ்ட்ரீமிங் மற்றும் பிரீமியம் அம்சங்களுக்கு $appName-ஐப் பாருங்கள். இங்கே பதிவிறக்கவும்: $url';
  }

  @override
  String shareAppSubject(String appName) {
    return '$appName-ஐப் பாருங்கள்';
  }

  @override
  String copyrightFooter(String year, String appName) {
    return '© $year $appName. அனைத்து உரிமைகளும் பாதுகாக்கப்பட்டவை.';
  }

  @override
  String get faq1Question => 'ஒலிபரப்பை எப்படி கண்டுபிடித்து இயக்குவது?';

  @override
  String get faq1Answer =>
      'வானொலி தாவலைத் திறந்து, பட்டியலை உலாவவும் அல்லது தேடவும், இயக்க நிலையத்தைத் தட்டவும். கிடைக்கும்போது தேடல் மற்றும் மொழி வடிகட்டிகளைப் பயன்படுத்தவும்.';

  @override
  String get faq2Question => 'இயக்கம் ஏன் தடைபடுகிறது அல்லது நின்றுவிடுகிறது?';

  @override
  String get faq2Answer =>
      'நேரடி ஸ்ட்ரீமிங்கிற்கு நிலையான இணையம் வேண்டும். Wi‑Fi அல்லது வலுவான சிக்னலை முயற்சிக்கவும். Android இல் பேட்டரி மேம்பாடு பின்புல ஆடியோவை நிறுத்தலாம்—கேட்கும்போது பயன்பாட்டை பின்புலத்தில் இயங்க அனுமதிக்கவும்.';

  @override
  String get faq3Question => 'பிரீமியம் எப்படி வேலை செய்கிறது?';

  @override
  String get faq3Answer =>
      'மேலும் → பிரீமியம் பெறுங்கள் என்பதற்குச் செல்லவும்; Google Play அல்லது Apple வழி சந்தா விருப்பங்கள். பிரீமியம் விளம்பரங்களை நீக்கி வாங்கும் போது காட்டப்படும் கூடுதல் அம்சங்களைத் தரலாம். அதே கடை கணக்குடன் புதிய சாதனத்தில் மீட்டமைக்கலாம். சில பாதைகளில் உரிம விசை அல்லது இணைக்கப்பட்ட சாதனங்கள் இருக்கலாம்.';

  @override
  String get faq4Question => 'இணையம் இல்லாமல் கேட்க முடியுமா?';

  @override
  String get faq4Answer =>
      'நேரடி வானொலி ஸ்ட்ரீமிங்கிற்கு செயலில் இணைப்பு தேவை. பதிவிறக்கங்கள் பகுதியில் உருப்படிகள் உரிம வரம்புகளுக்கு ஏற்ப ஆஃப்லைன் இயங்கலாம்.';

  @override
  String get faq5Question => 'பதிவுகள் எப்படி வேலை செய்கின்றன?';

  @override
  String get faq5Answer =>
      'நேரடி ஸ்ட்ரீமிற்கு பதிவு கிடைக்குமிடத்தில், ஆடியோ உங்கள் சாதன சேமிப்பில் சேமிக்கப்படும். பதிவுகளை தனிப்பட்ட, சட்டப்படியான பயன்பாட்டிற்கு மட்டும் பயன்படுத்தவும்; ஒளிபரப்பாளர் மற்றும் பதிப்புரிமை விதிகளை மதிக்கவும்.';

  @override
  String get faq6Question => 'தூக்க டைமர் மற்றும் வேக் மீ அப் என்றால் என்ன?';

  @override
  String get faq6Answer =>
      'தூக்க டைமர் நீங்கள் தேர்ந்தெடுத்த காலத்திற்குப் பிறகு இயக்கத்தை நிறுத்துகிறது. வேக் மீ அப் ஆதரவுள்ள தளங்களில் நேரத்திற்கு நிலையத்தைத் தொடங்க அட்டவணைப்படுத்துகிறது; Android இல் அறிவிப்பு அல்லது சரியான அலாரம் அனுமதி தேவைப்படலாம்.';

  @override
  String get faq7Question => 'நிலையத்தை பிடித்ததாக எப்படி சேர்ப்பது?';

  @override
  String get faq7Answer =>
      'பட்டியல் அல்லது பிளேயரில் இதய ஐகானைத் தட்டவும். பிடித்தவை வானொலி திரையில் தனி பிரிவில் தோன்றும்.';

  @override
  String get faq8Question => 'உதவி அல்லது சிக்கலை எப்படி தெரிவிப்பது?';

  @override
  String get faq8Answer =>
      'மேலும் → உதவி மற்றும் ஆதரவுக்குச் செல்லவும். கருத்து அல்லது தொடர்பு விருப்பங்கள் உள்ளன. அறிமுகத் திரையிலிருந்து மின்னஞ்சலும் அனுப்பலாம்.';

  @override
  String get terms1Title => 'விதிமுறைகளின் ஏற்பு';

  @override
  String terms1Body(String appName) {
    return '$appName ஐ பதிவிறக்க அல்லது பயன்படுத்துவதன் மூலம் இந்த சேவை விதிமுறைகளுக்கு நீங்கள் கட்டுப்படுகிறீர்கள். ஒப்புக்கொள்ளவில்லையெனில் பயன்பாட்டைப் பயன்படுத்த வேண்டாம்.';
  }

  @override
  String get terms2Title => 'சேவை';

  @override
  String terms2Body(String appName) {
    return '$appName நேரடி வானொலி நிலையங்களை ஸ்ட்ரீம் செய்ய, பயன்பாட்டின் மூலம் வழங்கப்படும் பதிவிறக்கக்கூடிய ஆடியோவை அணுக, கிடைக்குமிடத்தில் ஸ்ட்ரீம் பதிவு, தூக்க டைமர் போன்ற கருவிகள், விருப்ப அறிவிப்புகள் மற்றும் திட்டமிடப்பட்ட இயக்கம் (ஆதரவுள்ள சாதனங்களில் அலாரங்கள் உட்பட) வழங்குகிறது. அம்சங்கள் தளம் அல்லது பதிப்பைப் பொறுத்து மாறலாம். தேவைப்படும்போது சேவையின் எந்தப் பகுதியையும் மாற்ற, இடைநிறுத்த அல்லது நிறுத்தலாம்.';
  }

  @override
  String get terms3Title => 'பிரீமியம், கொள்முதல்கள் மற்றும் உரிமங்கள்';

  @override
  String get terms3Body =>
      'சந்தாக்கள் அல்லது ஒருமுறை கொள்முதல்கள் உங்கள் பயன்பாட்டுக் கடை மற்றும் RevenueCat போன்ற சேவைகள் உட்பட மூன்றாம் தரப்பினரால் செயலாக்கப்படலாம். சில பாதைகளில் உரிம விசை அல்லது சாதன இணைப்பு இருக்கலாம்; பொருந்துமிடத்தில் வரம்புகள் பயன்பாட்டில் காட்டப்படும். விலை, புதுப்பித்தல், ரத்து மற்றும் பணத்திரும்பப்பெறுதல் கடை/வழங்குநர் விதிகளுக்கு உட்பட்டது. வரிகள் உங்கள் பொறுப்பு.';

  @override
  String get terms4Title => 'ஏற்றுக்கொள்ளத்தக்க பயன்பாடு';

  @override
  String terms4Body(String appName) {
    return 'நீங்கள் $appName ஐ சட்டப்படியான தனிப்பட்ட கேட்டலுக்கு மட்டுமே பயன்படுத்துகிறீர்கள். கட்டணம் அல்லது உரிமை சரிபார்ப்பைத் தவிர்ப்பது, அமைப்புகள் மீது தாக்குதல், அல்லது ஸ்ட்ரீம்/பதிவிறக்கங்கள்/பதிவுகளை பதிப்புரிமை அல்லது ஒளிபரப்பாளர் விதிகளை மீறும் வகையில் பகிர்வது தடைசெய்யப்பட்டது. மொபைல் தரவு செலவுகள் மற்றும் உள்ளூர் சட்டங்களுக்கு இணங்குதல் உங்கள் பொறுப்பு.';
  }

  @override
  String get terms5Title => 'மூன்றாம் தரப்பு நிலையங்கள் மற்றும் உள்ளடக்கம்';

  @override
  String terms5Body(String appName) {
    return 'ஸ்ட்ரீம்கள், கலை, மெட்டாடேட்டா மற்றும் பதிவிறக்கக்கூடிய உள்ளடக்கம் மூன்றாம் தரப்பினரிடமிருந்து வருகிறது. $appName அந்த உள்ளடக்கத்தின் உரிமையாளர் அல்ல. கிடைப்புத்தன்மை மற்றும் தரம் மூலங்கள் மற்றும் உங்கள் இணைப்பைப் பொறுத்தது. எந்த நிலையமும் எப்போதும் கிடைக்கும் என உத்தரவாதம் இல்லை.';
  }

  @override
  String get terms6Title => 'மறுப்புகள் மற்றும் பொறுப்பு';

  @override
  String get terms6Body =>
      'சேவை சட்டம் அனுமதிக்கும் முழு அளவில் உத்தரவாதங்கள் இல்லாமல் வழங்கப்படுகிறது. மறைமுக சேதங்கள், தரவு கட்டணங்கள், சேவை இடையூறு, இழந்த பதிவுகள் அல்லது அலார் தோல்விகளுக்கு நாங்கள் பொறுப்பல்ல. சில பகுதிகளில் விதிவிலக்குகள் வேறுபடலாம்.';

  @override
  String get terms7Title => 'மாற்றங்கள் மற்றும் தொடர்பு';

  @override
  String terms7Body(String supportEmail) {
    return 'இந்த விதிமுறைகளைப் புதுப்பிக்கலாம்; புதுப்பித்தலுக்குப் பிறகு தொடர்ந்து பயன்பாடு திருத்தப்பட்ட விதிமுறைகளின் ஏற்பைக் குறிக்கிறது. கேள்விகளுக்கு $supportEmail.';
  }

  @override
  String get privacy1Title => 'அறிமுகம்';

  @override
  String privacy1Body(String appName) {
    return 'இந்த தனியுரிமைக் கொள்கை $appName எங்கள் மொபைல் பயன்பாட்டைப் பயன்படுத்தும்போது தகவலை எவ்வாறு கையாளுகிறது என்பதை விளக்குகிறது. இதை எங்கள் சேவை விதிமுறைகளுடன் படிக்கவும்.';
  }

  @override
  String get privacy2Title => 'நாங்கள் சேகரிக்கும் தகவல்';

  @override
  String get privacy2Body =>
      '• உள்ளமைவு, செயல்பாட்டு பதிவுகள், மோசடி தடுப்பு மற்றும் பிரீமியம் அல்லது சாதன வரம்புகளுக்காக சாதன/பயன்பாட்டு அடையாளங்கள் எங்கள் பின்னணி சேவைக்கு அனுப்பப்படலாம்.\n• தயாரிப்பு மேம்பாட்டிற்கு பொதுவான பயன்பாடு (திரைகள் அல்லது செயல்கள்) பதிவு செய்யப்படலாம்.\n• கொள்முதல்கள்: கட்டணம் பயன்பாட்டுக் கடை வழி; சந்தா நிலை RevenueCat போன்ற வழங்குநர்களால் செயலாக்கப்படலாம்—முழு அட்டை எண்ணை நாங்கள் பெற மாட்டோம்.\n• விளம்பரங்கள்: இயக்கப்பட்டால் Google Mobile Ads (AdMob) Google கொள்கைகளின்படி அடையாளங்களைப் பயன்படுத்தலாம்.\n• அறிவிப்புகள்: ஒப்புதல் அளித்தால் Firebase Cloud Messaging செய்திகளுக்கு புஷ் டோக்கனைப் பயன்படுத்தலாம்.\n• நீங்கள் உருவாக்கிய உள்ளடக்கம் (பதிவுகள், பதிவிறக்கங்கள்) நீங்கள் பகிரும் வரை உங்கள் சாதனத்தில் உள்ளது.';

  @override
  String get privacy3Title => 'தகவலை எவ்வாறு பயன்படுத்துகிறோம்';

  @override
  String privacy3Body(String appName) {
    return 'இந்த தரவை $appName இயக்கவும் மேம்படுத்தவும், பிரீமியம் உரிமைகளை வழங்கவும், விளம்பரங்கள் இயக்கப்பட்டால் காட்டவும், நீங்கள் கோரிய அறிவிப்புகளை அனுப்பவும், சேவையைப் பாதுகாக்கவும் மற்றும் சட்டக் கடமைகளுக்கு பயன்படுத்துகிறோம். உங்கள் தனிப்பட்ட தகவலை பணத்திற்கு விற்க மாட்டோம்.';
  }

  @override
  String get privacy4Title => 'அனுமதிகள்';

  @override
  String get privacy4Body =>
      'பயன்பாடு இணையம், சேமிப்பு/மீடியா (பதிவிறக்கங்கள் மற்றும் பதிவுகள்), அறிவிப்புகள், சில Android பதிப்புகளில் திட்டமிடப்பட்ட இயக்கத்திற்கு சரியான அலாரம், மற்றும் நீங்கள் பேச்சு அம்சங்களைப் பயன்படுத்தினால் மட்டுமே மைக்ரோஃபோன் கேட்கலாம். கணினி அமைப்புகளில் பல அனுமதிகளை மாற்றலாம்; சிலவற்றை மறுப்பது அம்சங்களைக் கட்டுப்படுத்தலாம்.';

  @override
  String get privacy5Title => 'மூன்றாம் தரப்பு சேவைகள்';

  @override
  String get privacy5Body =>
      'Google (FCM மற்றும் பொருந்துமிடத்தில் AdMob உட்பட), iOS இல் Apple தள சேவைகள், கொள்முதல்களுக்கு RevenueCat மற்றும் எங்கள் பின்னணி API ஆகியவற்றை நம்பியுள்ளோம். அவர்களின் நடைமுறைகள் அவர்களின் கொள்கைகளில் உள்ளன. வானொலி ஸ்ட்ரீம்கள் மற்றும் பதிவிறக்கக்கூடிய ஊடகம் எங்கள் கட்டுப்பாட்டிற்கு வெளியே உள்ள மூலங்களிலிருந்து வருகின்றன.';

  @override
  String get privacy6Title => 'தக்கவைப்பு மற்றும் பாதுகாப்பு';

  @override
  String get privacy6Body =>
      'சர்வர் பதிவுகளை மேலே உள்ள நோக்கங்கள் மற்றும் நியாயமான பாதுகாப்பிற்கு தேவையான காலம் வரை மட்டுமே வைத்திருக்கிறோம். எந்த பரிமாற்றமும் சேமிப்பும் முழுமையாக பாதுகாப்பானது அல்ல; தரவு வகைக்கு ஏற்ற பாதுகாப்புகளைப் பயன்படுத்துகிறோம்.';

  @override
  String get privacy7Title => 'குழந்தைகளின் தனியுரிமை';

  @override
  String privacy7Body(String appName) {
    return '$appName உங்கள் நாட்டில் பெற்றோர் ஒப்புதல் இல்லாமல் சம்மத வயதுக்குக் கீழுள்ள குழந்தைகளுக்கு இல்லை. சிறு குழந்தைகளின் தனிப்பட்ட தரவை வேண்டுமென்றே சேகரிக்க மாட்டோம். நாங்கள் சேகரித்தோம் என நினைத்தால் தொடர்புகொள்ளவும்; சட்டப்படி நீக்குவோம்.';
  }

  @override
  String get privacy8Title => 'தொடர்பு';

  @override
  String privacy8Body(String supportEmail) {
    return 'இந்தக் கொள்கை அல்லது உங்கள் தரவு பற்றி: $supportEmail. கொள்கையைப் புதுப்பிக்கலாம்; கீழுள்ள தேதி சமீபத்திய திருத்தத்தைக் காட்டுகிறது.';
  }

  @override
  String get privacyLastUpdatedFooter => 'கடைசி புதுப்பிப்பு: ஏப்ரல் 2026';

  @override
  String aboutIntroBody(String appName) {
    return '$appName நேரடி வானொலியைக் கண்டறிய, பிடித்தவை, கிடைக்கும்போது பதிவிறக்கங்கள், தூக்க டைமர் மற்றும் விருப்ப வேக்-அப் இயக்கம் போன்ற கருவிகளை வழங்குகிறது. பிரீமியம் விளம்பரங்களைக் குறைத்து வாங்கும் போது விவரிக்கப்பட்ட அம்சங்களைச் சேர்க்கலாம். கேட்டதற்கு நன்றி!';
  }

  @override
  String aboutVersionLabel(String version) {
    return 'பதிப்பு $version';
  }

  @override
  String get aboutLabelDeveloper => 'உருவாக்குநர்';

  @override
  String get aboutDeveloperName => 'Govardhana Rao Sugrivugari';

  @override
  String get aboutLabelContact => 'தொடர்பு';

  @override
  String get aboutLabelWebsite => 'வலைத்தளம்';

  @override
  String get aboutWebsiteDisplay => 'www.grradio.com';

  @override
  String aboutEmailSubject(String appName) {
    return '$appName — ஆதரவு விசாரணை';
  }

  @override
  String get faqScreenSubtitle =>
      'நிலையங்கள், பிரீமியம், பதிவுகள், அலாரங்கள் பற்றிய பதில்கள்';

  @override
  String get contactSupportTileSubtitle =>
      'மின்னஞ்சல் அல்லது படிவம் மூலம் ஆதரவுக் குழுவை அணுகவும்';

  @override
  String get feedbackFormTileSubtitle =>
      'சிக்கலைப் புகாரளிக்கவும் அல்லது பரிந்துரையைப் பகிரவும்';
}
