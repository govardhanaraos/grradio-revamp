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
  String get sleepTimerSheetTitle => 'स्लीप टाइमर';

  @override
  String sleepTimerMinutesChip(int minutes) {
    return '$minutes मिनट';
  }

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

  @override
  String get settingWakeMeUp => 'मुझे जगाएं';

  @override
  String get settingWakeMeUpSubtitle =>
      'एक बार, दैनिक या साप्ताहिक रेडियो अलार्म';

  @override
  String get wakeAlarmTitle => 'मुझे जगाएं';

  @override
  String get wakeAlarmHowItWorksTitle => 'यह कैसे काम करता है';

  @override
  String get wakeAlarmAndroidExplain =>
      'Android निर्धारित समय पर GR Radio खोल सकता है और आपका स्टेशन चला सकता है, भले ही ऐप बंद हो। एक बार वाले अलार्म के लिए आपकी चुनी तारीख का उपयोग होता है; दैनिक और साप्ताहिक अलार्म घड़ी के समय का (साप्ताहिक के लिए चुने गए दिन)। संकेत मिलने पर \"अलार्म और रिमाइंडर\" (सटीक अलार्म) की अनुमति दें, ऐप को जबरन बंद न करें, और कुछ फोनों पर बैटरी बचत से अलार्म में देरी हो सकती है।';

  @override
  String get wakeAlarmIosExplain =>
      'iOS ऐप बंद होने पर ऑडियो अपने आप शुरू नहीं करने देता। चुने समय पर सूचना मिलेगी — उसे खोलकर स्टेशन चलाएं। दैनिक और साप्ताहिक अनुसूची उन दिनों पर सूचनाओं से दोहराती है। GR Radio के लिए सूचनाएं चालू रखें।';

  @override
  String get wakeRepeatLabel => 'दोहराव';

  @override
  String get wakeRepeatOnce => 'एक बार';

  @override
  String get wakeRepeatDaily => 'हर दिन';

  @override
  String get wakeRepeatWeekly => 'साप्ताहिक';

  @override
  String get wakeWeekdaysLabel => 'दिन';

  @override
  String get wakeAlarmDate => 'तारीख';

  @override
  String get wakeAlarmTime => 'समय';

  @override
  String get wakeAlarmTimeRepeat => 'दिन में समय';

  @override
  String get wakeAlarmStation => 'स्टेशन';

  @override
  String get wakeAlarmSelectStation => 'स्टेशन चुनें';

  @override
  String get wakeAlarmSave => 'जगाने का समय सहेजें';

  @override
  String get wakeAlarmClear => 'जगाने का समय हटाएं';

  @override
  String get wakeAlarmScheduled => 'जगाने का समय सहेज लिया गया।';

  @override
  String get wakeAlarmDisabled => 'जगाने का समय हटा दिया गया।';

  @override
  String get wakeAlarmScheduleFailed =>
      'सहेज नहीं सका। Android पर सटीक-अलार्म अनुमति या iOS पर सूचना अनुमति, तारीख/समय और साप्ताहिक के लिए दिन जांचें।';

  @override
  String get wakeAlarmPickStation => 'पहले एक स्टेशन चुनें।';

  @override
  String get wakeAlarmPickFuture =>
      'अभी से कम से कम 30 सेकंड बाद की तारीख और समय चुनें।';

  @override
  String get wakeAlarmPickFutureRepeat =>
      'अगले अलार्म के लिए अभी से कम से कम 30 सेकंड बाद का समय चुनें।';

  @override
  String get wakeAlarmNoStations =>
      'अभी कोई स्टेशन लोड नहीं हुआ। पहले रेडियो टैब खोलें, फिर कोशिश करें।';

  @override
  String get noInternetStreamingTitle => 'इंटरनेट नहीं';

  @override
  String get noInternetStreamingBody =>
      'GR Radio को संगीत स्ट्रीम करने के लिए सक्रिय इंटरनेट कनेक्शन चाहिए। कृपया अपनी सेटिंग्स जांचें।';

  @override
  String get buttonRetryUpper => 'पुनः प्रयास';

  @override
  String get batteryOptimizationTitle => 'रेडियो चलता रखें';

  @override
  String get batteryOptimizationBody =>
      'स्क्रीन बंद होने या कॉल के दौरान रेडियो रुकने से बचाने के लिए, अगली स्क्रीन में ऐप को पृष्ठभूमि में चलने दें।';

  @override
  String get batteryOptimizationLater => 'बाद में';

  @override
  String get batteryOptimizationSettings => 'सेटिंग्स';

  @override
  String get recordingInProgressBadge => 'रिकॉर्डिंग जारी है';

  @override
  String sleepInHoursOnly(int h) {
    return '$h घंटे में नींद';
  }

  @override
  String sleepInHoursMinutes(int h, int m) {
    return '$h घंटे $m मिनट में नींद';
  }

  @override
  String sleepInMinutesOnly(int minutes) {
    return '$minutes मिनट में नींद';
  }

  @override
  String get premiumThankYou => 'धन्यवाद — प्रीमियम सक्रिय है।';

  @override
  String get premiumNoPackages => 'अभी कोई सदस्यता पैकेज उपलब्ध नहीं है।';

  @override
  String paywallCouldNotOpen(String error) {
    return 'सदस्यता नहीं खोल सके: $error';
  }

  @override
  String shareCouldNotOpen(String error) {
    return 'शेयर नहीं कर सके: $error';
  }

  @override
  String ratingCouldNotOpen(String error) {
    return 'रेटिंग नहीं खोल सके: $error';
  }

  @override
  String get screenFaq => 'अक्सर पूछे जाने वाले प्रश्न';

  @override
  String get screenTermsOfService => 'सेवा की शर्तें';

  @override
  String get screenPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get screenAbout => 'के बारे में';

  @override
  String get screenNotifications => 'सूचनाएं';

  @override
  String get screenFeedback => 'प्रतिक्रिया / शिकायत';

  @override
  String get screenContactSupport => 'सहायता से संपर्क';

  @override
  String get buttonSendEmail => 'ईमेल भेजें';

  @override
  String get licensesThirdParty => 'तृतीय-पक्ष लाइसेंस';

  @override
  String get languageApplicationLabel => 'ऐप की भाषा';

  @override
  String get languageListeningLabel => 'सुनने की भाषा';

  @override
  String languageSlotLabel(int index) {
    return 'भाषा $index';
  }

  @override
  String get premiumMembershipTitle => 'प्रीमियम सदस्यता';

  @override
  String get premiumManageDevices => 'लिंक किए गए डिवाइस प्रबंधित करें';

  @override
  String get premiumActivateNowUpper => 'अभी सक्रिय करें';

  @override
  String get premiumActivationSuccess => 'सक्रियकरण सफल!';

  @override
  String premiumActivateError(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get premiumDeactivatedDevice =>
      'इस डिवाइस के लिए प्रीमियम निष्क्रिय कर दिया गया।';

  @override
  String premiumUnlinkFailed(String error) {
    return 'अनलिंक विफल: $error';
  }

  @override
  String get activateRadioProTitle => 'Radio Pro सक्रिय करें';

  @override
  String get premiumActivatedAdsRemoved => 'प्रीमियम सक्रिय! विज्ञापन हटाए गए।';

  @override
  String get buttonActivateNow => 'अभी सक्रिय करें';

  @override
  String get miniPlayerHideTooltip => 'मिनी प्लेयर छिपाएं';

  @override
  String get radioStreamSubtitleDefault => 'रेडियो स्ट्रीम';

  @override
  String shareAppMessage(String appName, String url) {
    return 'अरे! उच्च-गुणवत्ता वाली रेडियो स्ट्रीमिंग और प्रीमियम सुविधाओं के लिए $appName देखें। यहाँ डाउनलोड करें: $url';
  }

  @override
  String shareAppSubject(String appName) {
    return '$appName देखें';
  }

  @override
  String copyrightFooter(String year, String appName) {
    return '© $year $appName. सर्वाधिकार सुरक्षित।';
  }

  @override
  String get faq1Question => 'मैं स्टेशन कैसे ढूँढूँ और चलाऊँ?';

  @override
  String get faq1Answer =>
      'रेडियो टैब खोलें, सूची ब्राउज़ या खोजें, और प्लेबैक शुरू करने के लिए किसी स्टेशन पर टैप करें। उपलब्ध होने पर खोज और भाषा फ़िल्टर से परिणाम सीमित करें।';

  @override
  String get faq2Question =>
      'प्लेबैक बफ़र क्यों होता है, रुकता या बंद क्यों हो जाता है?';

  @override
  String get faq2Answer =>
      'लाइव स्ट्रीमिंग के लिए स्थिर इंटरनेट चाहिए। Wi‑Fi या मजबूत सिग्नल आज़माएँ। Android पर बैटरी ऑप्टिमाइज़ेशन पृष्ठभूमि ऑडियो रोक सकता है—जब संकेत मिले, ऐप को पृष्ठभूमि में चलने दें ताकि स्क्रीन बंद होने पर भी चलता रहे।';

  @override
  String get faq3Question => 'प्रीमियम कैसे काम करता है?';

  @override
  String get faq3Answer =>
      'अधिक → प्रीमियम लें पर जाएँ; Google Play या Apple के माध्यम से सदस्यता विकल्प दिखेंगे। प्रीमियम विज्ञापन हटा सकता है और खरीद समय पर दिखाई गई अतिरिक्त सुविधाएँ दे सकता है। उसी स्टोर खाते से नए डिवाइस पर पुनर्स्थापित कर सकते हैं। कुछ प्रवाह लाइसेंस कुंजी या लिंक किए डिवाइस भी उपयोग कर सकते हैं।';

  @override
  String get faq4Question => 'क्या मैं इंटरनेट के बिना सुन सकता हूँ?';

  @override
  String get faq4Answer =>
      'लाइव रेडियो स्ट्रीम के लिए सक्रिय कनेक्शन ज़रूरी है। डाउनलोड्स क्षेत्र की फ़ाइलें लाइसेंस सीमाओं के अनुसार ऑफ़लाइन चल सकती हैं।';

  @override
  String get faq5Question => 'रिकॉर्डिंग कैसे काम करती है?';

  @override
  String get faq5Answer =>
      'जहाँ लाइव स्ट्रीम के लिए रिकॉर्डिंग उपलब्ध है, ऑडियो आपके डिवाइस स्टोरेज में सहेजा जाता है। रिकॉर्डिंग केवल व्यक्तिगत, कानूनी उपयोग के लिए रखें और प्रसारक व कॉपीराइट नियमों का सम्मान करें।';

  @override
  String get faq6Question => 'स्लीप टाइमर और वेक मी अप क्या हैं?';

  @override
  String get faq6Answer =>
      'स्लीप टाइमर आपके चुने गए समय बाद प्लेबैक रोकता है। वेक मी अप समर्थित प्लेटफ़ॉर्म पर निर्धारित समय पर स्टेशन शुरू करने की सुविधा देता है; Android पर सूचना या सटीक अलार्म अनुमति आवश्यक हो सकती है।';

  @override
  String get faq7Question => 'मैं स्टेशन को पसंदीदा कैसे बनाऊँ?';

  @override
  String get faq7Answer =>
      'सूची या प्लेयर में हार्ट आइकन पर टैप करें। पसंदीदा स्टेशन रेडियो स्क्रीन पर एक अलग खंड में तेज़ पहुँच के लिए दिखते हैं।';

  @override
  String get faq8Question => 'मदद या समस्या रिपोर्ट कैसे करूँ?';

  @override
  String get faq8Answer =>
      'अधिक → सहायता और समर्थन पर जाएँ। प्रतिक्रिया या संपर्क विकल्प उपलब्ध हैं। आप हमें About स्क्रीन से ईमेल भी कर सकते हैं।';

  @override
  String get terms1Title => 'शर्तों की स्वीकृति';

  @override
  String terms1Body(String appName) {
    return '$appName डाउनलोड या उपयोग करके आप इन सेवा शर्तों से बाध्य होते हैं। यदि सहमत नहीं हैं तो ऐप उपयोग न करें।';
  }

  @override
  String get terms2Title => 'सेवा';

  @override
  String terms2Body(String appName) {
    return '$appName लाइव रेडियो स्ट्रीम, ऐप के माध्यम से उपलब्ध डाउनलोड योग्य ऑडियो, जहाँ उपलब्ध हो स्ट्रीम रिकॉर्डिंग, स्लीप टाइमर जैसे टूल, वैकल्पिक सूचनाएँ और निर्धारित प्लेबैक (समर्थित डिवाइसों पर अलार्म सहित) प्रदान करता है। सुविधाएँ प्लेटफ़ॉर्म या संस्करण के अनुसार भिन्न हो सकती हैं। हम आवश्यकतानुसार सेवा के किसी भी हिस्से को बदल, निलंबित या बंद कर सकते हैं।';
  }

  @override
  String get terms3Title => 'प्रीमियम, खरीद और लाइसेंस';

  @override
  String get terms3Body =>
      'सदस्यता या एकमुश्त खरीद तीसरे पक्ष (जैसे आपका ऐप स्टोर और RevenueCat जैसी सेवाएँ) द्वारा संसाधित हो सकती है। कुछ प्रवाहों में लाइसेंस कुंजी या डिवाइस लिंकिंग हो सकती है; जहाँ लागू हो, सीमाएँ (जैसे लिंक किए डिवाइसों की संख्या) ऐप में दिखाई जाती हैं। मूल्य, नवीकरण, रद्दीकरण और रिफंड स्टोर/प्रदाता नियमों के अधीन हैं। कर और शुल्क आपकी ज़िम्मेदारी हैं।';

  @override
  String get terms4Title => 'स्वीकार्य उपयोग';

  @override
  String terms4Body(String appName) {
    return 'आप $appName का उपयोग केवल कानूनी, व्यक्तिगत सुनने के लिए करते हैं जब तक अन्यथा अनुमति न हो। भुगतान या एंटाइटलमेंट जाँच को बायपास करना, सिस्टम पर हमला करना, या स्ट्रीम/डाउनलोड/रिकॉर्डिंग को कॉपीराइट या प्रसारक शर्तों का उल्लंघन करते हुए पुनर्वितरित करना मना है। मोबाइल डेटा लागत और स्थानीय कानूनों का पालन आपकी ज़िम्मेदारी है।';
  }

  @override
  String get terms5Title => 'तृतीय-पक्ष स्टेशन और सामग्री';

  @override
  String terms5Body(String appName) {
    return 'स्ट्रीम, आर्टवर्क, मेटाडेटा और डाउनलोड योग्य सामग्री तृतीय पक्षों से आती है। $appName उस सामग्री का मालिक या नियंत्रक नहीं है। उपलब्धता और गुणवत्ता स्रोतों और आपके कनेक्शन पर निर्भर करती है। हम किसी स्टेशन या ट्रैक की निरंतर उपलब्धता की गारंटी नहीं देते।';
  }

  @override
  String get terms6Title => 'अस्वीकरण और दायित्व';

  @override
  String get terms6Body =>
      'सेवा कानून द्वारा अनुमत पूर्ण सीमा तक जैसी है वैसी प्रदान की जाती है, बिना किसी वारंटी के। हम अप्रत्यक्ष नुकसान, डेटा शुल्क, आउटेज, खोई रिकॉर्डिंग या अलार्म विफलता के लिए उत्तरदायी नहीं हैं। कुछ क्षेत्रों में कुछ बहिष्करण लागू नहीं हो सकते; वहाँ हमारा दायित्व कानून सीमा तक सीमित है।';

  @override
  String get terms7Title => 'परिवर्तन और संपर्क';

  @override
  String terms7Body(String supportEmail) {
    return 'हम इन शर्तों को अपडेट कर सकते हैं; अपडेट के बाद निरंतर उपयोग संशोधित शर्तों की स्वीकृति है। प्रश्नों के लिए $supportEmail पर लिखें।';
  }

  @override
  String get privacy1Title => 'परिचय';

  @override
  String privacy1Body(String appName) {
    return 'यह गोपनीयता नीति बताती है कि $appName हमारे मोबाइल ऐप का उपयोग करते समय जानकारी कैसे संभालता है। इसे हमारी सेवा की शर्तों के साथ पढ़ें।';
  }

  @override
  String get privacy2Title => 'हम जो जानकारी एकत्र करते हैं';

  @override
  String get privacy2Body =>
      '• कॉन्फ़िगरेशन, परिचालन लॉग, धोखाधड़ी रोकथाम और प्रीमियम/डिवाइस सीमाओं के लिए डिवाइस/ऐप पहचानकर्ता हमारे बैकएंड को भेजे जा सकते हैं।\n• उत्पाद सुधार के लिए सामान्य उपयोग (स्क्रीन या क्रियाएँ) लॉग हो सकता है।\n• खरीदारी: भुगतान ऐप स्टोर द्वारा; सदस्यता स्थिति RevenueCat जैसे प्रदाताओं द्वारा संसाधित—हमें आपका पूरा कार्ड नंबर नहीं मिलता।\n• विज्ञापन: सक्षम होने पर Google Mobile Ads (AdMob) Google नीतियों के अनुसार विज्ञापन पहचानकर्ता उपयोग कर सकता है।\n• सूचनाएँ: ऑप्ट-इन पर Firebase Cloud Messaging संदेश वितरण के लिए पुश टोकन उपयोग कर सकता है।\n• आपकी बनाई सामग्री (रिकॉर्डिंग, डाउनलोड) आपके डिवाइस पर रहती है जब तक आप स्वयं साझा न करें।';

  @override
  String get privacy3Title => 'जानकारी का उपयोग';

  @override
  String privacy3Body(String appName) {
    return 'हम इस डेटा का उपयोग $appName चलाने और सुधारने, प्रीमियम अधिकार देने, विज्ञापन चालू होने पर दिखाने, आपकी अनुरोधित सूचनाएँ भेजने, सेवा सुरक्षित करने और कानूनी दायित्वों के लिए करते हैं। हम आपकी व्यक्तिगत जानकारी पैसे के लिए नहीं बेचते।';
  }

  @override
  String get privacy4Title => 'अनुमतियाँ';

  @override
  String get privacy4Body =>
      'ऐप इंटरनेट, स्टोरेज/मीडिया (डाउनलोड और रिकॉर्डिंग), सूचनाएँ, कुछ Android संस्करणों पर निर्धारित प्लेबैक के लिए सटीक अलार्म, और केवल तभी माइक्रोफ़ोन जब आप वॉयस सुविधाएँ उपयोग करें, माँग सकता है। सिस्टम सेटिंग्स में कई अनुमतियाँ बदल सकते हैं; कुछ अस्वीकार करने पर सुविधाएँ सीमित हो सकती हैं।';

  @override
  String get privacy5Title => 'तृतीय-पक्ष सेवाएँ';

  @override
  String get privacy5Body =>
      'हम Google (FCM और जहाँ लागू हो AdMob सहित), iOS पर Apple प्लेटफ़ॉर्म सेवाएँ, खरीदारी के लिए RevenueCat, और अपना बैकएंड API उपयोग करते हैं। उनकी प्रथाएँ उनकी नीतियों में हैं। रेडियो स्ट्रीम और डाउनलोड योग्य मीडिया हमारे नियंत्रण से बाहर स्रोतों से आते हैं।';

  @override
  String get privacy6Title => 'प्रतिधारण और सुरक्षा';

  @override
  String get privacy6Body =>
      'हम सर्वर लॉग केवल उपरोक्त उद्देश्यों और उचित सुरक्षा के लिए आवश्यक समय तक रखते हैं। कोई भी संचरण या संग्रहण पूरी तरह सुरक्षित नहीं है; हम डेटा प्रकार के अनुरूप उपयुक्त सुरक्षा उपयोग करते हैं।';

  @override
  String get privacy7Title => 'बच्चों की गोपनीयता';

  @override
  String privacy7Body(String appName) {
    return '$appName उन बच्चों के लिए नहीं है जिनकी उम्र आपके देश में माता-पिता की सहमति के बिना सहमति की न्यूनतम आयु से कम है। हम जानबूझकर छोटे बच्चों से व्यक्तिगत डेटा एकत्र नहीं करते। यदि लगता है कि हमने किया है, तो संपर्क करें; कानून अनुसार हटा देंगे।';
  }

  @override
  String get privacy8Title => 'संपर्क';

  @override
  String privacy8Body(String supportEmail) {
    return 'इस नीति या आपके डेटा के बारे में: $supportEmail पर लिखें। हम नीति समय-समय पर अपडेट कर सकते हैं; नीचे की तारीख नवीनतम संशोधन दिखाती है।';
  }

  @override
  String get privacyLastUpdatedFooter => 'अंतिम अपडेट: अप्रैल 2026';

  @override
  String aboutIntroBody(String appName) {
    return '$appName लाइव रेडियो खोजने, पसंदीदा रखने, जहाँ उपलब्ध हो डाउनलोड उपयोग करने, और स्लीप टाइमर तथा वैकल्पिक वेक-अप प्लेबैक जैसे टूल देता है। प्रीमियम विज्ञापन कम कर सकता है और खरीद पर वर्णित सुविधाएँ जोड़ सकता है। सुनने के लिए धन्यवाद!';
  }

  @override
  String aboutVersionLabel(String version) {
    return 'संस्करण $version';
  }

  @override
  String get aboutLabelDeveloper => 'डेवलपर';

  @override
  String get aboutDeveloperName => 'Govardhana Rao Sugrivugari';

  @override
  String get aboutLabelContact => 'संपर्क';

  @override
  String get aboutLabelWebsite => 'वेबसाइट';

  @override
  String get aboutWebsiteDisplay => 'www.grradio.com';

  @override
  String aboutEmailSubject(String appName) {
    return '$appName — सहायता पूछताछ';
  }

  @override
  String get faqScreenSubtitle =>
      'स्टेशन, प्रीमियम, रिकॉर्डिंग, अलार्म आदि पर उत्तर';

  @override
  String get contactSupportTileSubtitle =>
      'ईमेल या फ़ॉर्म से हमारी सहायता टीम तक पहुँचें';

  @override
  String get feedbackFormTileSubtitle =>
      'समस्या रिपोर्ट करें या सुझाव साझा करें';
}
