import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grradio/Env.dart';
import 'package:grradio/ads/ad_config_provider.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:grradio/data/track_metadata.dart';
import 'package:grradio/handler/mp3playerhandler.dart';
import 'package:grradio/more/more.dart';
import 'package:grradio/more/notificationservice.dart';
import 'package:grradio/more/theme_provider.dart';
import 'package:grradio/mp3download/mp3downloadscreen.dart';
import 'package:grradio/mp3playerscreen.dart';
import 'package:grradio/radiostation.dart';
import 'package:grradio/radiostationserviceapi.dart';
import 'package:grradio/splash_animation_screen.dart';
import 'package:grradio/util/radio_handler_mobile.dart';
import 'package:grradio/util/screens/radioplayerscreen_mobile.dart';
import 'package:grradio/widgets/expanded_player_content.dart';
import 'package:grradio/widgets/mini_player_tile.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

// --- SSL CERTIFICATE OVERRIDE ---
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

final RadioStationServiceAPI _radioService = RadioStationServiceAPI();
final ValueNotifier<List<RadioStation>> stationsNotifier = ValueNotifier([]);
final ValueNotifier<bool> stationsLoadingComplete = ValueNotifier(false);
final AnalyticsServiceAPI _analyticsService = AnalyticsServiceAPI();

/// Global ad-config provider — initialised in main(), available app-wide.
late final AdConfigProvider adConfigProvider;

/// Legacy top-level flag kept for any existing call-sites.
/// Prefer reading from [adConfigProvider] in new code.
bool globalAdsEnabled = false;
String? deviceId;

List<RadioStation> get allRadioStations => stationsNotifier.value;

const int limitPerPage = 50;
bool _isInitializing = false;
final _storage = const FlutterSecureStorage();
final ValueNotifier<bool> isPremiumUser = ValueNotifier(false);

Future<void> initializeApp() async {
  if (_isInitializing) {
    await _analyticsService.logActivity(
      deviceId ?? "unknown-device",
      "initializeApp",
      details: {
        "message":
            "App initialization already in progress or complete. Skipping second call.",
      },
    );
    return;
  }
  _isInitializing = true;

  await Hive.initFlutter();
  Hive.registerAdapter(RadioStationAdapter());
  Hive.registerAdapter(TrackMetadataAdapter());

  final cachedStationsBox = await Hive.openBox<RadioStation>('cachedStations');
  await Hive.openBox<TrackMetadata>('tracks');
  final List<RadioStation> initialStations = cachedStationsBox.values.toList();
  stationsNotifier.value = initialStations;
}

Future<String> _getPersistentDeviceId() async {
  String? id = await _storage.read(key: 'unique_device_id');
  if (id == null) {
    id = await _getDeviceId();
    await _storage.write(key: 'unique_device_id', value: id);
  }
  return id;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> initializeRevenueCat() async {
  String apiKey;
  if (Env.environment == 'production') {
    if (Platform.isIOS) {
      apiKey = 'sk_CPpSAxwIVwwXPBizbMGkpdAMBJaan';
    } else if (Platform.isAndroid) {
      apiKey = 'sk_CPpSAxwIVwwXPBizbMGkpdAMBJaan';
    } else {
      throw UnsupportedError('Platform not supported');
    }
  } else {
    if (Platform.isIOS) {
      apiKey = 'test_EWJndZnjbUWEyVNJYEKSuRLKyBS';
    } else if (Platform.isAndroid) {
      apiKey = 'test_EWJndZnjbUWEyVNJYEKSuRLKyBS';
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  await Purchases.configure(PurchasesConfiguration(apiKey));

  Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    await _updateStatusFromCustomerInfo(customerInfo);
    // Propagate premium status change into the ad config provider.
    try {
      await adConfigProvider.updatePremiumStatus(isPremiumUser.value);
    } catch (e) {
      print('adConfigProvider not yet initialized: $e');
    }
  });
}

Future<void> updatePremiumStatus() async {
  try {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    await _updateStatusFromCustomerInfo(customerInfo);
  } catch (e) {
    print("Error fetching customer info: $e");
  }
}

Future<void> _updateStatusFromCustomerInfo(CustomerInfo customerInfo) async {
  final bool isEntitled =
      customerInfo.entitlements.all['premium']?.isActive ?? false;

  isPremiumUser.value = isEntitled;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_premium', isEntitled);
}

Future<String> _getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id ?? "unknown";
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? "unknown";
  }
  return "unknown";
}

bool isNewerVersion(String current, String latest) {
  List<int> c = current.split('.').map(int.parse).toList();
  List<int> l = latest.split('.').map(int.parse).toList();

  for (int i = 0; i < l.length; i++) {
    if (l[i] > c[i]) return true;
    if (l[i] < c[i]) return false;
  }
  return false;
}

