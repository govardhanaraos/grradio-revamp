import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'wake_alarm_callback.dart';
import 'wake_alarm_prefs.dart';
import 'wake_alarm_repeat.dart';

class WakeAlarmSnapshot {
  WakeAlarmSnapshot({
    required this.whenLocal,
    required this.stationId,
    required this.stationName,
    required this.repeat,
    required this.weekdays,
  });

  final DateTime whenLocal;
  final String stationId;
  final String stationName;
  final WakeAlarmRepeat repeat;
  final Set<int> weekdays;
}

/// Wake-up: one-shot, daily, or weekly. Android uses AlarmManager; iOS uses
/// local notifications (tap to play).
class WakeAlarmService {
  WakeAlarmService._();

  static const int _iosSingleOrDailyId = 941002;
  static const int _iosWeeklyBaseId = 941020;

  static final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();

  static bool _tzReady = false;

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _notif.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != 'wake_radio') return;
    SharedPreferences.getInstance().then((prefs) async {
      if (prefs.getBool(WakeAlarmPrefs.enabled) ?? false) {
        await prefs.setBool(WakeAlarmPrefs.firePending, true);
      }
    });
  }

  static Future<void> _ensureTz() async {
    if (_tzReady) return;
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
      _tzReady = true;
    } catch (e) {
      debugPrint('WakeAlarmService timezone init: $e');
      try {
        tzdata.initializeTimeZones();
      } catch (_) {}
      _tzReady = true;
    }
  }

  static Future<void> _cancelAllIosWakeNotifications() async {
    await _notif.cancel(_iosSingleOrDailyId);
    for (var w = 1; w <= 7; w++) {
      await _notif.cancel(_iosWeeklyBaseId + w);
    }
  }

  static Future<void> consumePendingWakeAndPlay({
    required Future<void> Function(String stationId) play,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final launch = await _notif.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true &&
        launch!.notificationResponse?.payload == 'wake_radio' &&
        (prefs.getBool(WakeAlarmPrefs.enabled) ?? false)) {
      await prefs.setBool(WakeAlarmPrefs.firePending, true);
    }

    final pending = prefs.getBool(WakeAlarmPrefs.firePending) ?? false;
    if (!pending) return;

    await prefs.setBool(WakeAlarmPrefs.firePending, false);

    final sid = prefs.getString(WakeAlarmPrefs.stationId);
    if (sid == null || sid.isEmpty) return;

    await Future<void>.delayed(const Duration(milliseconds: 700));
    try {
      await play(sid);
    } catch (e) {
      debugPrint('consumePendingWakeAndPlay play failed: $e');
    } finally {
      final repeat = WakeAlarmRepeatHelper.fromPrefs(prefs);
      if (repeat == WakeAlarmRepeat.once) {
        await _clearAlarmStateKeepStation();
      }
    }
  }

  /// After a one-shot fires, or if it is stale — keep last station for re-saving.
  static Future<void> _clearAlarmStateKeepStation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(WakeAlarmPrefs.enabled, false);
    await prefs.remove(WakeAlarmPrefs.scheduledMillis);
    await prefs.remove(WakeAlarmPrefs.repeatMode);
    await prefs.remove(WakeAlarmPrefs.weekdays);
    await prefs.remove(WakeAlarmPrefs.hour);
    await prefs.remove(WakeAlarmPrefs.minute);
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(WakeAlarmPrefs.androidAlarmId);
    }
    await _cancelAllIosWakeNotifications();
  }

  static Future<void> _clearAllWakeScheduling() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(WakeAlarmPrefs.enabled, false);
    await prefs.remove(WakeAlarmPrefs.scheduledMillis);
    await prefs.remove(WakeAlarmPrefs.repeatMode);
    await prefs.remove(WakeAlarmPrefs.weekdays);
    await prefs.remove(WakeAlarmPrefs.hour);
    await prefs.remove(WakeAlarmPrefs.minute);
    await prefs.remove(WakeAlarmPrefs.stationId);
    await prefs.remove(WakeAlarmPrefs.stationName);
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(WakeAlarmPrefs.androidAlarmId);
    }
    await _cancelAllIosWakeNotifications();
  }

  static Future<void> repairAndroidAlarmIfNeeded() async {
    if (!Platform.isAndroid) return;
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(WakeAlarmPrefs.enabled) ?? false)) return;

    final exact = await Permission.scheduleExactAlarm.status;
    if (!exact.isGranted) return;

    final ms = prefs.getInt(WakeAlarmPrefs.scheduledMillis);
    if (ms == null) return;

    final when = DateTime.fromMillisecondsSinceEpoch(ms);
    final repeat = WakeAlarmRepeatHelper.fromPrefs(prefs);

    if (when.isAfter(DateTime.now())) {
      await AndroidAlarmManager.oneShotAt(
        when,
        WakeAlarmPrefs.androidAlarmId,
        wakeRadioAlarmCallback,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        alarmClock: true,
        rescheduleOnReboot: true,
      );
      return;
    }

    if (repeat != WakeAlarmRepeat.once) {
      await armNextAndroidAlarmFromPrefs();
    }
  }

  /// Last chosen station while no active schedule (e.g. after a one-shot fired).
  static Future<({String id, String name})?> loadLastStationIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(WakeAlarmPrefs.enabled) ?? false) return null;
    final id = prefs.getString(WakeAlarmPrefs.stationId);
    final name = prefs.getString(WakeAlarmPrefs.stationName);
    if (id == null || id.isEmpty) return null;
    return (id: id, name: name ?? '');
  }

  static Future<WakeAlarmSnapshot?> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(WakeAlarmPrefs.enabled) ?? false)) return null;
    final ms = prefs.getInt(WakeAlarmPrefs.scheduledMillis);
    if (ms == null) return null;

    var when = DateTime.fromMillisecondsSinceEpoch(ms);
    final repeat = WakeAlarmRepeatHelper.fromPrefs(prefs);
    final weekdays = repeat == WakeAlarmRepeat.weekly
        ? WakeAlarmRepeatHelper.weekdaysFromPrefs(prefs)
        : <int>{};

    if (!when.isAfter(DateTime.now())) {
      if (repeat == WakeAlarmRepeat.once) {
        await _clearAlarmStateKeepStation();
        return null;
      }
      final hour = prefs.getInt(WakeAlarmPrefs.hour) ?? 7;
      final minute = prefs.getInt(WakeAlarmPrefs.minute) ?? 0;
      when = WakeAlarmRepeatHelper.nextOccurrence(
        hour: hour,
        minute: minute,
        repeat: repeat,
        weekdays: weekdays,
        from: DateTime.now(),
      );
      await prefs.setInt(WakeAlarmPrefs.scheduledMillis, when.millisecondsSinceEpoch);
    }

    final sid = prefs.getString(WakeAlarmPrefs.stationId) ?? '';
    final name = prefs.getString(WakeAlarmPrefs.stationName) ?? '';
    if (sid.isEmpty) return null;
    return WakeAlarmSnapshot(
      whenLocal: when,
      stationId: sid,
      stationName: name,
      repeat: repeat,
      weekdays: weekdays,
    );
  }

  static Future<bool> saveSchedule({
    required bool enabled,
    required WakeAlarmRepeat repeat,
    required Set<int> weekdays,
    required DateTime whenLocal,
    required String stationId,
    required String stationName,
  }) async {
    if (!enabled) {
      await _clearAllWakeScheduling();
      return true;
    }

    final prefs = await SharedPreferences.getInstance();

    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(WakeAlarmPrefs.androidAlarmId);
    }
    await _cancelAllIosWakeNotifications();

    if (stationId.isEmpty) return false;

    final hour = whenLocal.hour;
    final minute = whenLocal.minute;
    final days = repeat == WakeAlarmRepeat.weekly
        ? weekdays.where((w) => w >= 1 && w <= 7).toSet()
        : <int>{};

    if (repeat == WakeAlarmRepeat.weekly && days.isEmpty) return false;

    final firstFire = WakeAlarmRepeatHelper.firstScheduleTime(
      hour: hour,
      minute: minute,
      repeat: repeat,
      weekdays: days,
      oneShotDateTime: whenLocal,
    );

    if (!firstFire.isAfter(DateTime.now().add(const Duration(seconds: 30)))) {
      return false;
    }

    await prefs.setInt(WakeAlarmPrefs.hour, hour);
    await prefs.setInt(WakeAlarmPrefs.minute, minute);
    await WakeAlarmRepeatHelper.writeRepeat(prefs, repeat);
    if (repeat == WakeAlarmRepeat.weekly) {
      await WakeAlarmRepeatHelper.writeWeekdays(prefs, days);
    } else {
      await prefs.remove(WakeAlarmPrefs.weekdays);
    }

    await prefs.setString(WakeAlarmPrefs.stationId, stationId);
    await prefs.setString(WakeAlarmPrefs.stationName, stationName);
    await prefs.setInt(
      WakeAlarmPrefs.scheduledMillis,
      firstFire.millisecondsSinceEpoch,
    );
    await prefs.setBool(WakeAlarmPrefs.enabled, true);

    if (Platform.isAndroid) {
      var exact = await Permission.scheduleExactAlarm.status;
      if (!exact.isGranted) {
        exact = await Permission.scheduleExactAlarm.request();
      }
      if (!exact.isGranted) {
        await _rollbackNewSchedule(prefs);
        return false;
      }

      final ok = await AndroidAlarmManager.oneShotAt(
        firstFire,
        WakeAlarmPrefs.androidAlarmId,
        wakeRadioAlarmCallback,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        alarmClock: true,
        rescheduleOnReboot: true,
      );
      if (!ok) {
        await _rollbackNewSchedule(prefs);
        return false;
      }
      return true;
    }

    if (Platform.isIOS) {
      await _ensureTz();
      final ios = _notif.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final allowed =
          await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
      if (!allowed) {
        await _rollbackNewSchedule(prefs);
        return false;
      }

      switch (repeat) {
        case WakeAlarmRepeat.once:
          final scheduled = tz.TZDateTime(
            tz.local,
            whenLocal.year,
            whenLocal.month,
            whenLocal.day,
            hour,
            minute,
          );
          await _notif.zonedSchedule(
            _iosSingleOrDailyId,
            'Wake-up radio',
            'Tap to play $stationName',
            scheduled,
            const NotificationDetails(
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: 'wake_radio',
          );
        case WakeAlarmRepeat.daily:
          final scheduled = tz.TZDateTime(
            tz.local,
            firstFire.year,
            firstFire.month,
            firstFire.day,
            hour,
            minute,
          );
          await _notif.zonedSchedule(
            _iosSingleOrDailyId,
            'Wake-up radio',
            'Tap to play $stationName',
            scheduled,
            const NotificationDetails(
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: 'wake_radio',
            matchDateTimeComponents: DateTimeComponents.time,
          );
        case WakeAlarmRepeat.weekly:
          for (final w in (days.toList()..sort())) {
            final next = _nextTzOnWeekday(
              hour: hour,
              minute: minute,
              weekday: w,
              from: DateTime.now(),
            );
            await _notif.zonedSchedule(
              _iosWeeklyBaseId + w,
              'Wake-up radio',
              'Tap to play $stationName',
              next,
              const NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
              ),
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.wallClockTime,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              payload: 'wake_radio',
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            );
          }
      }
      return true;
    }

    await _rollbackNewSchedule(prefs);
    return false;
  }

  static tz.TZDateTime _nextTzOnWeekday({
    required int hour,
    required int minute,
    required int weekday,
    required DateTime from,
  }) {
    const minLead = Duration(seconds: 35);
    final threshold = from.add(minLead);
    for (var i = 0; i <= 7; i++) {
      final d = DateTime(from.year, from.month, from.day, hour, minute)
          .add(Duration(days: i));
      if (!d.isAfter(threshold)) continue;
      if (d.weekday == weekday) {
        return tz.TZDateTime(
          tz.local,
          d.year,
          d.month,
          d.day,
          hour,
          minute,
        );
      }
    }
    final d = DateTime(from.year, from.month, from.day, hour, minute)
        .add(const Duration(days: 7));
    return tz.TZDateTime(tz.local, d.year, d.month, d.day, hour, minute);
  }

  static Future<void> _rollbackNewSchedule(SharedPreferences prefs) async {
    await prefs.setBool(WakeAlarmPrefs.enabled, false);
    await prefs.remove(WakeAlarmPrefs.scheduledMillis);
    await prefs.remove(WakeAlarmPrefs.repeatMode);
    await prefs.remove(WakeAlarmPrefs.weekdays);
    await prefs.remove(WakeAlarmPrefs.hour);
    await prefs.remove(WakeAlarmPrefs.minute);
    await prefs.remove(WakeAlarmPrefs.stationId);
    await prefs.remove(WakeAlarmPrefs.stationName);
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(WakeAlarmPrefs.androidAlarmId);
    }
    await _cancelAllIosWakeNotifications();
  }
}
