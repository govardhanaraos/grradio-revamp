import 'package:flutter/material.dart';
import 'package:grradio/Env.dart';
import 'package:grradio/more/privacy_policy_screen.dart';
import 'package:grradio/more/terms_of_service_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _launchEmail() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: Env.supportEmail,
      query: 'subject=GR Radio Enquiry',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWebsite() async {
    final Uri uri = Uri.parse('https://www.grradio.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // App Logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x337C4DFF),
                      blurRadius: 12,
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
            ),
            const SizedBox(height: 16),
            Text(
              Env.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Version ${Env.appVersion}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                '${Env.appName} is your ultimate companion for high-quality audio streaming. '
                'Enjoy local and international stations with crystal clear sound and '
                'premium features like offline downloads and ad-free listening.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
            const Divider(),

            // Tappable info tiles
            _buildInfoTile(
              context,
              icon: Icons.person_rounded,
              iconColor: const Color(0xFF7C4DFF),
              label: 'Developer',
              value: 'Govardhana Rao Sugrivugari',
            ),
            _buildInfoTile(
              context,
              icon: Icons.email_rounded,
              iconColor: Colors.orange.shade700,
              label: 'Contact Us',
              value: Env.supportEmail,
              onTap: _launchEmail,
            ),
            _buildInfoTile(
              context,
              icon: Icons.language_rounded,
              iconColor: Colors.teal.shade600,
              label: 'Website',
              value: 'www.grradio.com',
              onTap: _launchWebsite,
            ),

            const Divider(),

            // Legal
            ListTile(
              leading: const Icon(
                Icons.privacy_tip_rounded,
                color: Color(0xFF7C4DFF),
              ),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.gavel_rounded,
                color: Color(0xFF7C4DFF),
              ),
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TermsOfServiceScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.article_rounded,
                color: Color(0xFF7C4DFF),
              ),
              title: const Text('Third-Party Licenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: Env.appName,
                applicationVersion: Env.appVersion,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '© 2025 ${Env.appName}. All Rights Reserved.',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: onTap != null ? const Color(0xFF7C4DFF) : null,
          decoration: onTap != null ? TextDecoration.underline : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
