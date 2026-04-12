import 'package:flutter/material.dart';
import 'package:grradio/Env.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:grradio/l10n/app_localizations.dart';
import 'package:grradio/main.dart';
import 'package:grradio/more/about_screen.dart';
import 'package:grradio/more/helpandsupport.dart';
import 'package:grradio/more/language_selection_screen.dart';
import 'package:grradio/more/locale_provider.dart';
import 'package:grradio/more/notification_settings_screen.dart';
import 'package:grradio/more/theme_provider.dart';
import 'package:grradio/more/wake_me_up_screen.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:share_plus/share_plus.dart';

class MoreScreen extends StatelessWidget {
  MoreScreen({super.key});

  static final InAppReview _inAppReview = InAppReview.instance;
  final AnalyticsServiceAPI _analyticsService = AnalyticsServiceAPI();

  Future<void> _shareApp(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final message = l.shareAppMessage(Env.appName, Env.playStoreUrl);
    final subject = l.shareAppSubject(Env.appName);
    try {
      _analyticsService.logActivity(deviceId ?? 'unknown', 'Share App Link');
      await SharePlus.instance.share(
        ShareParams(text: message, subject: subject),
      );
    } catch (e) {
      debugPrint('Share failed: $e');
      if (context.mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.shareCouldNotOpen('$e')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _rateApp(BuildContext context) async {
    _analyticsService.logActivity(deviceId ?? 'unknown', 'Rate App Clicked');
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        await _inAppReview.openStoreListing(
          appStoreId: Env.appStoreId.isEmpty ? null : Env.appStoreId,
          microsoftStoreId: null,
        );
      }
    } catch (e) {
      debugPrint('Error launching review: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open rating: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final l = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l.tabMore), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Info Card ──────────────────────────────────────────────
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4D7C4DFF),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/icons/gr_radio_launcher_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Env.appName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v${Env.appVersion}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.appTagline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Settings Section ───────────────────────────────────────────
            _buildSectionLabel(context, l.sectionSettings),
            const SizedBox(height: 12),

            _buildSettingsItem(
              context,
              icon: Icons.star_rounded,
              title: l.settingGoPremium,
              subtitle: l.settingGoPremiumSubtitle,
              iconColor: Colors.amber.shade700,
              onTap: () => _openPremiumPaywall(context),
            ),

            _buildSettingsItem(
              context,
              icon: Icons.notifications_rounded,
              title: l.settingNotifications,
              subtitle: l.settingNotificationsSubtitle,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () {
                _analyticsService.logActivity(
                  deviceId ?? 'unknown',
                  'Navigate to Notification Settings',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),

            _buildSettingsItem(
              context,
              icon: Icons.alarm_rounded,
              title: l.settingWakeMeUp,
              subtitle: l.settingWakeMeUpSubtitle,
              iconColor: Colors.deepPurple.shade400,
              onTap: () {
                _analyticsService.logActivity(
                  deviceId ?? 'unknown',
                  'Navigate to Wake Me Up',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WakeMeUpScreen()),
                );
              },
            ),

            // Dark mode tile
            _buildDarkModeTile(context, isDark, l),

            // Language tile
            _buildLanguageTile(context, l, localeProvider),

            const SizedBox(height: 24),

            // ── Support Section ────────────────────────────────────────────
            _buildSectionLabel(context, l.sectionSupport),
            const SizedBox(height: 12),

            _buildSettingsItem(
              context,
              icon: Icons.help_outline_rounded,
              title: l.settingHelpSupport,
              subtitle: l.settingHelpSupportSubtitle,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () {
                _analyticsService.logActivity(
                  deviceId ?? 'unknown',
                  'Navigate to Help and Support',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                );
              },
            ),

            _buildSettingsItem(
              context,
              icon: Icons.star_rate_rounded,
              title: l.settingRateApp,
              subtitle: l.settingRateAppSubtitle,
              iconColor: Colors.orange.shade700,
              onTap: () => _rateApp(context),
            ),

            _buildSettingsItem(
              context,
              icon: Icons.share_rounded,
              title: l.settingShareApp,
              subtitle: l.settingShareAppSubtitle,
              iconColor: Theme.of(context).colorScheme.secondary,
              onTap: () => _shareApp(context),
            ),

            _buildSettingsItem(
              context,
              icon: Icons.info_outline_rounded,
              title: l.settingAbout,
              subtitle: l.settingAboutSubtitle,
              iconColor: Colors.teal.shade600,
              onTap: () {
                _analyticsService.logActivity(
                  deviceId ?? 'unknown',
                  'Navigate to About Screen',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),

            const SizedBox(height: 30),

            // ── Footer ────────────────────────────────────────────────────
            Center(
              child: Text(
                l.copyrightFooter(
                  '${DateTime.now().year}',
                  Env.appName,
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Semantics(
      header: true,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          letterSpacing: 1.1,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _openPremiumPaywall(BuildContext context) async {
    _analyticsService.logActivity(
      deviceId ?? 'unknown',
      'Open Premium Paywall',
    );
    try {
      final paywallResult = await RevenueCatUI.presentPaywall();
      await updatePremiumStatus();
      if (!context.mounted) return;
      final loc = AppLocalizations.of(context)!;
      if (paywallResult == PaywallResult.purchased ||
          paywallResult == PaywallResult.restored) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.premiumThankYou),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (paywallResult == PaywallResult.notPresented) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.premiumNoPackages),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Paywall error: $e');
      if (context.mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.paywallCouldNotOpen('$e')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Standard settings row — distinct icon color per item, clean trailing arrow.
  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }

  /// Dark mode tile with a Switch trailing indicator showing current state.
  Widget _buildDarkModeTile(
    BuildContext context,
    bool isDark,
    AppLocalizations l,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: cs.primary,
            size: 20,
          ),
        ),
        title: Text(
          l.settingDarkMode,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          isDark ? l.settingDarkModeOnSubtitle : l.settingDarkModeOffSubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: isDark,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return cs.primary;
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return cs.primary.withValues(alpha: 0.35);
            }
            return null;
          }),
          onChanged: (_) {
            final target = isDark ? 'Light' : 'Dark';
            _analyticsService.logActivity(
              deviceId ?? 'unknown',
              'Toggle Theme',
              details: {'mode': target},
            );
            context.read<ThemeProvider>().toggleTheme();
          },
        ),
        onTap: () {
          final target = isDark ? 'Light' : 'Dark';
          _analyticsService.logActivity(
            deviceId ?? 'unknown',
            'Toggle Theme',
            details: {'mode': target},
          );
          context.read<ThemeProvider>().toggleTheme();
        },
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    AppLocalizations l,
    LocaleProvider localeProvider,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.translate_rounded, color: cs.secondary, size: 20),
        ),
        title: Text(
          l.settingLanguage,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          localeProvider.currentLanguageName,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: cs.onSurfaceVariant,
        ),
        onTap: () {
          _analyticsService.logActivity(
            deviceId ?? 'unknown',
            'Open Language Selection',
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
          );
        },
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isToggle = false,
    bool value = false,
    ValueChanged<bool>? onChanged,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icon, color: cs.primary),
      title: Text(title, style: tt.bodyLarge),
      trailing: isToggle
          ? Switch(value: value, onChanged: onChanged, activeColor: cs.primary)
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: isToggle ? null : onTap,
    );
  }
}
