// 💡 NEW: More Screen - Default Page
import 'package:flutter/material.dart';
import 'package:grradio/Env.dart';
import 'package:grradio/more/about_screen.dart';
import 'package:grradio/more/helpandsupport.dart';
import 'package:grradio/more/notification_settings_screen.dart';
import 'package:grradio/more/theme_provider.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:share_plus/share_plus.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  static final InAppReview _inAppReview = InAppReview.instance;

  Future<void> _shareApp() async {
    const String message =
        'Hey! Check out ${Env.appName} for high-quality radio streaming and premium features. Download it here: ${Env.playStoreUrl}';
    await SharePlus.instance.share(
      ShareParams(text: message, subject: 'Check out ${Env.appName}'),
    );
  }

  Future<void> _rateApp() async {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'More',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: isDark
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A0A3E), Color(0xFF0D0D0D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v${Env.appVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Ultimate Music Companion',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Settings Section ───────────────────────────────────────────
            _buildSectionLabel('Settings', isDark),
            const SizedBox(height: 12),

            _buildSettingsItem(
              icon: Icons.star_rounded,
              title: 'Go Premium (Ad-Free)',
              subtitle: 'Unlock all features with a subscription',
              iconColor: Colors.amber.shade700,
              isDark: isDark,
              onTap: () async {
                final paywallResult = await RevenueCatUI.presentPaywall();
                if (paywallResult == PaywallResult.purchased) {
                  debugPrint('Purchase successful!');
                }
              },
            ),

            _buildSettingsItem(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              iconColor: const Color(0xFF7C4DFF),
              isDark: isDark,
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
            _buildDarkModeTile(context, themeProvider, isDark),

            const SizedBox(height: 24),

            // ── Support Section ────────────────────────────────────────────
            _buildSectionLabel('Support', isDark),
            const SizedBox(height: 12),

            _buildSettingsItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              iconColor: const Color(0xFF7C4DFF),
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                );
              },
            ),

            _buildSettingsItem(
              icon: Icons.star_rate_rounded,
              title: 'Rate App',
              subtitle: 'Share your feedback with us',
              iconColor: Colors.orange.shade700,
              isDark: isDark,
              onTap: _rateApp,
            ),

            _buildSettingsItem(
              icon: Icons.share_rounded,
              title: 'Share App',
              subtitle: 'Share with your friends',
              iconColor: const Color(0xFF448AFF),
              isDark: isDark,
              onTap: _shareApp,
            ),

            _buildSettingsItem(
              icon: Icons.info_outline_rounded,
              title: 'About',
              subtitle: 'App version and information',
              iconColor: Colors.teal.shade600,
              isDark: isDark,
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
                '© 2025 ${Env.appName}. All Rights Reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }

  /// Standard settings row — distinct icon color per item, clean trailing arrow.
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool isDark,
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
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  /// Dark mode tile with a Switch trailing indicator showing current state.
  Widget _buildDarkModeTile(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isDark,
  ) {
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
            color: const Color(0xFF7C4DFF).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: const Color(0xFF7C4DFF),
            size: 20,
          ),
        ),
        title: const Text(
          'Dark Mode',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          isDark ? 'Dark theme is on' : 'Light theme is on',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        trailing: Switch(
          value: isDark,
          activeThumbColor: const Color(0xFF7C4DFF),
          onChanged: (_) {
            context.read<ThemeProvider>().toggleTheme();
          },
        ),
        onTap: () => context.read<ThemeProvider>().toggleTheme(),
      ),
    );
  }
}
