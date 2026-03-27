import 'package:flutter/material.dart';
import 'package:grradio/masstamilan/data/masstelugualbum.dart';
import 'package:grradio/masstamilan/data/massteluguservice.dart';
import 'package:grradio/masstamilan/presentation/albumdetailsview.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:grradio/main.dart';
import 'package:grradio/l10n/app_localizations.dart';

class AlbumListPage extends StatefulWidget {
  final String language;
  final String? serviceRoute;

  const AlbumListPage({
    super.key,
    required this.language,
    required this.serviceRoute,
  });

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> {
  final AlbumApi api = AlbumApi();
  final AnalyticsServiceAPI _analyticsService = AnalyticsServiceAPI();

  final List<Album> _albums = [];
  Pagination? _pagination;

  bool _isLoading = false;
  bool _error = false;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPage("");
  }

  Future<void> _loadPage(String pageUrl) async {
    setState(() {
      _isLoading = true;
      _error = false;
    });

    try {
      final res = await api.fetchAlbums(
        relativeUrl: pageUrl,
        language: widget.language,
        serviceRoute: widget.serviceRoute,
      );

      setState(() {
        _albums.clear(); // refresh list for each page
        _albums.addAll(res.albums);
        _pagination = res.pagination;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Search albums...",
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: InputBorder.none,
                  ),
                ),
              )
            : Text(AppLocalizations.of(context)!.masstamilanTitle),

        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),

          if (_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                final query = _searchController.text.trim();
                if (query.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter search text")),
                  );
                  return;
                }

                _analyticsService.logActivity(
                  deviceId!,
                  "Search Masstamilan Albums",
                  details: {"query": query, "language": widget.language},
                );

                _loadPage("/search?keyword=$query&commit=Search");
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
                _loadPage("");
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (_error)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Failed to load albums'),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                final album = _albums[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _analyticsService.logActivity(
                        deviceId!,
                        "Select Masstamilan Album",
                        details: {
                          "albumName": album.albumName,
                          "albumArt": album.albumArt,
                          "language": widget.language,
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlbumDetailsPage(
                            albumUrl: album.link,
                            language: widget.language,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              album.albumArt,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  album.albumName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                if (album.starring != null &&
                                    album.starring!.isNotEmpty)
                                  _info("Starring", album.starring),

                                if (album.music != null &&
                                    album.music!.isNotEmpty)
                                  _info("Music", album.music),

                                if (album.director != null &&
                                    album.director!.isNotEmpty)
                                  _info("Director", album.director),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          if (!_isLoading && _pagination != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildPagination(),
            ),
        ],
      ),
    );
  }

  Widget _info(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    if (_pagination == null) return const SizedBox();

    return Wrap(
      spacing: 8,
      children: _pagination!.pages.map((p) {
        final isCurrent = p.page == _pagination!.currentPage;

        return ElevatedButton(
          onPressed: isCurrent
              ? null
              : () {
                  _analyticsService.logActivity(
                    deviceId!,
                    "Navigate Masstamilan Pagination",
                    details: {"page": p.page, "language": widget.language},
                  );
                  _loadPage(p.url!);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrent ? Colors.blue : Colors.grey[300],
            foregroundColor: isCurrent ? Colors.white : Colors.black,
          ),
          child: Text("${p.page}"),
        );
      }).toList(),
    );
  }
}
