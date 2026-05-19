import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_message.dart';
import '../services/chatbot_service.dart';

class ChatbotController extends GetxController {
  final ChatbotService _service = ChatbotService();

  final messages      = <ChatMessage>[].obs;
  final isLoading     = false.obs;
  final textController   = TextEditingController();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // Greeting message
    messages.add(ChatMessage(
      role: 'assistant',
      content: "Hi! I'm Advisa 👋\nI can help you with grades, registration, exams, fees, and anything else about your studies. What's on your mind?",
      timestamp: DateTime.now(),
    ));
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> send() async {
    final text = textController.text.trim();
    if (text.isEmpty || isLoading.value) return;

    messages.add(ChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    ));
    textController.clear();
    _scrollToBottom();

    isLoading.value = true;
    try {
      // Gemini requires the conversation to start with a user message —
      // strip any leading assistant messages (e.g. the greeting).
      final all = messages
          .where((m) => m.role == 'user' || m.role == 'assistant')
          .toList();
      final firstUser = all.indexWhere((m) => m.role == 'user');
      final apiHistory = firstUser >= 0 ? all.sublist(firstUser) : all;

      final reply = await _service.sendMessage(apiHistory);
      messages.add(ChatMessage(
        role: 'assistant',
        content: reply,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      messages.add(ChatMessage(
        role: 'assistant',
        content: "⚠️ $e",
        timestamp: DateTime.now(),
      ));
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
