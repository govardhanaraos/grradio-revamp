import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 NEW

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefKey = "notifications_enabled";

  // 💡 NEW: Check if notifications are currently enabled in settings
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? true; // Default to enabled
  }

  Future<void> initNotifications() async {
    // Request permission for iOS and Android 13+
    await _fcm.requestPermission();

    // 💡 IMPROVED: Subscribe ONLY if enabled
    bool enabled = await isEnabled();
    if (enabled) {
      await _fcm.subscribeToTopic("all_users");
      print("🔔 Notifications are enabled: Subscribed to all_users");
    } else {
      await _fcm.unsubscribeFromTopic("all_users");
      print("🔕 Notifications are disabled: Unsubscribed from all_users");
    }

    // Listen for messages while app is open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // 💡 NEW: Final check to ensure we don't show foreground alerts if disabled
      if (await isEnabled() && message.notification != null) {
        showNotification(message);
      }
    });
  }

  // 💡 NEW: Logic to call when user clicks the Radio/Switch
  Future<void> toggleNotifications(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enable);

    if (enable) {
      await _fcm.subscribeToTopic("all_users");
    } else {
      await _fcm.unsubscribeFromTopic("all_users");
    }
    print("Notification setting changed to: $enable");
  }

  // 💡 NEW: Send a test notification to verify it's working
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification from your app settings!',
      platformDetails,
    );
  }

  Future<void> setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }
}
