import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grradio/main.dart';
import 'package:grradio/more/securestorage/deviceidsecurestorage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Use the http package

class ActivationScreen extends StatefulWidget {
  @override
  _ActivationScreenState createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _activateLicense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final devid = deviceId; // From Step 2 earlier

    try {
      final response = await http.post(
        Uri.parse(
          "http://127.0.0.1:8000/premium/verify-license",
        ), // Use your actual IP for physical devices
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "license_key": _keyController.text.trim(),
          "device_id": devid,
        }),
      );

      if (response.statusCode == 200) {
        // 1. Update Global State
        isUserPremium.value = true;

        // 2. Persist locally so ads stay hidden next time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_premium', true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Premium Activated! Ads Removed.")),
        );
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body)['detail'];
        throw Exception(error ?? "Activation failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Activate Radio Pro")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Enter your 6-digit license key to remove ads on this device.",
              ),
              TextFormField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: "License Key (e.g. A1B2C3)",
                ),
                validator: (val) =>
                    val!.length < 6 ? "Enter a valid key" : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _activateLicense,
                      child: Text("Activate Now"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
