import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grradio/ads/ad_config_provider.dart';
import 'package:grradio/ads/ad_widgets.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:grradio/main.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Models
// ─────────────────────────────────────────────────────────────────────────────

class RecordingFile {
  final String id;
  final String title;
  final String path;
  final int fileSizeInBytes;
  final DateTime dateCreated;
  final Duration duration;

  RecordingFile({
    required this.id,
    required this.title,
    required this.path,
    required this.fileSizeInBytes,
    required this.dateCreated,
    required this.duration,
  });
}

class DownloadedMp3File {
  final int id;
  final String title;
  final String path;
  final int fileSizeInBytes;
  final DateTime dateCreated;
  final Duration duration;
  final String? artist;

  DownloadedMp3File({
    required this.id,
    required this.title,
    required this.path,
    required this.fileSizeInBytes,
    required this.dateCreated,
    required this.duration,
    this.artist,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Sort options
// ─────────────────────────────────────────────────────────────────────────────

enum SortOption {
  nameAsc,
  nameDesc,
  dateNewest,
  dateOldest,
  durationLong,
  sizeLarge,
}

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.nameAsc:
        return 'Name (A to Z)';
      case SortOption.nameDesc:
        return 'Name (Z to A)';
      case SortOption.dateNewest:
        return 'Date (newest first)';
      case SortOption.dateOldest:
        return 'Date (oldest first)';
      case SortOption.durationLong:
        return 'Duration (longest)';
      case SortOption.sizeLarge:
        return 'Size (largest)';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.nameAsc:
      case SortOption.nameDesc:
        return Icons.sort_by_alpha_rounded;
      case SortOption.dateNewest:
      case SortOption.dateOldest:
        return Icons.calendar_today_rounded;
      case SortOption.durationLong:
        return Icons.timer_outlined;
      case SortOption.sizeLarge:
        return Icons.storage_outlined;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Date group header sentinel
// ─────────────────────────────────────────────────────────────────────────────

class _DateHeader {
  final String label;
  const _DateHeader(this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Mp3PlayerScreen
// ─────────────────────────────────────────────────────────────────────────────

class Mp3PlayerScreen extends StatefulWidget {
  final int initialTabIndex;
  const Mp3PlayerScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  _Mp3PlayerScreenState createState() => _Mp3PlayerScreenState();
}

class _Mp3PlayerScreenState extends State<Mp3PlayerScreen>
    with TickerProviderStateMixin {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AnalyticsServiceAPI _analyticsService = AnalyticsServiceAPI();

  late TabController _tabController;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;

  List<SongModel>? _songs;
  List<DownloadedMp3File>? _downloadedMp3s;
  List<RecordingFile>? _recordings;

  // ── Scroll controllers (one per tab) ─────────────────────────────────────
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];
  bool _showScrollTop = false;

  // ── Per-tab search ────────────────────────────────────────────────────────
  final List<TextEditingController> _searchControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<String> _searchQueries = ['', '', ''];
  bool _searchVisible = false;

  // ── Sort (persisted per tab) ──────────────────────────────────────────────
  static const _sortPrefKeys = [
    'sort_music',
    'sort_downloads',
    'sort_recordings',
  ];
  final List<SortOption> _sortOptions = [
    SortOption.nameAsc,
    SortOption.dateNewest,
    SortOption.dateNewest,
  ];

  // ── Multi-select ──────────────────────────────────────────────────────────
  final Set<String> _selectedIds = {};
  bool _isSelecting = false;
  bool _isRefreshing = false;

  // ── Ad state — snapshotted once in didChangeDependencies ──────────────────
  // Same pattern as RadioPlayerScreen: cache flags so build() never calls
  // context.watch<AdConfigProvider>() which causes spurious rebuilds.
  bool _showBanner = false;
  bool _showInterstitial = false;
  int _interstitialEvery = 5;
  int _tapCount = 0;
  InListPlacement _mp3ListPlacement = const InListPlacement();
  InListPlacement _downloadsListPlacement = const InListPlacement();
  InListPlacement _recordingsListPlacement = const InListPlacement();
  bool _adConfigLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (mounted)
        setState(() {
          _searchVisible = false;
          _isSelecting = false;
          _selectedIds.clear();
        });
    });
    for (final sc in _scrollControllers) sc.addListener(_onScrollChanged);
    for (int i = 0; i < 3; i++) {
      final idx = i;
      _searchControllers[idx].addListener(() {
        if (mounted)
          setState(() => _searchQueries[idx] = _searchControllers[idx].text);
      });
    }
    _init();

    // Snapshot ad config as soon as AdConfigProvider is ready.
    // We use a postFrameCallback so context is available, then either read
    // immediately (if already initialised) or attach a one-shot listener that
    // fires when initialize() completes and calls notifyListeners().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final adConfig = context.read<AdConfigProvider>();
      if (adConfig.initialized) {
        _snapshotAdConfig(adConfig);
      } else {
        late void Function() listener;
        listener = () {
          if (!mounted) return;
          _snapshotAdConfig(adConfig);
          adConfig.removeListener(listener);
        };
        adConfig.addListener(listener);
      }
    });
  }

  /// Reads all ad flags and placements from [adConfig] into local state and
  /// calls setState so the lists rebuild with ads inserted.
  void _snapshotAdConfig(AdConfigProvider adConfig) {
    if (!mounted) return;
    setState(() {
      _adConfigLoaded = true;
      _showBanner = adConfig.isBannerEnabled(AdScreen.player);
      _showInterstitial = adConfig.isInterstitialEnabled(AdScreen.player);
      _interstitialEvery = adConfig.interstitialEveryNTaps(AdScreen.player);
      _mp3ListPlacement = adConfig.mp3ListPlacement(AdScreen.player);
      _downloadsListPlacement = adConfig.downloadsListPlacement(
        AdScreen.player,
      );
      _recordingsListPlacement = adConfig.recordingsListPlacement(
        AdScreen.player,
      );
    });
    if (_showInterstitial) InterstitialAdManager.preload();
  }

  Future<void> _init() async {
    await _loadSortPrefs();
    await _checkAndRequestPermissions();
  }

  Future<void> _loadSortPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 3; i++) {
      final idx = prefs.getInt(_sortPrefKeys[i]);
      if (idx != null && idx < SortOption.values.length) {
        _sortOptions[i] = SortOption.values[idx];
      }
    }
  }

  Future<void> _saveSortPref(int tab) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sortPrefKeys[tab], _sortOptions[tab].index);
  }

  void _onScrollChanged() {
    final show = _scrollControllers.any(
      (sc) => sc.hasClients && sc.offset > 300,
    );
    if (show != _showScrollTop) setState(() => _showScrollTop = show);
  }

  void _scrollToTop() {
    HapticFeedback.lightImpact();
    final sc = _scrollControllers[_tabController.index];
    if (sc.hasClients)
      sc.animateTo(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return '0 B';
    const s = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${s[i]}';
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    if (d.inHours > 0)
      return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
    return '${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  void didUpdateWidget(covariant Mp3PlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != oldWidget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final sc in _scrollControllers) {
      sc.removeListener(_onScrollChanged);
      sc.dispose();
    }
    for (final tc in _searchControllers) tc.dispose();
    super.dispose();
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  Future<void> _checkAndRequestPermissions() async {
    setState(() => _isCheckingPermission = true);
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('audio_permission_granted') ?? false) {
      setState(() {
        _hasPermission = true;
        _isCheckingPermission = false;
      });
      _loadSongs();
      return;
    }
    bool granted = false;
    if (await Permission.audio.isGranted) {
      granted = true;
    } else {
      final s = await Permission.audio.request();
      if (s.isGranted) {
        granted = true;
      } else {
        if ((await Permission.storage.request()).isGranted) granted = true;
      }
    }
    if (granted) await prefs.setBool('audio_permission_granted', true);
    setState(() {
      _hasPermission = granted;
      _isCheckingPermission = false;
    });
    if (granted) _loadSongs();
  }

  // ── Data loading (parallel) ───────────────────────────────────────────────

  Future<void> _loadSongs() async {
    await Future.wait([
      _loadAllSongs(),
      _loadLocalRecordings(),
      _loadDownloadedMp3s(),
    ]);
  }

  Future<void> _loadAllSongs() async {
    try {
      final songs = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      if (mounted) setState(() => _songs = songs);
    } catch (e) {
      _analyticsService.logActivity(deviceId!, 'Error loading songs: $e');
      if (mounted) setState(() => _songs = []);
    }
  }

  Future<void> _loadDownloadedMp3s() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${appDir.path}/Music');
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
        if (mounted) setState(() => _downloadedMp3s = []);
        return;
      }
      final List<DownloadedMp3File> temp = [];
      for (var f in musicDir.listSync()) {
        if (f is File && (f.path.endsWith('.mp3') || f.path.endsWith('.m4a'))) {
          final stat = f.statSync();
          temp.add(
            DownloadedMp3File(
              id: f.hashCode,
              title: f.path.split('/').last,
              path: f.path,
              fileSizeInBytes: stat.size,
              dateCreated: stat.changed,
              duration: Duration.zero,
            ),
          );
        }
      }
      if (mounted) setState(() => _downloadedMp3s = temp);
    } catch (e) {
      print('Error loading downloads: $e');
    }
  }

  Future<void> _loadLocalRecordings() async {
    final dirs = <Directory>[];
    final ext = await getExternalStorageDirectories(
      type: StorageDirectory.downloads,
    );
    if (ext != null) dirs.addAll(ext);
    final docs = await getApplicationDocumentsDirectory();
    if (!dirs.any((d) => d.path == docs.path)) dirs.add(docs);
    if (dirs.isEmpty) {
      if (mounted) setState(() => _recordings = []);
      return;
    }

    final player = AudioPlayer();
    final List<RecordingFile> loaded = [];
    final Set<String> seen = {};
    try {
      for (final dir in dirs) {
        if (!dir.existsSync()) continue;
        for (final entity in dir.listSync().where(
          (f) =>
              f.path.toLowerCase().endsWith('.aac') ||
              f.path.toLowerCase().endsWith('.mp3') ||
              f.path.toLowerCase().endsWith('.m4a') ||
              f.path.toLowerCase().endsWith('.ts'),
        )) {
          if (entity is! File || !seen.add(entity.path)) continue;
          final stat = entity.statSync();
          if (stat.size == 0) continue;
          Duration dur = Duration.zero;
          try {
            dur = await player.setFilePath(entity.path) ?? Duration.zero;
          } catch (_) {}
          final fn = entity.uri.pathSegments.last;
          String title = fn.split('_').first;
          if (title.isEmpty) title = fn;
          loaded.add(
            RecordingFile(
              id: entity.path,
              title: title,
              path: entity.path,
              fileSizeInBytes: stat.size,
              dateCreated: stat.changed,
              duration: dur,
            ),
          );
        }
      }
    } catch (e) {
      _analyticsService.logActivity(deviceId!, 'Error loading recordings: $e');
    } finally {
      await player.dispose();
    }
    loaded.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
    if (mounted) setState(() => _recordings = loaded);
  }

  // ── Sort & filter ─────────────────────────────────────────────────────────

  List<dynamic> _applySort(List<dynamic> list, int tab) {
    final s = List<dynamic>.from(list);
    switch (_sortOptions[tab]) {
      case SortOption.nameAsc:
        s.sort((a, b) => _titleOf(a).compareTo(_titleOf(b)));
        break;
      case SortOption.nameDesc:
        s.sort((a, b) => _titleOf(b).compareTo(_titleOf(a)));
        break;
      case SortOption.dateNewest:
        s.sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));
        break;
      case SortOption.dateOldest:
        s.sort((a, b) => _dateOf(a).compareTo(_dateOf(b)));
        break;
      case SortOption.durationLong:
        s.sort((a, b) => _durOf(b).compareTo(_durOf(a)));
        break;
      case SortOption.sizeLarge:
        s.sort((a, b) => _sizeOf(b).compareTo(_sizeOf(a)));
        break;
    }
    return s;
  }

  List<dynamic> _applySearch(List<dynamic> list, int tab) {
    final q = _searchQueries[tab].toLowerCase().trim();
    if (q.isEmpty) return list;
    return list.where((i) => _titleOf(i).contains(q)).toList();
  }

  String _titleOf(dynamic i) {
    if (i is SongModel) return i.title.toLowerCase();
    if (i is RecordingFile) return i.title.toLowerCase();
    if (i is DownloadedMp3File) return i.title.toLowerCase();
    return '';
  }

  DateTime _dateOf(dynamic i) {
    if (i is SongModel)
      return DateTime.fromMillisecondsSinceEpoch(i.dateAdded ?? 0);
    if (i is RecordingFile) return i.dateCreated;
    if (i is DownloadedMp3File) return i.dateCreated;
    return DateTime(0);
  }

  int _durOf(dynamic i) {
    if (i is SongModel) return i.duration ?? 0;
    if (i is RecordingFile) return i.duration.inMilliseconds;
    if (i is DownloadedMp3File) return i.duration.inMilliseconds;
    return 0;
  }

  int _sizeOf(dynamic i) {
    if (i is RecordingFile) return (i as RecordingFile).fileSizeInBytes;
    if (i is DownloadedMp3File) return (i as DownloadedMp3File).fileSizeInBytes;
    return 0;
  }

  String _idOf(dynamic i) {
    if (i is SongModel) return i.data;
    if (i is RecordingFile) return i.path;
    if (i is DownloadedMp3File) return i.path;
    return '';
  }

  String _totalStorageLabel() {
    int b = 0;
    for (final RecordingFile r in (_recordings ?? [])) b += r.fileSizeInBytes;
    for (final DownloadedMp3File d in (_downloadedMp3s ?? []))
      b += d.fileSizeInBytes;
    if (b == 0) return '';
    return _formatBytes(b, 1) + ' used';
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _onFileTap(dynamic item) {
    if (_isSelecting) {
      _toggleSelect(item);
      return;
    }
    HapticFeedback.lightImpact();

    // Build the full visible list for the active tab — same order the user
    // sees — so next/previous in the expanded player navigate correctly.
    final tab = _tabController.index;
    final List<dynamic> visibleList;
    if (tab == 0) {
      visibleList = _applySearch(_applySort(_songs ?? [], tab), tab);
    } else if (tab == 1) {
      visibleList = _applySearch(_applySort(_downloadedMp3s ?? [], tab), tab);
    } else {
      visibleList = _applySearch(_applySort(_recordings ?? [], tab), tab);
    }

    final tappedIndex = visibleList.indexOf(item);
    final queue = visibleList
        .map((f) => {'path': _idOf(f), 'title': _titleOf(f)})
        .where((e) => e['path']!.isNotEmpty)
        .toList();

    if (queue.isNotEmpty && tappedIndex != -1) {
      // Load the whole sorted list as the active local queue, start at tapped item.
      globalRadioAudioHandler.loadLocalQueueAndPlay(queue, tappedIndex);
    } else {
      // Fallback: single-file play (queue is empty or item not found)
      final path = _idOf(item);
      final title = _titleOf(item);
      if (path.isNotEmpty) {
        globalRadioAudioHandler.playDownloadedFile(File(path), title);
      }
    }

    // Fire interstitial every N taps — same pattern as radio screen
    if (_showInterstitial) {
      _tapCount++;
      if (_tapCount % _interstitialEvery == 0) InterstitialAdManager.show();
    }
  }

  void _toggleSelect(dynamic item) {
    HapticFeedback.selectionClick();
    final id = _idOf(item);
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelecting = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _enterSelectMode(dynamic item) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelecting = true;
      _selectedIds.add(_idOf(item));
    });
  }

  void _onLongPress(dynamic item, bool isRec, bool isDl) {
    if (_isSelecting) {
      _toggleSelect(item);
      return;
    }
    HapticFeedback.mediumImpact();
    _showContextMenu(item, isRec, isDl);
  }

  Future<void> _bulkDelete(bool isRec) async {
    final count = _selectedIds.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete files'),
        content: Text(
          'Delete $count selected file${count > 1 ? 's' : ''}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    for (final p in _selectedIds) {
      try {
        await File(p).delete();
      } catch (_) {}
    }
    setState(() {
      _selectedIds.clear();
      _isSelecting = false;
    });
    HapticFeedback.lightImpact();
    _showSnackBar('$count file${count > 1 ? 's' : ''} deleted.');
    if (isRec)
      _loadLocalRecordings();
    else
      _loadDownloadedMp3s();
  }

  void _showContextMenu(dynamic item, bool isRec, bool isDl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                _titleOf(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const Divider(height: 1),
            _ctxTile(Icons.play_arrow_rounded, 'Play', () {
              Navigator.pop(context);
              _onFileTap(item);
            }),
            if (isRec || isDl)
              _ctxTile(Icons.ios_share_rounded, 'Share', () {
                Navigator.pop(context);
                _shareFile(item);
              }),
            if (isRec)
              _ctxTile(Icons.drive_file_rename_outline_rounded, 'Rename', () {
                Navigator.pop(context);
                _showRenameSheet(item as RecordingFile);
              }),
            _ctxTile(Icons.playlist_add_check_rounded, 'Select', () {
              Navigator.pop(context);
              _enterSelectMode(item);
            }),
            if (isRec || isDl)
              _ctxTile(Icons.delete_outline_rounded, 'Delete', () {
                Navigator.pop(context);
                _promptAndDeleteFile(item, isRec);
              }, color: Colors.red),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _ctxTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) => ListTile(
    leading: Icon(icon, color: color ?? const Color(0xFF7C4DFF), size: 22),
    title: Text(label, style: TextStyle(color: color, fontSize: 15)),
    onTap: onTap,
    dense: true,
  );

  Future<void> _showRenameSheet(RecordingFile file) async {
    final ctrl = TextEditingController(text: file.title);
    final newName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rename recording',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Recording name',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Rename'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (newName == null || newName.isEmpty || newName == file.title) return;
    try {
      final ext = file.path.split('.').last;
      final dir = file.path.substring(0, file.path.lastIndexOf('/'));
      await File(
        file.path,
      ).rename('$dir/${newName}_${DateTime.now().millisecondsSinceEpoch}.$ext');
      HapticFeedback.lightImpact();
      _showSnackBar('Renamed to "$newName".');
      _loadLocalRecordings();
    } catch (e) {
      _showSnackBar('Could not rename: $e');
    }
  }

  Future<void> _shareFile(dynamic file) async {
    HapticFeedback.lightImpact();
    try {
      final path = _idOf(file);
      final title = _titleOf(file);
      if (await File(path).exists()) {
        await Share.shareXFiles([XFile(path)], subject: 'Check out: $title');
      } else {
        _showSnackBar('Error: File not found.');
      }
    } catch (e) {
      _showSnackBar('Error sharing file.');
      _analyticsService.logActivity(deviceId!, 'Error sharing: $e');
    }
  }

  Future<void> _promptAndDeleteFile(dynamic file, bool isRec) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete file'),
        content: Text('Delete "${_titleOf(file)}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _doDeleteFile(file, isRec);
    }
  }

  Future<void> _doDeleteFile(dynamic file, bool isRec) async {
    try {
      final f = File(_idOf(file));
      if (await f.exists()) {
        await f.delete();
        HapticFeedback.lightImpact();
        _showSnackBar('"${_titleOf(file)}" deleted.');
        if (isRec)
          _loadLocalRecordings();
        else
          _loadDownloadedMp3s();
      } else {
        _showSnackBar('Error: File not found.');
      }
    } catch (e) {
      _analyticsService.logActivity(deviceId!, 'Error deleting: $e');
      _showSnackBar('Error deleting file.');
    }
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSortSheet() {
    final tab = _tabController.index;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort ${['music', 'downloads', 'recordings'][tab]} by',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              ...SortOption.values.map(
                (opt) => RadioListTile<SortOption>(
                  value: opt,
                  groupValue: _sortOptions[tab],
                  activeColor: const Color(0xFF7C4DFF),
                  secondary: Icon(
                    opt.icon,
                    size: 20,
                    color: const Color(0xFF7C4DFF),
                  ),
                  title: Text(opt.label, style: const TextStyle(fontSize: 14)),
                  onChanged: (val) {
                    if (val == null) return;
                    set(() {});
                    setState(() => _sortOptions[tab] = val);
                    _saveSortPref(tab);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final double emptyIconSz = sw * 0.2;
    final double emptyTitleSz = sw * 0.05;
    final double emptySubSz = sw * 0.035;
    final EdgeInsets btnPad = EdgeInsets.symmetric(
      horizontal: sw * 0.1,
      vertical: 12,
    );
    final double iconSz = sw * 0.07;

    final tab = _tabController.index;
    final isRecTab = tab == 2;
    final isDlTab = tab == 1;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF0D0D18), Colors.black]
                    : [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(isDark, sw),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _isSelecting
                        ? _buildSelectToolbar(isRecTab, isDlTab)
                        : const SizedBox.shrink(),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _searchVisible
                        ? _buildSearchBar(isDark, tab)
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: _isCheckingPermission
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF7C4DFF),
                            ),
                          )
                        : !_hasPermission
                        ? _buildPermissionDenied(
                            sw,
                            sh,
                            emptyIconSz,
                            emptyTitleSz,
                            emptySubSz,
                            iconSz,
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildSongList(
                                rawList: (_songs ?? []).cast<dynamic>(),
                                tabIndex: 0,
                                isRec: false,
                                isDl: false,
                                emptyIcon: Icons.music_note_outlined,
                                emptyTitle: 'No Music Found',
                                emptySubtitle:
                                    'Check your device storage for MP3 files.',
                                onRefresh: _loadAllSongs,
                                emptyIconSz: emptyIconSz,
                                emptyTitleSz: emptyTitleSz,
                                emptySubSz: emptySubSz,
                                btnPad: btnPad,
                              ),
                              _buildSongList(
                                rawList: (_downloadedMp3s ?? [])
                                    .cast<dynamic>(),
                                tabIndex: 1,
                                isRec: false,
                                isDl: true,
                                emptyIcon: Icons.download_for_offline_outlined,
                                emptyTitle: 'No Downloads',
                                emptySubtitle:
                                    'Songs you download will appear here.',
                                onRefresh: _loadDownloadedMp3s,
                                emptyIconSz: emptyIconSz,
                                emptyTitleSz: emptyTitleSz,
                                emptySubSz: emptySubSz,
                                btnPad: btnPad,
                              ),
                              _buildSongList(
                                rawList: (_recordings ?? []).cast<dynamic>(),
                                tabIndex: 2,
                                isRec: true,
                                isDl: false,
                                emptyIcon: Icons.mic_none_outlined,
                                emptyTitle: 'No Recordings',
                                emptySubtitle:
                                    'Your radio recordings will be saved here.',
                                onRefresh: _loadLocalRecordings,
                                emptyIconSz: emptyIconSz,
                                emptyTitleSz: emptyTitleSz,
                                emptySubSz: emptySubSz,
                                btnPad: btnPad,
                              ),
                            ],
                          ),
                  ),
                  StreamBuilder<MediaItem?>(
                    stream: globalRadioAudioHandler.mediaItem,
                    builder: (context, snap) {
                      final mi = snap.data;
                      if (mi == null)
                        return _showBanner
                            ? const BannerAdWidget()
                            : const SizedBox.shrink();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_showBanner) const BannerAdWidget(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 105),
                            child: _buildMiniPlayer(),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 110,
            child: AnimatedOpacity(
              opacity: _showScrollTop ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showScrollTop,
                child: FloatingActionButton.small(
                  heroTag: 'mp3_scroll_top_fab',
                  backgroundColor: const Color(0xFF7C4DFF),
                  elevation: 4,
                  onPressed: _scrollToTop,
                  child: const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark, double sw) {
    final storage = _totalStorageLabel();
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D18) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 14,
              left: 16,
              right: 8,
              bottom: 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _scrollToTop,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Library',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (storage.isNotEmpty)
                          Text(
                            storage,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _searchVisible
                        ? Icons.search_off_rounded
                        : Icons.search_rounded,
                  ),
                  tooltip: 'Search',
                  onPressed: () => setState(() {
                    _searchVisible = !_searchVisible;
                    if (!_searchVisible) {
                      for (final tc in _searchControllers) tc.clear();
                      for (int i = 0; i < 3; i++) _searchQueries[i] = '';
                    }
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.sort_rounded),
                  tooltip: 'Sort',
                  onPressed: _showSortSheet,
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: const Color(0xFF7C4DFF),
            indicatorWeight: 3,
            labelColor: const Color(0xFF7C4DFF),
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            tabs: [
              Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _tabLabel(Icons.music_note, 'Music', _songs?.length),
                ),
              ),
              Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _tabLabel(
                    Icons.download_done_rounded,
                    'Downloads',
                    _downloadedMp3s?.length,
                  ),
                ),
              ),
              Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _tabLabel(
                    Icons.mic,
                    'Recordings',
                    _recordings?.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabLabel(IconData icon, String label, int? count) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 16),
      const SizedBox(width: 4),
      Text(label),
      if (count != null && count > 0) ...[
        const SizedBox(width: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: const Color(0xFF7C4DFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ],
  );

  Widget _buildSearchBar(bool isDark, int tab) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _searchQueries[tab].isNotEmpty
              ? const Color(0xFF7C4DFF).withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchControllers[tab],
        autofocus: true,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          icon: Icon(
            Icons.search,
            color: _searchQueries[tab].isNotEmpty
                ? const Color(0xFF7C4DFF)
                : Colors.grey[500],
            size: 18,
          ),
          hintText: 'Search ${['songs', 'downloads', 'recordings'][tab]}...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          suffixIcon: _searchQueries[tab].isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[500], size: 18),
                  onPressed: () => _searchControllers[tab].clear(),
                )
              : null,
        ),
      ),
    ),
  );

  Widget _buildSelectToolbar(bool isRec, bool isDl) => Container(
    color: const Color(0xFF7C4DFF).withOpacity(0.08),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        Text(
          '${_selectedIds.length} selected',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C4DFF),
          ),
        ),
        const Spacer(),
        if (isRec || isDl)
          TextButton.icon(
            onPressed: () => _bulkDelete(isRec),
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: Colors.red,
            ),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => setState(() {
            _isSelecting = false;
            _selectedIds.clear();
          }),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );

  // ── Ad injection helper ───────────────────────────────────────────────────

  /// Injects NativeInFeedAdTile sentinels (null) into a flat item list.
  /// _DateHeader objects pass through unchanged and are excluded from the
  /// everyNItems row counter — spacing is relative to content rows only.
  List<dynamic> _injectAds(List<dynamic> items, InListPlacement p) {
    if (!p.enabled || items.isEmpty) return items;
    final every = p.everyNItems.clamp(1, 9999);
    final firstPos = p.firstAdPosition; // 0 → use everyNItems rhythm only
    final maxAds = p.maxAds; // 0 → unlimited

    final result = <dynamic>[];
    int adCount = 0;
    int rows = 0; // content rows only — _DateHeaders excluded
    int contentIdx = 0; // 1-based absolute content index for firstPos

    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);

      // Headers are structural — don't count them toward ad spacing.
      if (items[i] is _DateHeader) continue;

      rows++;
      contentIdx++;

      final hitFirst = firstPos > 0 && contentIdx == firstPos;
      final hitRegular = firstPos > 0
          ? (contentIdx > firstPos && (contentIdx - firstPos) % every == 0)
          : rows >= every;

      if (hitFirst || hitRegular) {
        if (maxAds == 0 || adCount < maxAds) {
          result.add(null); // null = ad slot sentinel
          adCount++;
          rows = 0;
        }
      }
    }
    return result;
  }

  // ── Song list ─────────────────────────────────────────────────────────────

  Widget _buildSongList({
    required List<dynamic> rawList,
    required int tabIndex,
    required bool isRec,
    required bool isDl,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
    required Future<void> Function() onRefresh,
    required double emptyIconSz,
    required double emptyTitleSz,
    required double emptySubSz,
    required EdgeInsets btnPad,
  }) {
    final sorted = _applySort(rawList, tabIndex);
    final filtered = _applySearch(sorted, tabIndex);

    // Pick the correct placement config for this tab
    final placement = tabIndex == 0
        ? _mp3ListPlacement
        : tabIndex == 1
        ? _downloadsListPlacement
        : _recordingsListPlacement;

    Widget child;
    if (filtered.isEmpty) {
      child = _buildEmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
        onRefresh: onRefresh,
        emptyIconSz: emptyIconSz,
        emptyTitleSz: emptyTitleSz,
        emptySubSz: emptySubSz,
        btnPad: btnPad,
      );
    } else {
      child = StreamBuilder<MediaItem?>(
        stream: globalRadioAudioHandler.mediaItem,
        builder: (context, ms) {
          final currentId = ms.data?.id;
          return StreamBuilder<PlaybackState>(
            stream: globalRadioAudioHandler.playbackState,
            builder: (context, ps) {
              final playing = ps.data?.playing ?? false;
              // Group recordings by date, then inject ads
              final grouped = isRec ? _buildGroupedItems(filtered) : filtered;
              final items = _injectAds(grouped, placement);

              return ListView.builder(
                controller: _scrollControllers[tabIndex],
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length,
                padding: const EdgeInsets.only(bottom: 140, top: 8),
                itemBuilder: (context, idx) {
                  final entry = items[idx];

                  // null sentinel = native in-feed ad slot
                  if (entry == null) {
                    return NativeInFeedAdTile(
                      key: ValueKey('mp3_ad_${tabIndex}_$idx'),
                    );
                  }

                  if (entry is _DateHeader)
                    return _buildDateHeader(entry.label);

                  final id = _idOf(entry);
                  final title = _titleOf(entry);
                  String subtitle = '';
                  Duration dur = Duration.zero;
                  int size = 0;
                  if (entry is SongModel) {
                    subtitle = entry.artist ?? 'Unknown Artist';
                    dur = Duration(milliseconds: entry.duration ?? 0);
                  } else if (entry is RecordingFile) {
                    subtitle = _formatBytes(entry.fileSizeInBytes, 1);
                    dur = entry.duration;
                    size = entry.fileSizeInBytes;
                  } else if (entry is DownloadedMp3File) {
                    subtitle =
                        entry.artist ?? _formatBytes(entry.fileSizeInBytes, 1);
                    dur = entry.duration;
                    size = entry.fileSizeInBytes;
                  }

                  final isSel = currentId != null && currentId == id;
                  final isPlay = isSel && playing;
                  final isMSel = _selectedIds.contains(id);
                  final canSw = isRec || isDl;

                  Widget tile = _buildListTile(
                    item: entry,
                    id: id,
                    title: title,
                    subtitle: subtitle,
                    dur: dur,
                    size: size,
                    isSel: isSel,
                    isPlay: isPlay,
                    isRec: isRec,
                    isDl: isDl,
                    isMSel: isMSel,
                  );

                  if (canSw && !_isSelecting) {
                    tile = Dismissible(
                      key: Key(id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      confirmDismiss: (_) async {
                        HapticFeedback.mediumImpact();
                        return await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                title: const Text('Delete File'),
                                content: Text(
                                  'Delete "$title"? This cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text('DELETE'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                      },
                      onDismissed: (_) => _doDeleteFile(entry, isRec),
                      child: tile,
                    );
                  }
                  return tile;
                },
              );
            },
          );
        },
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF7C4DFF),
      strokeWidth: 2.5,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await onRefresh();
      },
      child: child,
    );
  }

  List<dynamic> _buildGroupedItems(List<dynamic> recs) {
    final result = <dynamic>[];
    String? last;
    final now = DateTime.now();
    for (final r in recs) {
      final lbl = _dayLabel(_dateOf(r), now);
      if (lbl != last) {
        result.add(_DateHeader(lbl));
        last = lbl;
      }
      result.add(r);
    }
    return result;
  }

  String _dayLabel(DateTime d, DateTime now) {
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }

  Widget _buildDateHeader(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget _buildListTile({
    required dynamic item,
    required String id,
    required String title,
    required String subtitle,
    required Duration dur,
    required int size,
    required bool isSel,
    required bool isPlay,
    required bool isRec,
    required bool isDl,
    required bool isMSel,
  }) {
    final canAct = isRec || isDl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isMSel
            ? const Color(0xFF7C4DFF).withOpacity(0.12)
            : isSel
            ? const Color(0xFF7C4DFF).withOpacity(0.07)
            : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
        border: Border.all(
          color: isMSel
              ? const Color(0xFF7C4DFF).withOpacity(0.5)
              : isSel
              ? const Color(0xFF7C4DFF).withOpacity(0.3)
              : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.04)),
          width: isMSel || isSel ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSel
                ? const Color(0xFF7C4DFF).withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: isSel ? 12 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: _buildAvatar(isRec, isSel, isPlay, isMSel),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
            color: isSel ? const Color(0xFF7C4DFF) : null,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              if (dur != Duration.zero)
                _Chip(
                  label: _formatDuration(dur),
                  icon: Icons.timer_outlined,
                  color: const Color(0xFF7C4DFF),
                ),
              if (size > 0) ...[
                const SizedBox(width: 4),
                _Chip(
                  label: _formatBytes(size, 1),
                  icon: Icons.storage_outlined,
                  color: Colors.blueGrey,
                ),
              ],
            ],
          ),
        ),
        trailing: _isSelecting
            ? Checkbox(
                value: isMSel,
                activeColor: const Color(0xFF7C4DFF),
                onChanged: (_) => _toggleSelect(item),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canAct)
                    GestureDetector(
                      onTap: () => _shareFile(item),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.ios_share_rounded,
                          size: 16,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (c, a) =>
                        ScaleTransition(scale: a, child: c),
                    child: Icon(
                      isPlay
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      key: ValueKey(isPlay),
                      size: 34,
                      color: isSel ? const Color(0xFF7C4DFF) : Colors.grey[400],
                    ),
                  ),
                ],
              ),
        onTap: () => _onFileTap(item),
        onLongPress: () => _onLongPress(item, isRec, isDl),
      ),
    );
  }

  Widget _buildAvatar(bool isRec, bool isSel, bool isPlay, bool isMSel) =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSel && !isMSel
              ? const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMSel
              ? const Color(0xFF7C4DFF).withOpacity(0.15)
              : isSel
              ? null
              : Colors.grey.withOpacity(0.1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              isMSel
                  ? Icons.check
                  : isRec
                  ? Icons.mic
                  : Icons.music_note,
              color: isMSel
                  ? const Color(0xFF7C4DFF)
                  : isSel
                  ? Colors.white
                  : Colors.grey,
              size: 22,
            ),
            if (isPlay)
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7C4DFF), width: 2),
                ),
              ),
          ],
        ),
      );

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Future<void> Function() onRefresh,
    required double emptyIconSz,
    required double emptyTitleSz,
    required double emptySubSz,
    required EdgeInsets btnPad,
  }) => Center(
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: emptyIconSz * 1.2,
            height: emptyIconSz * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C4DFF).withOpacity(0.07),
            ),
            child: Icon(icon, size: emptyIconSz, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: emptyTitleSz,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: emptySubSz, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _isRefreshing
                ? null
                : () async {
                    if (!mounted) return;
                    setState(() => _isRefreshing = true);
                    await onRefresh();
                    if (mounted) setState(() => _isRefreshing = false);
                  },
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            label: Text(_isRefreshing ? 'Refreshing...' : 'Refresh'),
            style: ElevatedButton.styleFrom(
              padding: btnPad,
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    ),
  );

  Widget _buildPermissionDenied(
    double sw,
    double sh,
    double eIS,
    double eTiS,
    double eSuS,
    double iS,
  ) => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: eIS, color: Colors.grey[400]),
          SizedBox(height: sh * 0.03),
          Text(
            'Permission Required',
            style: TextStyle(fontSize: eTiS, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: sh * 0.015),
          Text(
            'We need access to your audio files to play local music.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: eSuS),
          ),
          SizedBox(height: sh * 0.04),
          ElevatedButton.icon(
            onPressed: _checkAndRequestPermissions,
            icon: Icon(Icons.security, size: iS * 0.8),
            label: Text('Grant Permission', style: TextStyle(fontSize: eSuS)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.1,
                vertical: sh * 0.02,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sw * 0.075),
              ),
            ),
          ),
          SizedBox(height: sh * 0.02),
          TextButton(
            onPressed: openAppSettings,
            child: Text('Open Settings', style: TextStyle(fontSize: eSuS)),
          ),
        ],
      ),
    ),
  );

  Widget _buildMiniPlayer() => StreamBuilder<MediaItem?>(
    stream: globalRadioAudioHandler.mediaItem,
    builder: (context, snap) {
      final mi = snap.data;
      if (mi == null) return const SizedBox.shrink();
      return StreamBuilder<PlaybackState>(
        stream: globalRadioAudioHandler.playbackState,
        builder: (context, ps) {
          final playing = ps.data?.playing ?? false;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 45,
                    height: 45,
                    color: const Color(0xFF7C4DFF).withOpacity(0.1),
                    child: const Icon(
                      Icons.music_note,
                      color: Color(0xFF7C4DFF),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mi.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        mi.artist ?? 'Unknown Artist',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                  iconSize: 32,
                  color: const Color(0xFF7C4DFF),
                  onPressed: () => playing
                      ? globalRadioAudioHandler.pause()
                      : globalRadioAudioHandler.play(),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => globalRadioAudioHandler.stop(),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// ── Small chip label ──────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Chip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color.withOpacity(0.8)),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
