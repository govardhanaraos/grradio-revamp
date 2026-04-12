import 'package:flutter/material.dart';
import 'package:grradio/Env.dart';
import 'package:grradio/l10n/app_localizations.dart';
import 'package:grradio/more/privacy_policy_screen.dart';
import 'package:grradio/more/terms_of_service_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _launchEmail(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final uri = Uri(
      scheme: 'mailto',
      path: Env.supportEmail,
      queryParameters: {'subject': l.aboutEmailSubject(Env.appName)},
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
    final l = AppLocalizations.of(context)!;
    final year = '${DateTime.now().year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l.screenAbout),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
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
              l.aboutVersionLabel(Env.appVersion),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                l.aboutIntroBody(Env.appName),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
            ),
            const Divider(),

            _buildInfoTile(
              context,
              icon: Icons.person_rounded,
              iconColor: const Color(0xFF7C4DFF),
              label: l.aboutLabelDeveloper,
              value: l.aboutDeveloperName,
            ),
            _buildInfoTile(
              context,
              icon: Icons.email_rounded,
              iconColor: Colors.orange.shade700,
              label: l.aboutLabelContact,
              value: Env.supportEmail,
              onTap: () => _launchEmail(context),
            ),
            _buildInfoTile(
              context,
              icon: Icons.language_rounded,
              iconColor: Colors.teal.shade600,
              label: l.aboutLabelWebsite,
              value: l.aboutWebsiteDisplay,
              onTap: _launchWebsite,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.privacy_tip_rounded,
                color: Color(0xFF7C4DFF),
              ),
              title: Text(l.screenPrivacyPolicy),
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
              title: Text(l.screenTermsOfService),
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
              title: Text(l.licensesThirdParty),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: Env.appName,
                applicationVersion: Env.appVersion,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              l.copyrightFooter(year, Env.appName),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
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
