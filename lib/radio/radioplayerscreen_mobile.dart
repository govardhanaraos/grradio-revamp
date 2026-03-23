import 'dart:async';
import 'dart:math' show Random;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grradio/ads/ad_config_provider.dart';
import 'package:grradio/ads/ad_widgets.dart';
import 'package:grradio/main.dart';
import 'package:grradio/more/theme_provider.dart';
import 'package:grradio/radio/radiostation.dart';
import 'package:grradio/radio/station_category_screen.dart';
import 'package:grradio/widgets/horizontal_station_list.dart';
import 'package:grradio/widgets/radio_animated_icons.dart';
import 'package:grradio/widgets/section_header.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PROGRESSIVE DISPLAY WITH INCREMENTAL AD INJECTION
//
//  Strategy:
//  1. main.dart fires stationsNotifier.value after EVERY page (50 stations).
//     stationsLoadingComplete fires once when the last page is done.
//
//  2. _onStationsUpdated() — called on every stationsNotifier change.
//     Receives the full cumulative station list so far (e.g. after page 3 it
//     holds stations 1-150).  It computes which stations are NEW (beyond
//     what was already rendered), runs _injectAdsIncremental() only on those
//     new stations, appends the result to _mixedItems, and calls setState.
//     Users see stations (with correct ad slots) appear page by page.
//
//  3. _onLoadComplete() — called once when stationsLoadingComplete fires.
//     At this point stationsNotifier.value is the fully-merged final list.
//     We do one final incremental pass over any tail stations not yet rendered,
//     set _adsInjected = true, and snapshot ad-flag config.
//
//  Incremental ad placement (_injectAdsIncremental):
//  The function accepts the continuation state (_adCount, _rowsSinceLastAd)
//  from the previous call, so ad slots are placed at globally correct
//  positions across page boundaries.  Example with everyNItems=6,
//  firstAdPosition=3, maxAds=10:
//    page 1 (50 stations): ad at pos 3, then 9,15,21,27,33,39,45 → 8 ads
//    page 2 (50 stations): continues from row-count=3 (50 - last-ad-pos),
//                          next ad lands at correct global position.
//
//  Why this is crash-safe:
//  • The widget tree Column/Sliver structure never changes — only
//    ListView.builder's itemCount grows. Flutter handles that safely.
//  • setState is called at most once per page — never mid-frame.
// ─────────────────────────────────────────────────────────────────────────────

// ── Mixed-list types ──────────────────────────────────────────────────────────

sealed class _ListItem {
  const _ListItem();
}

final class _StationItem extends _ListItem {
  final RadioStation station;
  const _StationItem(this.station);
}

final class _AdItem extends _ListItem {
  final int adIndex;
  const _AdItem(this.adIndex);
}

// ── Incremental ad injection ──────────────────────────────────────────────────
//
// _AdInjectState carries continuation context across page calls so that ad
// slots land at globally correct positions regardless of page boundaries.
//
// Usage per page:
//   final newItems = injectAdsIncremental(pageStations, placement, state);
//   _mixedItems.addAll(newItems);  // append — never rebuild the whole list
//
// Fields:
//   adCount            — total ads inserted so far (used as adIndex for keys)
//   rowsSinceAd        — content rows since the last ad was inserted (or 0)
//   globalStationCount — total stations processed so far (across all pages)

class _AdInjectState {
  int adCount = 0;
  int rowsSinceAd = 0;
  int globalStationCount = 0;

  void reset() {
    adCount = 0;
    rowsSinceAd = 0;
    globalStationCount = 0;
  }
}

