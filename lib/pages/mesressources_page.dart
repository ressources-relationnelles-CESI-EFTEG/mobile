import 'package:flutter/material.dart';
import '../shared/app_scaffold.dart';
import '../shared/api_service.dart';
import '../shared/models.dart';
import 'login_page.dart' show FCInfoBanner, FCPrimaryBtn;

class MesRessourcesPage extends StatefulWidget {
  const MesRessourcesPage({super.key});
  @override
  State<MesRessourcesPage> createState() => _MesRessourcesPageState();
}

class _MesRessourcesPageState extends State<MesRessourcesPage> {
  static const _blue     = Color(0xFF1C3177);
  static const _textDark = Color(0xFF1A1A1A);
  static const _textGrey = Color(0xFF666666);
  static const _bgGrey   = Color(0xFFF5F5F5);
  static const _border   = Color(0xFFDDDDDD);

  List<RessourceModel> _mesRessources     = [];
  List<RessourceModel> _ressourcesPartagees = [];
  List<Map<String, dynamic>> _categories  = [];
  bool _loading = true;

  // Filtres
  String _filterType       = 'Tous les types';
  String _filterCategorie  = 'Toutes';
  String _filterVisibilite = 'Toutes';
  String _filterStatut     = 'Tous les statuts';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = ApiService.session;
    if (session == null) return;
    try {
      final results = await Future.wait([
        ApiService.fetchRessourcesUtilisateur(session.id),
        ApiService.fetchRessources(),
        ApiService.fetchCategories(),
      ]);
      final toutes = (results[1] as List)
          .map((r) => RessourceModel.fromJson(r as Map<String, dynamic>))
          .toList();
      setState(() {
        _mesRessources = (results[0] as List)
            .map((r) => RessourceModel.fromJson(r as Map<String, dynamic>))
            .toList();
        // Ressources partagées = ressources publiques pas de moi
        _ressourcesPartagees = toutes
            .where((r) => r.utilisateur?['idUtilisateur'] != session.id)
            .toList();
        _categories = List<Map<String, dynamic>>.from(results[2] as List);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _resetFiltres() => setState(() {
    _filterType       = 'Tous les types';
    _filterCategorie  = 'Toutes';
    _filterVisibilite = 'Toutes';
    _filterStatut     = 'Tous les statuts';
  });

  List<RessourceModel> _applyFilters(List<RessourceModel> list) {
    return list.where((r) {
      final typeOk = _filterType == 'Tous les types' ||
          r.typeRessource?.toLowerCase() == _filterType.toLowerCase();
      final catOk = _filterCategorie == 'Toutes' ||
          (r.categorie?['nom'] == _filterCategorie);
      final visOk = _filterVisibilite == 'Toutes' ||
          r.visibilite.toLowerCase() == _filterVisibilite.toLowerCase();
      final statOk = _filterStatut == 'Tous les statuts' ||
          r.statut.toLowerCase() == _filterStatut.toLowerCase();
      return typeOk && catOk && visOk && statOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMes      = _applyFilters(_mesRessources);
    final filteredPartagees = _applyFilters(_ressourcesPartagees);
    final catOptions = ['Toutes', ..._categories.map((c) => c['nom'].toString())];

    return AppScaffold(
      navIndex: 3,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1C3177)))
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // ── Header ──────────────────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Breadcrumb
                        Row(children: [
                          _BreadcrumbLink(label: 'Accueil', onTap: () => Navigator.pushReplacementNamed(context, '/dashboard')),
                          const _BreadcrumbSep(),
                          _BreadcrumbLink(label: 'Mon compte', onTap: () => Navigator.pushNamed(context, '/account')),
                          const _BreadcrumbSep(),
                          const Text('Mes ressources', style: TextStyle(fontSize: 12, color: _textDark)),
                        ]),
                        const SizedBox(height: 16),
                        Row(children: [
                          const Icon(Icons.folder_outlined, size: 26, color: _textDark),
                          const SizedBox(width: 10),
                          const Expanded(child: Text('Mes ressources',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark))),
                        ]),
                        const SizedBox(height: 6),
                        const Text('Gérez vos ressources personnelles et partagées',
                            style: TextStyle(fontSize: 13, color: _textGrey)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/add-ressource'),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Créer une ressource',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: _border),

                  // ── Filtres ─────────────────────────────────────────────
                  Container(
                    color: _bgGrey,
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.filter_list, size: 18, color: _textDark),
                        SizedBox(width: 8),
                        Text('Filtrer :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                      ]),
                      const SizedBox(height: 16),
                      // Ligne 1 : Type + Catégorie
                      Row(children: [
                        Expanded(child: _FilterCol(
                          label: 'Type',
                          value: _filterType,
                          options: const ['Tous les types', 'Article', 'Video', 'Audio', 'Exercice', 'Activite', 'Jeu'],
                          onChanged: (v) => setState(() => _filterType = v),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _FilterCol(
                          label: 'Catégorie',
                          value: _filterCategorie,
                          options: catOptions,
                          onChanged: (v) => setState(() => _filterCategorie = v),
                        )),
                      ]),
                      const SizedBox(height: 12),
                      // Ligne 2 : Visibilité + Statut
                      Row(children: [
                        Expanded(child: _FilterCol(
                          label: 'Visibilité',
                          value: _filterVisibilite,
                          options: const ['Toutes', 'Privee', 'Partagee', 'Publique'],
                          onChanged: (v) => setState(() => _filterVisibilite = v),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _FilterCol(
                          label: 'Statut',
                          value: _filterStatut,
                          options: const ['Tous les statuts', 'Brouillon', 'En_attente', 'Validee', 'Rejetee'],
                          onChanged: (v) => setState(() => _filterStatut = v),
                        )),
                      ]),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _resetFiltres,
                        child: const Row(children: [
                          Icon(Icons.refresh, size: 14, color: _blue),
                          SizedBox(width: 4),
                          Text('Réinitialiser les filtres',
                              style: TextStyle(fontSize: 13, color: _blue, decoration: TextDecoration.underline)),
                        ]),
                      ),
                    ]),
                  ),

                  // ── Mes ressources ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Text('Mes ressources',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark)),
                        const SizedBox(width: 10),
                        _CountBadge(count: filteredMes.length),
                      ]),
                      const SizedBox(height: 14),
                      if (filteredMes.isEmpty)
                        _EmptyBanner(
                          title: 'Aucune ressource trouvée',
                          subtitle: "Vous n'avez pas encore créé de ressource, ou aucune ne correspond aux filtres.",
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredMes.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
                          itemBuilder: (_, i) => _RessourceRow(
                            ressource: filteredMes[i],
                            onDelete: () async {
                              await ApiService.deleteRessource(filteredMes[i].id);
                              _load();
                            },
                          ),
                        ),
                      const SizedBox(height: 32),

