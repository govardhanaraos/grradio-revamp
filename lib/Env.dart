class Env {
  //static late String apiBaseUrl = 'https://radio-backend-nysq.onrender.com';
  static String apiBaseUrl =
      'https://radio-backend-customer-care-radio.onrender.com';
  static const String environment = "production";
  static const int connectTimeoutMs = 60000;
  static const int receiveTimeoutMs = 60000;

  // ── App identity ────────────────────────────────────────────────────────────
  // TODO: Update packageName once the app is published on the Play Store.
  static const String packageName = 'com.grradio.app';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageName';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'grradio.customercare@gmail.com';
  static const String appStoreId = ''; // iOS App Store ID — set when available
  static const String appName = 'GR Radio';

  // ── RevenueCat ──────────────────────────────────────────────────────────────
  // Use PUBLIC SDK keys from RevenueCat dashboard:
  // Android key format usually starts with "goog_"
  // iOS key format usually starts with "appl_"
  //sk_CPpSAxwIVwwXPBizbMGkpdAMBJaan
  //test_EWJndZnjbUWEyVNJYEKSuRLKyBS
  static const String revenueCatAndroidPublicSdkKey =
      'sk_CPpSAxwIVwwXPBizbMGkpdAMBJaan';
  static const String revenueCatIosPublicSdkKey =
      'sk_CPpSAxwIVwwXPBizbMGkpdAMBJaan';
  static const String revenueCatEntitlementId = 'GR Radio Pro';
}
