import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grradio/api/world_radio_service.dart';
import 'package:grradio/main.dart';
import 'package:grradio/radio/radio_handler_base.dart';
import 'package:grradio/radio/radiostation.dart';
import 'package:grradio/widgets/radio_animated_icons.dart';

class WorldRadioScreen extends StatefulWidget {
  final VoidCallback onNavigateToPlayer;

  const WorldRadioScreen({Key? key, required this.onNavigateToPlayer})
    : super(key: key);

  @override
  State<WorldRadioScreen> createState() => _WorldRadioScreenState();
}

class _WorldRadioScreenState extends State<WorldRadioScreen> {
  final _searchController = TextEditingController();
  final _worldRadioService = WorldRadioService();

  List<CountryCount> _countries = [];
  bool _isLoadingCountries = true;

  CountryCount? _selectedCountry;
  List<RadioStation> _countryStations = [];
  bool _isLoadingCountryStations = false;

  List<RadioStation> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';
  Timer? _searchDebounce;

  final ValueNotifier<String?> _currentMediaIdVN = ValueNotifier<String?>(null);
  late StreamSubscription _playbackSubscription;
  late StreamSubscription _mediaItemSubscription;

  @override
  void initState() {
    super.initState();
    _fetchCountries();

    _mediaItemSubscription = globalRadioAudioHandler.mediaItem.listen((item) {
      if (mounted) {
        _currentMediaIdVN.value = item?.id;
      }
    });

    _playbackSubscription = globalRadioAudioHandler.playbackState.listen((
      state,
    ) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _mediaItemSubscription.cancel();
    _playbackSubscription.cancel();
    _currentMediaIdVN.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    setState(() => _isLoadingCountries = true);
    try {
      final countries = await _worldRadioService.fetchCountries();
      if (mounted) {
        setState(() {
          _countries = countries;
          _isLoadingCountries = false;
        });
      }
    } catch (e) {
      print("Failed to fetch countries: $e");
      if (mounted) setState(() => _isLoadingCountries = false);
    }
  }

  Future<void> _fetchCountryStations(CountryCount country) async {
    setState(() {
      _selectedCountry = country;
      _isLoadingCountryStations = true;
      _countryStations = [];
    });
    try {
      final stations = await _worldRadioService.fetchStationsByCountry(
        country.countrycode ?? country.country,
        limit: 100,
      );
      if (mounted) {
        setState(() {
          _countryStations = stations;
          _isLoadingCountryStations = false;
        });
      }
    } catch (e) {
      print("Failed to fetch country stations: $e");
      if (mounted) setState(() => _isLoadingCountryStations = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _searchQuery = '';
          _searchResults = [];
        });
        return;
      }
      setState(() {
        _searchQuery = query;
        _isSearching = true;
      });
      try {
        final results = await _worldRadioService.searchStations(
          query,
          limit: 30,
        );
        if (mounted && _searchQuery == query) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        print("Search failed: $e");
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  void _playStation(RadioStation station) {
    HapticFeedback.lightImpact();
    pauseMp3IfPlaying(); // Ensure mutually exclusive playback

    // Play using global radio handler
    (globalRadioAudioHandler as RadioHandlerBase).playStation(station);
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery;
      try {
        final results = await _worldRadioService.searchStations(
          query,
          limit: 30,
        );
        if (mounted && _searchQuery == query) {
          setState(() {
            _searchResults = results;
          });
        }
      } catch (e) {
        print("Refresh search failed: $e");
      }
    } else if (_selectedCountry != null) {
      await _fetchCountryStations(_selectedCountry!);
    } else {
      await _fetchCountries();
    }
  }

  Widget _buildVerticalTile(RadioStation station, String? currentMediaId) {
    final isPlaying = station.id == currentMediaId;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: (station.logoUrl != null && station.logoUrl!.isNotEmpty)
              ? Image.network(
                  station.logoUrl!,
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _logoPlaceholder(),
                )
              : _logoPlaceholder(),
        ),
        title: Text(
          station.name,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w600,
            color: isPlaying ? const Color(0xFF7C4DFF) : cs.onSurface,
          ),
        ),
        subtitle: Text(
          station.state ?? station.language ?? 'Global',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: isPlaying
            ? EqualizerIcon(isDark: isDark, size: 40, isPlaying: true)
            : Icon(Icons.play_arrow_rounded, color: cs.onSurfaceVariant),
        onTap: () => _playStation(station),
      ),
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
      child: const Icon(Icons.public, color: Color(0xFF7C4DFF)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          "World Radio",
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // AppBar configuration remains
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_selectedCountry != null) {
            setState(() {
              _selectedCountry = null;
              _countryStations = [];
            });
            return false;
          }
          return true;
        },
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search world radio stations...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildDefaultView()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultView() {
    if (_selectedCountry != null) {
      return _buildCountryStationsView();
    }

    final cs = Theme.of(context).colorScheme;

    // Always wrap in RefreshIndicator so pull-to-refresh works even during
    // loading or when the list is empty (e.g. after a failed network call).
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFF7C4DFF),
      child: _isLoadingCountries
          ? const Center(child: CircularProgressIndicator())
          : _countries.isEmpty
              ? ListView(
                  // A scrollable child is required for RefreshIndicator to
                  // detect the drag gesture when there is no data.
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text("No countries available.\nPull down to retry.")),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Color(0xFF7C4DFF),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        country.country,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      subtitle: Text('${country.stationCount} stations'),
                      trailing:
                          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _fetchCountryStations(country);
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildCountryStationsView() {
    return Column(
      children: [
        ListTile(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _selectedCountry = null;
                _countryStations = [];
              });
            },
          ),
          title: Text(
            _selectedCountry!.country,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color(0xFF7C4DFF),
            child: _isLoadingCountryStations
                ? const Center(child: CircularProgressIndicator())
                : _countryStations.isEmpty
                    ? ListView(
                        // Scrollable so RefreshIndicator detects the drag
                        // gesture even when there is nothing to show.
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              "No stations found.\nPull down to retry.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                    : ValueListenableBuilder<String?>(
                        valueListenable: _currentMediaIdVN,
                        builder: (context, currentId, _) {
                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _countryStations.length,
                            itemBuilder: (context, index) {
                              return _buildVerticalTile(
                                _countryStations[index],
                                currentId,
                              );
                            },
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    // Always wrap in RefreshIndicator so the user can pull-to-refresh even
    // when the search returned no results (e.g. to retry after a timeout).
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFF7C4DFF),
      child: _searchResults.isEmpty
          ? ListView(
              // A scrollable child is required for RefreshIndicator to
              // detect the drag gesture when there is no data.
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    "No stations found for '$_searchQuery'.\nPull down to retry.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : ValueListenableBuilder<String?>(
              valueListenable: _currentMediaIdVN,
              builder: (context, currentId, _) {
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return _buildVerticalTile(_searchResults[index], currentId);
                  },
                );
              },
            ),
    );
  }
}
