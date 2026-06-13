import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grradio/l10n/app_localizations.dart';
import 'package:grradio/main.dart';
import 'package:grradio/more/wake_alarm_repeat.dart';
import 'package:grradio/more/wake_alarm_service.dart';
import 'package:grradio/radio/radiostation.dart';
import 'package:intl/intl.dart';

class WakeMeUpScreen extends StatefulWidget {
  const WakeMeUpScreen({super.key});

  @override
  State<WakeMeUpScreen> createState() => _WakeMeUpScreenState();
}

class _WakeMeUpScreenState extends State<WakeMeUpScreen> {
  DateTime? _whenLocal;
  WakeAlarmRepeat _repeat = WakeAlarmRepeat.once;
  Set<int> _weekdays = {DateTime.monday};
  RadioStation? _station;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  String _weekdayLetter(BuildContext context, int weekday) {
    final locale = Localizations.localeOf(context).toString();
    final anchor = DateTime(2024, 1, 1);
    final d = anchor.add(Duration(days: weekday - 1));
    return DateFormat.E(locale).format(d);
  }

  Future<void> _hydrate() async {
    final snap = await WakeAlarmService.loadSnapshot();
    final last = await WakeAlarmService.loadLastStationIfAny();
    if (!mounted) return;

    setState(() {
      final now = DateTime.now();
      if (snap != null) {
        _whenLocal = snap.whenLocal;
        _repeat = snap.repeat;
        // FIX #6: Always restore weekdays from the snapshot regardless of
        // repeat mode so user selections survive a screen re-open. Previously
        // weekdays were reset to {now.weekday} for non-weekly repeat modes,
        // which discarded persisted values on every hydrate cycle.
        _weekdays = snap.weekdays.isNotEmpty
            ? Set<int>.from(snap.weekdays)
            : {now.weekday};
        RadioStation? found;
        for (final s in allRadioStations) {
          if (s.id == snap.stationId) {
            found = s;
            break;
          }
        }
        _station = found ??
            RadioStation(
              id: snap.stationId,
              name: snap.stationName,
              streamUrl: null,
              logoUrl: null,
            );
      } else {
        _whenLocal = DateTime(now.year, now.month, now.day, 7, 0);
        _repeat = WakeAlarmRepeat.once;
        _weekdays = {now.weekday};
        _station = null;
        if (last != null) {
          RadioStation? found;
          for (final s in allRadioStations) {
            if (s.id == last.id) {
              found = s;
              break;
            }
          }
          _station = found ??
              RadioStation(
                id: last.id,
                name: last.name,
                streamUrl: null,
                logoUrl: null,
              );
        }
      }
    });
  }

