import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Ad Unit IDs — replace test IDs with real AdMob IDs before release.
// ─────────────────────────────────────────────────────────────────────────────
class AdUnitIds {
  static const String bannerAndroid  = 'ca-app-pub-3940256099942544/6300978111';
  static const String bannerIos      = 'ca-app-pub-3940256099942544/2934735716';
  static const String nativeAndroid  = 'ca-app-pub-3940256099942544/2247696110';
  static const String nativeIos      = 'ca-app-pub-3940256099942544/3986624511';
  static const String interstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String interstitialIos     = 'ca-app-pub-3940256099942544/4411468910';
}

// ─────────────────────────────────────────────────────────────────────────────
//  BannerAdWidget
//
//  FIX: _loadAd() was previously called from initState(), which runs before
//  the widget is inserted into the tree.  Calling Theme.of(context) there
//  triggers:
//    "dependOnInheritedWidgetOfExactType() was called before initState() completed"
//
//  The correct lifecycle method for anything that needs an inherited widget
//  (Theme, MediaQuery, Provider, etc.) is didChangeDependencies(), which is
//  called after initState() and after the element is fully attached to the
//  tree.  We guard with _adLoaded = false so the load only fires once.
// ─────────────────────────────────────────────────────────────────────────────
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded   = false;
  bool _loadCalled = false; // guard — only load once

  @override
  void initState() {
    super.initState();
    // DO NOT call _loadAd() here — context has no inherited widgets yet.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe to call Theme.of(context) here.  Guard ensures we only load once.
    if (!_loadCalled) {
      _loadCalled = true;
      _loadAd();
    }
  }

  void _loadAd() {
    // Theme.of(context) is safe here — called from didChangeDependencies.
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final adUnitId = isIos ? AdUnitIds.bannerIos : AdUnitIds.bannerAndroid;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          if (mounted) setState(() => _isLoaded = false);
          debugPrint('BannerAd failed: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  NativeInFeedAdTile
//
//  Same fix applied: _loadAd() moved from initState() to didChangeDependencies()
//  with a _loadCalled guard.
// ─────────────────────────────────────────────────────────────────────────────
class NativeInFeedAdTile extends StatefulWidget {
  const NativeInFeedAdTile({Key? key}) : super(key: key);

  @override
  State<NativeInFeedAdTile> createState() => _NativeInFeedAdTileState();
}

class _NativeInFeedAdTileState extends State<NativeInFeedAdTile> {
  NativeAd? _nativeAd;
  bool _isLoaded   = false;
  bool _loadCalled = false;

  @override
  void initState() {
    super.initState();
    // DO NOT call _loadAd() here.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadCalled) {
      _loadCalled = true;
      _loadAd();
    }
  }

  void _loadAd() {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final adUnitId = isIos ? AdUnitIds.nativeIos : AdUnitIds.nativeAndroid;

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _nativeAd = null;
          if (mounted) setState(() => _isLoaded = false);
          debugPrint('NativeAd failed: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark
            ? const Color(0xFF1E1E2E).withOpacity(0.7)
            : Colors.grey.shade50,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.grey.shade200,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AdWidget(ad: _nativeAd!),
          ),
          Positioned(
            top: 6,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'AD',
                style: TextStyle(
                  color: Color(0xFF7C4DFF),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  InterstitialAdManager  (unchanged — static, no context needed)
// ─────────────────────────────────────────────────────────────────────────────
class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;
  static bool _isReady          = false;
  static int  _numLoadAttempts  = 0;
  static const int _maxAttempts = 3;

  // Uses Android ID by default — swap per-platform in a real build.
  static String get _adUnitId => AdUnitIds.interstitialAndroid;

  static void preload() => _loadAd();

  static void _loadAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd   = ad;
          _isReady          = true;
          _numLoadAttempts  = 0;
          _interstitialAd!.setImmersiveMode(true);
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isReady        = false;
              _loadAd(); // pre-load next immediately
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isReady        = false;
              debugPrint('Interstitial show failed: $error');
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isReady = false;
          _numLoadAttempts++;
          debugPrint('Interstitial load failed ($_numLoadAttempts): $error');
          if (_numLoadAttempts < _maxAttempts) _loadAd();
        },
      ),
    );
  }

  static void show() {
    if (_isReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      debugPrint('Interstitial not ready.');
    }
  }

  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isReady        = false;
  }
}
