import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grradio/Env.dart';
import 'package:grradio/ads/ad_config_provider.dart';
import 'package:grradio/ads/ad_widgets.dart';
import 'package:grradio/masstamilan/presentation/albumslist.dart';
import 'package:grradio/mp3download/mp3_constants.dart';
import 'package:grradio/mp3download/mp3downloadresults.dart';
import 'package:grradio/mp3download/oldmp3browserscreen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../more/theme_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Remote config models
//
//  Fetched from:  GET <baseUrl>/appconfig/download-screen
//
//  MongoDB document shape (see python_api_download_screen_config.py for the
//  full Pydantic model and FastAPI endpoint):
//
//  {
//    "languages_enabled": true,
//    "languages": [
//      { "label": "Telugu", "value": "Telugu" },
//      { "label": "Hindi",  "value": "Hindi"  }
//    ],
//    "content_types_enabled": true,
//    "content_types": [
//      { "label": "Song",   "value": "Song",   "icon": "music_note" },
//      { "label": "Movie",  "value": "Movie",  "icon": "movie"      },
//      { "label": "Album",  "value": "Album",  "icon": "album"      },
//      { "label": "Artist", "value": "Artist", "icon": "mic"        }
//    ],
//    "browse_by_album_enabled": true,
//    "album_entries": [
//      {
//        "label":    "Telugu",
//        "lang":     "telugu",
//        "base_url": "masstelugu",      ← API route PREFIX, not a full URL.
//                                         Appended to Env.apiBaseUrl at runtime:
//                                           ${Env.apiBaseUrl}/masstelugu/albums
//                                         Passed to AlbumListPage as serviceRoute
//                                         to override its internal language→path map.
//                                         Leave empty ("") to use AlbumListPage's default.
//        "icon":     "library_music",
//        "color_a":  "#7C4DFF",
//        "color_b":  "#9C6FFF",
//        "enabled":  true
//      },
//      ...
//    ],
//    "old_archive_enabled": true
//  }
//
//  Search section visibility is DERIVED:
//    visible  ⟺  languages_enabled=true  AND  languages non-empty
//              AND content_types_enabled=true AND content_types non-empty
//  No separate flag is needed in the database.
// ─────────────────────────────────────────────────────────────────────────────

class _LangOption {
  final String label; // displayed on chip
  final String value; // passed to search / archive navigator
  const _LangOption({required this.label, required this.value});
  factory _LangOption.fromJson(Map<String, dynamic> j) => _LangOption(
    label: j['label'] as String? ?? '',
    value: j['value'] as String? ?? '',
  );
}

class _ContentTypeOption {
  final String label;
  final String value;
  final String icon; // resolved via _iconForName()
  const _ContentTypeOption({
    required this.label,
    required this.value,
    required this.icon,
  });
  factory _ContentTypeOption.fromJson(Map<String, dynamic> j) =>
      _ContentTypeOption(
        label: j['label'] as String? ?? '',
        value: j['value'] as String? ?? '',
        icon: j['icon'] as String? ?? 'music_note',
      );
}

class _AlbumBrowseEntry {
  final String label;
  // Route PREFIX from MongoDB (e.g. "masstelugu").
  // Used two ways:
  //   1. Passed as serviceRoute to AlbumListPage so AlbumApi uses this path
  //      directly: ${Env.apiBaseUrl}/$baseUrl/albums
  //   2. Built into a full URL for OldMp3Browser: ${Env.apiBaseUrl}/$baseUrl
  // Empty string → AlbumListPage falls back to its own language→path switch.
  final String baseUrl;
  final String lang; // language key passed to AlbumListPage for display
  final String icon; // resolved via _iconForName()
  final Color colorA;
  final Color colorB;
  final bool enabled;
  const _AlbumBrowseEntry({
    required this.label,
    required this.baseUrl,
    required this.lang,
    required this.icon,
    required this.colorA,
    required this.colorB,
    required this.enabled,
  });

