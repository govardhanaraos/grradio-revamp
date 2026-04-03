import 'package:flutter/material.dart';
import 'package:grradio/api/analytics_service_api.dart';
import 'package:grradio/main.dart';
import 'package:grradio/more/locale_provider.dart';
import 'package:provider/provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  bool _showApplicationLanguage = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Application Language'),
            value: _showApplicationLanguage,
            onChanged: (value) {
              setState(() {
                _showApplicationLanguage = value;
              });
            },
          ),
          if (_showApplicationLanguage) const ApplicationLanguageList(),
          const Divider(),
          const ListTile(
            title: Text('Listening Language'),
          ),
          const Expanded(
            child: ListeningLanguageList(),
          ),
        ],
      ),
    );
  }
}

class ApplicationLanguageList extends StatelessWidget {
  const ApplicationLanguageList({super.key});

  static final AnalyticsServiceAPI _analyticsService = AnalyticsServiceAPI();

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: LocaleProvider.supportedLanguages.length,
      itemBuilder: (context, index) {
        final lang = LocaleProvider.supportedLanguages[index];
        final isSelected =
            localeProvider.currentLocale.languageCode == lang.locale.languageCode;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: isSelected ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isSelected
                  ? cs.primary
                  : cs.outline.withOpacity(0.2),
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
              await context.read<LocaleProvider>().setLocale(lang.locale);
            },
          ),
        );
      },
    );
  }

  Widget _flagIcon(String code, ColorScheme cs) {
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

class ListeningLanguageList extends StatelessWidget {
  const ListeningLanguageList({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder for the listening language functionality.
    // You can replace this with your actual implementation.
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Language ${index + 1}'),
        );
      },
    );
  }
}
