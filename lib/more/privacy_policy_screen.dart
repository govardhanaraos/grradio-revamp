import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF57C00), Color(0xFFFFB74D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Introduction'),
            _buildSectionContent(
              'Welcome to GR Radio. We are committed to protecting your personal information and your right to privacy. This policy explains how we collect, use, and safeguard your data when you use our mobile application.',
            ),

            _buildSectionTitle('2. Information We Collect'),
            _buildSectionContent(
              '• Device Information: We collect unique device identifiers (Device IDs) to manage premium subscriptions and device limits.\n'
              '• Usage Data: We collect information about which stations you listen to and app interactions to improve our service.\n'
              '• Log Data: Our servers automatically record information created by your use of the services.',
            ),

            _buildSectionTitle('3. How We Use Information'),
            _buildSectionContent(
              'We use the information we collect to:\n'
              '• Provide and maintain our Radio services.\n'
              '• Verify premium license keys and manage linked devices.\n'
              '• Deliver personalized content and advertisements.\n'
              '• Monitor and analyze usage and trends.',
            ),

            _buildSectionTitle('4. Third-Party Services'),
            _buildSectionContent(
              'Our app uses third-party services that may collect information used to identify you:\n'
              '• Google Mobile Ads (AdMob)\n'
              '• Firebase Analytics\n'
              '• Radio Station Streaming Providers',
            ),

            _buildSectionTitle('5. Security'),
            _buildSectionContent(
              'We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. However, no method of transmission over the internet is 100% secure.',
            ),

            _buildSectionTitle('6. Contact Us'),
            _buildSectionContent(
              'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at support@grradio.com.',
            ),

            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Last updated: December 2024',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE65100),
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
    );
  }
}
