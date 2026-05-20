import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../shared/app_scaffold.dart';
import '../shared/components.dart';
import '../shared/models.dart';
import '../shared/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  UserModel? _user;
  List<RessourceModel> _ressources = [];
  List<ConversationModel> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = ApiService.session;
    if (session == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    try {
      // Requêtes obligatoires
      final userResult = await ApiService.fetchUtilisateur(session.id);
      final ressourcesResult = await ApiService.fetchRessources();

      // Requête optionnelle : ne fait pas planter si elle échoue
      List conversations = [];
      try {
        conversations = await ApiService.fetchConversations(session.id);
      } catch (_) {
        // Pas de conversations, c'est normal
      }

      setState(() {
        _user = UserModel.fromJson(userResult as Map<String, dynamic>);
        _ressources = (ressourcesResult as List)
            .map((r) => RessourceModel.fromJson(r as Map<String, dynamic>))
            .take(2)
            .toList();
        _conversations = conversations
            .map((c) => ConversationModel.fromJson(c as Map<String, dynamic>))
            .take(3)
            .toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('ERREUR DASHBOARD: $e');
      setState(() {
        _user = UserModel.placeholder();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AppScaffold(
        navIndex: 1,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.blueLight),
        ),
      );
    }
    return AppScaffold(
      navIndex: 1,
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(user: _user!),
              const SizedBox(height: 16),
              if (_ressources.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _RessourcesCard(ressources: _ressources),
                ),
                const SizedBox(height: 12),
              ],
              if (_conversations.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _MessagesCard(conversations: _conversations),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HEADER ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final UserModel user;
  const _Header({required this.user});

  String _formatLogin(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inHours < 1) return 'il y a ${diff.inMinutes} min';
    if (diff.inDays < 1)
      return 'aujourd\'hui à ${DateFormat('HH:mm').format(dt)}';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.white,
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenue, ${user.fullName}', style: AppText.h1),
            const SizedBox(height: 4),
            Text(
              'Dernière connexion : ${_formatLogin(user.lastLogin)}',
              style: AppText.small,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/account'),
          icon: const Icon(Icons.edit_outlined, size: 14),
          label: const Text('Mon profil', style: TextStyle(fontSize: 11)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueLight,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
    ),
  );
}

// ─── RESSOURCES ───────────────────────────────────────────────────────────────
class _RessourcesCard extends StatelessWidget {
  final List<RessourceModel> ressources;
  const _RessourcesCard({required this.ressources});

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          icon: Icons.library_books_outlined,
          title: 'Ressources récentes',
        ),
        const SizedBox(height: 14),
        ...ressources.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/ressources'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blueSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.article_outlined,
                      color: AppColors.blueLight,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.titre,
                            style: AppText.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(r.typeLabel, style: AppText.caption),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.grey,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        LinkRow(
          icon: Icons.add,
          label: 'Voir toutes les ressources',
          onTap: () {},
        ),
      ],
    ),
  );
}

// ─── MESSAGES ─────────────────────────────────────────────────────────────────
class _MessagesCard extends StatelessWidget {
  final List<ConversationModel> conversations;
  const _MessagesCard({required this.conversations});

  @override
  Widget build(BuildContext context) {
    final myId = ApiService.session?.id ?? 0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            icon: Icons.mail_outline,
            title: 'Messages récents',
          ),
          const SizedBox(height: 14),
          ...conversations.asMap().entries.map(
            (e) => Column(
              children: [
                _ConvItem(conv: e.value, myId: myId),
                if (e.key < conversations.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LinkRow(
            icon: Icons.mail_outline,
            label: 'Voir tous les messages',
            onTap: () => Navigator.pushNamed(context, '/messages'),
          ),
        ],
      ),
    );
  }
}

class _ConvItem extends StatelessWidget {
  final ConversationModel conv;
  final int myId;
  const _ConvItem({required this.conv, required this.myId});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.blueSurface,
        child: const Icon(Icons.person, color: AppColors.blue, size: 18),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  conv.contactName(myId),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(conv.lastMessageAt),
                  style: AppText.caption,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              conv.lastMessagePreview,
              style: AppText.small,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ],
  );
}