  factory _AlbumBrowseEntry.fromJson(Map<String, dynamic> j) {
    Color _hexColor(String? hex, Color fallback) {
      try {
        final h = (hex ?? '').replaceAll('#', '');
        return Color(int.parse('FF$h', radix: 16));
      } catch (_) {
        return fallback;
      }
    }

    return _AlbumBrowseEntry(
      label: j['label'] as String? ?? '',
      baseUrl: j['base_url'] as String? ?? '',
      lang: j['lang'] as String? ?? '',
      icon: j['icon'] as String? ?? 'library_music',
      colorA: _hexColor(j['color_a'] as String?, const Color(0xFF7C4DFF)),
      colorB: _hexColor(j['color_b'] as String?, const Color(0xFF448AFF)),
      enabled: j['enabled'] as bool? ?? true,
    );
  }
}

class _DownloadScreenConfig {
  final bool languagesEnabled;
  final List<_LangOption> languages;
  final bool contentTypesEnabled;
  final List<_ContentTypeOption> contentTypes;
  final bool browseByAlbumEnabled;
  final List<_AlbumBrowseEntry> albumEntries;
  final bool oldArchiveEnabled;

  const _DownloadScreenConfig({
    required this.languagesEnabled,
    required this.languages,
    required this.contentTypesEnabled,
    required this.contentTypes,
    required this.browseByAlbumEnabled,
    required this.albumEntries,
    required this.oldArchiveEnabled,
  });

  /// Search section visible only when both selectors are on and non-empty.
  bool get searchEnabled =>
      languagesEnabled &&
      languages.isNotEmpty &&
      contentTypesEnabled &&
      contentTypes.isNotEmpty;

  factory _DownloadScreenConfig.fromJson(Map<String, dynamic> j) {
    List<T> _parseList<T>(String key, T Function(Map<String, dynamic>) from) {
      final raw = j[key];
      if (raw is! List) return [];
      return raw.whereType<Map<String, dynamic>>().map(from).toList();
    }

    return _DownloadScreenConfig(
      languagesEnabled: j['languages_enabled'] as bool? ?? true,
      languages: _parseList('languages', _LangOption.fromJson),
      contentTypesEnabled: j['content_types_enabled'] as bool? ?? true,
      contentTypes: _parseList('content_types', _ContentTypeOption.fromJson),
      browseByAlbumEnabled: j['browse_by_album_enabled'] as bool? ?? true,
      albumEntries: _parseList('album_entries', _AlbumBrowseEntry.fromJson),
      oldArchiveEnabled: j['old_archive_enabled'] as bool? ?? true,
    );
  }

  /// Hardcoded defaults used until the API responds.
  static _DownloadScreenConfig get fallback => _DownloadScreenConfig(
    languagesEnabled: true,
    languages: Mp3Constants.languages
        .map((l) => _LangOption(label: l, value: l))
        .toList(),
    contentTypesEnabled: true,
    contentTypes: Mp3Constants.fileTypes
        .map(
          (t) =>
              _ContentTypeOption(label: t, value: t, icon: _defaultIconName(t)),
        )
        .toList(),
    browseByAlbumEnabled: true,
    albumEntries: const [
      _AlbumBrowseEntry(
        label: 'Telugu',
        lang: 'telugu',
        baseUrl: '',
        icon: 'library_music',
        colorA: Color(0xFF7C4DFF),
        colorB: Color(0xFF9C6FFF),
        enabled: true,
      ),
      _AlbumBrowseEntry(
        label: 'Tamil',
        lang: 'tamil',
        baseUrl: '',
        icon: 'library_music',
        colorA: Color(0xFFE91E63),
        colorB: Color(0xFFFF5722),
        enabled: true,
      ),
      _AlbumBrowseEntry(
        label: 'Hindi',
        lang: 'hindi',
        baseUrl: '',
        icon: 'library_music',
        colorA: Color(0xFFFF6D00),
        colorB: Color(0xFFFF9800),
        enabled: true,
      ),
      _AlbumBrowseEntry(
        label: 'Malayalam',
        lang: 'malayalam',
        baseUrl: '',
        icon: 'library_music',
        colorA: Color(0xFF00897B),
        colorB: Color(0xFF26C6DA),
        enabled: true,
      ),
    ],
    oldArchiveEnabled: true,
  );

