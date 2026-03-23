import 'package:flutter/material.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:grradio/main.dart';
import 'package:grradio/more/locale_provider.dart';
import 'package:provider/provider.dart';

/// Full-screen language picker accessible from More > Settings > Language.
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  static final AnalyticsServiceAPI _analyticsService = AnalyticsServiceAPI();

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: LocaleProvider.supportedLanguages.length,
        itemBuilder: (context, index) {
          final lang = LocaleProvider.supportedLanguages[index];
          final isSelected =
              localeProvider.currentLocale.languageCode ==
              lang.locale.languageCode;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: isSelected ? 3 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isSelected
                    ? cs.primary
                    : cs.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: _flagIcon(lang.locale.languageCode, cs),
              title: Text(
                lang.nativeName,
                style: tt.titleMedium?.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? cs.primary : cs.onSurface,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: cs.primary,
                    )
                  : null,
              onTap: () async {
                _analyticsService.logActivity(
                  deviceId ?? 'unknown',
                  'Change Language',
                  details: {'language': lang.locale.languageCode},
                );
                await context
                    .read<LocaleProvider>()
                    .setLocale(lang.locale);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _flagIcon(String code, ColorScheme cs) {
    final icons = <String, IconData>{
      'en': Icons.language,
      'ar': Icons.language,
      'te': Icons.language,
      'ta': Icons.language,
      'kn': Icons.language,
      'hi': Icons.language,
    };
    // Show a coloured language-code badge instead of a flag emoji for
    // reliable rendering on all Android versions.
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          code.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: cs.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
