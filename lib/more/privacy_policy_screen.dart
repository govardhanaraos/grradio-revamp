import 'package:flutter/material.dart';
import 'package:grradio/Env.dart';
import 'package:grradio/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final sections = <({String title, String body})>[
      (title: l.privacy1Title, body: l.privacy1Body(Env.appName)),
      (title: l.privacy2Title, body: l.privacy2Body),
      (title: l.privacy3Title, body: l.privacy3Body(Env.appName)),
      (title: l.privacy4Title, body: l.privacy4Body),
      (title: l.privacy5Title, body: l.privacy5Body),
      (title: l.privacy6Title, body: l.privacy6Body),
      (title: l.privacy7Title, body: l.privacy7Body(Env.appName)),
      (title: l.privacy8Title, body: l.privacy8Body(Env.supportEmail)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.screenPrivacyPolicy),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in sections) ...[
              _buildSectionTitle(context, s.title),
              _buildSectionContent(context, s.body),
            ],
            const SizedBox(height: 30),
            Center(
              child: Text(
                l.privacyLastUpdatedFooter,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF7C4DFF),
            ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, String content) {
    return Text(
      content,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
    );
  }
}
