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
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grradio/Env.dart';
import 'package:grradio/ads/ad_config_provider.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:grradio/app/splash_animation_screen.dart';
import 'package:grradio/data/track_metadata.dart';
import 'package:grradio/more/more.dart';
import 'package:grradio/more/notificationservice.dart';
import 'package:grradio/more/theme_provider.dart';
import 'package:grradio/more/locale_provider.dart';
import 'package:grradio/l10n/app_localizations.dart';
import 'package:grradio/mp3download/mp3downloadscreen.dart';
import 'package:grradio/player/mp3playerhandler.dart';
import 'package:grradio/player/mp3playerscreen.dart';
import 'package:grradio/radio/radio_handler_mobile.dart';
import 'package:grradio/radio/radioplayerscreen_mobile.dart';
import 'package:grradio/radio/radiostation.dart';
import 'package:grradio/radio/radiostationserviceapi.dart';
import 'package:grradio/theme/app_theme.dart';
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

Future<void> setPremiumUserState(
  bool isPremium, {
  bool refreshAdsConfig = false,
}) async {
  isPremiumUser.value = isPremium;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_premium', isPremium);
  try {
    await adConfigProvider.updatePremiumStatus(isPremium);
    if (refreshAdsConfig) {
      await adConfigProvider.refresh(isPremiumUser: isPremium);
    }
  } catch (_) {
    // Provider may not be initialized during very early startup.
  }
}

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
  if (Platform.isIOS) {
    apiKey = Env.revenueCatIosPublicSdkKey;
  } else if (Platform.isAndroid) {
    apiKey = Env.revenueCatAndroidPublicSdkKey;
  } else {
    throw UnsupportedError('Platform not supported');
  }

  await Purchases.configure(PurchasesConfiguration(apiKey));

  Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    await _updateStatusFromCustomerInfo(customerInfo);
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
  final entitlement =
      customerInfo.entitlements.all[Env.revenueCatEntitlementId];
  final bool isEntitled =
      entitlement?.isActive ?? customerInfo.entitlements.active.isNotEmpty;
  await setPremiumUserState(isEntitled, refreshAdsConfig: !isEntitled);
}

Future<String> _getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
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
  try {
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
                _analyticsService.logActivity(
                  deviceId ?? 'unknown',
                  'Update App Clicked',
                  details: {'version': latestVersion},
                );
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
      _analyticsService.logActivity(
        deviceId ?? 'unknown',
        'Update Dialog Shown',
        details: {'version': latestVersion},
      );
    }
  } catch (e) {
    debugPrint('checkForUpdate failed: $e');
  }
}

/// Persists station list to Hive (`cachedStations`). [markSyncComplete] should be
/// true only after all pages are merged so the 12h refresh rule matches a full sync.
Future<void> _persistStationsToHive(
  List<RadioStation> stations, {
  bool markSyncComplete = true,
}) async {
  if (stations.isEmpty) return;
  try {
    final box = await Hive.openBox<RadioStation>('cachedStations');
    await box.clear();
    await box.addAll(stations);
    if (markSyncComplete) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_station_sync',
        DateTime.now().toIso8601String(),
      );
    }
  } catch (e) {
    debugPrint('Persist stations to Hive failed: $e');
  }
}