Future<Map<String, dynamic>> fetchAppConfig() async {
  final url = Uri.parse("${Env.apiBaseUrl}/appconfig");
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return jsonDecode(response.body)["config"];
  } else {
    return {};
  }
}

Future<void> setupNotificationSubscription() async {
  final prefs = await SharedPreferences.getInstance();
  bool isEnabled = prefs.getBool('notifications_enabled') ?? true;

  if (isEnabled) {
    await FirebaseMessaging.instance.subscribeToTopic('radio_alerts');
  } else {
    await FirebaseMessaging.instance.unsubscribeFromTopic('radio_alerts');
  }
}

void checkForUpdate(BuildContext context) async {
  final config = await fetchAppConfig();
  bool updateEnabled = config["app_update_enabled"] == "true";
  String latestVersion = config["app_update_version"] ?? "0.0.0";
  String updateUrl = config["app_update_url"] ?? "";
  String currentVersion = "1.0.0";

  if (updateEnabled && isNewerVersion(currentVersion, latestVersion)) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Update Available"),
        content: Text(
          "A new version ($latestVersion) of GR Radio is available. "
          "Please update to continue enjoying the best experience.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Later"),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(updateUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }
}

Future<void> _loadStationsInBackground(Box<RadioStation> box) async {
  List<RadioStation> mergedStations = [];
  int currentPage = 1;
  bool hasMore = true;

  try {
    while (hasMore) {
      final stations = await _radioService.fetchRadioStations(
        page: currentPage,
        limit: limitPerPage,
      );
      mergedStations.addAll(stations);
      // Fire per-page so RadioPlayerScreen can render progressively.
      // Use a new list copy so ValueNotifier detects the change.
      stationsNotifier.value = List.unmodifiable(mergedStations);
      if (stations.length < limitPerPage) {
        hasMore = false;
      }
      currentPage++;
    }
    // Mark all pages complete — triggers final ad injection in the screen.
    stationsLoadingComplete.value = true;
    await box.clear();
    await box.addAll(mergedStations);
  } catch (e) {
    print('Background station refresh failed: $e');
  }
}

Future<void> syncRemoteStations() async {
  try {
    final firstPage = await _radioService.fetchRadioStations(
      page: 1,
      limit: limitPerPage,
    );
    if (firstPage.isNotEmpty) {
      stationsLoadingComplete.value = false;
      stationsNotifier.value = firstPage;
      _loadRemainingStationsInBackground();
    }
  } catch (e) {
    print("❌ API failed, user is using cached data.");
  }
}

void _loadRemainingStationsInBackground() {
  Future.microtask(() async {
    int currentPage = 2;
    bool hasMore = true;
    while (hasMore) {
      final stations = await _radioService.fetchRadioStations(
        page: currentPage,
        limit: limitPerPage,
      );
      if (stations.isNotEmpty) {
        // Merge with current list and fire per-page for progressive rendering.
        final current = stationsNotifier.value;
        final merged = [...current, ...stations];
        final unique = {for (var s in merged) s.id: s}.values.toList();
        stationsNotifier.value = List.unmodifiable(unique);
        currentPage++;
        if (stations.length < limitPerPage) hasMore = false;
      } else {
        hasMore = false;
      }
    }
    // All pages done — triggers final ad injection in the screen.
    stationsLoadingComplete.value = true;

    final box = await Hive.openBox<RadioStation>('cachedStations');
    await box.clear();
    await box.addAll(stationsNotifier.value);
  });
}

late dynamic globalRadioAudioHandler;
late AudioPlayer globalMp3Player;
late Mp3PlayerHandler globalMp3QueueService;

void pauseRadioIfPlaying() {
  if (globalRadioAudioHandler.playbackState.value.playing) {
    globalRadioAudioHandler.pause();
  }
}

void pauseMp3IfPlaying() {
  try {
    globalMp3Player.stop();
  } catch (e) {
    print('Error attempting to stop globalMp3Player: $e');
  }
}

void setupAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(
    const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
    ),
  );
}

Future<void> _initAudioHandlers() async {
  setupAudioSession();
  globalMp3Player = AudioPlayer();

  globalRadioAudioHandler = await AudioService.init(
    builder: () => RadioHandlerImpl(stations: allRadioStations),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.radio.grradio',
      androidNotificationChannelName: 'Radio Streaming',
      androidNotificationChannelDescription:
          'Audio playback for internet radio',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: false,
      preloadArtwork: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidResumeOnClick: true,
      androidNotificationClickStartsActivity: true,
    ),
  );

  stationsNotifier.addListener(() {
    globalRadioAudioHandler.setStations(stationsNotifier.value);
  });

  globalMp3QueueService = await Mp3PlayerHandler();
  globalMp3QueueService.init();
}

