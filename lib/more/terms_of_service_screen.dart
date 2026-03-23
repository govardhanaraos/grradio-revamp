import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '1. Acceptance of Terms'),
            _buildSectionContent(
              context,
              'By accessing and using GR Radio, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
            ),

            _buildSectionTitle(context, '2. Description of Service'),
            _buildSectionContent(
              context,
              'GR Radio provides a platform for streaming radio stations and audio content. We reserve the right to modify, suspend, or discontinue any aspect of the service at any time.',
            ),

            _buildSectionTitle(context, '3. Premium Subscriptions & Licenses'),
            _buildSectionContent(
              context,
              '• License Keys: Premium features are activated using a unique 6-digit license key.\n'
              '• Device Limit: A single license key is valid for up to three (3) concurrent devices. Exceeding this limit may result in the suspension of the key.\n'
              '• Unlinking: You are responsible for managing your linked devices through the "Manage Devices" settings.',
            ),

            _buildSectionTitle(context, '4. User Conduct'),
            _buildSectionContent(
              context,
              'You agree not to:\n'
              '• Use the app for any illegal purposes.\n'
              '• Attempt to reverse engineer or hack the license verification system.\n'
              '• Redistribute or "rip" the audio streams provided through the app.',
            ),

            _buildSectionTitle(context, '5. Intellectual Property'),
            _buildSectionContent(
              context,
              'All app software, design, and branding are the exclusive property of GR Radio. Radio station content and logos belong to their respective broadcasters and are used here for streaming purposes only.',
            ),

            _buildSectionTitle(context, '6. Limitation of Liability'),
            _buildSectionContent(
              context,
              'GR Radio is provided "as is." We are not liable for any damages arising from your use of the app, including but not limited to data usage costs, service interruptions, or station unavailability.',
            ),

            _buildSectionTitle(context, '7. Changes to Terms'),
            _buildSectionContent(
              context,
              'We reserve the right to update these terms at any time. Continued use of the app after changes constitutes your acceptance of the new terms.',
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                '© 2024 GR Radio. All Rights Reserved.',
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