Future<void> syncRemoteStations({bool forceRefresh = false}) async {
  final prefs = await SharedPreferences.getInstance();
  final lastSyncStr = prefs.getString('last_station_sync');

  // If we have cached stations (length > 0) and not forcing a refresh, check the 12-hour rule
  if (stationsNotifier.value.isNotEmpty && !forceRefresh) {
    if (lastSyncStr != null) {
      final lastSync = DateTime.tryParse(lastSyncStr);
      if (lastSync != null &&
          DateTime.now().difference(lastSync).inHours < 12) {
        // Cache is fresh (under 12 hours). Mark loading as complete immediately so UI shows carousels.
        stationsLoadingComplete.value = true;
        return;
      }
    }
  }

  try {
    if (stationsNotifier.value.isEmpty || forceRefresh) {
      // If we have NO cached data, or we're explicitly pulled-to-refresh,
      // load page 1 and show it immediately (which triggers progressive loading for remaining pages).
      final firstPage = await _radioService.fetchRadioStations(
        page: 1,
        limit: limitPerPage,
      );
      if (firstPage.isNotEmpty) {
        stationsLoadingComplete.value = false;
        stationsNotifier.value = firstPage;
        // Save logos + metadata from page 1 immediately (full list overwrites later).
        await _persistStationsToHive(firstPage, markSyncComplete: false);
        _loadRemainingStationsInBackground(updateUIProgressively: true);
      }
    } else {
      // BACKGROUND REFRESH: Cache is >12 hours old, but we already have old stations showing.
      // Accumulate transparently without shrinking the UI back to page 1.
      _loadRemainingStationsInBackground(updateUIProgressively: false);
    }
  } catch (e) {
    print("❌ API failed, user is using cached data.");
    stationsLoadingComplete.value = true;
  }
}

void _loadRemainingStationsInBackground({required bool updateUIProgressively}) {
  Future.microtask(() async {
    int currentPage = updateUIProgressively ? 2 : 1;
    bool hasMore = true;

    // If not updating progressively, we just accumulate locally to avoid UI jank
    List<RadioStation> backgroundAccumulator = updateUIProgressively
        ? List.from(stationsNotifier.value)
        : [];

    while (hasMore) {
      final stations = await _radioService.fetchRadioStations(
        page: currentPage,
        limit: limitPerPage,
      );
      if (stations.isNotEmpty) {
        backgroundAccumulator.addAll(stations);

        if (updateUIProgressively) {
          final unique = {
            for (var s in backgroundAccumulator) s.id: s,
          }.values.toList();
          stationsNotifier.value = List.unmodifiable(unique);
        }

        currentPage++;
        if (stations.length < limitPerPage) hasMore = false;
      } else {
        hasMore = false;
      }
    }

    // All pages done
    final unique = {
      for (var s in backgroundAccumulator) s.id: s,
    }.values.toList();
    if (!updateUIProgressively) {
      // Atomic update for background refresh
      stationsNotifier.value = List.unmodifiable(unique);
    }

    stationsLoadingComplete.value = true;

    await _persistStationsToHive(unique, markSyncComplete: true);
  });
}

late dynamic globalRadioAudioHandler;
late AudioPlayer globalMp3Player;
late Mp3PlayerHandler globalMp3QueueService;
Future<void>? _mobileAdsInitFuture;

Future<void> _ensureMobileAdsInitialized() async {
  _mobileAdsInitFuture ??= () async {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('Google Mobile Ads init failed: $e');
    }
  }();
  await _mobileAdsInitFuture;
}

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

  globalMp3QueueService = Mp3PlayerHandler();
  globalMp3QueueService.init();
}

void _initializeAdsDelayed() {
  Future.microtask(() async {
    await _ensureMobileAdsInitialized();
  });
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  final prefs = await SharedPreferences.getInstance();
  isPremiumUser.value = prefs.getBool('is_premium') ?? false;
  deviceId = await _getPersistentDeviceId();
  await initializeApp();
  await _initAudioHandlers();

  adConfigProvider = AdConfigProvider(_analyticsService);
  await adConfigProvider.hydrateFromCache(isPremiumUser: isPremiumUser.value);
  globalAdsEnabled = adConfigProvider.globalAdsEnabled;
  // [globalAdsEnabled] stays false until deferred init completes — UI guards on
  // [AdConfigProvider.initialized] where needed.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Provide the already-initialised instance — no create needed.
        ChangeNotifierProvider<AdConfigProvider>.value(value: adConfigProvider),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadSavedLocale()),
      ],
      child: RadioApp(),
    ),
  );

  // Network-heavy startup: must not block the first frame or native splash handoff.
  unawaited(_completeDeferredStartup());
  // Initialize ads SDK early regardless of remote ad flags.
  unawaited(_ensureMobileAdsInitialized());

  // Firebase / notifications can take time; don't block app landing.
  unawaited(() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    final notificationService = NotificationService();
    await notificationService.initNotifications();
    setupNotificationSubscription();
  }());
  syncRemoteStations();
}

