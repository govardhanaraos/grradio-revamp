import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;

class SecurityService {
  static final _key = enc.Key.fromUtf8("YourSuperSecretKey12345678901234");
  static final _iv = enc.IV.fromUtf8("FixedIV123456789");

  static String encryptLicenseKey(String plainKey) {
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    return encrypter.encrypt(plainKey, iv: _iv).base64;
  }

  static String encryptPayload(Map<String, dynamic> data) {
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    return encrypter.encrypt(jsonEncode(data), iv: _iv).base64;
  }
}
