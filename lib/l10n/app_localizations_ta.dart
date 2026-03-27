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
  String get buttonCancel => 'రద్దు';

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
}