                      // ── Ressources partagées avec moi ─────────────────
                      Row(children: [
                        const Text('Ressources partagées avec moi',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark)),
                        const SizedBox(width: 10),
                        _CountBadge(count: filteredPartagees.length),
                      ]),
                      const SizedBox(height: 14),
                      if (filteredPartagees.isEmpty)
                        _EmptyBanner(
                          title: 'Aucune ressource partagée',
                          subtitle: 'Aucune ressource ne vous a encore été partagée, ou aucune ne correspond aux filtres.',
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredPartagees.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
                          itemBuilder: (_, i) => _RessourceRow(ressource: filteredPartagees[i]),
                        ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ]),
              ),
            ),
    );
  }
}

// ─── RESSOURCE ROW ────────────────────────────────────────────────────────────
class _RessourceRow extends StatelessWidget {
  final RessourceModel ressource;
  final VoidCallback? onDelete;
  const _RessourceRow({required this.ressource, this.onDelete});

  static const _blue     = Color(0xFF1C3177);
  static const _textDark = Color(0xFF1A1A1A);
  static const _textGrey = Color(0xFF666666);

  Color get _statutColor => switch (ressource.statut.toLowerCase()) {
        'validee'    => const Color(0xFF18753C),
        'en_attente' => const Color(0xFFB34000),
        'rejetee'    => const Color(0xFFCE0500),
        _            => const Color(0xFF666666),
      };

  String get _statutLabel => switch (ressource.statut.toLowerCase()) {
        'validee'    => 'Validée',
        'en_attente' => 'En attente',
        'rejetee'    => 'Rejetée',
        _            => 'Brouillon',
      };

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Icône type
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0F8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.article_outlined, color: _blue, size: 20),
          ),
          const SizedBox(width: 14),

          // Contenu
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ressource.titre,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _blue)),
            const SizedBox(height: 4),
            if (ressource.description != null)
              Text(ressource.description!,
                  style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.4),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 4, children: [
              _Tag(label: ressource.typeLabel, color: _blue),
              if (ressource.categorie != null)
                _Tag(label: ressource.categorie!['nom'] ?? '', color: const Color(0xFF555555)),
              _Tag(label: _statutLabel, color: _statutColor),
            ]),
          ])),

          // Actions
          if (onDelete != null)
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Supprimer'),
                  content: Text('Supprimer "${ressource.titre}" ?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                    TextButton(
                      onPressed: () { Navigator.pop(context); onDelete!(); },
                      child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.delete_outline, color: Color(0xFFCE0500), size: 20),
              ),
            ),
        ]),
      );
}

// ─── EMPTY BANNER ─────────────────────────────────────────────────────────────
class _EmptyBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEF0F8),
          border: Border.all(color: const Color(0xFF1C3177).withOpacity(0.4)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1C3177),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)),
            ),
            child: const Center(child: Text('i',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic))),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.5)),
            ]),
          )),
        ]),
      );
}

// ─── HELPERS ──────────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: const Color(0xFF1C3177), borderRadius: BorderRadius.circular(10)),
        child: Text(count.toString(), style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
      );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      );
}

class _BreadcrumbLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _BreadcrumbLink({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF1C3177), decoration: TextDecoration.underline)),
      );
}

class _BreadcrumbSep extends StatelessWidget {
  const _BreadcrumbSep();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Text('›', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
      );
}

class _FilterCol extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _FilterCol({required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A), width: 1.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              isExpanded: true,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF1A1A1A)),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ),
        ),
      ]);
}