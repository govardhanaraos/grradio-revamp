import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:grradio/ads/ad_config_provider.dart';
import 'package:grradio/ads/banner_ad_widget.dart';
import 'package:grradio/main.dart';
import 'package:grradio/theme/app_theme.dart';
import 'package:grradio/theme/app_theme_context.dart';
import 'package:grradio/more/downloadmanagerscreen.dart';
import 'package:grradio/mp3download/mp3_models.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:grradio/api/analytics_service_api.dart';

class OldMp3Browser extends StatefulWidget {
  final String initialUrl;

  const OldMp3Browser({Key? key, required this.initialUrl}) : super(key: key);

  @override
  _OldMp3BrowserState createState() => _OldMp3BrowserState();
}

class _OldMp3BrowserState extends State<OldMp3Browser> {
  late String _currentUrl;
  List<DirectoryItem> _directories = [];
  List<Mp3File> _mp3Files = [];
  List<PaginationItem> _pagination = [];
  bool _isLoading = false;
  List<String> _breadcrumbs = [];
  final AnalyticsServiceAPI _analyticsService = AnalyticsServiceAPI();

  Map<String, double> _downloadProgress = {};
  Map<String, bool> _isDownloading = {};

  final ValueNotifier<Map<String, double>> _downloadProgressNotifier =
      ValueNotifier<Map<String, double>>({});
  final ValueNotifier<Map<String, bool>> _isDownloadingNotifier =
      ValueNotifier<Map<String, bool>>({});
  final ValueNotifier<Map<String, int>> _downloadReceivedNotifier =
      ValueNotifier<Map<String, int>>({});
  final ValueNotifier<Map<String, int>> _downloadTotalNotifier =
      ValueNotifier<Map<String, int>>({});
  final Map<String, CancelToken> _cancelTokens = {};

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _loadPage(_currentUrl);
  }

  Future<void> _loadPage(String url) async {
    setState(() {
      _isLoading = true;
      _directories.clear();
      _mp3Files.clear();
      _pagination.clear();
    });

    try {
      print('🔍 Loading URL: $url');
      _analyticsService.logActivity(
        deviceId!,
        'Old MP3 Browser: Load Page',
        details: {'url': url},
      );
      final response = await http.get(Uri.parse(url));
      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        _parseHtml(document, url);

        // Update breadcrumbs
        if (url != widget.initialUrl) {
          final uri = Uri.parse(url);
          final pathSegments = uri.pathSegments;
          _breadcrumbs = ['Home'] + pathSegments;
        } else {
          _breadcrumbs = ['Home'];
        }

        // Debug summary
        print('📊 Parsing Summary:');
        print('   📁 Directories: ${_directories.length}');
        print('   🎵 MP3 Files: ${_mp3Files.length}');
        print('   📄 Pagination: ${_pagination.length}');
      } else {
        _showSnackbar(
          'Failed to load page: ${response.statusCode}',
          Colors.red,
        );
      }
    } catch (e) {
      print('❌ Error loading page: $e');
      _showSnackbar('Error loading page: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _parseHtml(dom.Document document, String baseUrl) {
    final anchorTags = document.querySelectorAll('a');
    print('🔗 Found ${anchorTags.length} anchor tags');

    final processedUrls = <String>{}; // To avoid duplicates

    for (final anchor in anchorTags) {
      final href = anchor.attributes['href'];
      final text = anchor.text.trim();

      if (href != null && href.isNotEmpty) {
        final fullUrl = _buildFullUrl(href, baseUrl);

        // Skip if already processed this URL
        if (processedUrls.contains(fullUrl)) {
          continue;
        }
        processedUrls.add(fullUrl);

        print('🔍 Processing link: $href -> $fullUrl');
        print('   Text: "$text"');

        // Parse in correct order: Pagination first, then directories, then MP3 files

        // 1. Check for PAGINATION first (contains 'page=' and usually also 'd=')
        if (href.contains('page=')) {
          print('   📄 Found PAGINATION link');
          _pagination.add(
            PaginationItem(
              name: text.isEmpty ? 'Page ${_pagination.length + 1}' : text,
              url: fullUrl,
            ),
          );
        }
        // 2. Check for DIRECTORIES (contains '?d=' but NOT 'page=')
        else if (href.contains('?d=') && !href.contains('page=')) {
          print('   📁 Found DIRECTORY link');
          _directories.add(
            DirectoryItem(
              name: text.isEmpty ? 'Unnamed Directory' : text,
              url: fullUrl,
            ),
          );
        }
        // 3. Check for MP3 FILES (contains '?f=' and mp3 extension or text)
        else if (href.contains('?f=') /*&&
            (href.toLowerCase().contains('.mp3') ||
                text.toLowerCase().contains('.mp3') ||
                _looksLikeMp3Link(href, text))*/ ) {
          print('   🎵 Found MP3 FILE link');
          _mp3Files.add(
            Mp3File(
              name: text.isEmpty
                  ? _extractFileNameFromUrl(fullUrl)
                  : _findParentWithBgClass(anchor),
              url: fullUrl,
            ),
          );
        }
        // 4. Additional check for MP3 files that might not have ?f= but have .mp3
        /* else if (href.toLowerCase().contains('.mp3') && !href.contains('?')) {
          print('   🎵 Found direct MP3 FILE link');
          _mp3Files.add(
            Mp3File(
              name: text.isEmpty ? _extractFileNameFromUrl(fullUrl) : text,
              url: fullUrl,
            ),
          );
        }*/
      }
    }
  }

  String _findParentWithBgClass(dom.Element anchorElement) {
    dom.Element? parent = anchorElement.parent;

    while (parent != null) {
      print(
        '🔍 Checking parent: ${parent.localName} with classes: ${parent.classes}',
      );
      String sizeText = '';
      // Check if this parent is a div with class "bg"
      if (parent.localName == 'div' && parent.classes.contains('bg')) {
        print('✅ Found parent div with bg class');
        final anchor = parent.querySelector('a[href*="f="]');
        sizeText = (anchor != null) ? anchor.text?.trim() ?? '' : '';
        final allElements = parent.querySelectorAll('*');
        bool foundTargetAnchor = false;

        for (final element in allElements) {
          if (element == anchorElement) {
            foundTargetAnchor = true;
            continue;
          }

          if (foundTargetAnchor && element.localName == 'small') {
            print(' element.localName: $element.localName');
            sizeText = sizeText + (element.text?.trim() ?? '');
            print(' sizeText $sizeText');
          }
        }

        // Concatenate anchor text with size text
        return sizeText.trim();
      }
    }

    print('❌ No parent div with bg class found');
    return '';
  }

  bool _looksLikeMp3Link(String href, String text) {
    // Check if the link looks like it leads to an MP3 file
    final lowerHref = href.toLowerCase();
    final lowerText = text.toLowerCase();

    return lowerHref.contains('download') ||
        lowerHref.contains('mp3') ||
        lowerText.contains('download') ||
        lowerText.contains('mp3') ||
        lowerText.endsWith('.mp3');
  }

  String _extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      if (path.isNotEmpty) {
        final fileName = path.split('/').last;
        return fileName.isNotEmpty ? fileName : 'Unknown File';
      }
    } catch (e) {
      print('Error extracting filename from URL: $e');
    }
    return 'Unknown File';
  }

  String _buildFullUrl(String relativeUrl, String baseUrl) {
    print('🔄 Building full URL from:');
    print('   Base: $baseUrl');
    print('   Relative: $relativeUrl');

    // If it's already a full URL, return as is
    if (relativeUrl.startsWith('http')) {
      print('   ✅ Already full URL');
      return relativeUrl;
    }

    final baseUri = Uri.parse(baseUrl);

    // Handle query parameters properly
    if (relativeUrl.startsWith('?')) {
      // This is a query string that should replace the current query
      final newUrl =
          '${baseUri.scheme}://${baseUri.host}${baseUri.path}$relativeUrl';
      print('   🔧 Query URL built: $newUrl');
      return newUrl;
    } else if (relativeUrl.startsWith('/')) {
      // Absolute path on same domain
      final newUrl = '${baseUri.scheme}://${baseUri.host}$relativeUrl';
      print('   🔧 Absolute path built: $newUrl');
      return newUrl;
    } else {
      // Relative path - handle properly
      final basePath = baseUri.path;
      String newPath;

      if (basePath.isEmpty || basePath == '/') {
        newPath = '/$relativeUrl';
      } else if (basePath.endsWith('/')) {
        newPath = '$basePath$relativeUrl';
      } else {
        // Remove the last path segment and append the relative URL
        final pathSegments = basePath.split('/')..removeLast();
        newPath = '${pathSegments.join('/')}/$relativeUrl';
      }

      final newUrl = '${baseUri.scheme}://${baseUri.host}$newPath';
      print('   🔧 Relative path built: $newUrl');
      return newUrl;
    }
  }

  Future<void> _downloadMp3(Mp3File mp3File) async {
    print('⬇️ Starting download: ${mp3File.name}');
    print('   URL: ${mp3File.url}');

    setState(() {
      _isLoading = true;
    });

    try {
      // For Android 13+ we use READ_MEDIA_AUDIO permission
      PermissionStatus status;

      if (await Permission.storage.isGranted) {
        status = PermissionStatus.granted;
      } else {
        // Request the appropriate permission based on Android version
        if (await Permission.manageExternalStorage.isRestricted) {
          // For Android 11+, we need to use media permissions
          status = await Permission.mediaLibrary.request();
        } else {
          status = await Permission.storage.request();
        }
      }

      print('📋 Permission status: $status');

      if (status.isGranted) {
        await _performDownload(mp3File);
      } else if (status.isPermanentlyDenied) {
        _showSnackbar(
          'Permission permanently denied. Please enable it in app settings.',
          Colors.red,
        );
        // Open app settings
        await openAppSettings();
      } else {
        _showSnackbar(
          'Storage permission is required to download files',
          Colors.red,
        );
      }
    } catch (e) {
      print('❌ Download error: $e');
      _showSnackbar('Download error: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadMp3NoPermission(Mp3File mp3File) async {
    print('⬇️ Starting download without permissions: ${mp3File.name}');
    _analyticsService.logActivity(
      deviceId!,
      'Old MP3 Browser: Start Download',
      details: {'fileName': mp3File.name, 'url': mp3File.url},
    );
    final downloadKey = '${Uri.parse(mp3File.url).hashCode}-${mp3File.name}';

    // Prevent duplicate downloads
    if (_isDownloading[downloadKey] == true) {
      _showSnackbar(
        'Download already in progress: ${mp3File.name}',
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isDownloadingNotifier.value[downloadKey] = true;
      _downloadProgressNotifier.value[downloadKey] = 0.0;
      _isDownloadingNotifier.notifyListeners();
      _downloadProgressNotifier.notifyListeners();
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadManagerScreen(
          downloadProgressNotifier: _downloadProgressNotifier,
          isDownloadingNotifier: _isDownloadingNotifier,
          downloadReceivedNotifier: _downloadReceivedNotifier,
          downloadTotalNotifier: _downloadTotalNotifier,
          onCancel: _cancelDownload,
        ),
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${directory.path}/Music');
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      String fileName = mp3File.name;
      if (!fileName.toLowerCase().endsWith('.mp3')) {
        fileName += '.mp3';
      }
      fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      final filePath = '${musicDir.path}/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        _showSnackbar('File already exists: $fileName', Colors.orange);
        setState(() {
          _isDownloading[downloadKey] = false;
          _downloadProgress.remove(downloadKey);
        });
        return;
      }

      final dio = Dio();
      _showSnackbar('Starting download: $fileName', Colors.blue);
      final cancelToken = CancelToken();
      _cancelTokens[downloadKey] = cancelToken;

      await dio.download(
        mp3File.url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total) * 100;
            setState(() {
              _downloadProgressNotifier.value[downloadKey] = progress;
              _downloadReceivedNotifier.value[downloadKey] = received;
              _downloadTotalNotifier.value[downloadKey] = total;

              _downloadProgressNotifier.notifyListeners();
              _downloadReceivedNotifier.notifyListeners();
              _downloadTotalNotifier.notifyListeners();
            });
          }
        },
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
          receiveTimeout: Duration(minutes: 5),
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      if (await file.exists()) {
        print('✅ Download completed: $filePath');
        _analyticsService.logActivity(
          deviceId!,
          'Old MP3 Browser: Download Success',
          details: {'fileName': mp3File.name, 'filePath': filePath},
        );
        _showSnackbar('Downloaded: $fileName to Music folder', Colors.green);
      } else {
        throw Exception('File download verification failed');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // 👉 Proper cancel message
        print('⛔ Download cancelled by user: ${mp3File.name}');
        _showSnackbar('Download cancelled: ${mp3File.name}', Colors.orange);
      } else {
        print('❌ Download error: $e');
        _analyticsService.logActivity(
          deviceId!,
          'Old MP3 Browser: Download Error',
          details: {'fileName': mp3File.name, 'error': e.toString()},
        );
        _showSnackbar('Download failed: ${e.toString()}', Colors.red);
      }
    } finally {
      setState(() {
        _isDownloadingNotifier.value[downloadKey] = false;
        _downloadProgressNotifier.value.remove(downloadKey);
        _isDownloadingNotifier.notifyListeners();
        _downloadProgressNotifier.notifyListeners();
      });
    }
  }

  void _cancelDownload(String downloadKey) {
    if (_cancelTokens.containsKey(downloadKey)) {
      _cancelTokens[downloadKey]?.cancel("Cancelled by user");
      _isDownloadingNotifier.value[downloadKey] = false;
      _downloadProgressNotifier.value.remove(downloadKey);
      _downloadReceivedNotifier.value.remove(downloadKey);
      _downloadTotalNotifier.value.remove(downloadKey);
      _isDownloadingNotifier.notifyListeners();
      _downloadProgressNotifier.notifyListeners();
      _downloadReceivedNotifier.notifyListeners();
      _downloadTotalNotifier.notifyListeners();
    }
  }

  Future<void> _downloadMp3Simple(Mp3File mp3File) async {
    print('⬇️ Simple download attempt: ${mp3File.name}');

    setState(() {
      _isLoading = true;
    });

    try {
      _showSnackbar('Starting download...', Colors.blue);

      // Try different directories
      Directory directory;

      // First try downloads directory
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        directory = downloadsDir;
      } else {
        // Fallback to app documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      String fileName = mp3File.name;
      if (!fileName.toLowerCase().endsWith('.mp3')) {
        fileName += '.mp3';
      }
      fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      final response = await http.get(Uri.parse(mp3File.url));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        _showSnackbar('Downloaded to: ${directory.path}', Colors.green);
      } else {
        _showSnackbar('Download failed', Colors.red);
      }
    } catch (e) {
      print('❌ Simple download error: $e');
      _showSnackbar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performDownload(Mp3File mp3File) async {
    try {
      _showSnackbar('Downloading ${mp3File.name}...', Colors.blue);

      // Get the Downloads directory - this should work without special permissions on Android 10+
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        _showSnackbar('Cannot access downloads directory', Colors.red);
        return;
      }

      print('📁 Downloads directory: ${directory.path}');

      // Clean up filename
      String fileName = mp3File.name;
      if (!fileName.toLowerCase().endsWith('.mp3')) {
        fileName += '.mp3';
      }
      // Remove any invalid characters from filename
      fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      // Create file path
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Check if file already exists
      if (await file.exists()) {
        _showSnackbar('File already exists: $fileName', Colors.orange);
        return;
      }

      // Create the request with headers to avoid blocking
      final response = await http.get(
        Uri.parse(mp3File.url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        // Write the file
        await file.writeAsBytes(response.bodyBytes);

        print('✅ Download completed: $filePath');
        print('📊 File size: ${file.lengthSync()} bytes');

        _showSnackbar('Downloaded: $fileName', Colors.green);

        // Verify file exists
        if (await file.exists()) {
          print('📁 File verified at: $filePath');
        } else {
          print('❌ File not found after download');
        }
      } else {
        print('❌ Download failed with status: ${response.statusCode}');
        _showSnackbar(
          'Failed to download file (Error ${response.statusCode})',
          Colors.red,
        );
      }
    } catch (e) {
      print('❌ Perform download error: $e');
      rethrow;
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateToDirectory(String url) {
    print('📁 Navigating to directory: $url');
    _analyticsService.logActivity(
      deviceId!,
      'Old MP3 Browser: Navigate Directory',
      details: {'targetUrl': url},
    );
    _loadPage(url);
  }

  void _goBack() {
    if (_breadcrumbs.length > 1) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Old MP3 Browser',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.brandViolet, AppTheme.brandBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Breadcrumbs
                if (_breadcrumbs.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(8),
                    color: context.appSurfaceContainer,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _breadcrumbs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final crumb = entry.value;
                          return Row(
                            children: [
                              Text(
                                crumb,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (index != _breadcrumbs.length - 1)
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.chevron_right, size: 12),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      // Directories
                      if (_directories.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Directories (${_directories.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        ..._directories.map(
                          (directory) => ListTile(
                            leading: Icon(
                              Icons.folder,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(directory.name),
                            /*subtitle: Text(
                              directory.url.length > 50
                                  ? '${directory.url.substring(0, 50)}...'
                                  : directory.url,
                              style: TextStyle(fontSize: 10),
                            ),*/
                            onTap: () => _navigateToDirectory(directory.url),
                          ),
                        ),
                      ],

                      // MP3 Files
                      if (_mp3Files.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'MP3 Files (${_mp3Files.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ),
                        ..._mp3Files.map(
                          (mp3File) => ListTile(
                            leading: Icon(
                              Icons.music_note,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            title: Text(mp3File.name),
                            /* subtitle: Text(
                              mp3File.url.length > 50
                                  ? '${mp3File.url.substring(0, 50)}...'
                                  : mp3File.url,
                              style: TextStyle(fontSize: 10),
                            ),*/
                            trailing: Icon(Icons.download),
                            onTap: () => _downloadMp3NoPermission(mp3File),
                          ),
                        ),
                      ],

                      // Pagination
                      // Pagination Section
                      if (_pagination.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Pages',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                          ),
                        ),

                        // Variation 2: Chips (lighter look)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: _pagination.map((page) {
                              final isActive = page.url == _currentUrl;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(page.name),
                                  selected: isActive,
                                  selectedColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.5),
                                  backgroundColor: context.appSurfaceContainer,
                                  labelStyle: TextStyle(
                                    color: isActive
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurface,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontFamily: 'Outfit',
                                  ),
                                  onSelected: (_) =>
                                      _navigateToDirectory(page.url),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      if (_directories.isEmpty &&
                          _mp3Files.isEmpty &&
                          _pagination.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No directories or MP3 files found',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Check debug console for parsing details',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Consumer<AdConfigProvider>(
                  builder: (context, ad, _) {
                    if (!ad.globalAdsEnabled) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      alignment: Alignment.center,
                      height: 60, // Guaranteed space for the ad
                      child: const BannerAdWidget(),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
