import 'package:shared_preferences/shared_preferences.dart';

import 'wake_alarm_prefs.dart';

enum WakeAlarmRepeat { once, daily, weekly }

class WakeAlarmRepeatHelper {
  WakeAlarmRepeatHelper._();

  static WakeAlarmRepeat fromPrefs(SharedPreferences prefs) {
    final s = prefs.getString(WakeAlarmPrefs.repeatMode);
    switch (s) {
      case WakeAlarmPrefs.valueDaily:
        return WakeAlarmRepeat.daily;
      case WakeAlarmPrefs.valueWeekly:
        return WakeAlarmRepeat.weekly;
      default:
        return WakeAlarmRepeat.once;
    }
  }

  static Future<void> writeRepeat(
    SharedPreferences prefs,
    WakeAlarmRepeat mode,
  ) async {
    switch (mode) {
      case WakeAlarmRepeat.once:
        await prefs.setString(WakeAlarmPrefs.repeatMode, WakeAlarmPrefs.valueOnce);
      case WakeAlarmRepeat.daily:
        await prefs.setString(
          WakeAlarmPrefs.repeatMode,
          WakeAlarmPrefs.valueDaily,
        );
      case WakeAlarmRepeat.weekly:
        await prefs.setString(
          WakeAlarmPrefs.repeatMode,
          WakeAlarmPrefs.valueWeekly,
        );
    }
  }

  /// ISO weekdays 1=Monday … 7=Sunday ([DateTime.weekday]).
  static Set<int> weekdaysFromPrefs(SharedPreferences prefs) {
    final raw = prefs.getString(WakeAlarmPrefs.weekdays);
    if (raw == null || raw.isEmpty) return {DateTime.monday};
    final out = <int>{};
    for (final part in raw.split(',')) {
      final v = int.tryParse(part.trim());
      if (v != null && v >= 1 && v <= 7) out.add(v);
    }
    return out.isEmpty ? {DateTime.monday} : out;
  }

  static Future<void> writeWeekdays(
    SharedPreferences prefs,
    Set<int> weekdays,
  ) async {
    final sorted = weekdays.where((w) => w >= 1 && w <= 7).toList()..sort();
    await prefs.setString(WakeAlarmPrefs.weekdays, sorted.join(','));
  }

  /// Next fire time strictly after [from] (with a short lead so we do not
  /// reschedule the same minute the alarm just rang).
  static DateTime nextOccurrence({
    required int hour,
    required int minute,
    required WakeAlarmRepeat repeat,
    required Set<int> weekdays,
    required DateTime from,
  }) {
    const minLead = Duration(seconds: 35);
    final threshold = from.add(minLead);

    switch (repeat) {
      case WakeAlarmRepeat.once:
        throw StateError('nextOccurrence is not used for one-shot');
      case WakeAlarmRepeat.daily:
        var d = DateTime(from.year, from.month, from.day, hour, minute);
        if (!d.isAfter(threshold)) {
          d = d.add(const Duration(days: 1));
        }
        return d;
      case WakeAlarmRepeat.weekly:
        final days = weekdays.isNotEmpty ? weekdays : {from.weekday};
        for (var i = 0; i <= 7; i++) {
          final d = DateTime(from.year, from.month, from.day, hour, minute)
              .add(Duration(days: i));
          if (!d.isAfter(threshold)) continue;
          if (days.contains(d.weekday)) return d;
        }
        return DateTime(from.year, from.month, from.day, hour, minute)
            .add(const Duration(days: 7));
    }
  }

  /// First schedule time when the user taps Save (from “now”).
  static DateTime firstScheduleTime({
    required int hour,
    required int minute,
    required WakeAlarmRepeat repeat,
    required Set<int> weekdays,
    required DateTime oneShotDateTime,
  }) {
    final now = DateTime.now();
    switch (repeat) {
      case WakeAlarmRepeat.once:
        return oneShotDateTime;
      case WakeAlarmRepeat.daily:
      case WakeAlarmRepeat.weekly:
        return nextOccurrence(
          hour: hour,
          minute: minute,
          repeat: repeat,
          weekdays: weekdays,
          from: now,
        );
    }
  }
}
