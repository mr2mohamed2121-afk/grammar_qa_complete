import 'package:flutter/material.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'time': DateTime.now(),
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'text': _getAIResponse(message),
          'isUser': false,
          'time': DateTime.now(),
        });
      });
      _scrollToBottom();
    });
  }

  String _getAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('اسم') || lowerMessage.contains('مبتدأ')) {
      return 'الاسم في الجملة الاسمية هو المبتدأ، وهو ما نُسند إليه الخبر. مثال: "الطالبُ مجتهٌ" - الطالب مبتدأ.';
    } else if (lowerMessage.contains('فعل') || lowerMessage.contains(' verb')) {
      return 'الفعل في العربية ثلاثة أنواع: ماضٍ، مضارع، وأمر. كل نوع له علامات خاصة.';
    } else if (lowerMessage.contains('حرف') || lowerMessage.contains('جر')) {
      return 'حروف الجر: من، إلى، عن، على، في، الباء، الكاف، لام، حتى، منذ، مذ، ربّ، تاء، واو، سواء، خلا، عدا، حاشا، ليس، لا، كي، إذ، لعل، لكن.';
    } else if (lowerMessage.contains('مرفوع') || lowerMessage.contains('ضمة')) {
      return 'العلامات الرفع: الضمة (الفتحة في الأسماء الممنوعة من الصرف)، الألف (جمع المؤنث السالم)، الواو (جمع المذكر السالم).';
    } else if (lowerMessage.contains('منصوب') || lowerMessage.contains('فتحة')) {
      return 'العلامات النصب: الفتحة، الألف (مثال: رأيتُ المُعلِّمينَ)، الياء (مثال: مررتُ بالمُعلِّمينَ).';
    } else if (lowerMessage.contains('مجزوم') || lowerMessage.contains('سكون')) {
      return 'العلامات الجزم: السكون، حذف حرف العلة (للمضارع المعتل)، حذف النون (الأفعال الخمسة).';
    } else {
      return 'شكراً لسؤالك! هذا موضوع ممتاز في النحو العربي. يمكنك طرح سؤال أكثر تحديداً عن: المبتدأ والخبر، الفعل والفاعل، المفعول به، الإضافة، أو أي موضوع نحوي آخر.';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFE94560),
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text(
              'أستاذ النحو الذكي',
              style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Welcome message
          if (_messages.isEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE94560), width: 1),
              ),
              child: const Column(
                children: [
                  Icon(Icons.waving_hand, size: 48, color: Color(0xFFE94560)),
                  SizedBox(height: 12),
                  Text(
                    'مرحباً! أنا أستاذ النحو الذكي',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اسألني أي شيء عن النحو العربي:\n• ما هو المبتدأ والخبر؟\n• علامات الإعراب\n• أنواع الفعل\n• الإضافة والبدل',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Cairo',
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'] as bool;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF16213E),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Cairo',
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(message['time'] as DateTime).hour}:${(message['time'] as DateTime).minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'اسأل عن النحو العربي...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0F3460),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: const Color(0xFFE94560),
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}