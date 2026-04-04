import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../shared/app_scaffold.dart';
import '../shared/models.dart';

// ─── PAGE LISTE DES CONVERSATIONS ────────────────────────────────────────────
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  // [BDD] fetch conversations WHERE participant_id = currentUser.id
  List<ConversationModel> get _conversations => ConversationModel.placeholders();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navIndex: 2,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: const Row(children: [
              Icon(Icons.chat_bubble_outline, color: AppColors.blue, size: 20),
              SizedBox(width: 8),
              Text('Messagerie',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.blue)),
            ]),
          ),
          // Barre de recherche
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.search, color: AppColors.grey, size: 18),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher une conversation...',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.grey),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Liste
          Expanded(
            child: ListView.separated(
              itemCount: _conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border, indent: 70),
              itemBuilder: (_, i) => _ConversationTile(
                conv: _conversations[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _ChatPage(conv: _conversations[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TUILE CONVERSATION ───────────────────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final ConversationModel conv;
  final VoidCallback onTap;
  const _ConversationTile({required this.conv, required this.onTap});

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return DateFormat('HH:mm').format(dt);
    if (diff.inDays == 1) return 'Hier';
    return DateFormat('dd/MM/yy').format(dt);
  }

  IconData get _avatarIcon => conv.contactType == 'support' ? Icons.support_agent : Icons.person;
  Color get _avatarBg => conv.contactType == 'support' ? AppColors.greenSurface : AppColors.blueSurface;
  Color get _avatarColor => conv.contactType == 'support' ? AppColors.green : AppColors.blue;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            // Avatar + badge online
            Stack(children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _avatarBg,
                child: Icon(_avatarIcon, color: _avatarColor, size: 24),
              ),
              if (conv.isOnline)
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 11, height: 11,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                ),
            ]),
            const SizedBox(width: 12),
            // Contenu
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(conv.contactName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: conv.unreadCount > 0 ? FontWeight.w800 : FontWeight.w600,
                        color: AppColors.text,
                      )),
                  Text(_formatTime(conv.lastMessageAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Expanded(
                    child: Text(conv.lastMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: conv.unreadCount > 0 ? AppColors.text : AppColors.grey,
                          fontWeight: conv.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (conv.unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.blueLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${conv.unreadCount}',
                          style: const TextStyle(fontSize: 10, color: AppColors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ]),
              ]),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.grey, size: 18),
          ]),
        ),
      );
}

// ─── PAGE CHAT ────────────────────────────────────────────────────────────────
class _ChatPage extends StatefulWidget {
  final ConversationModel conv;
  const _ChatPage({required this.conv});

  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  // [BDD] fetch messages WHERE conversation_id = conv.id ORDER BY created_at ASC
  late List<ChatMessageModel> _messages;

  @override
  void initState() {
    super.initState();
    _messages = ChatMessageModel.placeholders(widget.conv.id);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages = [
        ..._messages,
        ChatMessageModel(
          id: 'cmsg_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: widget.conv.id,
          senderId: 'user_001',
          isMe: true,
          body: text,
          sentAt: DateTime.now(),
        ),
      ];
      _inputCtrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    // [BDD] POST messages { conversation_id, body, sender_id }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(children: [
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) return _DateSeparator(date: _messages.first.sentAt);
              return _ChatBubble(message: _messages[i - 1]);
            },
          ),
        ),
        // Barre de saisie
        _InputBar(controller: _inputCtrl, onSend: _sendMessage),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          Stack(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.blueSurface,
              child: const Icon(Icons.person, color: AppColors.blue, size: 18),
            ),
            if (widget.conv.isOnline)
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 9, height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.green, shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ),
          ]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.conv.contactName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
              Text(widget.conv.isOnline ? 'En ligne' : 'Hors ligne',
                  style: TextStyle(fontSize: 11,
                      color: widget.conv.isOnline ? AppColors.green : AppColors.grey)),
            ]),
          ),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: AppColors.grey),
            onPressed: () {}, // [NAV] → Visio
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.grey),
            onPressed: () {},
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      );
}

// ─── SÉPARATEUR DATE ──────────────────────────────────────────────────────────
class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  String get _label {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    return DateFormat('dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          const Expanded(child: Divider(color: AppColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(_label, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          ),
          const Expanded(child: Divider(color: AppColors.border)),
        ]),
      );
}

// ─── BULLE DE MESSAGE ────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.blueSurface,
              child: Icon(Icons.person, color: AppColors.blue, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: message.isMe ? AppColors.blueSurface : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(message.isMe ? 16 : 4),
                    bottomRight: Radius.circular(message.isMe ? 4 : 16),
                  ),
                  border: message.isMe ? null : Border.all(color: AppColors.border),
                ),
                child: Text(message.body,
                    style: const TextStyle(fontSize: 14, color: AppColors.text, height: 1.4)),
              ),
              const SizedBox(height: 4),
              Text(DateFormat('HH:mm').format(message.sentAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── BARRE DE SAISIE ─────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: AppColors.grey),
            onPressed: () {}, // [BDD] upload pièce jointe
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Écrivez un message...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.blueLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: AppColors.white, size: 18),
            ),
          ),
        ]),
      );
}