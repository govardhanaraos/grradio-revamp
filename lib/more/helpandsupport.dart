import 'package:flutter/material.dart';
import 'package:grradio/more/contactsupport.dart';
import 'package:grradio/more/faq_screen.dart';
import 'package:grradio/more/feedback_form_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _fade,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Icon(icon, size: 28, color: Colors.orange.shade700),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help & Support"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF57C00), Color(0xFFFFB74D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildItem(
              icon: Icons.question_answer,
              title: "FAQ",
              subtitle: "Frequently asked questions",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FAQScreen()),
                );
              },
            ),
            _buildItem(
              icon: Icons.support_agent,
              title: "Contact Support",
              subtitle: "Reach out to our support team",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ContactSupportScreen()),
                );
              },
            ),

            _buildItem(
              icon: Icons.feedback,
              title: "Submit Feedback / Complaint",
              subtitle: "Tell us your issue or suggestion",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FeedbackFormScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
