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
}
