import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../shared/app_scaffold.dart';
import '../shared/models.dart';
import '../shared/api_service.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<ConversationModel> _conversations = [];
  bool _loading = true;
  final int _myId = ApiService.session?.id ?? 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.fetchConversations(_myId);
      setState(() {
        _conversations = data.map(ConversationModel.fromJson).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navIndex: 2,
      body: Column(children: [
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: const Row(children: [
            Icon(Icons.chat_bubble_outline, color: AppColors.blue, size: 20),
            SizedBox(width: 8),
            Text('Messagerie',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.blue)),
          ]),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.blueLight))
              : _conversations.isEmpty
                  ? const Center(child: Text('Aucune conversation', style: TextStyle(color: AppColors.grey)))
                  : ListView.separated(
                      itemCount: _conversations.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1, color: AppColors.border, indent: 70),
                      itemBuilder: (_, i) => _ConvTile(
                        conv: _conversations[i],
                        myId: _myId,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _ChatPage(conv: _conversations[i], myId: _myId),
                          ),
                        ),
                      ),
                    ),
        ),
      ]),
    );
  }
}

class _ConvTile extends StatelessWidget {
  final ConversationModel conv;
  final int myId;
  final VoidCallback onTap;
  const _ConvTile({required this.conv, required this.myId, required this.onTap});

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return DateFormat('HH:mm').format(dt);
    if (diff.inDays == 1) return 'Hier';
    return DateFormat('dd/MM').format(dt);
  }

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.blueSurface,
              child: const Icon(Icons.person, color: AppColors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(conv.contactName(myId),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: conv.hasUnread ? FontWeight.w800 : FontWeight.w600,
                      color: AppColors.text,
                    )),
                Text(_formatTime(conv.lastMessageAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.grey)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Expanded(
                  child: Text(conv.lastMessagePreview,
                      style: TextStyle(
                        fontSize: 12,
                        color: conv.hasUnread ? AppColors.text : AppColors.grey,
                        fontWeight: conv.hasUnread ? FontWeight.w500 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                if (conv.hasUnread)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.blueLight,
                      shape: BoxShape.circle,
                    ),
                  ),
              ]),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.grey, size: 18),
          ]),
        ),
      );
}

// ─── PAGE CHAT ────────────────────────────────────────────────────────────────
class _ChatPage extends StatefulWidget {
  final ConversationModel conv;
  final int myId;
  const _ChatPage({required this.conv, required this.myId});
  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<MessageModel> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.fetchMessages(widget.conv.id);
      setState(() {
        _messages = data.map(MessageModel.fromJson).toList();
        _loading = false;
      });
      // Marquer comme lus
      await ApiService.markAsRead(widget.conv.id, widget.myId);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    try {
      final msg = await ApiService.sendMessage(
        idConversation: widget.conv.id,
        idUtilisateur: widget.myId,
        contenu: text,
      );
      setState(() => _messages.add(MessageModel.fromJson(msg)));
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          surfaceTintColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.blue),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(children: [
            const CircleAvatar(radius: 18, backgroundColor: AppColors.blueSurface,
                child: Icon(Icons.person, color: AppColors.blue, size: 18)),
            const SizedBox(width: 10),
            Text(widget.conv.contactName(widget.myId),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.text)),
          ]),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: AppColors.border),
          ),
        ),
        body: Column(children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.blueLight))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _Bubble(msg: _messages[i], myId: widget.myId),
                  ),
          ),
          _InputBar(ctrl: _ctrl, onSend: _send),
        ]),
      );
}

class _Bubble extends StatelessWidget {
  final MessageModel msg;
  final int myId;
  const _Bubble({required this.msg, required this.myId});

  @override
  Widget build(BuildContext context) {
    final isMe = msg.isMe(myId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const CircleAvatar(radius: 14, backgroundColor: AppColors.blueSurface,
                child: Icon(Icons.person, color: AppColors.blue, size: 14)),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.blueSurface : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  border: isMe ? null : Border.all(color: AppColors.border),
                ),
                child: Text(msg.contenu,
                    style: const TextStyle(fontSize: 14, color: AppColors.text, height: 1.4)),
              ),
              const SizedBox(height: 4),
              Text(DateFormat('HH:mm').format(msg.dateEnvoi),
                  style: const TextStyle(fontSize: 11, color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSend;
  const _InputBar({required this.ctrl, required this.onSend});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: ctrl,
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
                color: AppColors.blueLight, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: AppColors.white, size: 18),
            ),
          ),
        ]),
      );
}