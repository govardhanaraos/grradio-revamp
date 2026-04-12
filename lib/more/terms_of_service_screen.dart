import 'package:flutter/material.dart';
import 'package:grradio/Env.dart';
import 'package:grradio/l10n/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final year = '${DateTime.now().year}';
    final sections = <({String title, String body})>[
      (title: l.terms1Title, body: l.terms1Body(Env.appName)),
      (title: l.terms2Title, body: l.terms2Body(Env.appName)),
      (title: l.terms3Title, body: l.terms3Body),
      (title: l.terms4Title, body: l.terms4Body(Env.appName)),
      (title: l.terms5Title, body: l.terms5Body(Env.appName)),
      (title: l.terms6Title, body: l.terms6Body),
      (title: l.terms7Title, body: l.terms7Body(Env.supportEmail)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.screenTermsOfService),
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
                l.copyrightFooter(year, Env.appName),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, String content) {
    return Text(
      content,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
    );
  }
}
