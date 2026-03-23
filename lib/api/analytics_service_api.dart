import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:grradio/Env.dart';
import 'package:grradio/ads/ad_config_provider.dart'; // single source of truth for ScreenAdConfig
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// NOTE: ScreenAdConfig, InListPlacement and all ad-config models live ONLY in
// ad_config_provider.dart.  This file imports and re-uses them — it never
// re-declares them.  Having two classes with the same name in different files
// causes a runtime "type 'X' is not a subtype of type 'X'" crash when
// Future.wait returns List<dynamic> and the cast picks the wrong library's type.
// ─────────────────────────────────────────────────────────────────────────────

final String _baseUrl = Env.apiBaseUrl;
const String _analyticsEndpoint = '/analytics';

/// Retries transient TLS/HTTP failures (e.g. "Connection closed before full header",
/// broken pipe) common on cold Render.com connections.
Future<http.Response> _getWithRetry(Uri uri) async {
  const maxAttempts = 3;
  Object? lastErr;
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await http.get(uri).timeout(Duration(seconds: 12 + attempt * 6));
    } catch (e) {
      lastErr = e;
      if (attempt < maxAttempts - 1) {
        await Future<void>.delayed(
          Duration(milliseconds: 350 * (1 << attempt)),
        );
      }
    }
  }
  throw lastErr ?? Exception('GET failed after $maxAttempts attempts');
}

bool _coerceAdsEnabledFlag(dynamic raw) {
  if (raw == null) return false;
  if (raw is bool) return raw;
  if (raw is num) return raw != 0;
  if (raw is String) {
    final s = raw.toLowerCase().trim();
    return s == 'true' || s == '1' || s == 'yes';
  }
  return false;
}

class AnalyticsServiceAPI {
  // ── Global master switch ───────────────────────────────────────────────────
  // GET /analytics/config/global  →  { "ads_enabled": true }
  Future<bool> fetchGlobalAdsEnabled() async {
    final uri = Uri.parse('$_baseUrl$_analyticsEndpoint/config/global');
    try {
      final response = await _getWithRetry(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _coerceAdsEnabledFlag(data['ads_enabled']);
      }
    } catch (e) {
      debugPrint('Error fetching global ads config: $e');
    }
    return false;
  }

  // ── Screen-level config ────────────────────────────────────────────────────
  // GET /analytics/ads/<screen>
  // Returns the full ScreenAdConfig (defined in ad_config_provider.dart).
  //
  // Backend response shape (example for 'radio'):
  // {
  //   "screen": "radio",
  //   "ads_enabled": true,
  //   "banner_enabled": true,
  //   "interstitial_enabled": true,
  //   "interstitial_every_n_taps": 5,
  //   "inlist_enabled": true,
  //   "stations_list":   { "enabled": true,  "every_n_items": 6, "first_ad_position": 3, "max_ads": 10 },
  //   "mp3_list":        { "enabled": true,  "every_n_items": 8, "first_ad_position": 0, "max_ads": 3  },
  //   "downloads_list":  { "enabled": false, "every_n_items": 6, "first_ad_position": 0, "max_ads": 0  },
  //   "recordings_list": { "enabled": false, "every_n_items": 6, "first_ad_position": 0, "max_ads": 0  }
  // }
  /// [fetchedOk] is false when the HTTP request failed or returned non-200.
  /// Callers should fall back to [ScreenAdConfig.fallbackWhenGlobalAdsOn] when
  /// the global master switch is on but per-screen config could not be loaded.
  Future<({ScreenAdConfig config, bool fetchedOk})> fetchScreenAdConfig(
    String screen,
  ) async {
    final uri = Uri.parse('$_baseUrl$_analyticsEndpoint/ads/$screen');
    try {
      final response = await _getWithRetry(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return (config: ScreenAdConfig.fromJson(data), fetchedOk: true);
      }
    } catch (e) {
      debugPrint('Error fetching ads config for $screen: $e');
    }
    return (config: ScreenAdConfig.disabled, fetchedOk: false);
  }

  // ── Device Registration ────────────────────────────────────────────────────
  Future<void> registerDevice(String deviceId, {String? platform}) async {
    final uri = Uri.parse('$_baseUrl$_analyticsEndpoint/device/register');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'deviceId': deviceId, 'platform': platform}),
      );
      print('Device registration response: ${response.body}');
    } catch (e) {
      print('Error registering device: $e');
    }
  }

  // ── Activity Logging ───────────────────────────────────────────────────────
  Future<void> logActivity(
    String deviceId,
    String event, {
    Map<String, dynamic>? details,
  }) async {
    final uri = Uri.parse('$_baseUrl$_analyticsEndpoint/log');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceId': deviceId,
          'event': event,
          'details': details ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      print('Log response: ${response.body}');
    } catch (e) {
      print('Error logging activity: $e');
    }
  }
}
