import 'package:flutter/foundation.dart';
import 'package:grradio/api/analytics_service_api.dart';

// ─────────────────────────────────────────────────────────────────────────────
// IMPORTANT — single source of truth
//
// ScreenAdConfig and InListPlacement are defined HERE and ONLY here.
// analytics_service_api.dart imports this file and returns ScreenAdConfig
// directly from fetchScreenAdConfig(), so there is never more than one class
// with that name on the Dart type system.  Duplicate class definitions across
// files cause the runtime error:
//   "type 'ScreenAdConfig' is not a subtype of type 'ScreenAdConfig'"
// because Dart considers two classes with identical names in different library
// URIs as completely different types.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Screen key constants
//
// These must match the "screen" field in the backend ScreenAdsConfig documents.
//
// AdScreen.radio      → RadioPlayerScreen  (screen: "radio")
// AdScreen.player     → Mp3PlayerScreen    (screen: "player")
//                       ↳ used for Music / Downloads / Recordings tabs,
//                         banner, interstitial, mp3_list, downloads_list,
//                         recordings_list placement configs.
// AdScreen.mp3Download → Mp3DownloadScreen (screen: "mp3_download")
//                        ↳ the download-manager screen, NOT the library player.
// ─────────────────────────────────────────────────────────────────────────────
class AdScreen {
  static const String radio = 'radio';
  static const String player = 'player';
  static const String mp3Download = 'mp3_download';
}

// ─────────────────────────────────────────────────────────────────────────────
// InListPlacement
// Mirrors the backend InListAdPlacement Pydantic model.
// ─────────────────────────────────────────────────────────────────────────────
class InListPlacement {
  /// Whether in-list ads are active for this particular list.
  final bool enabled;

  /// Insert one ad tile after every [everyNItems] content rows.
  final int everyNItems;

  /// Index override for the very first ad tile. 0 = use everyNItems.
  final int firstAdPosition;

  /// Cap on total ad tiles in the list. 0 = unlimited.
  final int maxAds;

  const InListPlacement({
    this.enabled = false,
    this.everyNItems = 6,
    this.firstAdPosition = 0,
    this.maxAds = 0,
  });

  factory InListPlacement.fromJson(Map<String, dynamic> json) {
    return InListPlacement(
      enabled: json['enabled'] as bool? ?? false,
      everyNItems: json['every_n_items'] as int? ?? 6,
      firstAdPosition: json['first_ad_position'] as int? ?? 0,
      maxAds: json['max_ads'] as int? ?? 0,
    );
  }

  static const InListPlacement disabled = InListPlacement();
}

// ─────────────────────────────────────────────────────────────────────────────
// ScreenAdConfig
// Mirrors the backend ScreenAdsConfig Pydantic model.
// ─────────────────────────────────────────────────────────────────────────────
class ScreenAdConfig {
  final bool adsEnabled;
  final bool bannerEnabled;
  final bool interstitialEnabled;
  final int interstitialEveryNTaps;
  final bool inlistEnabled;

  final InListPlacement stationsList;
  final InListPlacement mp3List;
  final InListPlacement downloadsList;
  final InListPlacement recordingsList;

  const ScreenAdConfig({
    this.adsEnabled = false,
    this.bannerEnabled = false,
    this.interstitialEnabled = false,
    this.interstitialEveryNTaps = 5,
    this.inlistEnabled = false,
    this.stationsList = InListPlacement.disabled,
    this.mp3List = InListPlacement.disabled,
    this.downloadsList = InListPlacement.disabled,
    this.recordingsList = InListPlacement.disabled,
  });

  factory ScreenAdConfig.fromJson(Map<String, dynamic> json) {
    final bool screenEnabled = json['ads_enabled'] as bool? ?? false;

    InListPlacement parsePlacement(String key) {
      final raw = json[key];
      if (raw is Map<String, dynamic>) return InListPlacement.fromJson(raw);
      // Backward-compat: sub-doc absent → inherit screen-level enabled flag.
      return InListPlacement(enabled: screenEnabled);
    }

    return ScreenAdConfig(
      adsEnabled: screenEnabled,
      bannerEnabled: json['banner_enabled'] as bool? ?? screenEnabled,
      interstitialEnabled: json['interstitial_enabled'] as bool? ?? false,
      interstitialEveryNTaps: json['interstitial_every_n_taps'] as int? ?? 5,
      inlistEnabled: json['inlist_enabled'] as bool? ?? screenEnabled,
      stationsList: parsePlacement('stations_list'),
      mp3List: parsePlacement('mp3_list'),
      downloadsList: parsePlacement('downloads_list'),
      recordingsList: parsePlacement('recordings_list'),
    );
  }

