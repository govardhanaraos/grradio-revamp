import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
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
            _buildSectionTitle('1. Acceptance of Terms'),
            _buildSectionContent(
              'By accessing and using GR Radio, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
            ),

            _buildSectionTitle('2. Description of Service'),
            _buildSectionContent(
              'GR Radio provides a platform for streaming radio stations and audio content. We reserve the right to modify, suspend, or discontinue any aspect of the service at any time.',
            ),

            _buildSectionTitle('3. Premium Subscriptions & Licenses'),
            _buildSectionContent(
              '• License Keys: Premium features are activated using a unique 6-digit license key.\n'
              '• Device Limit: A single license key is valid for up to three (3) concurrent devices. Exceeding this limit may result in the suspension of the key.\n'
              '• Unlinking: You are responsible for managing your linked devices through the "Manage Devices" settings.',
            ),

            _buildSectionTitle('4. User Conduct'),
            _buildSectionContent(
              'You agree not to:\n'
              '• Use the app for any illegal purposes.\n'
              '• Attempt to reverse engineer or hack the license verification system.\n'
              '• Redistribute or "rip" the audio streams provided through the app.',
            ),

            _buildSectionTitle('5. Intellectual Property'),
            _buildSectionContent(
              'All app software, design, and branding are the exclusive property of GR Radio. Radio station content and logos belong to their respective broadcasters and are used here for streaming purposes only.',
            ),

            _buildSectionTitle('6. Limitation of Liability'),
            _buildSectionContent(
              'GR Radio is provided "as is." We are not liable for any damages arising from your use of the app, including but not limited to data usage costs, service interruptions, or station unavailability.',
            ),

            _buildSectionTitle('7. Changes to Terms'),
            _buildSectionContent(
              'We reserve the right to update these terms at any time. Continued use of the app after changes constitutes your acceptance of the new terms.',
            ),

            const SizedBox(height: 30),
            const Center(
              child: Text(
                '© 2024 GR Radio. All Rights Reserved.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
