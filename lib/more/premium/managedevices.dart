import 'package:flutter/material.dart';
import 'package:grradio/api/commonapi.dart';
import 'package:grradio/main.dart'; // To access isPremiumUser and deviceId
import 'package:shared_preferences/shared_preferences.dart';

class ManageDevicesScreen extends StatefulWidget {
  final String plainLicenseKey; // Match the param name from activation screen
  ManageDevicesScreen({required this.plainLicenseKey});

  @override
  _ManageDevicesScreenState createState() => _ManageDevicesScreenState();
}

class _ManageDevicesScreenState extends State<ManageDevicesScreen> {
  List<dynamic> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    try {
      final devices = await LicenseService.listDevices(widget.plainLicenseKey);
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unlinkDevice(String dId) async {
    try {
      await LicenseService.removeDevice(widget.plainLicenseKey, dId);

      // Check if the current device was the one removed
      if (dId == deviceId) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_premium', false);
        await prefs.remove('saved_license_key');

        // This triggers the UI to switch to Activation Form immediately
        isPremiumUser.value = false;

        Navigator.pop(context); // Go back to activation screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Premium deactivated for this device.")),
        );
      } else {
        _fetchDevices(); // Just refresh list if it was a different device
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to unlink: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Linked Devices")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final dId = _devices[index];
                final isCurrent = dId == deviceId;
                return ListTile(
                  leading: Icon(
                    isCurrent ? Icons.phonelink_ring : Icons.phone_android,
                  ),
                  title: Text(
                    isCurrent ? "This Device" : "Other Device ${index + 1}",
                  ),
                  subtitle: Text(dId.toString().substring(0, 8) + "..."),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _unlinkDevice(dId),
                  ),
                );
              },
            ),
    );
  }
}