/// Analytics / ads / subscriptions — runs after [runApp] so landing is not blocked
/// by HTTP (stations already load from Hive; [syncRemoteStations] refreshes in background).
Future<void> _completeDeferredStartup() async {
  try {
    // RevenueCat first so [isPremiumUser] matches entitlements before we load
    // ad config (premium must hide ads even when /analytics/config/global is on).
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      await initializeRevenueCat();
      await updatePremiumStatus();
    } catch (e) {
      debugPrint('RevenueCat deferred init: $e');
    }

    await adConfigProvider.initialize(isPremiumUser: isPremiumUser.value);
    globalAdsEnabled = adConfigProvider.globalAdsEnabled;

    await _analyticsService.registerDevice(
      deviceId ?? "unknown-device",
      platform: Platform.operatingSystem,
    );

    if (adConfigProvider.globalAdsEnabled) _initializeAdsDelayed();
  } catch (e, st) {
    debugPrint('Deferred startup failed: $e\n$st');
  }
}

class RadioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'GR Radio',
      locale: localeProvider.currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
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
  int _mp3SubTabIndex = 0;
  bool _isRecording = false;
  bool _isPanelOpen = false;
  final PanelController _panelController = PanelController();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isDialogShowing = false;
  bool _sleepTimerActive = false;
  int _sleepRemainingSeconds = 0;

  /// When set to the current [MediaItem.id], the collapsed + tab mini players are hidden until the track changes or playback stops.
  String? _miniPlayerDismissedForMediaId;

  StreamSubscription? _customEventSub;

  void _dismissMiniPlayerForCurrentTrack(MediaItem? mediaItem) {
    if (mediaItem == null) return;
    setState(() => _miniPlayerDismissedForMediaId = mediaItem.id);
    _analyticsService.logActivity(
      deviceId ?? 'unknown',
      'Dismiss Mini Player',
      details: {
        'trackTitle': mediaItem.title,
        'trackId': mediaItem.id,
      },
    );
    if (_isPanelOpen) _panelController.close();
  }

  void _stopAndDismissMiniPlayer(MediaItem? mediaItem) {
    if (_isRecording) return;
    try {
      globalRadioAudioHandler.stop();
    } catch (_) {}
    try {
      pauseMp3IfPlaying();
    } catch (_) {}
    _dismissMiniPlayerForCurrentTrack(mediaItem);
  }

  void _navigateToMp3RecordingsTab() {
    if (_isRecording) return;
    if (_isPanelOpen) _panelController.close();
    setState(() {
      _mp3SubTabIndex = 2;
      _selectedIndex = 1;
    });
    _analyticsService.logActivity(
      deviceId ?? 'unknown',
      'Navigate to Recordings Shortcut',
    );
  }

  /// Radio screen "Player" shortcut — resets MP3 sub-tab to Music (0).
  void _openPlayerTabFromRadio() {
    if (_isRecording) return;
    if (_isPanelOpen) _panelController.close();
    setState(() {
      _selectedIndex = 1;
      _mp3SubTabIndex = 0;
    });
    _analyticsService.logActivity(
      deviceId ?? 'unknown',
      'Open Player from Radio Shortcut',
    );
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
        } else if (type == 'sleep_timer_update') {
          final active = event['active'] as bool? ?? false;
          final remaining = event['remaining_seconds'] as int? ?? 0;
          if (mounted) {
            setState(() {
              _sleepTimerActive = active;
              _sleepRemainingSeconds = remaining;
            });
          }
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

  String _sleepMiniLabel() {
    if (!_sleepTimerActive || _sleepRemainingSeconds <= 0) return '';
    final minutes = (_sleepRemainingSeconds / 60).ceil();
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      if (m == 0) return 'Sleep in ${h}h';
      return 'Sleep in ${h}h ${m}m';
    }
    return 'Sleep in ${minutes}m';
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
    _analyticsService.logActivity(
      deviceId ?? 'unknown',
      'No Internet Dialog Shown',
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
    _connectivitySubscription?.cancel();
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
      _analyticsService.logActivity(
        deviceId ?? 'unknown',
        'Battery Optimization Dialog Shown',
      );
    }
  }

  void _syncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await setPremiumUserState(
      prefs.getBool('is_premium') ?? false,
      refreshAdsConfig: false,
    );
  }

  void _onItemTapped(int index) {
    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.stopRecordingBeforeSwitch),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Same tab — no-op (do not collapse panel or reset MP3 state).
    if (index == _selectedIndex) return;

    if (_isPanelOpen) _panelController.close();

    final labels = ['Radio', 'Player', 'Download', 'More'];
    _analyticsService.logActivity(
      deviceId ?? 'unknown',
      'Switch Tab',
      details: {
        'from': labels[_selectedIndex],
        'to': labels[index],
      },
    );

    setState(() {
      _selectedIndex = index;
      // Do not reset _mp3SubTabIndex here — ValueKey(_mp3SubTabIndex) would
      // recreate Mp3PlayerScreen and restart local playback. Use
      // [_openPlayerTabFromRadio] when opening Player from the Radio screen.
    });
  }

  /// Wide landscape (typical car / tablet): side rail instead of bottom bar.
  bool _useSideNavigation(MediaQueryData mq) {
    return mq.orientation == Orientation.landscape && mq.size.width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final mq = MediaQuery.of(context);
    final useSideNav = _useSideNavigation(mq);
    final bottomInset = mq.padding.bottom;
    final keyboardOpen = mq.viewInsets.bottom > 0;
    final navBarClearance = useSideNav ? 16.0 : 95.0;

    return Scaffold(
      body: StreamBuilder<MediaItem?>(
        stream: globalRadioAudioHandler.mediaItem,
        builder: (context, itemSnapshot) {
          return StreamBuilder<PlaybackState>(
            stream: globalRadioAudioHandler.playbackState,
            builder: (context, stateSnapshot) {
              final mediaItem = itemSnapshot.data;
              final isPlaying = stateSnapshot.data?.playing ?? false;

              if (mediaItem == null && _miniPlayerDismissedForMediaId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _miniPlayerDismissedForMediaId = null);
                  }
                });
              }

              final bool showMiniPlayerChrome =
                  mediaItem != null &&
                  _miniPlayerDismissedForMediaId != mediaItem.id;

              final double screenHeight = mq.size.height;

              final stackBody = Stack(
                children: [
                  IndexedStack(
                    index: _selectedIndex,
                    children: [
                      RadioPlayerScreen(
                        onNavigateToMp3Tab: _openPlayerTabFromRadio,
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

                  if (!useSideNav && _selectedIndex != 0 && !keyboardOpen)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 105),
                        child: _buildMiniPlayer(),
                      ),
                    ),

                  if (!useSideNav)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomInset),
                        child: _buildFloatingNavigationBar(isDark),
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
                              child: useSideNav
                                  ? _buildNavigationRail(
                                      isDark,
                                      extended: false,
                                    )
                                  : _buildFloatingNavigationBar(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );

              final panelBody = useSideNav
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildNavigationRail(
                          isDark,
                          extended: mq.size.width >= 900,
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        Expanded(
                          child: ClipRect(
                            clipBehavior: Clip.hardEdge,
                            child: Navigator(
                              // Keep “see all / details” pages inside the left 70%.
                              // This prevents them from covering the right-side
                              // expanded player in landscape.
                              key: ValueKey('leftNavigator_${_selectedIndex}'),
                              onGenerateRoute: (settings) {
                                return MaterialPageRoute(
                                  builder: (_) => stackBody,
                                  settings: settings,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : stackBody;

              if (useSideNav) {
                final expandedPlayerWidth = mq.size.width * 0.30;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: panelBody),
                    SizedBox(
                      width: expandedPlayerWidth,
                      child: ExpandedPlayerContent(
                        mediaItem: mediaItem,
                        isPlaying: isPlaying,
                        audioHandler: globalRadioAudioHandler,
                        pc: null, // expanded player is always visible in landscape
                        sidePanel: true,
                        onNavigateToRecordings: _navigateToMp3RecordingsTab,
                        onRecordingStatusChanged: (v) =>
                            setState(() => _isRecording = v),
                      ),
                    ),
                  ],
                );
              }

              return SlidingUpPanel(
                controller: _panelController,
                onPanelOpened: () => setState(() {
                  _isPanelOpen = true;
                  _miniPlayerDismissedForMediaId = null;
                }),
                onPanelClosed: () => setState(() => _isPanelOpen = false),
                minHeight: (showMiniPlayerChrome && !keyboardOpen) ? 80.0 : 0.0,
                maxHeight: screenHeight - navBarClearance,
                margin: EdgeInsets.only(bottom: navBarClearance),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                color: isDark ? const Color(0xFF121212) : Colors.white,
                collapsed: (showMiniPlayerChrome && !keyboardOpen)
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
                        onDismiss: () => _stopAndDismissMiniPlayer(mediaItem),
                        audioHandler: globalRadioAudioHandler,
                        sleepLabel: _sleepMiniLabel(),
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
                body: panelBody,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMiniPlayer() {
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<MediaItem?>(
      stream: globalRadioAudioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();
        if (mediaItem.id == _miniPlayerDismissedForMediaId) {
          return const SizedBox.shrink();
        }
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
                          _sleepMiniLabel().isNotEmpty
                              ? _sleepMiniLabel()
                              : (mediaItem.artist ?? "Radio Stream"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: _sleepMiniLabel().isNotEmpty
                                ? const Color(0xFF7C4DFF)
                                : Colors.grey[600],
                            fontWeight: _sleepMiniLabel().isNotEmpty
                                ? FontWeight.w700
                                : FontWeight.w500,
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
                    tooltip: 'Hide mini player',
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: _isRecording
                        ? null
                        : () => _stopAndDismissMiniPlayer(mediaItem),
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

  /// Left rail for landscape / wide displays (car-friendly).
  Widget _buildNavigationRail(bool isDark, {required bool extended}) {
    const icons = <IconData>[
      Icons.radio,
      Icons.music_note,
      CupertinoIcons.arrow_down_circle_fill,
      Icons.more_horiz,
    ];
    const labels = ['Radio', 'Player', 'Download', 'More'];

    const brandPurple = Color(0xFF7C4DFF);
    final unselectedGrey = Colors.grey.shade500;
    return Material(
      elevation: 8,
      color: isDark
          ? Colors.black.withOpacity(0.85)
          : Colors.white.withOpacity(0.95),
      child: NavigationRail(
        extended: extended,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        labelType: extended
            ? NavigationRailLabelType.all
            : NavigationRailLabelType.all,
        minWidth: extended ? 88 : 72,
        groupAlignment: 0,
        useIndicator: true,
        indicatorColor: brandPurple.withOpacity(0.14),
        selectedIconTheme: const IconThemeData(color: brandPurple, size: 26),
        unselectedIconTheme: IconThemeData(color: unselectedGrey, size: 24),
        selectedLabelTextStyle: const TextStyle(
          color: brandPurple,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: unselectedGrey,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        destinations: [
          for (var i = 0; i < 4; i++)
            NavigationRailDestination(
              icon: Icon(icons[i]),
              selectedIcon: Icon(icons[i]),
              label: Text(labels[i]),
            ),
        ],
      ),
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
