import 'package:flutter/material.dart';
import '../shared/app_scaffold.dart';
import '../shared/api_service.dart';
import '../shared/models.dart';

// ════════════════════════════════════════════════════════════════════════════
// PAGE LISTE DES RESSOURCES
// ════════════════════════════════════════════════════════════════════════════
class RessourcesPage extends StatefulWidget {
  const RessourcesPage({super.key});
  @override
  State<RessourcesPage> createState() => _RessourcesPageState();
}

class _RessourcesPageState extends State<RessourcesPage> {
  static const _blue = Color(0xFF1C3177);
  static const _textDark = Color(0xFF1A1A1A);
  static const _textGrey = Color(0xFF666666);
  static const _bgGrey = Color(0xFFF5F5F5);
  static const _border = Color(0xFFDDDDDD);

  List<RessourceModel> _ressources = [];
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;
  String? _error;

  // Filtres
  String _filtreType = '';
  String _filtreCategorie = '';

  final List<Map<String, String>> _typesRessource = const [
    {'value': '', 'label': 'Tous les types'},
    {'value': 'ARTICLE', 'label': 'Article'},
    {'value': 'VIDEO', 'label': 'Vidéo'},
    {'value': 'AUDIO', 'label': 'Audio'},
    {'value': 'EXERCICE', 'label': 'Exercice'},
    {'value': 'ACTIVITE', 'label': 'Activité'},
    {'value': 'JEU', 'label': 'Jeu'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService.fetchRessources(),
        ApiService.fetchCategories(),
      ]);
      setState(() {
        _ressources = (results[0] as List)
            .map((r) => RessourceModel.fromJson(r as Map<String, dynamic>))
            .toList();
        _categories = List<Map<String, dynamic>>.from(results[1] as List);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les ressources.';
        _loading = false;
      });
    }
  }

  List<RessourceModel> get _filtered => _ressources.where((r) {
    final typeOk =
        _filtreType.isEmpty || (r.typeRessource?.toUpperCase() == _filtreType);
    final catOk =
        _filtreCategorie.isEmpty ||
        (r.categorie?['idCategorie']?.toString() == _filtreCategorie);
    return typeOk && catOk;
  }).toList();

  void _resetFiltres() => setState(() {
    _filtreType = '';
    _filtreCategorie = '';
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navIndex: 3,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Header ───────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Erreur ───────────────────────────────────────────────────
            if (_error != null) SliverToBoxAdapter(child: _buildError()),

            // ── Chargement ───────────────────────────────────────────────
            if (_loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF1C3177)),
                ),
              )
            else ...[
              // ── Filtres ─────────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildFiltres()),

              // ── Résultats ────────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildResultsHeader()),

              if (_filtered.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RessourceCard(
                          ressource: _filtered[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RessourceDetailPage(id: _filtered[i].id),
                            ),
                          ),
                        ),
                      ),
                      childCount: _filtered.length,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb
        Row(
          children: [
            GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/dashboard'),
              child: const Text(
                'Accueil',
                style: TextStyle(
                  fontSize: 12,
                  color: _blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '›',
                style: TextStyle(fontSize: 12, color: _textGrey),
              ),
            ),
            const Text(
              'Ressources',
              style: TextStyle(fontSize: 12, color: _textDark),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.folder_outlined, size: 24, color: _textDark),
                      SizedBox(width: 8),
                      Text(
                        'Ressources',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Découvrez toutes les ressources publiées par la communauté',
                    style: TextStyle(fontSize: 13, color: _textGrey),
                  ),
                ],
              ),
            ),
            if (ApiService.isLoggedIn)
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/add-ressource'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Créer',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  elevation: 0,
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _buildFiltres() => Container(
    color: _bgGrey,
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.filter_list, size: 16, color: _textDark),
            SizedBox(width: 6),
            Text(
              'Filtrer :',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FilterCol(
                label: 'Type',
                value: _filtreType,
                items: _typesRessource
                    .map(
                      (t) => DropdownMenuItem(
                        value: t['value']!,
                        child: Text(t['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _filtreType = v ?? ''),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterCol(
                label: 'Catégorie',
                value: _filtreCategorie,
                items: [
                  const DropdownMenuItem(value: '', child: Text('Toutes')),
                  ..._categories.map(
                    (c) => DropdownMenuItem(
                      value: c['idCategorie'].toString(),
                      child: Text(c['nom'].toString()),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _filtreCategorie = v ?? ''),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _resetFiltres,
          child: const Row(
            children: [
              Icon(Icons.refresh, size: 14, color: _blue),
              SizedBox(width: 4),
              Text(
                'Réinitialiser les filtres',
                style: TextStyle(
                  fontSize: 12,
                  color: _blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildResultsHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Row(
      children: [
        const Text(
          'Toutes les ressources',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _filtered.length.toString(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => Padding(
    padding: const EdgeInsets.all(16),
    child: _InfoBanner(
      title: 'Aucune ressource trouvée',
      text: 'Aucune ressource ne correspond aux filtres sélectionnés.',
    ),
  );

  Widget _buildError() => Padding(
    padding: const EdgeInsets.all(16),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        border: Border.all(color: const Color(0xFFFCA5A5)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── RESSOURCE CARD ───────────────────────────────────────────────────────────
class _RessourceCard extends StatelessWidget {
  final RessourceModel ressource;
  final VoidCallback onTap;
  const _RessourceCard({required this.ressource, required this.onTap});

  static const _blue = Color(0xFF1C3177);
  static const _textDark = Color(0xFF1A1A1A);
  static const _textGrey = Color(0xFF666666);
  static const _border = Color(0xFFDDDDDD);

  IconData get _icon => switch (ressource.typeRessource?.toUpperCase()) {
    'VIDEO' => Icons.videocam_outlined,
    'AUDIO' => Icons.headphones_outlined,
    'EXERCICE' => Icons.fitness_center_outlined,
    'ACTIVITE' => Icons.event_outlined,
    'JEU' => Icons.gamepad_outlined,
    _ => Icons.article_outlined,
  };

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _nomAuteur() {
    final u = ressource.utilisateur;
    if (u == null) return 'Anonyme';
    final p = u['prenom'] ?? '';
    final n = u['nom'] ?? '';
    return '$p $n'.trim().isEmpty ? 'Anonyme' : '$p $n'.trim();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Corps
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type
                Row(
                  children: [
                    Icon(_icon, size: 16, color: _textGrey),
                    const SizedBox(width: 6),
                    Text(
                      ressource.typeLabel,
                      style: const TextStyle(fontSize: 12, color: _textGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Titre
                Text(
                  ressource.titre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _blue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Description
                if (ressource.description != null &&
                    ressource.description!.isNotEmpty)
                  Text(
                    ressource.description!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textGrey,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 10),

                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (ressource.categorie != null)
                      _Tag(label: ressource.categorie!['nom'] ?? ''),
                    _Tag(label: ressource.typeLabel),
                  ],
                ),
                const SizedBox(height: 10),

                // Métadonnées
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: _textGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _nomAuteur(),
                      style: const TextStyle(fontSize: 12, color: _textGrey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: _textGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(ressource.dateCreation),
                      style: const TextStyle(fontSize: 12, color: _textGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 14, color: _blue),
                const SizedBox(width: 6),
                Text(
                  'Voir',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 18, color: _textGrey),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// PAGE DÉTAIL RESSOURCE
// ════════════════════════════════════════════════════════════════════════════
class RessourceDetailPage extends StatefulWidget {
  final int id;
  const RessourceDetailPage({super.key, required this.id});

  @override
  State<RessourceDetailPage> createState() => _RessourceDetailPageState();
}

class _RessourceDetailPageState extends State<RessourceDetailPage> {
  static const _blue = Color(0xFF1C3177);
  static const _textDark = Color(0xFF1A1A1A);
  static const _textGrey = Color(0xFF666666);
  static const _bgGrey = Color(0xFFF5F5F5);
  static const _border = Color(0xFFDDDDDD);

  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.fetchRessource(widget.id);
      setState(() {
        _data = data;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.isNotFound
            ? 'Cette ressource est introuvable.'
            : 'Impossible de charger cette ressource.';
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Impossible de charger cette ressource.';
        _loading = false;
      });
    }
  }

  Future<void> _supprimer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text(
          'Supprimer « ${_data!['titre']} » ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ApiService.deleteRessource(widget.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  bool get _isModo {
    final role = ApiService.session?.role.toLowerCase() ?? '';
    return ['moderateur', 'administrateur', 'super_admin'].contains(role);
  }

  String _labelType(String? type) => switch (type?.toUpperCase()) {
    'VIDEO' => 'Vidéo',
    'AUDIO' => 'Audio',
    'EXERCICE' => 'Exercice',
    'ACTIVITE' => 'Activité',
    'JEU' => 'Jeu',
    _ => 'Article',
  };

  String _labelRelation(String? type) => switch (type?.toUpperCase()) {
    'FAMILLE' => 'Famille',
    'COUPLE' => 'Couple',
    'AMITIE' => 'Amitié',
    'PROFESSIONNEL' => 'Professionnel',
    'COMMUNAUTAIRE' => 'Communautaire',
    _ => type ?? '',
  };

  String _labelNiveau(String? n) => switch (n?.toUpperCase()) {
    'DEBUTANT' => 'Débutant',
    'INTERMEDIAIRE' => 'Intermédiaire',
    'AVANCE' => 'Avancé',
    _ => n ?? '',
  };

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '—';
    return '${dt.day} ${_mois(dt.month)} ${dt.year}';
  }

  String _mois(int m) => const [
    '',
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ][m];

  String _nomAuteur(Map<String, dynamic>? u) {
    if (u == null) return 'Anonyme';
    final p = u['prenom'] ?? '';
    final n = u['nom'] ?? '';
    return '$p $n'.trim().isEmpty ? 'Anonyme' : '$p $n'.trim();
  }

  IconData _iconType(String? type) => switch (type?.toUpperCase()) {
    'VIDEO' => Icons.videocam_outlined,
    'AUDIO' => Icons.headphones_outlined,
    'EXERCICE' => Icons.fitness_center_outlined,
    'ACTIVITE' => Icons.event_outlined,
    'JEU' => Icons.gamepad_outlined,
    _ => Icons.article_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _data?['titre'] ?? 'Ressource',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFDDDDDD)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : _error != null
          ? _buildError()
          : _buildContent(),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(fontSize: 15, color: _textDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Retour aux ressources'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              side: const BorderSide(color: _blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildContent() {
    final d = _data!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Breadcrumb ──────────────────────────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/dashboard'),
                child: const Text(
                  'Accueil',
                  style: TextStyle(
                    fontSize: 12,
                    color: _blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '›',
                  style: TextStyle(fontSize: 12, color: _textGrey),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Ressources',
                  style: TextStyle(
                    fontSize: 12,
                    color: _blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '›',
                  style: TextStyle(fontSize: 12, color: _textGrey),
                ),
              ),
              Expanded(
                child: Text(
                  d['titre'] ?? '',
                  style: const TextStyle(fontSize: 12, color: _textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Type ─────────────────────────────────────────────────────────
          Row(
            children: [
              Icon(_iconType(d['typeRessource']), size: 16, color: _textGrey),
              const SizedBox(width: 6),
              Text(
                _labelType(d['typeRessource']),
                style: const TextStyle(fontSize: 12, color: _textGrey),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Titre ─────────────────────────────────────────────────────────
          Text(
            d['titre'] ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // ── Description ───────────────────────────────────────────────────
          if (d['description'] != null &&
              d['description'].toString().isNotEmpty) ...[
            Text(
              d['description'],
              style: const TextStyle(
                fontSize: 15,
                color: _textGrey,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Tags ─────────────────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (d['categorie'] != null)
                _Tag(label: d['categorie']['nom'] ?? ''),
              if (d['typeRelation'] != null)
                _Tag(label: _labelRelation(d['typeRelation'])),
              if (d['niveauDifficulte'] != null)
                _Tag(label: _labelNiveau(d['niveauDifficulte'])),
            ],
          ),
          const SizedBox(height: 20),

          // ── Séparateur ─────────────────────────────────────────────────
          const Divider(color: _border, height: 1),
          const SizedBox(height: 20),

          // ── Contenu ───────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgGrey,
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: _textDark,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Contenu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  d['contenu'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textDark,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Lien externe ─────────────────────────────────────────────────
          if (d['lienPartage'] != null &&
              d['lienPartage'].toString().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0F8),
                border: Border.all(color: _blue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 16, color: _blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d['lienPartage'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: _blue,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Informations ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgGrey,
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: _textDark),
                    SizedBox(width: 6),
                    Text(
                      'Informations',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MetaRow(label: 'Auteur', value: _nomAuteur(d['utilisateur'])),
                if (d['categorie'] != null)
                  _MetaRow(
                    label: 'Catégorie',
                    value: d['categorie']['nom'] ?? '',
                  ),
                _MetaRow(label: 'Type', value: _labelType(d['typeRessource'])),
                if (d['typeRelation'] != null)
                  _MetaRow(
                    label: 'Relation',
                    value: _labelRelation(d['typeRelation']),
                  ),
                if (d['niveauDifficulte'] != null)
                  _MetaRow(
                    label: 'Niveau',
                    value: _labelNiveau(d['niveauDifficulte']),
                  ),
                _MetaRow(
                  label: 'Publié le',
                  value: _formatDate(d['dateCreation']),
                ),
                if (d['nombreVues'] != null)
                  _MetaRow(label: 'Vues', value: d['nombreVues'].toString()),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Actions ───────────────────────────────────────────────────────
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Retour', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _blue,
                  side: const BorderSide(color: _blue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (_isModo) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _supprimer,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text(
                    'Supprimer',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── COMPOSANTS PARTAGÉS ─────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFEEF0F8),
      borderRadius: BorderRadius.circular(2),
      border: Border.all(color: const Color(0xFF1C3177).withOpacity(0.2)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1C3177),
      ),
    ),
  );
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

class _InfoBanner extends StatelessWidget {
  final String title;
  final String text;
  const _InfoBanner({required this.title, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFEEF0F8),
      border: Border.all(color: const Color(0xFF1C3177).withOpacity(0.4)),
      borderRadius: BorderRadius.circular(2),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF1C3177),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(2),
              bottomLeft: Radius.circular(2),
            ),
          ),
          child: const Center(
            child: Text(
              'i',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF333333),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _FilterCol extends StatelessWidget {
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  const _FilterCol({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.any((i) => i.value == value) ? value : null,
            isExpanded: true,
            hint: Text(label, style: const TextStyle(fontSize: 12)),
            style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A)),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Color(0xFF1A1A1A),
            ),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}
