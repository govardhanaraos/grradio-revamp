import 'package:flutter/material.dart';
import 'package:grradio/Env.dart';
import 'package:grradio/more/about_screen.dart';
import 'package:grradio/more/helpandsupport.dart';
import 'package:grradio/more/notification_settings_screen.dart';
import 'package:grradio/more/theme_provider.dart';
import 'package:grradio/main.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:share_plus/share_plus.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static final InAppReview _inAppReview = InAppReview.instance;

  Future<void> _shareApp(BuildContext context) async {
    const String message =
        'Hey! Check out ${Env.appName} for high-quality radio streaming and premium features. Download it here: ${Env.playStoreUrl}';
    try {
      await SharePlus.instance.share(
        ShareParams(text: message, subject: 'Check out ${Env.appName}'),
      );
    } catch (e) {
      debugPrint('Share failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _rateApp(BuildContext context) async {
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('More'),
        centerTitle: true,
      ),
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
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                      'Your Ultimate Music Companion',
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
            _buildSectionLabel(context, 'Settings'),
            const SizedBox(height: 12),

            _buildSettingsItem(
              context,
              icon: Icons.star_rounded,
              title: 'Go Premium (Ad-Free)',
              subtitle: 'Unlock all features with a subscription',
              iconColor: Colors.amber.shade700,
              onTap: () => _openPremiumPaywall(context),
            ),

            _buildSettingsItem(
              context,
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),

            // Dark mode tile — uses a Switch as trailing to show current state
            _buildDarkModeTile(context, isDark),

            const SizedBox(height: 24),

            // ── Support Section ────────────────────────────────────────────
            _buildSectionLabel(context, 'Support'),
            const SizedBox(height: 12),

            _buildSettingsItem(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                );
              },
            ),

            _buildSettingsItem(
              context,
              icon: Icons.star_rate_rounded,
              title: 'Rate App',
              subtitle: 'Share your feedback with us',
              iconColor: Colors.orange.shade700,
              onTap: () => _rateApp(context),
            ),

            _buildSettingsItem(
              context,
              icon: Icons.share_rounded,
              title: 'Share App',
              subtitle: 'Share with your friends',
              iconColor: Theme.of(context).colorScheme.secondary,
              onTap: () => _shareApp(context),
            ),

            _buildSettingsItem(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About',
              subtitle: 'App version and information',
              iconColor: Colors.teal.shade600,
              onTap: () {
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
                '© ${DateTime.now().year} ${Env.appName}. All Rights Reserved.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.75),
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
    try {
      final paywallResult = await RevenueCatUI.presentPaywall();
      await updatePremiumStatus();
      if (!context.mounted) return;
      if (paywallResult == PaywallResult.purchased ||
          paywallResult == PaywallResult.restored) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you — Premium is active.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (paywallResult == PaywallResult.notPresented) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No subscription package is currently available.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Paywall error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open subscriptions: $e'),
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
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
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
          'Dark Mode',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          isDark ? 'Dark theme is on' : 'Light theme is on',
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
            context.read<ThemeProvider>().toggleTheme();
          },
        ),
        onTap: () => context.read<ThemeProvider>().toggleTheme(),
      ),
    );
  }
}
