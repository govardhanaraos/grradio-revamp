import 'dart:convert';

import 'package:http/http.dart' as http;

const String _baseUrl = 'https://radio-backend-nysq.onrender.com';
const String _analyticsEndpoint = '/analytics';

class AnalyticsServiceAPI {
  // --- Global Ads Config ---
  Future<bool> fetchGlobalAdsEnabled() async {
    final uri = Uri.parse('$_baseUrl$_analyticsEndpoint/ads/global');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ads_enabled'] ?? false;
      }
    } catch (e) {
      print('Error fetching global ads config: $e');
    }
    return false; // default fallback
  }

  // --- Screen Ads Config ---
  Future<bool> fetchScreenAdsEnabled(String screen) async {
    final uri = Uri.parse('$_baseUrl$_analyticsEndpoint/ads/$screen');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ads_enabled'] ?? false;
      }
    } catch (e) {
      print('Error fetching ads config for $screen: $e');
    }
    return false;
  }

  // --- Device Registration ---
  Future<void> registerDevice(String deviceId, {String? platform}) async {
    final uri = Uri.parse('$_baseUrl$_analyticsEndpoint/device/register');
    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"deviceId": deviceId, "platform": platform}),
      );
      print('Device registration response: ${response.body}');
    } catch (e) {
      print('Error registering device: $e');
    }
  }

  // --- Logging ---
  Future<void> logActivity(
    String deviceId,
    String event, {
    Map<String, dynamic>? details,
  }) async {
    final uri = Uri.parse('$_baseUrl$_analyticsEndpoint/log');
    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "deviceId": deviceId,
          "event": event,
          "details": details ?? {},
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );
      print('Log response: ${response.body}');
    } catch (e) {
      print('Error logging activity: $e');
    }
  }
}
