import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grradio/Env.dart';
import 'package:http/http.dart' as http;

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController subjectCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController messageCtrl = TextEditingController();

  final TextEditingController searchCtrl = TextEditingController();

  bool loading = false;
  String? generatedRefNo;
  bool viewingComplaint = false;

  Map<String, dynamic>? fetchedComplaint;

  // ---------------------------
  // SUBMIT COMPLAINT
  // ---------------------------
  Future<void> submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final url = Uri.parse("${Env.apiBaseUrl}/submitcomplaint");

    final body = {
      "name": nameCtrl.text.trim(),
      "subject": subjectCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "contact": phoneCtrl.text.trim(),
      "description": messageCtrl.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      setState(() => loading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          generatedRefNo = data["reference_no"];
          viewingComplaint = true;
        });

        _showDialog(
          "Success",
          "Your complaint has been submitted successfully.",
        );
        _formKey.currentState!.reset();
      } else {
        _showDialog("Error", "Failed to submit. Please try again later.");
      }
    } catch (e) {
      setState(() => loading = false);
      _showDialog("Error", "Something went wrong. Please try again.");
    }
  }

  // ---------------------------
  // FETCH COMPLAINT BY REF NO
  // ---------------------------
  Future<void> fetchComplaint() async {
    if (searchCtrl.text.trim().isEmpty) {
      _showDialog("Error", "Please enter a complaint reference number.");
      return;
    }

    final url = Uri.parse(
      "${Env.apiBaseUrl}/getcomplaint/${searchCtrl.text.trim()}",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          fetchedComplaint = jsonDecode(response.body);
          viewingComplaint = true;
        });
      } else {
        setState(() {
          fetchedComplaint = null;
          viewingComplaint = false; // SHOW FORM AGAIN
        });

        _showDialog(
          "Not Found",
          "No complaint found with this reference number.",
        );
      }
    } catch (e) {
      _showDialog("Error", "Unable to fetch complaint details.");
    }
  }

  // ---------------------------
  // UI HELPERS
  // ---------------------------
  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: type,
        validator: (v) => v!.isEmpty ? "Required field" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        controller: TextEditingController(text: value),
      ),
    );
  }

  // ---------------------------
  // BUILD UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Feedback / Complaint"), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!viewingComplaint) ...[
              // ---------------------------
              // COMPLAINT FORM
              // ---------------------------
              Text(
                "Submit a Complaint",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _inputField("Name", nameCtrl),
                    _inputField("Subject", subjectCtrl),
                    _inputField(
                      "Email",
                      emailCtrl,
                      type: TextInputType.emailAddress,
                    ),
                    _inputField(
                      "Contact Number",
                      phoneCtrl,
                      type: TextInputType.phone,
                    ),
                    _inputField(
                      "Issue / Feedback Description",
                      messageCtrl,
                      maxLines: 5,
                    ),

                    SizedBox(height: 20),

                    loading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.orange.shade700,
                            ),
                            onPressed: submitComplaint,
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
            // ---------------------------
            // DISPLAY GENERATED REF NO
            // ---------------------------
            if (generatedRefNo != null) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "Your Complaint Reference Number",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SelectableText(
                      generatedRefNo!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Please save this reference number to track your complaint resolution later.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],

            // ---------------------------
            // SEARCH COMPLAINT
            // ---------------------------
            Text(
              "Track Complaint Status",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                labelText: "Enter Complaint Reference Number",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: fetchComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Fetch Details",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            SizedBox(height: 20),

            // ---------------------------
            // DISPLAY FETCHED COMPLAINT
            // ---------------------------
            if (fetchedComplaint != null) ...[
              Text(
                "Complaint Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              _readonlyField("Reference No", fetchedComplaint!["reference_no"]),
              _readonlyField("Name", fetchedComplaint!["name"]),
              _readonlyField("Subject", fetchedComplaint!["subject"]),
              _readonlyField("Email", fetchedComplaint!["email"]),
              _readonlyField("Contact", fetchedComplaint!["contact"]),
              _readonlyField("Description", fetchedComplaint!["description"]),
              _readonlyField(
                "Status",
                fetchedComplaint!["status"] == 'P'
                    ? "Pending"
                    : (fetchedComplaint!["status"] == 'R'
                          ? 'Replied'
                          : 'Closed'),
              ),
              _readonlyField("Created At", fetchedComplaint!["created_at"]),
            ],
          ],
        ),
      ),
    );
  }
}