  static String _defaultIconName(String type) {
    switch (type.toLowerCase()) {
      case 'song':
        return 'music_note';
      case 'movie':
        return 'movie';
      case 'album':
        return 'album';
      case 'artist':
        return 'mic';
      default:
        return 'music_note';
    }
  }
}

// ── Icon name → IconData ──────────────────────────────────────────────────────
IconData _iconForName(String name) {
  const _map = <String, IconData>{
    'music_note': Icons.music_note_rounded,
    'movie': Icons.movie_rounded,
    'album': Icons.album_rounded,
    'mic': Icons.mic_rounded,
    'library_music': Icons.library_music_rounded,
    'headphones': Icons.headphones_rounded,
    'queue_music': Icons.queue_music_rounded,
    'piano': Icons.piano_rounded,
    'star': Icons.star_rounded,
    'favorite': Icons.favorite_rounded,
  };
  return _map[name] ?? Icons.music_note_rounded;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Mp3DownloadScreen
// ─────────────────────────────────────────────────────────────────────────────

class Mp3DownloadScreen extends StatefulWidget {
  @override
  _Mp3DownloadScreenState createState() => _Mp3DownloadScreenState();
}

class _Mp3DownloadScreenState extends State<Mp3DownloadScreen>
    with SingleTickerProviderStateMixin {
  // ── Selection state ────────────────────────────────────────────────────────
  String? _selectedLanguage;
  String? _selectedFileType;
  final TextEditingController _searchController = TextEditingController();
  AnimationController? _searchShakeController;
  Animation<double>? _searchShakeAnim;
  bool _isLoading = false;

  // ── Remote screen config ───────────────────────────────────────────────────
  _DownloadScreenConfig _config = _DownloadScreenConfig.fallback;
  bool _configLoaded =
      false; // flips true once fetch completes (success or fail)
  String? _configError; // non-null on fetch failure — shown as debug banner

  // ── Ad state ───────────────────────────────────────────────────────────────
  // AdScreen.mp3Download ('mp3_download') is the correct key for this screen.
  // AdScreen.player ('player') is used by Mp3PlayerScreen (Library tabs).
  bool _showBanner = false;
  bool _showInterstitial = false;
  int _interstitialEvery = 5;
  int _tapCount = 0;
  bool _adConfigLoaded = false;

  // ── Old-archive URL ────────────────────────────────────────────────────────
  // base_url in the MongoDB document is a route PREFIX (e.g. "masstelugu"),
  // not a full URL.  We build the full URL by appending it to Env.apiBaseUrl.
  // If no matching entry has a non-empty base_url we fall back to the constant.
  String get _oldArchiveUrl {
    if (_selectedLanguage != null) {
      final match = _config.albumEntries
          .where((e) => e.label == _selectedLanguage && e.baseUrl.isNotEmpty)
          .firstOrNull;
      if (match != null) return '${Env.apiBaseUrl}/${match.baseUrl}';
    }
    // No language selected or no entry found — use the app-wide default
    return Mp3Constants.oldMp3InitialUrl;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // Shake animation for invalid-search validation feedback
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _searchShakeController = ctrl;
    _searchShakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));

    // Fetch remote screen config (sections, languages, album entries…)
    _fetchConfig();

    // Snapshot ad config as soon as AdConfigProvider.initialize() completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final adConfig = context.read<AdConfigProvider>();
      if (adConfig.initialized) {
        _snapshotAdConfig(adConfig);
      } else {
        late void Function() _listener;
        _listener = () {
          if (!mounted) return;
          _snapshotAdConfig(adConfig);
          adConfig.removeListener(_listener);
        };
        adConfig.addListener(_listener);
      }
    });
  }

  void _snapshotAdConfig(AdConfigProvider adConfig) {
    if (!mounted) return;
    setState(() {
      _adConfigLoaded = true;
      _showBanner = adConfig.isBannerEnabled(AdScreen.mp3Download);
      _showInterstitial = adConfig.isInterstitialEnabled(AdScreen.mp3Download);
      _interstitialEvery = adConfig.interstitialEveryNTaps(
        AdScreen.mp3Download,
      );
    });
    if (_showInterstitial) InterstitialAdManager.preload();
  }

  Future<void> _fetchConfig() async {
    final url = '${Env.apiBaseUrl}/appconfig/download-screen';
    debugPrint('DownloadScreen ▶ fetching config: $url');
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 65));

      debugPrint('DownloadScreen ◀ status=${response.statusCode}');
      debugPrint('DownloadScreen ◀ body=${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        var decoded = jsonDecode(response.body);

        // Some API responses wrap the payload under a top-level "config" key
        // (same pattern as the existing /appconfig endpoint in main.dart).
        // Handle both: { "languages_enabled": ... } and { "config": { ... } }.
        Map<String, dynamic> data;
        if (decoded is Map<String, dynamic>) {
          data =
              decoded.containsKey('config') &&
                  decoded['config'] is Map<String, dynamic>
              ? decoded['config'] as Map<String, dynamic>
              : decoded;
        } else {
          throw FormatException(
            'Unexpected JSON root type: ${decoded.runtimeType}',
          );
        }

        final parsed = _DownloadScreenConfig.fromJson(data);
        debugPrint(
          'DownloadScreen ✓ parsed: '
          '${parsed.languages.length} languages, '
          '${parsed.albumEntries.length} album entries '
          '(${parsed.albumEntries.where((e) => e.enabled).length} enabled)',
        );

        if (!mounted) return;
        setState(() {
          _config = parsed;
          _configLoaded = true;
          _configError = null;
          // Clear selections no longer valid in the refreshed config
          if (_selectedLanguage != null &&
              !_config.languages.any((l) => l.label == _selectedLanguage)) {
            _selectedLanguage = null;
          }
          if (_selectedFileType != null &&
              !_config.contentTypes.any((t) => t.label == _selectedFileType)) {
            _selectedFileType = null;
          }
        });
      } else {
        final msg = 'HTTP ${response.statusCode} from $url\n${response.body}';
        debugPrint('DownloadScreen ✗ $msg');
        if (mounted) {
          setState(() {
            _configLoaded = true;
            _configError = msg;
          });
        }
      }
    } on TimeoutException {
      const msg = 'Request timed out after 10 s';
      debugPrint('DownloadScreen ✗ $msg');
      if (mounted)
        setState(() {
          _configLoaded = true;
          _configError = msg;
        });
    } catch (e, st) {
      final msg = '$e';
      debugPrint('DownloadScreen ✗ exception: $e\n$st');
      if (mounted)
        setState(() {
          _configLoaded = true;
          _configError = msg;
        });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchShakeController?.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _searchMp3() async {
    if (_selectedLanguage == null || _selectedFileType == null) {
      HapticFeedback.mediumImpact();
      _searchShakeController?.forward(from: 0);
      _showSnackbar('Please select a language and content type', Colors.red);
      return;
    }
    if (_searchController.text.trim().isEmpty) {
      HapticFeedback.mediumImpact();
      _searchShakeController?.forward(from: 0);
      _showSnackbar('Please enter a search term', Colors.red);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    if (_showInterstitial) {
      _tapCount++;
      if (_tapCount % _interstitialEvery == 0) InterstitialAdManager.show();
    }
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Mp3DownloadResultsScreen(
            searchQuery: _searchController.text.trim(),
            language: _selectedLanguage!,
            fileType: _selectedFileType!,
          ),
        ),
      );
    } catch (e) {
      _showSnackbar('Error starting search: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToOldMp3() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    if (_showInterstitial) {
      _tapCount++;
      if (_tapCount % _interstitialEvery == 0) InterstitialAdManager.show();
    }
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OldMp3Browser(initialUrl: _oldArchiveUrl),
        ),
      );
    } catch (e) {
      _showSnackbar('Error loading Old MP3: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Build helpers ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, IconData icon) => Row(
    children: [
      Icon(
        icon,
        size: 14,
        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.4),
      ),
      const SizedBox(width: 5),
      Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.5),
        ),
      ),
    ],
  );

  Widget _buildLanguageChips() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Language', CupertinoIcons.globe),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _config.languages.map((lang) {
            final sel = _selectedLanguage == lang.label;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedLanguage = lang.label);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF7C4DFF)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: sel
                          ? const Color(0xFF7C4DFF)
                          : Theme.of(context).dividerColor,
                      width: 1.5,
                    ),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: const Color(0xFF7C4DFF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    lang.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      color: sel
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );

  Widget _buildContentTypeGrid() {
    final types = _config.contentTypes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Content type', CupertinoIcons.folder),
        const SizedBox(height: 8),
        Row(
          children: types.asMap().entries.map((e) {
            final idx = e.key;
            final type = e.value;
            final sel = _selectedFileType == type.label;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: idx == types.length - 1 ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedFileType = type.label);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFF7C4DFF).withOpacity(0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel
                            ? const Color(0xFF7C4DFF)
                            : Theme.of(context).dividerColor,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconForName(type.icon),
                          size: 22,
                          color: sel
                              ? const Color(0xFF7C4DFF)
                              : Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color!.withOpacity(0.5),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          type.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: sel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: sel
                                ? const Color(0xFF7C4DFF)
                                : Theme.of(context).textTheme.bodyLarge!.color!
                                      .withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchRowContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Search', CupertinoIcons.search),
      const SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _searchMp3(),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Movie name, song, artist…',
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withOpacity(0.35),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withOpacity(0.4),
                      size: 18,
                    ),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (_, val, __) => val.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () => _searchController.clear(),
                              color: Colors.grey,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _isLoading
              ? const SizedBox(
                  width: 52,
                  height: 52,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: _searchMp3,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C4DFF).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.search,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
        ],
      ),
    ],
  );

  Widget _buildSearchRow() {
    final anim = _searchShakeAnim;
    if (anim == null) return _buildSearchRowContent();
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) =>
          Transform.translate(offset: Offset(anim.value, 0), child: child),
      child: _buildSearchRowContent(),
    );
  }

  Widget _buildAlbumGrid() {
    final entries = _config.albumEntries.where((e) => e.enabled).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Browse by album', Icons.library_music_rounded),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3.0,
          children: entries.map(_buildAlbumCard).toList(),
        ),
      ],
    );
  }

  Widget _buildAlbumCard(_AlbumBrowseEntry entry) => GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      Navigator.push(
        context,
        MaterialPageRoute(
          // entry.lang  — the language key AlbumListPage uses for display
          // entry.baseUrl — the API route prefix from MongoDB (e.g. "masstelugu").
          //   Passed as serviceRoute so AlbumListPage / AlbumApi uses this
          //   path directly instead of its internal language→path switch.
          //   When empty the page falls back to its own mapping.
          builder: (_) => AlbumListPage(
            language: entry.lang,
            serviceRoute: entry.baseUrl.isNotEmpty ? entry.baseUrl : null,
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [entry.colorA, entry.colorB],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: entry.colorA.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(_iconForName(entry.icon), color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            entry.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white54,
            size: 18,
          ),
        ],
      ),
    ),
  );

  Widget _buildOldMp3Button() => OutlinedButton(
    onPressed: _navigateToOldMp3,
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.clock,
          size: 18,
          color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          'Browse Old MP3 Archive',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(
              context,
            ).textTheme.bodyLarge!.color!.withOpacity(0.75),
          ),
        ),
      ],
    ),
  );

  // ── Main build ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MP3 Download',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Theme.of(context).textTheme.bodyLarge!.color
                  : Colors.white,
            ),
          ),
          Text(
            'Find songs, albums & artists',
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!.withOpacity(0.5)
                  : Colors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
      flexibleSpace: isDark
          ? Container(color: const Color(0xFF121212))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // ── Show a loading shimmer until config is fetched ──────────────────────
    if (!_configLoaded) {
      return Scaffold(
        appBar: _buildAppBar(isDark), // extract your AppBar into a helper
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7C4DFF),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final cfg = _config;

    // Visibility flags derived from config
    final showLanguages = cfg.languagesEnabled && cfg.languages.isNotEmpty;
    final showContentTypes =
        cfg.contentTypesEnabled && cfg.contentTypes.isNotEmpty;
    final showSearch = cfg.searchEnabled;
    final showBrowse =
        cfg.browseByAlbumEnabled && cfg.albumEntries.any((e) => e.enabled);
    final showOldArchive = cfg.oldArchiveEnabled;
    final showDivider = showBrowse || showOldArchive;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MP3 Download',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? Theme.of(context).textTheme.bodyLarge!.color
                    : Colors.white,
              ),
            ),
            Text(
              'Find songs, albums & artists',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withOpacity(0.5)
                    : Colors.white.withOpacity(0.75),
              ),
            ),
          ],
        ),
        flexibleSpace: isDark
            ? Container(color: const Color(0xFF121212))
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: const Color(0xFF7C4DFF),
        strokeWidth: 2.5,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          setState(() {
            _configError = null;
            _configLoaded = false;
          });
          await _fetchConfig();
        },
        child: SingleChildScrollView(
          // Always-scrollable so the pull-to-refresh gesture triggers even
          // when the content is shorter than the viewport.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── DEBUG: config fetch error banner ──────────────────────
              // Visible whenever _fetchConfig fails (any status or exception).
              // Shows the exact error + a retry button.  Remove in production
              // if you prefer silent fallback.
              if (_configError != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.35)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Config load failed (showing defaults):\n$_configError',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _configError = null;
                            _configLoaded = false;
                          });
                          _fetchConfig();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.refresh,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── 1. Language chips ───────────────────────────────────────
              if (showLanguages) ...[
                _buildLanguageChips(),
                const SizedBox(height: 22),
              ],

              // ── 2. Content type tiles ───────────────────────────────────
              if (showContentTypes) ...[
                _buildContentTypeGrid(),
                const SizedBox(height: 22),
              ],

              // ── 3. Search row ───────────────────────────────────────────
              //    Only shown when both language + content-type are on
              //    AND have at least one option each.
              if (showSearch) ...[
                _buildSearchRow(),
                const SizedBox(height: 28),
              ],

              // ── OR BROWSE divider ───────────────────────────────────────
              if (showDivider) ...[
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).dividerColor,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR BROWSE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.color!.withOpacity(0.35),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).dividerColor,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // ── 4. Browse by album grid ─────────────────────────────────
              if (showBrowse) ...[
                _buildAlbumGrid(),
                const SizedBox(height: 16),
              ],

              // ── 5. Old MP3 archive button ───────────────────────────────
              if (showOldArchive) ...[
                _buildOldMp3Button(),
                const SizedBox(height: 16),
              ],

              // ── 6. Banner ad ────────────────────────────────────────────
              if (_showBanner) ...[
                const SizedBox(height: 4),
                Container(
                  alignment: Alignment.center,
                  child: const BannerAdWidget(),
                ),
              ],

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
