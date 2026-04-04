import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../shared/app_scaffold.dart';
import '../shared/components.dart';
import '../shared/models.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // [BDD] À remplacer par de vrais fetch
  final UserModel _user = UserModel.placeholder();
  List<DocumentModel> _myDocs = DocumentModel.myDocumentsPlaceholders();
  List<DocumentModel> _sharedDocs = DocumentModel.sharedDocumentsPlaceholders();

  // Filtres
  String _filterType     = 'Tous';
  String _filterCategory = 'Tous';
  String _filterAuthor   = 'Tous';
  String _filterFavoris  = 'Tous';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navIndex: 4,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DonneesPersonnellesTab(user: _user),
                _PreferencesTab(),
                _buildRessourcesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Row(
          children: [
            // [BDD] Remplacer par NetworkImage(_user.avatarUrl)
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.blueSurface,
              child: const Icon(Icons.person, color: AppColors.blue, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Mon Compte', style: AppText.h1),
                const SizedBox(height: 4),
                Text('Gérez vos informations personnelles et vos préférences',
                    style: AppText.small),
              ]),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
              icon: const Icon(Icons.arrow_back, size: 14),
              label: const Text('Tableau\nde bord',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, height: 1.3)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLight,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
      );

  // ── TAB BAR ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() => Container(
        color: AppColors.white,
        child: TabBar(
          controller: _tabController,
          labelColor: AppColors.blueLight,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.blueLight,
          indicatorWeight: 2,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.person_outline, size: 18), text: 'Mes données'),
            Tab(icon: Icon(Icons.settings_outlined, size: 18), text: 'Préférences'),
            Tab(icon: Icon(Icons.folder_outlined, size: 18), text: 'Mes ressources'),
          ],
        ),
      );

  // ── ONGLET MES RESSOURCES ──────────────────────────────────────────────────
  Widget _buildRessourcesTab() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bouton enregistrer
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                PrimaryBtn(
                  label: 'Enregistrer les modifications',
                  icon: Icons.save_outlined,
                  onTap: () {}, // [BDD] PATCH documents SET is_favorite = ...
                ),
              ]),
            ),
            const SizedBox(height: 8),

            // Filtres
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFiltres(),
            ),
            const SizedBox(height: 16),

            // Mes documents
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Mes documents', style: AppText.h2),
            ),
            const SizedBox(height: 12),
            _buildDocumentCarousel(_myDocs, isOwned: true),
            const SizedBox(height: 16),

            // Importer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PrimaryBtn(
                label: 'Importer un document',
                icon: Icons.upload_outlined,
                onTap: () {}, // [BDD] POST documents (multipart upload)
              ),
            ),
            const SizedBox(height: 24),

            // Documents partagés
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Documents partagés', style: AppText.h2),
            ),
            const SizedBox(height: 12),
            _buildDocumentCarousel(_sharedDocs, isOwned: false),
            const SizedBox(height: 32),
          ],
        ),
      );

  // ── FILTRES ────────────────────────────────────────────────────────────────
  Widget _buildFiltres() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtrer :', style: AppText.h3.copyWith(color: AppColors.blueLight)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _FilterDropdown(
              label: 'Type',
              value: _filterType,
              options: const ['Tous', 'PDF', 'DOCX', 'PPTX'],
              onChanged: (v) => setState(() => _filterType = v),
            )),
            const SizedBox(width: 10),
            Expanded(child: _FilterDropdown(
              label: 'Catégorie',
              value: _filterCategory,
              options: const ['Tous', 'CV', 'Formation', 'Notes'],
              onChanged: (v) => setState(() => _filterCategory = v),
            )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _FilterDropdown(
              label: 'Auteur',
              value: _filterAuthor,
              options: const ['Tous', 'Jean P.', 'Sophie M.', 'Thomas L.'],
              onChanged: (v) => setState(() => _filterAuthor = v),
            )),
            const SizedBox(width: 10),
            Expanded(child: _FilterDropdown(
              label: 'Favoris',
              value: _filterFavoris,
              options: const ['Tous', 'Favoris uniquement'],
              onChanged: (v) => setState(() => _filterFavoris = v),
            )),
          ]),
        ],
      );

  // ── CAROUSEL DOCUMENTS ─────────────────────────────────────────────────────
  Widget _buildDocumentCarousel(List<DocumentModel> docs, {required bool isOwned}) =>
      SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _DocumentCard(
              doc: docs[i],
              isOwned: isOwned,
              onFavoriteToggle: () {
                // [BDD] PATCH documents SET is_favorite = !doc.isFavorite WHERE id = doc.id
                setState(() {
                  final list = isOwned ? _myDocs : _sharedDocs;
                  final idx = list.indexWhere((d) => d.id == docs[i].id);
                  if (idx != -1) {
                    final updated = DocumentModel(
                      id: list[idx].id,
                      title: list[idx].title,
                      fileType: list[idx].fileType,
                      sizeKb: list[idx].sizeKb,
                      isFavorite: !list[idx].isFavorite,
                      isShared: list[idx].isShared,
                      sharedBy: list[idx].sharedBy,
                      url: list[idx].url,
                    );
                    final newList = List<DocumentModel>.from(list)..[idx] = updated;
                    if (isOwned) _myDocs = newList;
                    else _sharedDocs = newList;
                  }
                });
              },
            ),
          ),
        ),
      );
}

