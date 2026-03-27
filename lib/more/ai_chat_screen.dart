import 'package:flutter/material.dart';
import 'package:grradio/api/ai_chat_service.dart';
import 'package:grradio/l10n/app_localizations.dart';
import 'package:grradio/main.dart';
import 'package:url_launcher/url_launcher.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({Key? key}) : super(key: key);

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AiChatService _chatService = AiChatService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AiChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  AiChatConfig? _config;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    _config = await _chatService.getConfig();
    if (deviceId != null) {
      final history = await _chatService.getHistory(deviceId!);
      if (mounted) {
        setState(() {
          _messages = history;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || deviceId == null) return;

    _msgController.clear();
    setState(() {
      _messages.add(AiChatMessage(role: 'user', content: text));
      _isTyping = true;
    });
    _scrollToBottom();

    final l = AppLocalizations.of(context);
    final locale = l?.localeName ?? 'en';

    final reply = await _chatService.sendMessage(deviceId!, text, locale);

    if (mounted) {
      setState(() {
        _isTyping = false;
        if (reply != null) {
          _messages.add(AiChatMessage(role: 'assistant', content: reply));
        } else {
          _messages.add(AiChatMessage(
            role: 'assistant',
            content: l?.aiError ?? 'Failed to get response, please try again.',
          ));
        }
      });
      _scrollToBottom();
    }
  }

  Future<void> _clearChat() async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l?.aiClearChat ?? 'Clear Chat'),
        content: Text(l?.aiClearConfirm ?? 'Are you sure you want to clear chat history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l?.buttonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l?.buttonOk ?? 'OK'),
          ),
        ],
      ),
    );

    if (confirm == true && deviceId != null) {
      setState(() => _isLoading = true);
      await _chatService.clearHistory(deviceId!);
      setState(() {
        _messages.clear();
        _isLoading = false;
      });
    }
  }

  void _contactHumanSupport() async {
    if (_config == null || !_config!.humanSupportEnabled) return;
    final uri = Uri.parse(_config!.humanSupportValue);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l?.aiAssistant ?? 'AI Assistant'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l?.aiClearChat ?? 'Clear Chat',
            onPressed: _messages.isEmpty ? null : _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 64, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _config?.welcomeMessage ?? l?.aiWelcome ?? 'Hi! I\'m GR Radio\'s AI assistant. How can I help you today?',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _buildTypingIndicator(l);
                        }
                        final msg = _messages[index];
                        final isUser = msg.role == 'user';
                        return _buildMessageBubble(msg.content, isUser, isDark);
                      },
                    ),
            ),

          if (_config?.humanSupportEnabled == true && _messages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.support_agent, size: 18),
                  label: Text(_config?.humanSupportLabel ?? l?.aiContactHuman ?? 'Contact Human Support'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF7C4DFF),
                  ),
                  onPressed: _contactHumanSupport,
                ),
              ),
            ),

          // Message Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: l?.aiChatHint ?? 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF7C4DFF),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser 
              ? const Color(0xFF7C4DFF) 
              : (isDark ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser 
                ? Colors.white 
                : (isDark ? Colors.white : Colors.black87),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(AppLocalizations? l) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[800] 
              : Colors.grey[200],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Text(
          l?.aiTyping ?? 'AI is typing...',
          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ),
    );
  }
}
