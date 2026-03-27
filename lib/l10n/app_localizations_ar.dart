// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'GR راديو';

  @override
  String get tabRadio => 'راديو';

  @override
  String get tabPlayer => 'مشغل';

  @override
  String get tabDownloads => 'تنزيلات';

  @override
  String get tabMore => 'المزيد';

  @override
  String get sectionSettings => 'الإعدادات';

  @override
  String get sectionSupport => 'الدعم';

  @override
  String get settingDarkMode => 'الوضع المظلم';

  @override
  String get settingDarkModeOnSubtitle => 'الوضع المظلم مفعّل';

  @override
  String get settingDarkModeOffSubtitle => 'الوضع الفاتح مفعّل';

  @override
  String get settingLanguage => 'اللغة';

  @override
  String get settingLanguageSubtitle => 'اختر لغتك المفضلة';

  @override
  String get settingGoPremium => 'الاشتراك المميز (بدون إعلانات)';

  @override
  String get settingGoPremiumSubtitle => 'افتح جميع الميزات باشتراك';

  @override
  String get settingNotifications => 'الإشعارات';

  @override
  String get settingNotificationsSubtitle => 'إدارة تفضيلات الإشعارات';

  @override
  String get settingHelpSupport => 'المساعدة والدعم';

  @override
  String get settingHelpSupportSubtitle => 'احصل على مساعدة وتواصل مع الدعم';

  @override
  String get settingRateApp => 'تقييم التطبيق';

  @override
  String get settingRateAppSubtitle => 'شارك تعليقاتك معنا';

  @override
  String get settingShareApp => 'مشاركة التطبيق';

  @override
  String get settingShareAppSubtitle => 'شارك مع أصدقائك';

  @override
  String get settingAbout => 'حول';

  @override
  String get settingAboutSubtitle => 'إصدار التطبيق ومعلوماته';

  @override
  String get appTagline => 'رفيقك الموسيقي الأمثل';

  @override
  String get discoverHeader => 'اكتشف';

  @override
  String get nowPlaying => 'يُشغَّل الآن';

  @override
  String get searchStations => 'البحث عن المحطات...';

  @override
  String noStationsMatch(String query) {
    return 'لا توجد محطات تطابق \"$query\"';
  }

  @override
  String noLanguageStations(String language) {
    return 'لا توجد محطات $language';
  }

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get tryDifferentFilter => 'جرّب بحثاً أو فلتر لغة مختلفاً';

  @override
  String get sectionFavourites => 'المفضلة';

  @override
  String get sectionRecentlyPlayed => 'المُشغَّلة مؤخراً';

  @override
  String get sectionForYou => 'لأجلك';

  @override
  String get sectionTrending => 'الرائج';

  @override
  String get sectionAllStations => 'جميع المحطات';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get mp3PlayerTitle => 'موسيقاي';

  @override
  String get mp3TabMusic => 'موسيقى';

  @override
  String get mp3TabDownloads => 'تنزيلات';

  @override
  String get mp3TabRecordings => 'تسجيلات';

  @override
  String get mp3NoFiles => 'لم يتم العثور على ملفات';

  @override
  String get mp3SearchHint => 'البحث عن أغاني...';

  @override
  String get downloadTitle => 'تنزيل MP3';

  @override
  String get downloadSearchHint => 'البحث عن ملفات MP3...';

  @override
  String get downloadSearchAction => 'بحث';

  @override
  String get dialogUpdateTitle => 'تحديث متاح';

  @override
  String dialogUpdateContent(String version) {
    return 'الإصدار الجديد ($version) من GR راديو متاح. يرجى التحديث للاستمتاع بأفضل تجربة.';
  }

  @override
  String get dialogUpdateLater => 'لاحقاً';

  @override
  String get dialogUpdateNow => 'تحديث';

  @override
  String get dialogNoInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get dialogNoInternetContent =>
      'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get dialogRetry => 'إعادة المحاولة';

  @override
  String get languageSelectionTitle => 'اختر اللغة';

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
  String get buttonCancel => 'إلغاء';

  @override
  String get buttonDelete => 'حذف';

  @override
  String get buttonRename => 'إعادة التسمية';

  @override
  String get buttonOk => 'موافق';

  @override
  String get buttonOverwrite => 'استبدال';

  @override
  String get buttonTryAgain => 'حاول مرة أخرى';

  @override
  String get buttonAllow => 'سماح';

  @override
  String get buttonOpenSettings => 'فتح الإعدادات';

  @override
  String get buttonGrantPermission => 'منح الإذن';

  @override
  String get mp3DeleteFilesTitle => 'حذف الملفات';

  @override
  String get mp3DeleteFileTitle => 'حذف الملف';

  @override
  String mp3DeleteFileConfirm(String name) {
    return 'هل تريد حذف \"$name\"؟ لا يمكن التراجع عن هذا.';
  }

  @override
  String get sleepIn10 => 'النوم في 10 دقائق';

  @override
  String get sleepIn20 => 'النوم في 20 دقيقة';

  @override
  String get sleepIn30 => 'النوم في 30 دقيقة';

  @override
  String get sleepIn45 => 'النوم في 45 دقيقة';

  @override
  String get sleepIn60 => 'النوم في 60 دقيقة';

  @override
  String get sleepCancel => 'إلغاء مؤقت النوم';

  @override
  String get recordingNameHint => 'اسم التسجيل';

  @override
  String get emptyNoMusicTitle => 'لم يتم العثور على موسيقى';

  @override
  String get emptyNoMusicSubtitle => 'تحقق من تخزين جهازك بحثًا عن ملفات MP3.';

  @override
  String get emptyNoDownloadsTitle => 'لا توجد تنزيلات';

  @override
  String get emptyNoDownloadsSubtitle => 'ستظهر الأغاني التي تنزّلها هنا.';

  @override
  String get emptyNoRecordingsTitle => 'لا توجد تسجيلات';

  @override
  String get emptyNoRecordingsSubtitle =>
      'سيتم حفظ تسجيلات الراديو الخاصة بك هنا.';

  @override
  String get searchSongsHint => 'البحث عن أغاني...';

  @override
  String get searchDownloadsHint => 'البحث في التنزيلات...';

  @override
  String get searchRecordingsHint => 'البحث في التسجيلات...';

  @override
  String get deleteLabel => 'حذف';

  @override
  String get permissionStorageTitle => 'مطلوب إذن التخزين';

  @override
  String get permissionRequiredTitle => 'إذن مطلوب';

  @override
  String get downloadCompleteTitle => 'اكتمل التنزيل';

  @override
  String downloadFileLabel(String name) {
    return 'الملف: $name';
  }

  @override
  String downloadSizeLabel(String size) {
    return 'الحجم: $size';
  }

  @override
  String get fileExistsTitle => 'الملف موجود';

  @override
  String get tabAlbumsFolders => 'الألبومات/المجلدات';

  @override
  String get tabIndividualFiles => 'الملفات الفردية';

  @override
  String get masstamilanTitle => 'أحدث ألبومات التيلوغو';

  @override
  String get stopRecordingBeforeSwitch => 'أوقف التسجيل قبل تبديل التبويب.';

  @override
  String get mp3DownloadSearchHint => 'اسم الفيلم أو الأغنية أو الفنان.';

  @override
  String get aiAssistant => 'مساعد الذكاء الاصطناعي';

  @override
  String get aiAssistantSubtitle => 'احصل على مساعدة فورية من الذكاء الاصطناعي';

  @override
  String get aiChatHint => 'اكتب رسالة...';

  @override
  String get aiTyping => 'الذكاء الاصطناعي يكتب...';

  @override
  String get aiClearChat => 'مسح الدردشة';

  @override
  String get aiClearConfirm => 'هل أنت متأكد من مسح سجل الدردشة؟';

  @override
  String get aiContactHuman => 'اتصل بالدعم الفني';

  @override
  String get aiWelcome =>
      'مرحباً! أنا مساعد الذكاء الاصطناعي لراديو GR. كيف يمكنني مساعدتك؟';

  @override
  String get aiError => 'فشل الحصول على رد، يرجى المحاولة مرة أخرى.';
}
