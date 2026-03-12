// 💡 NEW: More Screen - Default Page
import 'package:flutter/material.dart';
import 'package:grradio/more/about_screen.dart';
import 'package:grradio/more/helpandsupport.dart';
import 'package:grradio/more/premium/premium_activation_screen.dart';
import 'package:grradio/more/theme_provider.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class MoreScreen extends StatelessWidget {
  MoreScreen({Key? key}) : super(key: key);

  final InAppReview _inAppReview = InAppReview.instance;

  void _shareApp() {
    const String appUrl =
        'https://play.google.com/store/apps/details?id=com.your.package.name'; // Replace with your actual ID
    const String message =
        'Hey! Check out GR Radio for high-quality radio streaming and premium features. Download it here: $appUrl';

    Share.share(message, subject: 'Check out GR Radio App');
  }

  Future<void> _rateApp() async {
    try {
      // Check if the in-app review dialog is available (usually works on physical devices)
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        // If the dialog is not available, open the store listing directly
        // Replace 'com.your.package.name' with your actual package ID
        await _inAppReview.openStoreListing(
          appStoreId: 'YOUR_APP_STORE_ID', // Only required for iOS
          microsoftStoreId: null,
        );
      }
    } catch (e) {
      debugPrint("Error launching review: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'More Options',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF57C00), // Dark Orange
                Color(0xFFFFB74D), // Light Orange
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade600,
                            Colors.purple.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
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
                    SizedBox(height: 16),
                    Text(
                      'GR Radio',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your Ultimate Music Companion',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Settings Section
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            SizedBox(height: 12),

            _buildSettingsItem(
              icon: Icons.star,
              title: 'Go Premium (Ad-Free)',
              subtitle: 'Get Premium subscription',
              color: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PremiumActivationScreen()),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              color: Theme.of(context).textTheme.bodyLarge!.color!,
              onTap: () {},
            ),

            _buildSettingsItem(
              icon: Icons.nightlight_round,
              title: 'Dark Mode',
              subtitle: 'Switch between light and dark themes',
              color: Theme.of(context).textTheme.bodyLarge!.color!,
              onTap: () {
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme();
              },
            ),

            SizedBox(height: 20),

            // Support Section
            Text(
              'Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            SizedBox(height: 12),

            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              color: Theme.of(context).textTheme.bodyLarge!.color!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                );
              },
            ),

            _buildSettingsItem(
              icon: Icons.star_rate,
              title: 'Rate App',
              subtitle: 'Share your feedback with us',
              color: Theme.of(context).textTheme.bodyLarge!.color!,
              onTap: _rateApp,
            ),

            _buildSettingsItem(
              icon: Icons.share,
              title: 'Share App',
              subtitle: 'Share with your friends',
              color: Theme.of(context).textTheme.bodyLarge!.color!,
              onTap: _shareApp,
            ),

            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              color: Theme.of(context).textTheme.bodyLarge!.color!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),

            SizedBox(height: 30),

            // App Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.9)),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
        onTap: onTap,
      ),
    );
  }
}
