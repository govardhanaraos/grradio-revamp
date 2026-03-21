import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true; // Default value

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  // Load the saved status from local storage
  Future<void> _loadNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  // Save status and update FCM subscription
  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    if (value) {
      // Subscribe to your general topic (e.g., 'all_users' or 'radio_alerts')
      await FirebaseMessaging.instance.subscribeToTopic('radio_alerts');
      debugPrint("Subscribed to notifications");
    } else {
      // Unsubscribe from the topic
      await FirebaseMessaging.instance.unsubscribeFromTopic('radio_alerts');
      debugPrint("Unsubscribed from notifications");
    }

    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Push Notifications',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Receive alerts about new stations and shows',
                ),
                secondary: Icon(
                  _notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: _notificationsEnabled ? Colors.blue : Colors.grey,
                ),
                value: _notificationsEnabled,
                activeColor: Colors.blue,
                onChanged: (bool value) {
                  _toggleNotifications(value);
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Turning off notifications will stop all alerts from being sent to this device.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
