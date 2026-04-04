import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../shared/app_scaffold.dart';
import '../shared/components.dart';
import '../shared/models.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // [BDD] Ces appels seront remplacés par de vrais fetch async (FutureBuilder / Riverpod / Bloc)
  UserModel get _user             => UserModel.placeholder();
  MentorModel get _mentor         => MentorModel.placeholder();
  GoalModel get _goal             => GoalModel.placeholder();
  SessionModel get _session       => SessionModel.placeholder();
  List<ResourceModel> get _resources => ResourceModel.placeholders();
  List<MessageModel> get _messages   => MessageModel.placeholders();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navIndex: 1,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(user: _user),
            const SizedBox(height: 16),
            _padded(_MentorCard(mentor: _mentor)),
            const SizedBox(height: 12),
            _padded(_EvolutionCard(goal: _goal)),
            const SizedBox(height: 12),
            _padded(_ResourcesCard(resources: _resources)),
            const SizedBox(height: 12),
            _FindMentorSection(),
            const SizedBox(height: 12),
            _padded(_NextSessionCard(session: _session)),
            const SizedBox(height: 12),
            _padded(_MessagesCard(messages: _messages)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _padded(Widget w) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: w);
}

// ─── HEADER ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final UserModel user;
  const _Header({required this.user});

  String _formatLastLogin(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inHours < 1)   return 'il y a ${diff.inMinutes} min';
    if (diff.inDays < 1)    return 'aujourd\'hui à ${DateFormat('HH:mm').format(dt)}';
    return DateFormat('dd/MM/yyyy à HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bienvenue, ${user.fullName}', style: AppText.h1),
              const SizedBox(height: 4),
              Text('Dernière connexion : ${_formatLastLogin(user.lastLogin)}',
                  style: AppText.small),
            ]),
            ElevatedButton.icon(
              onPressed: () {}, // [NAV] → AccountPage
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text('Modifier\nmon profil',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, height: 1.3)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLight,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
}

// ─── MON MENTOR ───────────────────────────────────────────────────────────────
class _MentorCard extends StatelessWidget {
  final MentorModel mentor;
  const _MentorCard({required this.mentor});

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle(icon: Icons.person_outline, title: 'Mon mentor'),
          const SizedBox(height: 14),
          Row(children: [
            // [BDD] Remplacer par NetworkImage(mentor.avatarUrl) quand dispo
            const CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.blueSurface,
              child: Icon(Icons.person, color: AppColors.blue, size: 28),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mentor.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.blue)),
              Text(mentor.specialty, style: AppText.small),
            ]),
          ]),
          const SizedBox(height: 12),
          if (mentor.currentQuote != null)
            Text(mentor.currentQuote!,
                style: AppText.body.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[700])),
          const SizedBox(height: 12),
          LinkRow(
            icon: Icons.chat_bubble_outline,
            label: 'Envoyer un message',
            onTap: () {}, // [NAV] → MessagesPage(mentorId: mentor.id)
          ),
        ]),
      );
}

// ─── MON ÉVOLUTION ────────────────────────────────────────────────────────────
class _EvolutionCard extends StatelessWidget {
  final GoalModel goal;
  const _EvolutionCard({required this.goal});

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle(icon: Icons.trending_up, title: 'Mon évolution'),
          const SizedBox(height: 14),
          Text('Objectif actuel : ${goal.title}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.blue)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progressPercent,
              backgroundColor: AppColors.blueSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blueLight),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text('${(goal.progressPercent * 100).round()}% complété', style: AppText.caption),
          const SizedBox(height: 16),
          Text('Séances réalisées', style: AppText.label),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text('${goal.sessionsCompleted}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.blue)),
            const SizedBox(width: 6),
            Text('sur ${goal.sessionsTotal} prévues', style: AppText.small),
          ]),
          const SizedBox(height: 12),
          LinkRow(
            icon: Icons.description_outlined,
            label: 'Voir le détail',
            onTap: () {}, // [NAV] → GoalDetailPage(goalId: goal.id)
          ),
        ]),
      );
}

