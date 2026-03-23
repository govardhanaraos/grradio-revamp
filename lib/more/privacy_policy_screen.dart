import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '1. Introduction'),
            _buildSectionContent(context, 
              'Welcome to GR Radio. We are committed to protecting your personal information and your right to privacy. This policy explains how we collect, use, and safeguard your data when you use our mobile application.',
            ),

            _buildSectionTitle(context, '2. Information We Collect'),
            _buildSectionContent(context, 
              '• Device Information: We collect unique device identifiers (Device IDs) to manage premium subscriptions and device limits.\n'
              '• Usage Data: We collect information about which stations you listen to and app interactions to improve our service.\n'
              '• Log Data: Our servers automatically record information created by your use of the services.',
            ),

            _buildSectionTitle(context, '3. How We Use Information'),
            _buildSectionContent(context, 
              'We use the information we collect to:\n'
              '• Provide and maintain our Radio services.\n'
              '• Verify premium license keys and manage linked devices.\n'
              '• Deliver personalized content and advertisements.\n'
              '• Monitor and analyze usage and trends.',
            ),

            _buildSectionTitle(context, '4. Third-Party Services'),
            _buildSectionContent(context, 
              'Our app uses third-party services that may collect information used to identify you:\n'
              '• Google Mobile Ads (AdMob)\n'
              '• Firebase Analytics\n'
              '• Radio Station Streaming Providers',
            ),

            _buildSectionTitle(context, '5. Security'),
            _buildSectionContent(context, 
              'We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. However, no method of transmission over the internet is 100% secure.',
            ),

            _buildSectionTitle(context, '6. Contact Us'),
            _buildSectionContent(context, 
              'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at support@grradio.com.',
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                'Last updated: December 2024',
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
