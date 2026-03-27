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

  @override
  String get buttonCancel => 'रद्द करें';

  @override
  String get buttonDelete => 'हटाएं';

  @override
  String get buttonRename => 'नाम बदलें';

  @override
  String get buttonOk => 'ठीक है';

  @override
  String get buttonOverwrite => 'ओवरराइट करें';

  @override
  String get buttonTryAgain => 'पुनः प्रयास करें';

  @override
  String get buttonAllow => 'अनुमति दें';

  @override
  String get buttonOpenSettings => 'सेटिंग्स खोलें';

  @override
  String get buttonGrantPermission => 'अनुमति दें';

  @override
  String get mp3DeleteFilesTitle => 'फ़ाइलें हटाएं';

  @override
  String get mp3DeleteFileTitle => 'फ़ाइल हटाएं';

  @override
  String mp3DeleteFileConfirm(String name) {
    return '\"$name\" हटाना है? इसे पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get sleepIn10 => '10 मिनट में नींद';

  @override
  String get sleepIn20 => '20 मिनट में नींद';

  @override
  String get sleepIn30 => '30 मिनट में नींद';

  @override
  String get sleepIn45 => '45 मिनट में नींद';

  @override
  String get sleepIn60 => '60 मिनट में नींद';

  @override
  String get sleepCancel => 'स्लीप टाइमर रद्द करें';

  @override
  String get recordingNameHint => 'रिकॉर्डिंग नाम';

  @override
  String get emptyNoMusicTitle => 'कोई संगीत नहीं मिला';

  @override
  String get emptyNoMusicSubtitle =>
      'MP3 फ़ाइलों के लिए अपना डिवाइस स्टोरेज जांचें।';

  @override
  String get emptyNoDownloadsTitle => 'कोई डाउनलोड नहीं';

  @override
  String get emptyNoDownloadsSubtitle =>
      'आपके द्वारा डाउनलोड किए गए गाने यहां दिखाई देंगे।';

  @override
  String get emptyNoRecordingsTitle => 'कोई रिकॉर्डिंग नहीं';

  @override
  String get emptyNoRecordingsSubtitle =>
      'आपकी रेडियो रिकॉर्डिंग यहां सहेजी जाएंगी।';

  @override
  String get searchSongsHint => 'गाने खोजें...';

  @override
  String get searchDownloadsHint => 'डाउनलोड खोजें...';

  @override
  String get searchRecordingsHint => 'रिकॉर्डिंग खोजें...';

  @override
  String get deleteLabel => 'हटाएं';

  @override
  String get permissionStorageTitle => 'स्टोरेज अनुमति आवश्यक है';

  @override
  String get permissionRequiredTitle => 'अनुमति आवश्यक है';

  @override
  String get downloadCompleteTitle => 'डाउनलोड पूर्ण';

  @override
  String downloadFileLabel(String name) {
    return 'फ़ाइल: $name';
  }

  @override
  String downloadSizeLabel(String size) {
    return 'आकार: $size';
  }

  @override
  String get fileExistsTitle => 'फ़ाइल मौजूद है';

  @override
  String get tabAlbumsFolders => 'एल्बम/फ़ोल्डर';

  @override
  String get tabIndividualFiles => 'व्यक्तिगत फ़ाइलें';

  @override
  String get masstamilanTitle => 'नवीनतम तेलुगु एल्बम';

  @override
  String get stopRecordingBeforeSwitch =>
      'टैब बदलने से पहले रिकॉर्डिंग बंद करें।';

  @override
  String get mp3DownloadSearchHint => 'फिल्म का नाम, गाना, कलाकार।';

  @override
  String get aiAssistant => 'एआई सहायक';

  @override
  String get aiAssistantSubtitle => 'हमारे एआई से तुरंत सहायता प्राप्त करें';

  @override
  String get aiChatHint => 'एक संदेश टाइप करें...';

  @override
  String get aiTyping => 'एआई टाइप कर रहा है...';

  @override
  String get aiClearChat => 'चैट साफ़ करें';

  @override
  String get aiClearConfirm => 'क्या आप वाकई चैट इतिहास साफ़ करना चाहते हैं?';

  @override
  String get aiContactHuman => 'मानव सहायता से संपर्क करें';

  @override
  String get aiWelcome =>
      'नमस्ते! मैं जीआर रेडियो का एआई सहायक हूँ। मैं आपकी कैसे मदद कर सकता हूँ?';

  @override
  String get aiError =>
      'प्रतिक्रिया प्राप्त करने में विफल, कृपया पुनः प्रयास करें।';
}
