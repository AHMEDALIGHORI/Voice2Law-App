import '../data/content_data.dart';
import '../models/models.dart';

/// Conversation context is memory-only and is erased by the safety exit.
class ConversationStore {
  int epoch = 0;
  final List<ChatMessage> messages = [
    ChatMessage(
      id: 'greeting',
      isUser: false,
      text: ContentData.assistantGreeting,
    ),
  ];
  void clear() {
    epoch++;
    messages
      ..clear()
      ..add(
        ChatMessage(
          id: 'greeting',
          isUser: false,
          text: ContentData.assistantGreeting,
        ),
      );
  }
}
