import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  static const List<Map<String, String>> _faqData = [
    {
      'q': 'How do I use GR Radio?',
      'a': 'Browse stations from the Discover screen, tap any station card to start playing. Use the language chips or search bar to find stations by name or language.',
    },
    {
      'q': 'Why is audio buffering?',
      'a': 'Check your internet connection. Streaming radio requires a stable connection. Try switching from mobile data to Wi-Fi, or vice versa.',
    },
    {
      'q': 'How do I report an issue?',
      'a': 'Go to More → Help & Support → Submit Feedback and describe your issue. Our team typically responds within 24 hours.',
    },
    {
      'q': 'Can I listen offline?',
      'a': 'Live radio streams require an active internet connection and cannot be played offline. Premium subscribers can access offline downloads for select content.',
    },
    {
      'q': 'How do I favourite a station?',
      'a': 'Tap the heart icon on any station tile. Your favourites will appear at the top of the Discover screen for quick access.',
    },
    {
      'q': 'What does Premium include?',
      'a': 'Premium removes all advertisements, unlocks higher audio quality, and gives access to offline downloads. Tap "Go Premium" in the More screen to subscribe.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FAQ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqData.length,
        itemBuilder: (context, index) {
          final item = _faqData[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              iconColor: const Color(0xFF7C4DFF),
              collapsedIconColor: Colors.grey[500],
              textColor: const Color(0xFF7C4DFF),
              title: Text(
                item['q']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    item['a']!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
