import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';

class ChatbotService {
  final _db = Supabase.instance.client;

  Future<String> sendMessage(List<ChatMessage> history) async {
    final response = await _db.functions.invoke(
      'chat',
      body: {
        'messages': history.map((m) => m.toApiMap()).toList(),
      },
    );

    final data = response.data;

    if (data == null) {
      throw Exception('Edge function returned no data (status ${response.status})');
    }

    final map = data as Map<String, dynamic>;

    if (map.containsKey('error')) {
      throw Exception('Function error: ${map['error']}');
    }

    final contentList = map['content'] as List?;
    if (contentList == null || contentList.isEmpty) {
      throw Exception('Unexpected response shape: $map');
    }

    return contentList.first['text'] as String;
  }
}