/// Processes [newStations] (one page slice) and returns the _ListItems to
/// append.  Mutates [state] in place so the next call continues seamlessly.
List<_ListItem> _injectAdsIncremental(
  List<RadioStation> newStations,
  InListPlacement p,
  _AdInjectState state,
) {
  if (!p.enabled || newStations.isEmpty) {
    state.globalStationCount += newStations.length;
    return [for (final s in newStations) _StationItem(s)];
  }

  final every = p.everyNItems.clamp(1, 9999);
  final firstPos = p.firstAdPosition; // 0 → use everyNItems rhythm only
  final maxAds = p.maxAds; // 0 → unlimited
  final result = <_ListItem>[];

  for (int i = 0; i < newStations.length; i++) {
    result.add(_StationItem(newStations[i]));
    state.rowsSinceAd++;

    // Absolute 1-based index of this station across all pages.
    final globalIdx = state.globalStationCount + i + 1;

    final hitFirst = firstPos > 0 && globalIdx == firstPos;
    final hitRegular = firstPos > 0
        ? (globalIdx > firstPos && (globalIdx - firstPos) % every == 0)
        : state.rowsSinceAd >= every;

    if (hitFirst || hitRegular) {
      if (maxAds == 0 || state.adCount < maxAds) {
        result.add(_AdItem(state.adCount++));
        state.rowsSinceAd = 0;
      }
    }
  }

  state.globalStationCount += newStations.length;
  return result;
}

// ─────────────────────────────────────────────────────────────────────────────
//  RadioPlayerScreen
// ─────────────────────────────────────────────────────────────────────────────

class RadioPlayerScreen extends StatefulWidget {
  final Function(bool) onRecordingStatusChanged;
  final dynamic onNavigateToMp3Tab;
  final dynamic onNavigateToRecordings;

  const RadioPlayerScreen({
    Key? key,
    required this.onNavigateToMp3Tab,
    required this.onNavigateToRecordings,
    required this.onRecordingStatusChanged,
  }) : super(key: key);

  @override
  _RadioPlayerScreenState createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends State<RadioPlayerScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<RadioStation> _trendingStations = [];
  List<RadioStation> _forYouStations = [];

  String _searchQuery = '';
  String _selectedLanguage = 'All';
  bool _showScrollTop = false;

  Set<String> _favouriteIds = {};
  static const _prefsKey = 'favourite_station_ids';

  // Cached SharedPreferences instance — avoids getInstance() on every tap.
  SharedPreferences? _prefs;

  // Search debounce timer — prevents _filteredItems from running on every keystroke.
  Timer? _searchDebounce;

  int _stationTapCount = 0;
  final ValueNotifier<String?> _currentMediaIdVN = ValueNotifier<String?>(null);

  // ── Core data ─────────────────────────────────────────────────────────────
  // _allStations: the full cumulative station list, updated per page.
  // _mixedItems:  grows incrementally — each page appends stations + ad slots.
  //   Never rebuilt from scratch during streaming; only appended to.
  List<RadioStation> _allStations = [];
  List<_ListItem> _mixedItems = [];

  // ── Filter cache ──────────────────────────────────────────────────────────
  // _filteredItems() is O(n) and called in build(). We memoize by tracking
  // the last inputs; any change invalidates the cache.
  List<_ListItem>? _cachedFilteredItems;
  String _cacheQuery = '';
  String _cacheLanguage = '';

  // _injectState: persists the ad-injection cursor across page calls.
  //   adCount, rowsSinceAd, globalStationCount are updated per page so the
  //   next page continues placing ads at globally correct positions.
  final _AdInjectState _injectState = _AdInjectState();

  // _adPlacement: resolved from AdConfigProvider once the provider is ready.
  //   Null until the provider is initialised.
  InListPlacement? _adPlacement;

  // _adsInjected: true after _onLoadComplete fires — guards against
  //   overwriting the finalised list if stationsNotifier fires again.
  bool _adsInjected = false;

  // _isLoaded: true once at least one station page has arrived.
  //   Switches the body from shimmer → real list.
  bool _isLoaded = false;

  // Ad flags — snapshotted once in _onLoadComplete, never re-read in build().
  bool _showBanner = false;
  bool _showInterstitial = false;
  int _interstitialEvery = 5;

  // Theme — cached so build() never subscribes to ThemeProvider or Theme.
  bool _isDark = false;

