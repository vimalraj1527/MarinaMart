import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/support_controller.dart';
import '../../controllers/theme_controller.dart';

class DirectChatView extends StatefulWidget {
  const DirectChatView({super.key});

  @override
  State<DirectChatView> createState() => _DirectChatViewState();
}

class _DirectChatViewState extends State<DirectChatView> {
  final SupportController _controller = Get.find<SupportController>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.startPolling();
    // Scroll to bottom after layout
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _controller.stopPolling();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = ThemeController.to.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.headset_mic_rounded, color: primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Support Agent",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "Online",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message History
          Expanded(
            child: Obx(() {
              if (_controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
                          ],
                        ),
                        child: Icon(Icons.chat_bubble_outline_rounded, color: primary.withOpacity(0.5), size: 40),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Start a Conversation",
                        style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Ask us anything, we will reply instantly!",
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                );
              }

              // Trigger scroll to bottom on new messages
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = _controller.messages[index];
                  final isMe = msg['senderType'] == 'User';
                  final text = msg['message'] ?? '';
                  final timeRaw = msg['createdAt']?.toString() ?? '';
                  String timeStr = '';
                  if (timeRaw.isNotEmpty) {
                    try {
                      DateTime parsed = DateTime.parse(
                        timeRaw.endsWith('Z') || timeRaw.contains('+') || timeRaw.contains('-') ? timeRaw : '${timeRaw}Z'
                      ).toUtc().add(const Duration(hours: 5, minutes: 30));
                      timeStr = DateFormat('hh:mm a').format(parsed);
                    } catch (_) {}
                  }

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe ? primary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isMe ? 0.08 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text,
                            style: TextStyle(
                              color: isMe ? Colors.white : const Color(0xFF1E293B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              timeStr,
                              style: TextStyle(
                                color: isMe ? Colors.white.withOpacity(0.7) : const Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Message Input Field
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(() => GestureDetector(
                  onTap: _controller.isSending.value ? null : _send,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))
                      ],
                    ),
                    child: _controller.isSending.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _controller.sendMessage(text).then((success) {
        if (success) {
          _messageController.clear();
          _scrollToBottom();
        }
      });
    }
  }
}
