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
  String get sleepTimerSheetTitle => 'مؤقت النوم';

  @override
  String sleepTimerMinutesChip(int minutes) {
    return '$minutes د';
  }

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

  @override
  String get settingWakeMeUp => 'أيقظني';

  @override
  String get settingWakeMeUpSubtitle =>
      'منبه راديو لمرة واحدة أو يومي أو أسبوعي';

  @override
  String get wakeAlarmTitle => 'أيقظني';

  @override
  String get wakeAlarmHowItWorksTitle => 'كيف يعمل';

  @override
  String get wakeAlarmAndroidExplain =>
      'يمكن لنظام Android فتح GR Radio في الوقت المحدد وتشغيل محطتك حتى لو كان التطبيق مغلقاً. تستخدم المنبهات لمرة واحدة التاريخ الذي تختاره؛ اليومية والأسبوعية تستخدم وقت الساعة (والأيام للأسبوعي). اسمح بإذن \"التنبيهات والتذكيرات\" (التنبيهات الدقيقة) عند الطلب، وتجنب إيقاف التطبيق بالقوة، وقد تتأخر بعض الأجهزة بسبب توفير البطارية.';

  @override
  String get wakeAlarmIosExplain =>
      'لا يسمح iOS بتشغيل الصوت تلقائياً عند إغلاق التطبيق. ستصلك إشعار في الوقت المحدد — افتحه لتشغيل المحطة. تتكرر الجداول اليومية والأسبوعية عبر الإشعارات في تلك الأيام. اترك الإشعارات مفعّلة لـ GR Radio.';

  @override
  String get wakeRepeatLabel => 'التكرار';

  @override
  String get wakeRepeatOnce => 'مرة واحدة';

  @override
  String get wakeRepeatDaily => 'يومياً';

  @override
  String get wakeRepeatWeekly => 'أسبوعياً';

  @override
  String get wakeWeekdaysLabel => 'الأيام';

  @override
  String get wakeAlarmDate => 'التاريخ';

  @override
  String get wakeAlarmTime => 'الوقت';

  @override
  String get wakeAlarmTimeRepeat => 'وقت اليوم';

  @override
  String get wakeAlarmStation => 'المحطة';

  @override
  String get wakeAlarmSelectStation => 'اختر محطة';

  @override
  String get wakeAlarmSave => 'حفظ المنبه';

  @override
  String get wakeAlarmClear => 'إلغاء المنبه';

  @override
  String get wakeAlarmScheduled => 'تم حفظ المنبه.';

  @override
  String get wakeAlarmDisabled => 'تم إلغاء المنبه.';

  @override
  String get wakeAlarmScheduleFailed =>
      'تعذر الحفظ. تحقق من إذن التنبيه الدقيق (Android) أو الإشعارات (iOS) والتاريخ/الوقت والأيام للأسبوعي.';

  @override
  String get wakeAlarmPickStation => 'اختر محطة أولاً.';

  @override
  String get wakeAlarmPickFuture =>
      'اختر تاريخاً ووقتاً بعد 30 ثانية على الأقل من الآن.';

  @override
  String get wakeAlarmPickFutureRepeat =>
      'اختر وقتاً بعد 30 ثانية على الأقل للتنبيه التالي.';

  @override
  String get wakeAlarmNoStations =>
      'لم تُحمَّل المحطات بعد. افتح تبويب الراديو ثم حاول مرة أخرى.';

  @override
  String get noInternetStreamingTitle => 'لا إنترنت';

  @override
  String get noInternetStreamingBody =>
      'يحتاج GR Radio إلى اتصال إنترنت نشط لبث الموسيقى. يرجى التحقق من الإعدادات.';

  @override
  String get buttonRetryUpper => 'إعادة المحاولة';

  @override
  String get batteryOptimizationTitle => 'إبقاء الراديو يعمل';

  @override
  String get batteryOptimizationBody =>
      'لتقليل توقف الراديو عند إطفاء الشاشة أو أثناء المكالمات، اسمح للتطبيق بالعمل في الخلفية في الشاشة التالية.';

  @override
  String get batteryOptimizationLater => 'لاحقاً';

  @override
  String get batteryOptimizationSettings => 'الإعدادات';

  @override
  String get recordingInProgressBadge => 'جاري التسجيل';

  @override
  String sleepInHoursOnly(int h) {
    return 'النوم خلال $h س';
  }

  @override
  String sleepInHoursMinutes(int h, int m) {
    return 'النوم خلال $h س $m د';
  }

  @override
  String sleepInMinutesOnly(int minutes) {
    return 'النوم خلال $minutes د';
  }

  @override
  String get premiumThankYou => 'شكراً — البريميوم مفعّل.';

  @override
  String get premiumNoPackages => 'لا توجد حزمة اشتراك متاحة حالياً.';

  @override
  String paywallCouldNotOpen(String error) {
    return 'تعذر فتح الاشتراكات: $error';
  }

  @override
  String shareCouldNotOpen(String error) {
    return 'تعذر المشاركة: $error';
  }

  @override
  String ratingCouldNotOpen(String error) {
    return 'تعذر فتح التقييم: $error';
  }

  @override
  String get screenFaq => 'الأسئلة الشائعة';

  @override
  String get screenTermsOfService => 'شروط الخدمة';

  @override
  String get screenPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get screenAbout => 'حول';

  @override
  String get screenNotifications => 'الإشعارات';

  @override
  String get screenFeedback => 'ملاحظات / شكوى';

  @override
  String get screenContactSupport => 'اتصل بالدعم';

  @override
  String get buttonSendEmail => 'إرسال بريد';

  @override
  String get licensesThirdParty => 'تراخيص الطرف الثالث';

  @override
  String get languageApplicationLabel => 'لغة التطبيق';

  @override
  String get languageListeningLabel => 'لغة الاستماع';

  @override
  String languageSlotLabel(int index) {
    return 'اللغة $index';
  }

  @override
  String get premiumMembershipTitle => 'العضوية المميزة';

  @override
  String get premiumManageDevices => 'إدارة الأجهزة المرتبطة';

  @override
  String get premiumActivateNowUpper => 'تفعيل الآن';

  @override
  String get premiumActivationSuccess => 'تم التفعيل بنجاح!';

  @override
  String premiumActivateError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get premiumDeactivatedDevice => 'تم إلغاء البريميوم لهذا الجهاز.';

  @override
  String premiumUnlinkFailed(String error) {
    return 'فشل إلغاء الربط: $error';
  }

  @override
  String get activateRadioProTitle => 'تفعيل Radio Pro';

  @override
  String get premiumActivatedAdsRemoved => 'تم التفعيل! أزيلت الإعلانات.';

  @override
  String get buttonActivateNow => 'تفعيل الآن';

  @override
  String get miniPlayerHideTooltip => 'إخفاء المشغّل المصغّر';

  @override
  String get radioStreamSubtitleDefault => 'بث الراديو';

  @override
  String shareAppMessage(String appName, String url) {
    return 'مرحباً! جرّب $appName للبث الراديوي عالي الجودة والميزات المميزة. حمّله من هنا: $url';
  }

  @override
  String shareAppSubject(String appName) {
    return 'جرّب $appName';
  }

  @override
  String copyrightFooter(String year, String appName) {
    return '© $year $appName. جميع الحقوق محفوظة.';
  }

  @override
  String get faq1Question => 'كيف أجد محطة وأشغّلها؟';

  @override
  String get faq1Answer =>
      'افتح تبويب الراديو، تصفّح القائمة أو ابحث، واضغط على محطة لبدء التشغيل. استخدم البحث وفلاتر اللغة عند توفرها.';

  @override
  String get faq2Question => 'لماذا يتوقف التشغيل أو يتقطع؟';

  @override
  String get faq2Answer =>
      'البث المباشر يحتاج اتصالاً مستقراً. جرّب Wi‑Fi أو إشارة أقوى. على أندرويد قد توقف تحسين البطارية الصوت في الخلفية—اسمح للتطبيق بالعمل في الخلفية عند الطلب.';

  @override
  String get faq3Question => 'كيف يعمل الاشتراك المميز؟';

  @override
  String get faq3Answer =>
      'اذهب إلى المزيد → الانتقال إلى المميز لعرض خيارات الاشتراك عبر Google Play أو Apple. قد يزيل الإعلانات ويضيف مزايا موضحة عند الشراء. يمكن استعادة المشتريات على جهاز جديد بنفس حساب المتجر. قد تتوفر مفاتيح ترخيص أو ربط أجهزة في بعض المسارات.';

  @override
  String get faq4Question => 'هل يمكن الاستماع دون إنترنت؟';

  @override
  String get faq4Answer =>
      'بث الراديو المباشر يحتاج اتصالاً فعّالاً. قد تعمل عناصر التنزيلات دون اتصال وفقاً لكيفية الحصول عليها وقيود الترخيص.';

  @override
  String get faq5Question => 'كيف تعمل التسجيلات؟';

  @override
  String get faq5Answer =>
      'حيث يتوفر التسجيل للبث المباشر، يُحفظ الصوت على جهازك. استخدم التسجيلات لأغراض شخصية قانونية واحترم حقوق المذيعين وحقوق النشر.';

  @override
  String get faq6Question => 'ما مؤقت النوم و«أوقظني»؟';

  @override
  String get faq6Answer =>
      'مؤقت النوم يوقف التشغيل بعد المدة التي تختارها. «أوقظني» يجدول تشغيل محطة في وقت محدد حيث يُدعم؛ على أندرويد قد تُطلب أذونات الإشعارات أو المنبّه الدقيق.';

  @override
  String get faq7Question => 'كيف أضيف محطة إلى المفضلة؟';

  @override
  String get faq7Answer =>
      'اضغط أيقونة القلب في القائمة أو المشغّل. تظهر المفضلة في قسم مخصص في شاشة الراديو.';

  @override
  String get faq8Question => 'كيف أحصل على مساعدة أو أبلغ عن مشكلة؟';

  @override
  String get faq8Answer =>
      'اذهب إلى المزيد → المساعدة والدعم. يمكنك أيضاً مراسلتنا من شاشة «حول».';

  @override
  String get terms1Title => 'قبول الشروط';

  @override
  String terms1Body(String appName) {
    return 'بتنزيل $appName أو استخدامه فإنك توافق على شروط الخدمة هذه. إذا لم توافق فلا تستخدم التطبيق.';
  }

  @override
  String get terms2Title => 'الخدمة';

  @override
  String terms2Body(String appName) {
    return 'يتيح $appName بث محطات راديو مباشرة، والوصول إلى صوت قابل للتنزيل عبر التطبيق، وتسجيل البث حيث يتوفر، وأدوات مثل مؤقت النوم، وإشعارات اختيارية وتشغيل مجدول (بما في ذلك المنبهات على الأجهزة المدعومة). قد تختلف الميزات حسب المنصة. قد نعدّل أو نعلّق أو نوقف أي جزء عند الحاجة.';
  }

  @override
  String get terms3Title => 'الاشتراك المميز والمشتريات والتراخيص';

  @override
  String get terms3Body =>
      'قد تُعالج الاشتراكات أو المشتريات عبر أطراف ثالثة بما في ذلك متجر التطبيق وخدمات مثل RevenueCat. قد تستخدم بعض المسارات مفتاح ترخيص أو ربط أجهزة؛ حيث ينطبق ذلك تُعرض الحدود في التطبيق. الأسعار والتجديد والإلغاء والاسترداد وفق قواعد المتجر أو المزوّد. الضرائب والرسوم على عاتقك.';

  @override
  String get terms4Title => 'الاستخدام المقبول';

  @override
  String terms4Body(String appName) {
    return 'تستخدم $appName للاستماع الشخصي القانوني ما لم يُسمح بخلاف ذلك. يُحظر إساءة الاستخدام أو تجاوز التحقق من الدفع أو الهجوم على الأنظمة أو إعادة توزيع البث أو التنزيلات أو التسجيلات بما يخالف حقوق النشر أو شروط المذيعين. أنت مسؤول عن تكاليف البيانات والامتثال للقوانين المحلية.';
  }

  @override
  String get terms5Title => 'المحطات والمحتوى من أطراف ثالثة';

  @override
  String terms5Body(String appName) {
    return 'البث والصور والبيانات الوصفية والمحتوى القابل للتنزيل يأتي من أطراف ثالثة. $appName لا يملك ذلك المحتوى. التوفر والجودة يعتمدان على المصادر واتصالك. لا نضمن استمرار توفر أي محطة أو مقطع.';
  }

  @override
  String get terms6Title => 'إخلاء المسؤولية والمسؤولية';

  @override
  String get terms6Body =>
      'تُقدَّم الخدمة كما هي دون ضمانات في أقصى حد يسمح به القانون. لسنا مسؤولين عن الأضرار غير المباشرة أو رسوم البيانات أو الانقطاع أو فقدان التسجيلات أو فشل المنبه. في بعض المناطق تنطبق حدود مختلفة وفق القانون.';

  @override
  String get terms7Title => 'التغييرات والاتصال';

  @override
  String terms7Body(String supportEmail) {
    return 'قد نحدّث هذه الشروط؛ الاستمرار بعد التحديث يعني القبول. للأسئلة راسلنا على $supportEmail.';
  }

  @override
  String get privacy1Title => 'مقدمة';

  @override
  String privacy1Body(String appName) {
    return 'توضح سياسة الخصوصية هذه كيفية تعامل $appName مع المعلومات عند استخدام التطبيق. اقرأها مع شروط الخدمة.';
  }

  @override
  String get privacy2Title => 'المعلومات التي نجمعها';

  @override
  String get privacy2Body =>
      '• قد تُرسل معرّفات الجهاز/التطبيق إلى خادمنا للإعدادات والسجلات التشغيلية ومنع الاحتيال ودعم الاشتراك المميز أو حدود الأجهزة.\n• قد نسجّل استخداماً عاماً (مثل الشاشات أو الإجراءات) لتحسين المنتج.\n• المشتريات: تتم عبر متجر التطبيق؛ قد تُعالج حالة الاشتراك عبر مزوّدين مثل RevenueCat—لا نتلقى رقم بطاقتك الكامل.\n• الإعلانات: عند التفعيل قد يستخدم AdMob معرّفات وفق سياسات Google.\n• الإشعارات: عند الموافقة قد يستخدم Firebase Cloud Messaging رمز دفع لإيصال الرسائل.\n• المحتوى الذي تنشئه (تسجيلات، تنزيلات) يبقى على جهازك ما لم تشاركه.';

  @override
  String get privacy3Title => 'كيف نستخدم المعلومات';

  @override
  String privacy3Body(String appName) {
    return 'نستخدم البيانات لتشغيل $appName وتحسينه، وتقديم الامتيازات المميزة، وعرض الإعلانات عند تفعيلها، وإرسال الإشعارات التي تطلبها، وحماية الخدمة، والامتثال للقانون. لا نبيع معلوماتك الشخصية مقابل مال.';
  }

  @override
  String get privacy4Title => 'الأذونات';

  @override
  String get privacy4Body =>
      'قد يطلب التطبيق الإنترنت، والتخزين/الوسائط (للتنزيلات والتسجيلات)، والإشعارات، والمنبّه الدقيق على بعض إصدارات أندرويد للتشغيل المجدول، والميكروفون فقط إذا استخدمت ميزات صوتية. يمكنك تغيير الأذونات في إعدادات النظام؛ رفض بعضها قد يحدّ الميزات.';

  @override
  String get privacy5Title => 'خدمات الطرف الثالث';

  @override
  String get privacy5Body =>
      'نعتمد على مزوّدين مثل Google (بما في ذلك FCM وAdMob حيث ينطبق)، وخدمات Apple على iOS، وRevenueCat للمشتريات، وواجهة خادمنا الخلفية. ممارساتهم في سياساتهم. بث الراديو والوسائط القابلة للتنزيل من مصادر خارج سيطرتنا.';

  @override
  String get privacy6Title => 'الاحتفاظ والأمان';

  @override
  String get privacy6Body =>
      'نحتفظ بسجلات الخادم فقط للمدة اللازمة للأغراض أعلاه والأمان المعقول. لا يوجد نقل أو تخزين آمن تماماً؛ نستخدم ضمانات مناسبة لنوع البيانات.';

  @override
  String get privacy7Title => 'خصوصية الأطفال';

  @override
  String privacy7Body(String appName) {
    return '$appName غير موجّه للأطفال دون السن المطلوبة للموافقة في بلدك. لا نجمع عن قصد بيانات شخصية من أطفال صغار. إذا ظننت أننا فعلنا ذلك، تواصل معنا وسنحذفها حيث يقتضي القانون.';
  }

  @override
  String get privacy8Title => 'اتصل بنا';

  @override
  String privacy8Body(String supportEmail) {
    return 'للأسئلة حول هذه السياسة أو بياناتك: $supportEmail. قد نحدّث السياسة؛ التاريخ في الأسفل يعكس آخر مراجعة.';
  }

  @override
  String get privacyLastUpdatedFooter => 'آخر تحديث: أبريل 2026';

  @override
  String aboutIntroBody(String appName) {
    return '$appName يساعدك على اكتشاف الراديو المباشر والمفضلة والتنزيلات حيث تتوفر، وأدوات مثل مؤقت النوم والتشغيل المجدول الاختياري. قد يقلل الاشتراك المميز الإعلانات ويضيف مزايا موضحة عند الشراء. شكراً لاستماعك!';
  }

  @override
  String aboutVersionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get aboutLabelDeveloper => 'المطوّر';

  @override
  String get aboutDeveloperName => 'Govardhana Rao Sugrivugari';

  @override
  String get aboutLabelContact => 'اتصل بنا';

  @override
  String get aboutLabelWebsite => 'الموقع';

  @override
  String get aboutWebsiteDisplay => 'www.grradio.com';

  @override
  String aboutEmailSubject(String appName) {
    return '$appName — استفسار دعم';
  }

  @override
  String get faqScreenSubtitle =>
      'إجابات عن المحطات والبريميوم والتسجيلات والمنبهات وغيرها';

  @override
  String get contactSupportTileSubtitle =>
      'تواصل مع فريق الدعم عبر البريد أو النموذج';

  @override
  String get feedbackFormTileSubtitle => 'أبلغ عن مشكلة أو شارك اقتراحاً';
}
