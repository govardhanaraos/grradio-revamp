import 'dart:convert';

import 'package:grradio/Env.dart';
import 'package:grradio/more/premium/securityservice.dart';
import 'package:http/http.dart' as http;

class LicenseService {
  static final String baseUrl = "${Env.apiBaseUrl}/premium";

  /// Verifies a new key and links the device
  static Future<Map<String, dynamic>> verifyLicense(
    String plainKey,
    String deviceId,
  ) async {
    final String encryptedKey = SecurityService.encryptLicenseKey(plainKey);
    final String transportPayload = SecurityService.encryptPayload({
      "license_key": encryptedKey,
      "device_id": deviceId,
    });

    final response = await http.post(
      Uri.parse("$baseUrl/verify-license"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"payload": transportPayload}),
    );
    return _handleResponse(response);
  }

  /// New: Checks if this device ID is already premium in the DB
  /// You should implement a simple GET/POST on backend for this or
  /// rely on the verify call with the stored key.
  static Future<List<dynamic>> listDevices(String plainKey) async {
    final String encryptedKey = SecurityService.encryptLicenseKey(plainKey);
    final String transportPayload = SecurityService.encryptPayload({
      "license_key": encryptedKey,
    });

    final response = await http.post(
      Uri.parse("$baseUrl/list-devices"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"payload": transportPayload}),
    );
    final result = await _handleResponse(response);
    return result['active_devices'] ?? [];
  }

  static Future<void> removeDevice(String plainKey, String deviceId) async {
    final String encryptedKey = SecurityService.encryptLicenseKey(plainKey);
    final String transportPayload = SecurityService.encryptPayload({
      "license_key": encryptedKey,
      "device_id": deviceId,
    });

    await http.post(
      Uri.parse("$baseUrl/remove-device"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"payload": transportPayload}),
    );
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body)['detail'] ?? "Unknown Error";
      throw Exception(error);
    }
  }
}
