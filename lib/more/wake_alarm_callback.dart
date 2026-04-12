import 'dart:io';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'wake_alarm_prefs.dart';
import 'wake_alarm_repeat.dart';

/// Runs in the alarm manager background isolate (not the main app isolate).
@pragma('vm:entry-point')
void wakeRadioAlarmCallback(int alarmId) {
  Future(() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(WakeAlarmPrefs.firePending, true);

      const intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: 'com.radio.grradio',
        componentName: 'com.radio.grradio/com.radio.grradio.MainActivity',
        flags: <int>[
          Flag.FLAG_ACTIVITY_NEW_TASK,
          Flag.FLAG_ACTIVITY_CLEAR_TOP,
        ],
      );
      await intent.launch();

      await armNextAndroidAlarmFromPrefs();
    } catch (e, st) {
      debugPrint('wakeRadioAlarmCallback: $e\n$st');
    }
  });
}

/// Schedules the following occurrence for daily/weekly (not one-shot).
Future<void> armNextAndroidAlarmFromPrefs() async {
  if (!Platform.isAndroid) return;
  final prefs = await SharedPreferences.getInstance();
  if (!(prefs.getBool(WakeAlarmPrefs.enabled) ?? false)) return;

  final repeat = WakeAlarmRepeatHelper.fromPrefs(prefs);
  if (repeat == WakeAlarmRepeat.once) return;

  final hour = prefs.getInt(WakeAlarmPrefs.hour) ?? 7;
  final minute = prefs.getInt(WakeAlarmPrefs.minute) ?? 0;
  final weekdays = WakeAlarmRepeatHelper.weekdaysFromPrefs(prefs);

  final next = WakeAlarmRepeatHelper.nextOccurrence(
    hour: hour,
    minute: minute,
    repeat: repeat,
    weekdays: weekdays,
    from: DateTime.now(),
  );

  await prefs.setInt(WakeAlarmPrefs.scheduledMillis, next.millisecondsSinceEpoch);

  try {
    await AndroidAlarmManager.oneShotAt(
      next,
      WakeAlarmPrefs.androidAlarmId,
      wakeRadioAlarmCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      alarmClock: true,
      rescheduleOnReboot: true,
    );
  } catch (e, st) {
    debugPrint('armNextAndroidAlarmFromPrefs: $e\n$st');
  }
}
