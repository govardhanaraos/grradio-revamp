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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns a staggered fade+slide animation for each item in the list.
  /// Each item fades in slightly after the previous one for a cascade effect.
  Animation<double> _fadeFor(int index) {
    final start = index * 0.15;
    final end = (start + 0.55).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Widget _buildItem({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _fadeFor(index),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(_fadeFor(index)),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: const Color(0xFF7C4DFF)),
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 4),
          _buildItem(
            index: 0,
            icon: Icons.question_answer_rounded,
            title: 'FAQ',
            subtitle: 'Frequently asked questions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FAQScreen()),
            ),
          ),
          _buildItem(
            index: 1,
            icon: Icons.support_agent_rounded,
            title: 'Contact Support',
            subtitle: 'Reach out to our support team',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
            ),
          ),
          _buildItem(
            index: 2,
            icon: Icons.feedback_rounded,
            title: 'Submit Feedback',
            subtitle: 'Tell us your issue or suggestion',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FeedbackFormScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
