/// SharedPreferences keys and IDs for wake-up radio scheduling.
class WakeAlarmPrefs {
  WakeAlarmPrefs._();

  static const enabled = 'wake_alarm_enabled';
  static const firePending = 'wake_alarm_fire_pending';
  static const stationId = 'wake_alarm_station_id';
  static const stationName = 'wake_alarm_station_name';
  static const scheduledMillis = 'wake_alarm_scheduled_millis';

  static const repeatMode = 'wake_alarm_repeat_mode';
  static const valueOnce = 'once';
  static const valueDaily = 'daily';
  static const valueWeekly = 'weekly';

  static const weekdays = 'wake_alarm_weekdays';
  static const hour = 'wake_alarm_hour';
  static const minute = 'wake_alarm_minute';

  /// Passed to [AndroidAlarmManager.oneShotAt].
  static const int androidAlarmId = 941001;
}