// ─── RESSOURCES RECOMMANDÉES ──────────────────────────────────────────────────
class _ResourcesCard extends StatelessWidget {
  final List<ResourceModel> resources;
  const _ResourcesCard({required this.resources});

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle(icon: Icons.library_books_outlined, title: 'Ressources recommandées'),
          const SizedBox(height: 14),
          ...resources.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ResourceItem(resource: r),
              )),
          LinkRow(
            icon: Icons.add,
            label: 'Voir toutes les ressources',
            onTap: () {}, // [NAV] → ResourcesPage
          ),
        ]),
      );
}

class _ResourceItem extends StatelessWidget {
  final ResourceModel resource;
  const _ResourceItem({required this.resource});

  IconData get _icon => switch (resource.type) {
        'pdf'   => Icons.picture_as_pdf_outlined,
        'video' => Icons.play_circle_outline,
        _       => Icons.article_outlined,
      };

  Color get _bgColor => switch (resource.type) {
        'pdf'   => AppColors.amberSurface,
        'video' => AppColors.blueSurface,
        _       => const Color(0xFFE8F5E9),
      };

  Color get _iconColor => switch (resource.type) {
        'pdf'   => AppColors.amber,
        'video' => AppColors.blueLight,
        _       => const Color(0xFF2E7D32),
      };

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {}, // [NAV] → ResourceDetailPage(resourceId: resource.id)
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(_icon, color: _iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(resource.title, style: AppText.label),
              const SizedBox(height: 2),
              Text(resource.meta, style: AppText.caption),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.grey, size: 18),
          ]),
        ),
      );
}

// ─── TROUVER UN MENTOR ────────────────────────────────────────────────────────
// [BDD] Sera alimentée par un fetch mentors avec filtres dynamiques
class _FindMentorSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle(icon: Icons.search, title: 'Trouver un mentor'),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text('Rechercher par mots-clés...',
                      style: TextStyle(color: Color(0xFFADB5BD), fontSize: 13)),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(6)),
                child: const Padding(padding: EdgeInsets.all(8),
                    child: Icon(Icons.search, color: AppColors.white, size: 18)),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Filtrer par :', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMedium)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _FilterDropdown(label: 'Type d\'accompagnement', value: 'Tous')),
                const SizedBox(width: 10),
                Expanded(child: _FilterDropdown(label: 'Région', value: 'Toutes régions')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _FilterInput(label: 'Métier (optionnel)', hint: 'Ex: Développeur, RH...')),
                const SizedBox(width: 10),
                Expanded(child: _FilterDropdown(label: 'Disponibilité', value: 'Tous')),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('Mentors recommandés',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.blue)),
          const SizedBox(height: 12),
          // [BDD] Remplacer par une liste dynamique depuis l'API
          _MentorResultCard(mentor: MentorModel.placeholder()),
        ]),
      );
}

class _MentorResultCard extends StatelessWidget {
  final MentorModel mentor;
  const _MentorResultCard({required this.mentor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // [BDD] Remplacer par NetworkImage(mentor.avatarUrl) quand dispo
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.purpleSurface,
              child: Icon(Icons.person, color: AppColors.purple, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mentor.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text)),
              const SizedBox(height: 4),
              Row(children: [
                ...List.generate(mentor.rating.floor(), (_) => const Icon(Icons.star, size: 14, color: AppColors.amber)),
                if (mentor.rating % 1 >= 0.5) const Icon(Icons.star_half, size: 14, color: AppColors.amber),
                const SizedBox(width: 4),
                Text('(${mentor.reviewCount})', style: AppText.caption),
              ]),
              const SizedBox(height: 4),
              Text(mentor.specialty, style: AppText.small),
            ])),
          ]),
          const SizedBox(height: 10),
          Text(mentor.bio, style: AppText.body),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: mentor.modes.map((m) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: TagChip(label: m),
                )).toList()),
            GestureDetector(
              onTap: () {}, // [NAV] → MentorProfilePage(mentorId: mentor.id)
              child: Row(children: [
                Text('Voir profil', style: AppText.link),
                const Icon(Icons.chevron_right, color: AppColors.blueLight, size: 16),
              ]),
            ),
          ]),
        ]),
      );
}

