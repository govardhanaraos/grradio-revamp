import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

// 2. Persistent Device ID Service
class DeviceService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'persistent_device_id';

  static Future<String> getPersistentId() async {
    String? id = await _storage.read(key: _key);
    if (id == null) {
      id = const Uuid().v4(); // Generate a truly unique, persistent ID
      await _storage.write(key: _key, value: id);
    }
    return id;
  }
}

// 3. Global Premium State
final ValueNotifier<bool> isUserPremium = ValueNotifier(false);
