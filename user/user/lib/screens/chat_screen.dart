import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:user/global/map_key.dart';
import 'package:user/models/prompt_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final List<Content> history=[]; 
  Future<void> getChatMessages() async {
    var docs=await FirebaseFirestore.instance.collection("Chatbot").get();
    for(var eachPrompt in docs.docs){
      PromptModel promptModel=PromptModel.fromDocument(eachPrompt);
      history.add(Content.multi([
      TextPart(promptModel.question!)
    ]));
    history.add(Content.multi([
      TextPart(promptModel.responses!)
    ]));
    }
   
   
    
  }

  @override
  void initState() {
    super.initState();
    getChatMessages();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: gemini_key,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );
    _chat = _model.startChat(history: history);
  
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
    });
    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      setState(() {
        _messages.add(ChatMessage(text: text!, isUser: false));
        _scrollDown();
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Error occured", isUser: false));
      });
    } finally {
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('AI ChatBot'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(message: _messages[index]);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Nhập câu hỏi",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ), // OutlineInputBorder
                    ), // InputDecoration
                  ),
                  IconButton(
                      onPressed: () => _sendMessage(_textController.text),
                      icon: Icon(Icons.send))
                ], // Row
              ), // Padding
            )
          ],
        ));
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  const ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.25),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: message.isUser ? Radius.circular(12) : Radius.zero,
              bottomRight: message.isUser ? Radius.zero : Radius.circular(12)),
          color: message.isUser ? Colors.blue[200] : Colors.green[200],
        ),
        child: Text(message.text),
      ),
    );
  }
}
