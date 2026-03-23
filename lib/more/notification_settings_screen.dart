import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:grradio/main.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isSaving = false;

  SharedPreferences? _prefs;
  Future<SharedPreferences> get _sharedPrefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  Future<void> _loadNotificationStatus() async {
    final prefs = await _sharedPrefs;
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (_isSaving) return; // debounce rapid taps
    setState(() => _isSaving = true);

    try {
      final prefs = await _sharedPrefs;
      await prefs.setBool('notifications_enabled', value);

      if (value) {
        await FirebaseMessaging.instance.subscribeToTopic('radio_alerts');
        AnalyticsServiceAPI().logActivity(deviceId!, "Subscribe to Notifications", details: {"topic": "radio_alerts"});
        debugPrint('Subscribed to notifications');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('radio_alerts');
        AnalyticsServiceAPI().logActivity(deviceId!, "Unsubscribe from Notifications", details: {"topic": "radio_alerts"});
        debugPrint('Unsubscribed from notifications');
      }

      if (mounted) setState(() => _notificationsEnabled = value);
    } catch (e) {
      debugPrint('Error toggling notifications: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(
                  'Push Notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Receive alerts about new stations and shows',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                secondary: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF7C4DFF),
                        ),
                      )
                    : Icon(
                        _notificationsEnabled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        color: _notificationsEnabled
                            ? const Color(0xFF7C4DFF)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                value: _notificationsEnabled,
                activeThumbColor: const Color(0xFF7C4DFF),
                onChanged: _isSaving ? null : _toggleNotifications,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Turning off notifications will stop all alerts from being sent to this device.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