  Future<void> _pickDate() async {
    if (_repeat != WakeAlarmRepeat.once) return;
    final l = AppLocalizations.of(context)!;
    final base = _whenLocal ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      helpText: l.wakeAlarmDate,
    );
    if (d == null || !mounted) return;
    setState(() {
      _whenLocal = DateTime(d.year, d.month, d.day, base.hour, base.minute);
    });
  }

  Future<void> _pickTime() async {
    final base = _whenLocal ?? DateTime.now();
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: base.hour, minute: base.minute),
      helpText: AppLocalizations.of(context)!.wakeAlarmTime,
    );
    if (t == null || !mounted) return;
    setState(() {
      _whenLocal = DateTime(
        base.year,
        base.month,
        base.day,
        t.hour,
        t.minute,
      );
    });
  }

  void _toggleWeekday(int w) {
    setState(() {
      if (_weekdays.contains(w)) {
        if (_weekdays.length > 1) _weekdays.remove(w);
      } else {
        _weekdays = {..._weekdays, w};
      }
    });
  }

  Future<void> _pickStation() async {
    final picked = await showModalBottomSheet<RadioStation>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.92,
          builder: (_, scrollCtrl) {
            return ValueListenableBuilder<List<RadioStation>>(
              valueListenable: stationsNotifier,
              builder: (context, list, _) {
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        AppLocalizations.of(context)!.wakeAlarmNoStations,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: scrollCtrl,
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final s = list[i];
                    return ListTile(
                      title: Text(s.name),
                      subtitle: Text(
                        s.language ?? s.state ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.pop(ctx, s),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
    if (picked != null) setState(() => _station = picked);
  }

  bool _validateBeforeSave(AppLocalizations l) {
    if (_station == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.wakeAlarmPickStation),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    final when = _whenLocal;
    if (when == null) return false;

    if (_repeat == WakeAlarmRepeat.once) {
      if (when.isBefore(DateTime.now().add(const Duration(seconds: 30)))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.wakeAlarmPickFuture),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
    } else {
      final days = _repeat == WakeAlarmRepeat.weekly
          ? _weekdays
          : <int>{};
      final first = WakeAlarmRepeatHelper.firstScheduleTime(
        hour: when.hour,
        minute: when.minute,
        repeat: _repeat,
        weekdays: days,
        oneShotDateTime: when,
      );
      if (!first.isAfter(DateTime.now().add(const Duration(seconds: 30)))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.wakeAlarmPickFutureRepeat),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _save({required bool enabled}) async {
    final l = AppLocalizations.of(context)!;
    if (enabled && !_validateBeforeSave(l)) return;

    setState(() => _saving = true);
    final ok = await WakeAlarmService.saveSchedule(
      enabled: enabled,
      repeat: _repeat,
      weekdays: _weekdays,
      whenLocal: _whenLocal ?? DateTime.now(),
      stationId: _station?.id ?? '',
      stationName: _station?.name ?? '',
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled ? l.wakeAlarmScheduled : l.wakeAlarmDisabled,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (!enabled) {
        setState(() {
          _station = null;
          _repeat = WakeAlarmRepeat.once;
          _weekdays = {DateTime.now().weekday};
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.wakeAlarmScheduleFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final when = _whenLocal;
    final locale = Localizations.localeOf(context).toString();
    final df = DateFormat.yMMMd(locale);
    final tf = DateFormat.jm(locale);

    return Scaffold(
      appBar: AppBar(title: Text(l.wakeAlarmTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: cs.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.wakeAlarmHowItWorksTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    Platform.isAndroid
                        ? l.wakeAlarmAndroidExplain
                        : l.wakeAlarmIosExplain,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.wakeRepeatLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<WakeAlarmRepeat>(
            segments: [
              ButtonSegment(
                value: WakeAlarmRepeat.once,
                label: Text(l.wakeRepeatOnce),
                icon: const Icon(Icons.looks_one_rounded, size: 18),
              ),
              ButtonSegment(
                value: WakeAlarmRepeat.daily,
                label: Text(l.wakeRepeatDaily),
                icon: const Icon(Icons.today_rounded, size: 18),
              ),
              ButtonSegment(
                value: WakeAlarmRepeat.weekly,
                label: Text(l.wakeRepeatWeekly),
                icon: const Icon(Icons.date_range_rounded, size: 18),
              ),
            ],
            selected: {_repeat},
            onSelectionChanged: (next) {
              setState(() {
                _repeat = next.first;
                if (_repeat == WakeAlarmRepeat.weekly &&
                    _weekdays.isEmpty) {
                  _weekdays = {DateTime.now().weekday};
                }
              });
            },
          ),
          if (_repeat == WakeAlarmRepeat.once) ...[
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.calendar_today_rounded),
              title: Text(l.wakeAlarmDate),
              subtitle: Text(when != null ? df.format(when) : '—'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _pickDate,
            ),
          ],
          ListTile(
            leading: const Icon(Icons.schedule_rounded),
            title: Text(
              _repeat == WakeAlarmRepeat.once
                  ? l.wakeAlarmTime
                  : l.wakeAlarmTimeRepeat,
            ),
            subtitle: Text(when != null ? tf.format(when) : '—'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _pickTime,
          ),
          if (_repeat == WakeAlarmRepeat.weekly) ...[
            const SizedBox(height: 8),
            Text(
              l.wakeWeekdaysLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var w = 1; w <= 7; w++)
                  FilterChip(
                    label: Text(_weekdayLetter(context, w)),
                    selected: _weekdays.contains(w),
                    onSelected: (_) => _toggleWeekday(w),
                  ),
              ],
            ),
          ],
          ListTile(
            leading: const Icon(Icons.radio_rounded),
            title: Text(l.wakeAlarmStation),
            subtitle: Text(
              _station?.name ?? l.wakeAlarmSelectStation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _pickStation,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : () => _save(enabled: true),
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.alarm_add_rounded),
            label: Text(l.wakeAlarmSave),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _saving ? null : () => _save(enabled: false),
            child: Text(l.wakeAlarmClear),
          ),
        ],
      ),
    );
  }
}