// ─── CARTE DOCUMENT ───────────────────────────────────────────────────────────
class _DocumentCard extends StatelessWidget {
  final DocumentModel doc;
  final bool isOwned;
  final VoidCallback onFavoriteToggle;

  const _DocumentCard({
    required this.doc,
    required this.isOwned,
    required this.onFavoriteToggle,
  });

  IconData get _fileIcon => switch (doc.fileType.toLowerCase()) {
        'pdf'  => Icons.picture_as_pdf_outlined,
        'docx' => Icons.description_outlined,
        'pptx' => Icons.slideshow_outlined,
        _      => Icons.insert_drive_file_outlined,
      };

  @override
  Widget build(BuildContext context) => Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Icône + favori
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blueSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_fileIcon, color: AppColors.blueLight, size: 22),
            ),
            GestureDetector(
              onTap: onFavoriteToggle,
              child: Icon(
                doc.isFavorite ? Icons.star : Icons.star_border,
                color: doc.isFavorite ? AppColors.amber : AppColors.grey,
                size: 20,
              ),
            ),
          ]),
          const SizedBox(height: 10),

          // Titre
          Text(doc.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.blueLight),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(doc.meta, style: AppText.caption),
          if (doc.sharedBy != null) ...[
            const SizedBox(height: 2),
            Text('Partagé par: ${doc.sharedBy}', style: AppText.caption),
          ],
          const Spacer(),

          // Boutons d'action
          Row(children: [
            _ActionBtn(
              label: 'Voir',
              icon: Icons.visibility_outlined,
              color: AppColors.blueLight,
              onTap: () {}, // [NAV] → DocumentViewerPage(doc.url)
            ),
            const SizedBox(width: 6),
            _ActionBtn(
              label: '',
              icon: isOwned ? Icons.delete_outline : Icons.share_outlined,
              color: isOwned ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
              onTap: () {}, // [BDD] DELETE ou share
            ),
          ]),
        ]),
      );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: label.isEmpty ? 8 : 10, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: AppColors.white, size: 14),
            if (label.isNotEmpty) ...[const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600))],
          ]),
        ),
      );
}

// ─── ONGLET DONNÉES PERSONNELLES (placeholder) ────────────────────────────────
class _DonneesPersonnellesTab extends StatelessWidget {
  final UserModel user;
  const _DonneesPersonnellesTab({required this.user});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionTitle(icon: Icons.person_outline, title: 'Informations personnelles'),
            const SizedBox(height: 16),
            _FieldPlaceholder(label: 'Prénom', value: user.firstName),        // [BDD] users.first_name
            const SizedBox(height: 12),
            _FieldPlaceholder(label: 'Nom', value: user.lastName),             // [BDD] users.last_name
            const SizedBox(height: 12),
            const _FieldPlaceholder(label: 'Email', value: 'marie.dupont@sante.gouv.fr'), // [BDD] users.email
            const SizedBox(height: 12),
            const _FieldPlaceholder(label: 'Téléphone', value: '+33 6 00 00 00 00'),      // [BDD] users.phone
            const SizedBox(height: 12),
            const _FieldPlaceholder(label: 'Ministère / Service', value: 'DSI – Pôle numérique'), // [BDD] users.department
            const SizedBox(height: 20),
            PrimaryBtn(label: 'Enregistrer', icon: Icons.save_outlined, onTap: () {}), // [BDD] PATCH users
          ]),
        ),
      );
}

class _FieldPlaceholder extends StatelessWidget {
  final String label;
  final String value;
  const _FieldPlaceholder({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.greyLight,
            ),
            child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.text)),
          ),
        ],
      );
}

// ─── ONGLET PRÉFÉRENCES (placeholder) ─────────────────────────────────────────
class _PreferencesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionTitle(icon: Icons.settings_outlined, title: 'Mes préférences'),
            const SizedBox(height: 16),
            _PrefSwitch(label: 'Notifications email', value: true),           // [BDD] users.notif_email
            const SizedBox(height: 12),
            _PrefSwitch(label: 'Notifications push', value: false),           // [BDD] users.notif_push
            const SizedBox(height: 12),
            _PrefSwitch(label: 'Partage de profil visible', value: true),     // [BDD] users.profile_visible
            const SizedBox(height: 20),
            PrimaryBtn(label: 'Enregistrer', icon: Icons.save_outlined, onTap: () {}), // [BDD] PATCH users
          ]),
        ),
      );
}

class _PrefSwitch extends StatefulWidget {
  final String label;
  final bool value;
  const _PrefSwitch({required this.label, required this.value});

  @override
  State<_PrefSwitch> createState() => _PrefSwitchState();
}

class _PrefSwitchState extends State<_PrefSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.label, style: AppText.body),
          Switch(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
            activeColor: AppColors.blueLight,
          ),
        ],
      );
}

// ─── HELPERS ──────────────────────────────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(6),
              color: AppColors.white,
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              style: const TextStyle(fontSize: 12, color: AppColors.text),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ),
        ],
      );
}