  // ── Subscriptions ─────────────────────────────────────────────────────────
  StreamSubscription<MediaItem?>? _mediaItemSub;
  late final VoidCallback _loadCompleteListener;
  late final VoidCallback _stationsListener;
  /// Re-runs [_onLoadComplete] when [AdConfigProvider] finishes after deferred startup
  /// so banners / in-feed ads appear (stations often load before analytics HTTP returns).
  late final VoidCallback _adConfigListener;
  Timer? _stationsUiDebounce;

  static const List<String> _languageFilters = [
    'All',
    'Telugu',
    'Arabic',
    'Tamil',
    'Hindi',
    'English',
    'Kannada',
    'Malayalam',
    'Punjabi',
    'Bengali',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavourites();
    _scrollController.addListener(_onScroll);

    // ── Listener 1: stationsNotifier ─────────────────────────────────────────
    // Fires on every page arrival. Renders stations immediately without ads,
    // replacing shimmer as soon as the first page is available.
    _stationsListener = _onStationsUpdated;
    stationsNotifier.addListener(_stationsListener);

    // ── Listener 2: stationsLoadingComplete ──────────────────────────────────
    // Fires once when all pages have merged. Injects ads into the final list.
    _loadCompleteListener = _onLoadComplete;
    stationsLoadingComplete.addListener(_loadCompleteListener);

    // Cache the current notifier value to avoid calling .value twice.
    final currentStations = stationsNotifier.value;

    // If the app resumed and data is already present, bootstrap both states.
    if (currentStations.isNotEmpty) {
      _onStationsUpdated();
    }
    if (stationsLoadingComplete.value && currentStations.isNotEmpty) {
      _onLoadComplete();
    }

    // Track now-playing for the NOW PLAYING badge — this setState is safe
    // because it only updates a String?, not list structure.
    _mediaItemSub = globalRadioAudioHandler.mediaItem.listen((item) {
      _currentMediaIdVN.value = item?.id;
    });

    _adConfigListener = () {
      if (!mounted) return;
      if (!adConfigProvider.initialized) return;
      if (!stationsLoadingComplete.value) return;
      if (stationsNotifier.value.isEmpty) return;
      _onLoadComplete();
      _maybePreloadRadioInterstitial();
    };
    adConfigProvider.addListener(_adConfigListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePreloadRadioInterstitial();
    });
  }

  void _maybePreloadRadioInterstitial() {
    if (!mounted) return;
    final adConfig = context.read<AdConfigProvider>();
    if (adConfig.isInterstitialEnabled(AdScreen.radio)) {
      InterstitialAdManager.preload();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe place to read inherited widgets — called after initState and
    // whenever dependencies change. We cache _isDark so build() never
    // calls Provider.of / Theme.of (both register listeners that cause
    // spurious rebuilds during station page loading → crash).
    final tp = Provider.of<ThemeProvider>(context, listen: false);
    final newDark = tp.isDarkMode;
    if (newDark != _isDark) {
      _isDark = newDark;
      // Only rebuild if actually mounted and the value changed.
      if (mounted) setState(() {});
    }
  }

  /// Called on every stationsNotifier change (one new page has arrived).
  ///
  /// [stationsNotifier.value] is the CUMULATIVE list (all pages so far).
  /// We update visible stations progressively, but defer in-feed ad injection
  /// until [_onLoadComplete] so ad widgets are not churned while pages stream in.
  /// This keeps ad slots stable and avoids "Ad ... could not be found/disposed"
  /// errors seen during initial launch.
  void _onStationsUpdated() {
    if (!mounted) return;
    final all = stationsNotifier.value;
    if (all.isEmpty) return;
    if (_adsInjected) return; // final pass already done; don't overwrite
    // First page should appear immediately; subsequent page bursts are batched.
    if (!_isLoaded) {
      _applyStationsSnapshot(all);
      return;
    }
    _stationsUiDebounce?.cancel();
    _stationsUiDebounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted || _adsInjected) return;
      _applyStationsSnapshot(stationsNotifier.value);
    });
  }

  void _applyStationsSnapshot(List<RadioStation> all) {
    if (!mounted) return;
    setState(() {
      _allStations = List.unmodifiable(all);
      _mixedItems = [for (final s in all) _StationItem(s)];
      _isLoaded = true;
      _cachedFilteredItems = null; // invalidate filter cache
    });
  }

  /// Called exactly once when stationsLoadingComplete becomes true.
  ///
  /// At this point stationsNotifier.value is the fully-merged final list.
  /// We do one last incremental pass over any tail stations not yet rendered
  /// (edge case: final page arrives after _onStationsUpdated's last call),
  /// snapshot ad-flags from the provider, and set _adsInjected = true so
  /// _onStationsUpdated ignores any further spurious notifier fires.
  void _onLoadComplete() {
    if (!stationsLoadingComplete.value) return;
    if (!mounted) return;
    _stationsUiDebounce?.cancel();

    final adConfig = context.read<AdConfigProvider>();
    final all = List<RadioStation>.unmodifiable(stationsNotifier.value);
    final placement = adConfig.stationsListPlacement(AdScreen.radio);
    _adPlacement = placement;

    _injectState.reset();
    final finalMixed = _injectAdsIncremental(all.toList(), placement, _injectState);

    // Build "For You" from a random sample of stations and "Trending"
    // from a different sample so they feel distinct and meaningful.
    final rng = Random();
    final shuffled = all.toList()..shuffle(rng);
    final forYou = shuffled.take(6).toList();
    // Trending: take 6 from the opposite end of the shuffle
    final trending = (shuffled.length > 6)
        ? shuffled.sublist(shuffled.length - 6)
        : shuffled.reversed.toList();

    setState(() {
      _allStations = all;
      _mixedItems = finalMixed;
      _adsInjected = true;
      _isLoaded = true;
      _cachedFilteredItems = null; // invalidate filter cache
      _showBanner = adConfig.isBannerEnabled(AdScreen.radio);
      _showInterstitial = adConfig.isInterstitialEnabled(AdScreen.radio);
      _interstitialEvery = adConfig.interstitialEveryNTaps(AdScreen.radio);

      _forYouStations = forYou;
      _trendingStations = trending;
    });
  }

  void _onScroll() {
    final show = _scrollController.offset > 300;
    if (show != _showScrollTop) setState(() => _showScrollTop = show);
  }

  @override
  void dispose() {
    _stationsUiDebounce?.cancel();
    adConfigProvider.removeListener(_adConfigListener);
    stationsNotifier.removeListener(_stationsListener);
    stationsLoadingComplete.removeListener(_loadCompleteListener);
    _mediaItemSub?.cancel();
    _currentMediaIdVN.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ── Favourites ─────────────────────────────────────────────────────────────

  Future<SharedPreferences> get _sharedPrefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> _loadFavourites() async {
    final prefs = await _sharedPrefs;
    final saved = prefs.getStringList(_prefsKey) ?? [];
    if (mounted) setState(() => _favouriteIds = saved.toSet());
  }

  Future<void> _toggleFavourite(RadioStation station) async {
    HapticFeedback.lightImpact();
    setState(() {
      if (_favouriteIds.contains(station.id)) {
        _favouriteIds.remove(station.id);
      } else {
        _favouriteIds.add(station.id);
      }
    });
    final prefs = await _sharedPrefs;
    await prefs.setStringList(_prefsKey, _favouriteIds.toList());
  }

  void _navigateToCategory(String title, List<RadioStation> stations) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StationCategoryScreen(
          title: title,
          stations: stations,
          audioHandler: globalRadioAudioHandler,
        ),
      ),
    );
  }

  void _playStation(RadioStation station) {
    HapticFeedback.lightImpact();
    globalRadioAudioHandler.playFromMediaId(station.id);
    if (_showInterstitial) {
      _stationTapCount++;
      if (_stationTapCount % _interstitialEvery == 0) {
        InterstitialAdManager.show();
      }
    }
  }

  // ── Filtering ──────────────────────────────────────────────────────────────
  // Filtering operates on _allStations (the full snapshot), not stationsNotifier.
  // When a filter is active the result is a subset of stations — ads are
  // re-injected into that subset using a fresh _AdInjectState so placement
  // is correct relative to the filtered list (not the full global list).
  //
  // Results are memoized by (_searchQuery, _selectedLanguage) to avoid
  // running O(n) work on every build() call (e.g. from the media-item stream).

  List<_ListItem> _filteredItems() {
    if (_mixedItems.isEmpty) return const [];

    // Return cached result if inputs haven't changed.
    if (_cachedFilteredItems != null &&
        _cacheQuery == _searchQuery &&
        _cacheLanguage == _selectedLanguage) {
      return _cachedFilteredItems!;
    }

    Iterable<RadioStation> stations = _allStations;

    if (_selectedLanguage != 'All') {
      final q = _selectedLanguage.toLowerCase();
      stations = stations.where(
        (s) =>
            (s.language?.toLowerCase().contains(q) ?? false) ||
            s.name.toLowerCase().contains(q) ||
            (s.genre?.toLowerCase().contains(q) ?? false) ||
            (s.page?.toLowerCase().contains(q) ?? false) ||
            (s.state?.toLowerCase().contains(q) ?? false),
      );
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      stations = stations.where(
        (s) =>
            s.name.toLowerCase().contains(q) ||
            (s.state?.toLowerCase().contains(q) ?? false) ||
            (s.language?.toLowerCase().contains(q) ?? false) ||
            (s.genre?.toLowerCase().contains(q) ?? false) ||
            (s.page?.toLowerCase().contains(q) ?? false),
      );
    }

    final filtered = stations.toList();

    List<_ListItem> result;

    // No filter active — return the pre-built mixed list with ads as-is.
    if (filtered.length == _allStations.length) {
      result = _mixedItems;
    } else {
      // Filter active — re-inject ads into the filtered subset.
      // Use a fresh _AdInjectState so the main list's cursor is not affected,
      // and so ad positions are relative to the filtered list length.
      final placement = _adPlacement ?? InListPlacement.disabled;
      if (!placement.enabled) {
        result = [for (final s in filtered) _StationItem(s)];
      } else {
        result = _injectAdsIncremental(filtered, placement, _AdInjectState());
      }
    }

    // Update cache.
    _cachedFilteredItems = result;
    _cacheQuery = _searchQuery;
    _cacheLanguage = _selectedLanguage;
    return result;
  }

  void _scrollToTop() {
    HapticFeedback.lightImpact();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    // Reset all state so the progressive+incremental cycle restarts cleanly.
    setState(() {
      _isLoaded = false;
      _adsInjected = false;
      _allStations = [];
      _mixedItems = [];
      _adPlacement = null;
      _cachedFilteredItems = null;
      _injectState.reset();
    });
    try {
      await adConfigProvider.refresh(isPremiumUser: isPremiumUser.value);
      await syncRemoteStations(forceRefresh: true);
      // syncRemoteStations fires page 1 immediately via stationsNotifier,
      // then _loadRemainingStationsInBackground fires subsequent pages.
      // Each fire triggers _onStationsUpdated; final fire triggers _onLoadComplete.
    } finally {
      // Refresh complete — _onStationsUpdated and _onLoadComplete will
      // update _isLoaded and _adsInjected via stationsNotifier.
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  //
  //  Widget tree structure is constant across all phases:
  //    Scaffold → Stack → RefreshIndicator → CustomScrollView
  //      slivers: [SliverAppBar, SliverToBoxAdapter(body), footer]
  //    body = shimmer (phase 1) OR Column with ListView.builder (phases 2-3)
  //
  //  Phase 1 — _isLoaded=false:  shimmer shown, no stations yet
  //  Phase 2 — _isLoaded=true, _adsInjected=false:
  //            ListView.builder grows page by page with stations + inline ads
  //            at correct global positions, using incremental injection
  //  Phase 3 — _adsInjected=true:
  //            final ad-enriched list, itemCount frozen, ad flags active
  //
  //  Only ListView.builder's itemCount changes between rebuilds — the outer
  //  Column/Sliver skeleton stays identical → no _InactiveElements crash.
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // isDark and ad flags are stored as local state (_isDark, _showBanner, etc.).
    // We intentionally do NOT call Provider.of, context.watch, or Theme.of here.
    // Any of those register this widget as a listener and cause spurious rebuilds
    // during station page loading, which changes the body column structure mid-frame
    // and triggers the _InactiveElements.remove assertion.
    final isDark = _isDark;

    final items = _isLoaded ? _filteredItems() : <_ListItem>[];
    final stations = items
        .whereType<_StationItem>()
        .map((e) => e.station)
        .toList();
    final favourites = stations
        .where((s) => _favouriteIds.contains(s.id))
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          RefreshIndicator(
            color: const Color(0xFF7C4DFF),
            strokeWidth: 2.5,
            displacement: 60,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),

                // Single body sliver — always SliverToBoxAdapter, always present.
                SliverToBoxAdapter(
                  child: !_isLoaded
                      ? _buildShimmerBody(isDark)
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Banner ad
                            if (_showBanner) const BannerAdWidget(),
                            // Search
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                              child: _buildSearchBar(),
                            ),
                            // Language chips
                            _buildLanguageChips(),
                            // Favourites — stable Visibility to avoid tree structure changes
                            Visibility(
                              visible: favourites.isNotEmpty,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SectionHeader(
                                    title: '❤️ Favourites',
                                    onSeeAll: () => _navigateToCategory(
                                      'Favourites',
                                      favourites,
                                    ),
                                  ),
                                  ValueListenableBuilder<String?>(
                                    valueListenable: _currentMediaIdVN,
                                    builder: (context, currentId, _) {
                                      return HorizontalStationList(
                                        stations: favourites,
                                        currentMediaId: currentId,
                                        onPlay: _playStation,
                                        onRemoveFavourite: _toggleFavourite,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // For You
                            SectionHeader(
                              title: 'For You',
                              onSeeAll: () => _navigateToCategory(
                                'For You',
                                _forYouStations,
                              ),
                            ),
                            if (_forYouStations.isNotEmpty)
                              ValueListenableBuilder<String?>(
                                valueListenable: _currentMediaIdVN,
                                builder: (context, currentId, _) {
                                  return HorizontalStationList(
                                    stations: _forYouStations,
                                    currentMediaId: currentId,
                                    onPlay: _playStation,
                                  );
                                },
                              )
                            else
                              _buildShimmerCarousel(isDark),
                            // Trending
                            SectionHeader(
                              title: 'Trending Now',
                              onSeeAll: () => _navigateToCategory(
                                'Trending',
                                _trendingStations,
                              ),
                            ),
                            if (_trendingStations.isNotEmpty)
                              ValueListenableBuilder<String?>(
                                valueListenable: _currentMediaIdVN,
                                builder: (context, currentId, _) {
                                  return HorizontalStationList(
                                    stations: _trendingStations,
                                    currentMediaId: currentId,
                                    onPlay: _playStation,
                                  );
                                },
                              )
                            else
                              _buildShimmerCarousel(isDark),
                            // All Stations — tighter bottom padding so the vertical
                            // list sits closer to the title (matches carousel density).
                            SectionHeader(
                              title: 'All Stations',
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              onSeeAll: () =>
                                  _navigateToCategory('All Stations', stations),
                            ),
                            // Station list — regular ListView, not a sliver.
                            // Item count is fixed after _onLoadComplete.
                            // Keys on every tile prevent any element reuse issues.
                            items.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final item = items[index];
                                      final firstRow = index == 0;
                                      if (item is _AdItem) {
                                        return NativeInFeedAdTile(
                                          key: ValueKey('ad_${item.adIndex}'),
                                          margin: firstRow
                                              ? const EdgeInsets.fromLTRB(
                                                  16,
                                                  0,
                                                  16,
                                                  4,
                                                )
                                              : const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 4,
                                                ),
                                        );
                                      }
                                      final s = (item as _StationItem).station;
                                      return ValueListenableBuilder<String?>(
                                        valueListenable: _currentMediaIdVN,
                                        builder: (context, currentId, _) {
                                          return _buildVerticalTile(
                                            s,
                                            currentMediaId: currentId,
                                            tileKey: ValueKey('station_${s.id}'),
                                            tightenTop: firstRow,
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ],
                        ),
                ),

                // Footer — always present
                const SliverToBoxAdapter(child: SizedBox(height: 160)),
              ],
            ),
          ),

          // Scroll-to-top FAB
          Positioned(
            right: 16,
            bottom: 90,
            child: AnimatedScale(
              scale: _showScrollTop ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: _showScrollTop ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_showScrollTop,
                  child: FloatingActionButton.small(
                    heroTag: 'scroll_top_fab',
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
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Widget helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLanguageChips() {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _languageFilters.length,
        itemBuilder: (context, index) {
          final lang = _languageFilters[index];
          final isSelected = _selectedLanguage == lang;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedLanguage = lang;
                  _cachedFilteredItems = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.only(
                  left: 14,
                  right: isSelected && lang != 'All' ? 8 : 14,
                  top: 6,
                  bottom: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF7C4DFF)
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF7C4DFF)
                        : cs.outline.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : cs.onSurfaceVariant,
                      ),
                    ),
                    if (isSelected && lang != 'All') ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedLanguage = 'All';
                            _cachedFilteredItems = null;
                          });
                        },
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.radio_outlined,
            size: 64,
            color: cs.primary.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No stations match "$_searchQuery"'
                : 'No $_selectedLanguage stations found',
            textAlign: TextAlign.center,
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or language filter',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedLanguage = 'All';
                _cachedFilteredItems = null;
              });
            },
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7C4DFF),
              side: const BorderSide(color: Color(0xFF7C4DFF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mq = MediaQuery.of(context);
    final wideLandscape =
        mq.orientation == Orientation.landscape && mq.size.width >= 600;
    final titlePadBottom = wideLandscape ? 8.0 : 16.0;
    final discoverSize = wideLandscape ? 20.0 : 24.0;
    return SliverAppBar(
      toolbarHeight: wideLandscape ? 48 : kToolbarHeight,
      expandedHeight: wideLandscape ? 86 : 130,
      pinned: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      backgroundColor: cs.surface,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 16, bottom: titlePadBottom),
        background: isDark
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A0A3E), Color(0xFF0D0D0D)],
                  ),
                ),
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF5F0FF), Colors.white],
                  ),
                ),
              ),
        title: GestureDetector(
          onTap: _scrollToTop,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(
                'Discover',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Outfit',
                      color: cs.onSurface,
                      fontSize: discoverSize,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (_favouriteIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '${_favouriteIds.length}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _searchQuery.isNotEmpty
              ? cs.primary.withValues(alpha: 0.45)
              : cs.outline.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          // Debounce: wait 200 ms after the last keystroke before filtering.
          // This avoids running O(n) _filteredItems on every character typed.
          _searchDebounce?.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 200), () {
            if (mounted) {
              setState(() {
                _searchQuery = v;
                _cachedFilteredItems = null;
              });
            }
          });
        },
        style: tt.bodyLarge?.copyWith(color: cs.onSurface),
        decoration: InputDecoration(
          icon: Icon(
            Icons.search,
            color: _searchQuery.isNotEmpty
                ? cs.primary
                : cs.onSurfaceVariant,
          ),
          hintText: 'Search stations...',
          hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          border: InputBorder.none,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: cs.onSurfaceVariant,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchDebounce?.cancel();
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _cachedFilteredItems = null;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  // ── Station tile helpers ───────────────────────────────────────────────────

  /// Builds the 54×54 logo with loading/error fallbacks and a live-dot overlay.
  Widget _buildStationLogo(RadioStation station, {required bool isPlaying}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: (station.logoUrl != null && station.logoUrl!.isNotEmpty)
              ? Image.network(
                  station.logoUrl!,
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 54,
                      height: 54,
                      color: const Color(0xFF7C4DFF).withOpacity(0.08),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF7C4DFF),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (c, e, s) => _logoPlaceholder(),
                )
              : _logoPlaceholder(),
        ),
        if (isPlaying) Positioned(right: 0, top: 0, child: _LiveDot()),
      ],
    );
  }

  Widget _logoPlaceholder() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF7C4DFF).withOpacity(0.1),
      ),
      child: const Icon(Icons.radio, color: Color(0xFF7C4DFF)),
    );
  }

  /// Builds the "NOW PLAYING" badge shown in the subtitle row.
  Widget _buildNowPlayingBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFF7C4DFF).withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'NOW PLAYING',
        style: TextStyle(
          color: Color(0xFF7C4DFF),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildVerticalTile(
    RadioStation station, {
    required String? currentMediaId,
    Key? tileKey,
    bool tightenTop = false,
  }) {
    final isPlaying = station.id == currentMediaId;
    final isFav = _favouriteIds.contains(station.id);
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      key: tileKey,
      duration: const Duration(milliseconds: 300),
      margin: tightenTop
          ? const EdgeInsets.fromLTRB(16, 0, 16, 4)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isPlaying
            ? const Color(0xFF7C4DFF).withOpacity(0.08)
            : Colors.transparent,
        border: isPlaying
            ? Border.all(
                color: const Color(0xFF7C4DFF).withOpacity(0.25),
                width: 1,
              )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: _buildStationLogo(station, isPlaying: isPlaying),
        title: Text(
          station.name,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w600,
            color: isPlaying
                ? const Color(0xFF7C4DFF)
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Row(
          children: [
            if (isPlaying) _buildNowPlayingBadge(),
            Expanded(
              child: Text(
                station.language ?? 'Global',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Favourite button — InkWell gives better touch feedback and
            // a larger, more comfortable hit area than a bare GestureDetector.
            InkWell(
              onTap: () => _toggleFavourite(station),
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.red.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(isFav),
                    color: isFav ? Colors.red : cs.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            isPlaying
                ? EqualizerIcon(isDark: isDark, size: 40, isPlaying: true)
                : Icon(
                    Icons.play_arrow_rounded,
                    color: cs.onSurfaceVariant,
                  ),
          ],
        ),
        onTap: () => _playStation(station),
      ),
    );
  }

  Widget _buildShimmerCarousel(bool isDark) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(right: 16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: 140, height: 140, radius: 20, isDark: isDark),
                const SizedBox(height: 8),
                _ShimmerBox(width: 100, height: 16, radius: 4, isDark: isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerBody(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _ShimmerBox(width: 160, height: 30, radius: 8, isDark: isDark),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: _ShimmerBox(
            width: double.infinity,
            height: 48,
            radius: 18,
            isDark: isDark,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: _ShimmerBox(
            width: 260,
            height: 36,
            radius: 20,
            isDark: isDark,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: _ShimmerBox(width: 100, height: 18, radius: 6, isDark: isDark),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _ShimmerBox(
                width: 110,
                height: 130,
                radius: 14,
                isDark: isDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < 8; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _ShimmerBox(width: 54, height: 54, radius: 10, isDark: isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(
                        width: double.infinity,
                        height: 14,
                        radius: 4,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 6),
                      _ShimmerBox(
                        width: 100,
                        height: 11,
                        radius: 4,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 160),
      ],
    );
  }
}

// ── Animated LIVE dot ──────────────────────────────────────────────────────────
class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _scale = Tween<double>(
      begin: 1.0,
      end: 2.2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(
      begin: 0.7,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF7C4DFF),
                  ),
                ),
              ),
            ),
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer box ────────────────────────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  final double width, height, radius;
  final bool isDark;
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.isDark,
  });
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFE8E8F0);
    // Avoid pure white in dark mode — it flashed as a bright strip during shimmer.
    final highlight =
        widget.isDark ? const Color(0xFF2E2E3E) : Colors.white;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: [base, highlight, base],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}
