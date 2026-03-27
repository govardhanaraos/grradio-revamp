import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grradio/Env.dart';

class AiChatMessage {
  final String role;
  final String content;
  final String? timestamp;

  AiChatMessage({
    required this.role,
    required this.content,
    this.timestamp,
  });

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'],
    );
  }
}

class AiChatConfig {
  final bool enabled;
  final bool humanSupportEnabled;
  final String humanSupportType;
  final String humanSupportValue;
  final String humanSupportLabel;
  final String welcomeMessage;

  AiChatConfig({
    required this.enabled,
    required this.humanSupportEnabled,
    required this.humanSupportType,
    required this.humanSupportValue,
    required this.humanSupportLabel,
    required this.welcomeMessage,
  });

  factory AiChatConfig.fromJson(Map<String, dynamic> json) {
    return AiChatConfig(
      enabled: json['enabled'] ?? true,
      humanSupportEnabled: json['human_support_enabled'] ?? true,
      humanSupportType: json['human_support_type'] ?? 'email',
      humanSupportValue: json['human_support_value'] ?? 'support@grradio.app',
      humanSupportLabel: json['human_support_label'] ?? 'Email Support',
      welcomeMessage: json['welcome_message'] ?? 'Hi! I\'m GR Radio\'s AI assistant. How can I help you today?',
    );
  }
}

class AiChatService {
  final String baseUrl = '${Env.apiBaseUrl}/ai';

  Future<AiChatConfig?> getConfig() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/config'));
      if (response.statusCode == 200) {
        return AiChatConfig.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Failed to get AI config: $e');
    }
    return null;
  }

  Future<List<AiChatMessage>> getHistory(String deviceId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/chat/history/$deviceId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = data['messages'] as List;
        return messages.map((m) => AiChatMessage.fromJson(m)).toList();
      }
    } catch (e) {
      print('Failed to get AI chat history: $e');
    }
    return [];
  }

  Future<void> clearHistory(String deviceId) async {
    try {
      await http.delete(Uri.parse('$baseUrl/chat/history/$deviceId'));
    } catch (e) {
      print('Failed to clear AI chat history: $e');
    }
  }

  Future<String?> sendMessage(String deviceId, String message, String locale) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'message': message,
          'locale': locale,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'];
      }
    } catch (e) {
      print('Failed to send AI chat message: $e');
    }
    return null;
  }
}
