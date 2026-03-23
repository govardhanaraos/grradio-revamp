import 'package:flutter/material.dart';
import 'package:grradio/api/commonapi.dart';
import 'package:grradio/main.dart';
import 'package:grradio/more/premium/managedevices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumActivationScreen extends StatefulWidget {
  @override
  _PremiumActivationScreenState createState() =>
      _PremiumActivationScreenState();
}

class _PremiumActivationScreenState extends State<PremiumActivationScreen> {
  final TextEditingController _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleActivation() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final String inputKey = _keyController.text.trim().toUpperCase();
      final result = await LicenseService.verifyLicense(inputKey, deviceId!);
      print('result: $result');
      print(result['is_premium']);
      if (result['is_premium'] == true) {
        print('is_premium: true');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'saved_license_key',
          inputKey,
        ); // Store to manage devices later

        // This triggers the UI to switch automatically
        await setPremiumUserState(true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Activation Successful!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Premium Membership")),
      body: ValueListenableBuilder<bool>(
        valueListenable: isPremiumUser,
        builder: (context, isPremium, child) {
          return isPremium ? _buildPremiumView() : _buildActivationForm();
        },
      ),
    );
  }

  Widget _buildPremiumView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified, size: 100, color: Colors.amber),
          const SizedBox(height: 20),
          const Text(
            "You are a PRO Member",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            "Ads are now disabled across the app.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final key = prefs.getString('saved_license_key') ?? "";
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ManageDevicesScreen(plainLicenseKey: key),
                ),
              );
            },
            icon: const Icon(Icons.devices),
            label: const Text("Manage Linked Devices"),
          ),
        ],
      ),
    );
  }

  Widget _buildActivationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Icon(Icons.workspace_premium, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Enter your 6-digit Key",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: "License Key",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLength: 6,
              validator: (v) =>
                  (v == null || v.length < 6) ? "Invalid Key" : null,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleActivation,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("ACTIVATE NOW"),
                  ),
          ],
        ),
      ),
    );
  }
}