void _initializeAdsDelayed() {
  Future.microtask(() async {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      print('❌ Failed to initialize Google Mobile Ads (Delayed): $e');
    }
  });
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  isPremiumUser.value = prefs.getBool('is_premium') ?? false;
  deviceId = await _getPersistentDeviceId();
  await initializeApp();
  await Firebase.initializeApp();
  NotificationService notificationService = NotificationService();
  await notificationService.initNotifications();
  await _initAudioHandlers();

  adConfigProvider = AdConfigProvider(_analyticsService);
  await adConfigProvider.initialize(isPremiumUser: isPremiumUser.value);
  globalAdsEnabled = adConfigProvider.globalAdsEnabled;

  await Purchases.setLogLevel(LogLevel.debug);
  await initializeRevenueCat();
  await updatePremiumStatus();

  await _analyticsService.registerDevice(
    deviceId ?? "unknown-device",
    platform: Platform.operatingSystem,
  );

  // Boot AdMob SDK only if ads are actually enabled.
  if (adConfigProvider.globalAdsEnabled) _initializeAdsDelayed();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Provide the already-initialised instance — no create needed.
        ChangeNotifierProvider<AdConfigProvider>.value(value: adConfigProvider),
      ],
      child: RadioApp(),
    ),
  );

  setupNotificationSubscription();
  syncRemoteStations();
}

class RadioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    const brandViolet = Color(0xFF7C4DFF);
    const brandBlue = Color(0xFF448AFF);

    return MaterialApp(
      title: 'GR Radio',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        primaryColor: brandViolet,
        scaffoldBackgroundColor: Colors.grey.shade50,
        colorScheme: const ColorScheme.light(
          primary: brandViolet,
          secondary: brandBlue,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white.withOpacity(0.8),
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primaryColor: brandViolet,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: brandViolet,
          secondary: brandBlue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AnimatedSplashScreen(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  int _mp3SubTabIndex = 0;
  bool _isRecording = false;
  bool _isPanelOpen = false;
  final PanelController _panelController = PanelController();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isDialogShowing = false;

  StreamSubscription? _customEventSub;

  void _navigateToMp3RecordingsTab() {
    if (_isRecording) return;
    setState(() {
      _mp3SubTabIndex = 2;
      _selectedIndex = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();

    // 2. Real-time listener for status changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.contains(ConnectivityResult.none)) {
        _showNoInternetDialog();
      } else {
        _dismissDialog();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdate(context);
      _syncStatus();
      _showBatteryOptimizationDialog();
    });

    _customEventSub = globalRadioAudioHandler.customEvent.listen((event) {
      if (event is Map) {
        final type = event['event'];
        if (type == 'record_status') {
          final isRec = event['isRecording'] as bool? ?? false;
          if (mounted) setState(() => _isRecording = isRec);
        } else if (type == 'permission_denied') {
          final msg = event['message'] as String? ?? 'Permission denied';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
            setState(() => _isRecording = false);
          }
        }
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    if (_isDialogShowing || !mounted) return;

    setState(() => _isDialogShowing = true);

    showDialog(
      context: context,
      barrierDismissible: false, // Force user to acknowledge or reconnect
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.signal_wifi_off, color: Colors.red),
            SizedBox(width: 10),
            Text("No Internet"),
          ],
        ),
        content: const Text(
          "GR Radio requires an active internet connection to stream music. Please check your settings.",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final result = await Connectivity().checkConnectivity();
              if (!result.contains(ConnectivityResult.none)) {
                _dismissDialog();
              }
            },
            child: const Text("RETRY"),
          ),
        ],
      ),
    );
  }

  void _dismissDialog() {
    if (_isDialogShowing && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => _isDialogShowing = false);
    }
  }

  void showNoInternetMessage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No internet connection"),
          content: Text("Please check your internet connection and try again."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _customEventSub?.cancel();
    super.dispose();
  }

  Future<void> _showBatteryOptimizationDialog() async {
    var status = await Permission.ignoreBatteryOptimizations.status;
    if (!status.isGranted && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Keep Radio Playing"),
          content: const Text(
            "To prevent the radio from stopping when your screen is off or during phone calls, "
            "please allow the app to run in the background in the next screen.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("LATER"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Permission.ignoreBatteryOptimizations.request();
              },
              child: const Text("SETTINGS"),
            ),
          ],
        ),
      );
    }
  }

  void _syncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isPremiumUser.value = prefs.getBool('is_premium') ?? false;
  }

  void _onItemTapped(int index) {
    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Stop recording before switching tabs.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
      if (index == 1) _mp3SubTabIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: StreamBuilder<MediaItem?>(
        stream: globalRadioAudioHandler.mediaItem,
        builder: (context, itemSnapshot) {
          return StreamBuilder<PlaybackState>(
            stream: globalRadioAudioHandler.playbackState,
            builder: (context, stateSnapshot) {
              final mediaItem = itemSnapshot.data;
              final isPlaying = stateSnapshot.data?.playing ?? false;
              final bool hasMedia = mediaItem != null;

              final double navBarClearance = 95.0;
              final double screenHeight = MediaQuery.of(context).size.height;

              return SlidingUpPanel(
                controller: _panelController,
                onPanelOpened: () =>
                    setState(() => _isPanelOpen = true), // ✅ ADD
                onPanelClosed: () => setState(() => _isPanelOpen = false),
                minHeight: hasMedia ? 80.0 : 0.0,
                maxHeight: screenHeight - navBarClearance,
                margin: const EdgeInsets.only(bottom: 95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                color: isDark ? const Color(0xFF121212) : Colors.white,
                collapsed: hasMedia
                    ? MiniPlayerTile(
                        mediaItem: mediaItem,
                        isPlaying: isPlaying,
                        isRecording: _isRecording,
                        isBuffering:
                            stateSnapshot.data?.processingState ==
                                AudioProcessingState.loading ||
                            stateSnapshot.data?.processingState ==
                                AudioProcessingState.buffering,
                        onTogglePlay: () => isPlaying
                            ? globalRadioAudioHandler.pause()
                            : globalRadioAudioHandler.play(),
                        onTap: () => _panelController.open(),
                        audioHandler: globalRadioAudioHandler,
                      )
                    : const SizedBox.shrink(),
                panel: ExpandedPlayerContent(
                  mediaItem: mediaItem,
                  isPlaying: isPlaying,
                  audioHandler: globalRadioAudioHandler,
                  pc: _panelController,
                  onNavigateToRecordings: _navigateToMp3RecordingsTab,
                  onRecordingStatusChanged: (v) =>
                      setState(() => _isRecording = v),
                ),
                body: Stack(
                  children: [
                    IndexedStack(
                      index: _selectedIndex,
                      children: [
                        RadioPlayerScreen(
                          onNavigateToMp3Tab: () => _onItemTapped(1),
                          onRecordingStatusChanged: (v) =>
                              setState(() => _isRecording = v),
                          onNavigateToRecordings: _navigateToMp3RecordingsTab,
                        ),
                        Mp3PlayerScreen(
                          key: ValueKey(_mp3SubTabIndex),
                          initialTabIndex: _mp3SubTabIndex,
                        ),
                        Mp3DownloadScreen(),
                        MoreScreen(),
                      ],
                    ),

                    if (_selectedIndex != 0)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 105),
                          child: _buildMiniPlayer(),
                        ),
                      ),

                    IgnorePointer(
                      ignoring: _isPanelOpen,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom,
                          ),
                          child: _buildFloatingNavigationBar(isDark),
                        ),
                      ),
                    ),

                    if (_isRecording)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _PulsingDot(),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'RECORDING IN PROGRESS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AbsorbPointer(
                              child: Opacity(
                                opacity: 0.35,
                                child: _buildFloatingNavigationBar(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return StreamBuilder<MediaItem?>(
      stream: globalRadioAudioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();
        return StreamBuilder<PlaybackState>(
          stream: globalRadioAudioHandler.playbackState,
          builder: (context, stateSnapshot) {
            final isPlaying = stateSnapshot.data?.playing ?? false;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
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
                          mediaItem.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          mediaItem.artist ?? "Radio Stream",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Opacity(
                    opacity: _isRecording ? 0.35 : 1.0,
                    child: IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                      iconSize: 38,
                      color: _isRecording
                          ? Colors.grey
                          : const Color(0xFF7C4DFF),
                      onPressed: _isRecording
                          ? null
                          : () => isPlaying
                                ? globalRadioAudioHandler.pause()
                                : globalRadioAudioHandler.play(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _isRecording
                        ? null
                        : () => globalRadioAudioHandler.stop(),
                    color: _isRecording ? Colors.grey : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingNavigationBar(bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 85,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(4, (index) {
              final icons = [
                Icons.radio,
                Icons.music_note,
                CupertinoIcons.arrow_down_circle_fill,
                Icons.more_horiz,
              ];
              final labels = ['Radio', 'Player', 'Download', 'More'];
              final isSelected = _selectedIndex == index;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onItemTapped(index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF7C4DFF),
                                      Color(0xFF448AFF),
                                    ],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            icons[index],
                            size: 24,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF7C4DFF)
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Small blinking dot used in the recording lock badge ───────────────────────
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}
