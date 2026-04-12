import 'package:flutter/material.dart';
import 'package:grradio/l10n/app_localizations.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final faqs = <({String q, String a})>[
      (q: l.faq1Question, a: l.faq1Answer),
      (q: l.faq2Question, a: l.faq2Answer),
      (q: l.faq3Question, a: l.faq3Answer),
      (q: l.faq4Question, a: l.faq4Answer),
      (q: l.faq5Question, a: l.faq5Answer),
      (q: l.faq6Question, a: l.faq6Answer),
      (q: l.faq7Question, a: l.faq7Answer),
      (q: l.faq8Question, a: l.faq8Answer),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.screenFaq),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final item = faqs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              iconColor: const Color(0xFF7C4DFF),
              collapsedIconColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              textColor: const Color(0xFF7C4DFF),
              title: Text(
                item.q,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    item.a,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
