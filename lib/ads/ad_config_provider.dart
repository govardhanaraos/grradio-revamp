import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// When [fetchScreenAdConfig] fails but GET /analytics/config/global returned
  /// ads on — use this so banners/in-list ads are not stuck off.
  static const ScreenAdConfig fallbackWhenGlobalAdsOn = ScreenAdConfig(
    adsEnabled: true,
    bannerEnabled: true,
    interstitialEnabled: true,
    interstitialEveryNTaps: 5,
    inlistEnabled: true,
    stationsList: InListPlacement(
      enabled: true,
      everyNItems: 6,
      firstAdPosition: 0,
      maxAds: 0,
    ),
    mp3List: InListPlacement(
      enabled: true,
      everyNItems: 6,
      firstAdPosition: 0,
      maxAds: 0,
    ),
    downloadsList: InListPlacement(
      enabled: true,
      everyNItems: 6,
      firstAdPosition: 0,
      maxAds: 0,
    ),
    recordingsList: InListPlacement(
      enabled: true,
      everyNItems: 6,
      firstAdPosition: 0,
      maxAds: 0,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AdConfigProvider
// ─────────────────────────────────────────────────────────────────────────────
class AdConfigProvider extends ChangeNotifier {
  final AnalyticsServiceAPI _api;

  AdConfigProvider(this._api);

  static const String _prefsGlobalAdsEnabledKey = 'ads_cfg_global_enabled';
  static const String _prefsScreenConfigsKey = 'ads_cfg_screen_configs_json';

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

  /// Hydrates ad flags from SharedPreferences so screens can show/hide ads
  /// immediately on app start while network refresh runs in background.
  Future<void> hydrateFromCache({required bool isPremiumUser}) async {
    _isPremiumUser = isPremiumUser;
    try {
      final prefs = await SharedPreferences.getInstance();
      _globalAdsEnabled = prefs.getBool(_prefsGlobalAdsEnabledKey) ?? false;

      final raw = prefs.getString(_prefsScreenConfigsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _screenConfigs
            ..clear()
            ..addAll({
              for (final entry in decoded.entries)
                entry.key: entry.value is Map<String, dynamic>
                    ? ScreenAdConfig.fromJson(entry.value)
                    : ScreenAdConfig.disabled,
            });
        }
      }
    } catch (_) {
      // Cache parse/read failure should never block ad config init.
    }
    _initialized = true;
    notifyListeners();
  }

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

    _globalAdsEnabled = await _api.fetchGlobalAdsEnabled();

    final radioResult = await _api.fetchScreenAdConfig(AdScreen.radio);
    final playerResult = await _api.fetchScreenAdConfig(AdScreen.player);
    final mp3Result = await _api.fetchScreenAdConfig(AdScreen.mp3Download);

    _screenConfigs[AdScreen.radio] = _mergeScreenFetch(radioResult);
    _screenConfigs[AdScreen.player] = _mergeScreenFetch(playerResult);
    _screenConfigs[AdScreen.mp3Download] = _mergeScreenFetch(mp3Result);

    await _saveCache();
    _initialized = true;
    notifyListeners();
  }

  /// Per-screen GET success uses server flags. On failure, if the global master
  /// switch is on, use [ScreenAdConfig.fallbackWhenGlobalAdsOn] so UI matches
  /// `/analytics/config/global` instead of staying permanently disabled.
  ScreenAdConfig _mergeScreenFetch(
    ({ScreenAdConfig config, bool fetchedOk}) result,
  ) {
    if (result.fetchedOk) return result.config;
    if (_globalAdsEnabled) return ScreenAdConfig.fallbackWhenGlobalAdsOn;
    return ScreenAdConfig.disabled;
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

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsGlobalAdsEnabledKey, _globalAdsEnabled);
      await prefs.setString(
        _prefsScreenConfigsKey,
        jsonEncode({
          for (final entry in _screenConfigs.entries)
            entry.key: {
              'ads_enabled': entry.value.adsEnabled,
              'banner_enabled': entry.value.bannerEnabled,
              'interstitial_enabled': entry.value.interstitialEnabled,
              'interstitial_every_n_taps': entry.value.interstitialEveryNTaps,
              'inlist_enabled': entry.value.inlistEnabled,
              'stations_list': _placementToJson(entry.value.stationsList),
              'mp3_list': _placementToJson(entry.value.mp3List),
              'downloads_list': _placementToJson(entry.value.downloadsList),
              'recordings_list': _placementToJson(entry.value.recordingsList),
            },
        }),
      );
    } catch (_) {
      // Best-effort cache write only.
    }
  }

  Map<String, dynamic> _placementToJson(InListPlacement placement) {
    return {
      'enabled': placement.enabled,
      'every_n_items': placement.everyNItems,
      'first_ad_position': placement.firstAdPosition,
      'max_ads': placement.maxAds,
    };
  }
}