  /// All flags disabled — safe fallback on error or when global ads are off.
  static const ScreenAdConfig disabled = ScreenAdConfig();
}

// ─────────────────────────────────────────────────────────────────────────────
// AdConfigProvider
// ─────────────────────────────────────────────────────────────────────────────
class AdConfigProvider extends ChangeNotifier {
  final AnalyticsServiceAPI _api;

  AdConfigProvider(this._api);

  bool _globalAdsEnabled = false;
  bool _isPremiumUser = false;
  bool _initialized = false;

  final Map<String, ScreenAdConfig> _screenConfigs = {};

  // ── Public getters ─────────────────────────────────────────────────────────
  bool get globalAdsEnabled => _globalAdsEnabled && !_isPremiumUser;
  bool get isPremiumUser => _isPremiumUser;
  bool get initialized => _initialized;

  // ── Top-level per-screen helpers ───────────────────────────────────────────
  bool isAdsEnabled(String screen) =>
      globalAdsEnabled && (_screenConfigs[screen]?.adsEnabled ?? false);

  bool isBannerEnabled(String screen) =>
      globalAdsEnabled && (_screenConfigs[screen]?.bannerEnabled ?? false);

  bool isInterstitialEnabled(String screen) =>
      globalAdsEnabled &&
      (_screenConfigs[screen]?.interstitialEnabled ?? false);

  bool isInlistEnabled(String screen) =>
      globalAdsEnabled && (_screenConfigs[screen]?.inlistEnabled ?? false);

  int interstitialEveryNTaps(String screen) =>
      _screenConfigs[screen]?.interstitialEveryNTaps ?? 5;

  // ── Per-list placement helpers ─────────────────────────────────────────────
  InListPlacement stationsListPlacement(String screen) {
    if (!isInlistEnabled(screen)) return InListPlacement.disabled;
    return _screenConfigs[screen]?.stationsList ?? InListPlacement.disabled;
  }

  InListPlacement mp3ListPlacement(String screen) {
    if (!isInlistEnabled(screen)) return InListPlacement.disabled;
    return _screenConfigs[screen]?.mp3List ?? InListPlacement.disabled;
  }

  InListPlacement downloadsListPlacement(String screen) {
    if (!isInlistEnabled(screen)) return InListPlacement.disabled;
    return _screenConfigs[screen]?.downloadsList ?? InListPlacement.disabled;
  }

  InListPlacement recordingsListPlacement(String screen) {
    if (!isInlistEnabled(screen)) return InListPlacement.disabled;
    return _screenConfigs[screen]?.recordingsList ?? InListPlacement.disabled;
  }

  // ── Initialisation ─────────────────────────────────────────────────────────

  /// Fetches the global flag + all screen configs in one parallel batch.
  /// Because analytics_service_api.dart imports this file and its
  /// fetchScreenAdConfig() returns THIS ScreenAdConfig, the Future.wait
  /// results cast cleanly — there is only one ScreenAdConfig type.
  Future<void> initialize({required bool isPremiumUser}) async {
    _isPremiumUser = isPremiumUser;

    if (isPremiumUser) {
      _globalAdsEnabled = false;
      _initialized = true;
      notifyListeners();
      return;
    }

    // Typed futures — avoids the List<dynamic> cast ambiguity entirely.
    final globalFuture = _api.fetchGlobalAdsEnabled();
    final radioFuture = _api.fetchScreenAdConfig(AdScreen.radio);
    final playerFuture = _api.fetchScreenAdConfig(AdScreen.player);
    final mp3Future = _api.fetchScreenAdConfig(AdScreen.mp3Download);

    // Await individually so each result is already strongly typed.
    // (Future.wait returns List<dynamic> which triggered the bad cast before.)
    _globalAdsEnabled = await globalFuture;
    _screenConfigs[AdScreen.radio] = await radioFuture;
    _screenConfigs[AdScreen.player] = await playerFuture;
    _screenConfigs[AdScreen.mp3Download] = await mp3Future;

    _initialized = true;
    notifyListeners();
  }

  /// Call whenever premium status changes (e.g. after a purchase).
  Future<void> updatePremiumStatus(bool isPremium) async {
    _isPremiumUser = isPremium;
    if (isPremium) _globalAdsEnabled = false;
    notifyListeners();
  }

  /// Re-fetch everything from the server.
  Future<void> refresh({bool? isPremiumUser}) async {
    if (isPremiumUser != null) _isPremiumUser = isPremiumUser;
    await initialize(isPremiumUser: _isPremiumUser);
  }
}