// ─── PROCHAINE SÉANCE ─────────────────────────────────────────────────────────
class _NextSessionCard extends StatelessWidget {
  final SessionModel session;
  const _NextSessionCard({required this.session});

  String _formatDate(DateTime dt) {
    const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return '${jours[dt.weekday - 1]} • ${DateFormat('HH\'h\'mm').format(dt)} - durée ${session.duration}';
  }

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle(icon: Icons.calendar_today_outlined, title: 'Prochaine séance'),
          const SizedBox(height: 14),
          Text(session.title, style: AppText.h3),
          const SizedBox(height: 10),
          _InfoRow(icon: Icons.access_time_outlined, text: _formatDate(session.date)),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.location_on_outlined, text: session.location),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: PrimaryBtn(
              label: session.isConfirmed ? 'Présence confirmée ✓' : 'Confirmer ma présence',
              icon: session.isConfirmed ? null : Icons.check,
              onTap: () {}, // [BDD] UPDATE sessions SET confirmed_by_user = true WHERE id = session.id
            )),
            const SizedBox(width: 10),
            SecondaryBtn(
              label: 'Détails',
              icon: Icons.info_outline,
              onTap: () {}, // [NAV] → SessionDetailPage(sessionId: session.id)
            ),
          ]),
        ]),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: AppText.small)),
      ]);
}

// ─── MESSAGES RÉCENTS ─────────────────────────────────────────────────────────
class _MessagesCard extends StatelessWidget {
  final List<MessageModel> messages;
  const _MessagesCard({required this.messages});

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle(icon: Icons.mail_outline, title: 'Messages récents'),
          const SizedBox(height: 14),
          ...messages.asMap().entries.map((e) => Column(children: [
                _MessageItem(message: e.value),
                if (e.key < messages.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
              ])),
          const SizedBox(height: 14),
          LinkRow(
            icon: Icons.mail_outline,
            label: 'Voir tous les messages',
            onTap: () {}, // [NAV] → MessagesPage
          ),
        ]),
      );
}

class _MessageItem extends StatelessWidget {
  final MessageModel message;
  const _MessageItem({required this.message});

  IconData get _avatarIcon => switch (message.senderType) {
        'support' => Icons.support_agent,
        'mentor'  => Icons.person,
        _         => Icons.person_outline,
      };

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Aujourd\'hui à ${DateFormat('HH:mm').format(dt)}';
    if (diff.inDays == 1) return 'Hier à ${DateFormat('HH:mm').format(dt)}';
    if (diff.inDays == 2) return 'Avant-hier à ${DateFormat('HH:mm').format(dt)}';
    return DateFormat('dd/MM').format(dt);
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: AppColors.blueSurface,
              child: Icon(_avatarIcon, color: AppColors.blue, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(message.senderName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.text)),
            Row(children: [
              if (!message.isRead) ...[const AppBadge(label: 'Nouveau'), const SizedBox(width: 6)],
              Text(_formatTime(message.sentAt), style: AppText.caption),
            ]),
          ])),
        ]),
        const SizedBox(height: 8),
        Text(message.preview, style: AppText.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        LinkRow(
          icon: Icons.reply,
          label: 'Répondre',
          onTap: () {}, // [NAV] → MessagesPage(messageId: message.id)
        ),
      ]);
}

// ─── FILTER HELPERS ───────────────────────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  const _FilterDropdown({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              Expanded(child: Text(value, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.grey),
            ]),
          ),
        ],
      );
}

class _FilterInput extends StatelessWidget {
  final String label;
  final String hint;
  const _FilterInput({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(6)),
            child: Text(hint, style: const TextStyle(fontSize: 12, color: Color(0xFFADB5BD)), overflow: TextOverflow.ellipsis),
          ),
        ],
      );
}