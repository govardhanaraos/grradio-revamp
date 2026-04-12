import 'package:grradio/api/ai_chat_service.dart';
import 'package:grradio/api/top_songs_service.dart';

void main() async {
  print("Testing AI Chat Config...");
  final aiService = AiChatService();
  try {
    final config = await aiService.getConfig();
    print("Config: ${config?.welcomeMessage}");
  } catch(e) {
    print("Config Error: $e");
  }

  print("Testing Top Songs...");
  final tsService = TopSongsService();
  try {
    final songs = await tsService.fetchTopSongs("hindi");
    print("Top Songs Length: ${songs.length}");
  } catch(e) {
    print("Top Songs Error: $e");
  }
}
