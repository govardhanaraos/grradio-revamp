import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> faqData = const [
    {
      "q": "How do I use GR Radio?",
      "a": "Browse stations, tap to play, and enjoy seamless streaming.",
    },
    {
      "q": "Why is audio buffering?",
      "a": "Check your internet connection or try lowering audio quality.",
    },
    {
      "q": "How do I report an issue?",
      "a": "Use the Feedback/Complaint form in the Help & Support section.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FAQ"), centerTitle: true),
      body: ListView.builder(
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ExpansionTile(
              title: Text(
                faqData[index]["q"]!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(faqData[index]["a"]!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
