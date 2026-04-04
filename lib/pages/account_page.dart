import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../shared/app_scaffold.dart';
import '../shared/components.dart';
import '../shared/models.dart';
import '../shared/api_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _user;
  List<RessourceModel> _mesRessources = [];
  List<Map<String, dynamic>> _mesFavoris = [];
  List<Map<String, dynamic>> _mesProgressions = [];
  bool _loading = true;
  String _filterType = 'Tous';
  String _filterStatut = 'Tous';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final session = ApiService.session;
    if (session == null) return;
    try {
      final results = await Future.wait([
        ApiService.fetchUtilisateur(session.id),
        ApiService.fetchRessourcesUtilisateur(session.id),
        ApiService.fetchFavoris(session.id),
        ApiService.fetchProgressions(session.id),
      ]);
      setState(() {
        _user = UserModel.fromJson(results[0] as Map<String, dynamic>);
        _mesRessources = (results[1] as List).map((r) => RessourceModel.fromJson(r as Map<String, dynamic>)).toList();
        _mesFavoris = List<Map<String, dynamic>>.from(results[2] as List);
        _mesProgressions = List<Map<String, dynamic>>.from(results[3] as List);
        _loading = false;
      });
    } catch (_) {
      setState(() { _user = UserModel.placeholder(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navIndex: 4,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.blueLight))
          : Column(children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(child: TabBarView(
                controller: _tabController,
                children: [
                  _DonneesPersonnellesTab(user: _user!),
                  const _PreferencesTab(),
                  _buildRessourcesTab(),
                ],
              )),
            ]),
    );
  }

  Widget _buildHeader() => Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.blueSurface,
            backgroundImage: _user?.avatarUrl != null ? NetworkImage(_user!.avatarUrl!) : null,
            child: _user?.avatarUrl == null ? const Icon(Icons.person, color: AppColors.blue, size: 30) : null,
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Mon Compte', style: AppText.h1),
            const SizedBox(height: 4),
            Text(_user?.fullName ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.blueLight)),
          ])),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            icon: const Icon(Icons.arrow_back, size: 14),
            label: const Text('Tableau\nde bord', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, height: 1.3)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueLight, foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
            ),
          ),
        ]),
      );

  Widget _buildTabBar() => Container(
        color: AppColors.white,
        child: TabBar(
          controller: _tabController,
          labelColor: AppColors.blueLight, unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.blueLight, indicatorWeight: 2,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.person_outline, size: 18), text: 'Mes données'),
            Tab(icon: Icon(Icons.settings_outlined, size: 18), text: 'Préférences'),
            Tab(icon: Icon(Icons.folder_outlined, size: 18), text: 'Mes ressources'),
          ],
        ),
      );

  Widget _buildRessourcesTab() {
    final filtered = _mesRessources.where((r) {
      final typeOk = _filterType == 'Tous' || r.typeRessource?.toLowerCase() == _filterType.toLowerCase();
      final statutOk = _filterStatut == 'Tous' || r.statut.toLowerCase() == _filterStatut.toLowerCase();
      return typeOk && statutOk;
    }).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            color: AppColors.white, padding: const EdgeInsets.all(16),
            child: Row(children: [
              _StatChip(label: 'Ressources', value: _mesRessources.length.toString(), color: AppColors.blueLight),
              const SizedBox(width: 10),
              _StatChip(label: 'Favoris', value: _mesFavoris.length.toString(), color: AppColors.amber),
              const SizedBox(width: 10),
              _StatChip(label: 'En cours', value: _mesProgressions.length.toString(), color: AppColors.green),
            ]),
          ),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildFiltres()),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/add-ressource'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter une ressource', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.blueLight, side: const BorderSide(color: AppColors.blueLight),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Mes ressources (${filtered.length})', style: AppText.h2)),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Column(children: [
                Icon(Icons.folder_open, color: AppColors.grey, size: 40),
                SizedBox(height: 8),
                Text('Aucune ressource', style: TextStyle(fontSize: 13, color: AppColors.grey)),
              ])),
            )
          else
            ListView.separated(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _RessourceCard(
                ressource: filtered[i],
                onDelete: () async { await ApiService.deleteRessource(filtered[i].id); _load(); },
              ),
            ),
          const SizedBox(height: 16),
          if (_mesFavoris.isNotEmpty) ...[
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Mes favoris (${_mesFavoris.length})', style: AppText.h2)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _mesFavoris.length,
                itemBuilder: (_, i) {
                  final f = _mesFavoris[i];
                  final r = f['ressource'] as Map<String, dynamic>?;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _FavoriCard(
                      titre: r?['titre'] ?? 'Ressource',
                      type: r?['typeRessource'] ?? 'article',
                      onRemove: () async {
                        final s = ApiService.session;
                        if (s == null) return;
                        await ApiService.removeFavori(s.id, f['idRessource']);
                        _load();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_mesProgressions.isNotEmpty) ...[
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('En cours (${_mesProgressions.length})', style: AppText.h2)),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mesProgressions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ProgressionRow(progression: _mesProgressions[i]),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _buildFiltres() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtrer :', style: AppText.h3.copyWith(color: AppColors.blueLight)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _FilterDropdown(label: 'Type', value: _filterType,
                options: const ['Tous', 'Article', 'Video', 'Audio', 'Exercice', 'Activite', 'Jeu'],
                onChanged: (v) => setState(() => _filterType = v))),
            const SizedBox(width: 10),
            Expanded(child: _FilterDropdown(label: 'Statut', value: _filterStatut,
                options: const ['Tous', 'Brouillon', 'En_attente', 'Validee', 'Rejetee'],
                onChanged: (v) => setState(() => _filterStatut = v))),
          ]),
        ],
      );
}

class _StatChip extends StatelessWidget {
  final String label; final String value; final Color color;
  const _StatChip({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
          ]),
        ),
      );
}

class _RessourceCard extends StatelessWidget {
  final RessourceModel ressource; final VoidCallback onDelete;
  const _RessourceCard({required this.ressource, required this.onDelete});

  Color get _statutColor => switch (ressource.statut.toLowerCase()) {
    'validee' => AppColors.green, 'en_attente' => AppColors.amber,
    'rejetee' => AppColors.red, _ => AppColors.grey,
  };
  String get _statutLabel => switch (ressource.statut.toLowerCase()) {
    'validee' => 'Validée', 'en_attente' => 'En attente',
    'rejetee' => 'Rejetée', _ => 'Brouillon',
  };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.blueSurface, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.article_outlined, color: AppColors.blueLight, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ressource.titre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              Text(ressource.typeLabel, style: AppText.caption),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _statutColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(_statutLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statutColor)),
              ),
            ]),
            const SizedBox(height: 2),
            Text(DateFormat('dd/MM/yyyy').format(ressource.dateCreation), style: AppText.caption),
          ])),
          GestureDetector(
            onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
              title: const Text('Supprimer'),
              content: Text('Supprimer "${ressource.titre}" ?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                TextButton(onPressed: () { Navigator.pop(context); onDelete(); },
                    child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
              ],
            )),
            child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.delete_outline, color: AppColors.red, size: 20)),
          ),
        ]),
      );
}

class _FavoriCard extends StatelessWidget {
  final String titre; final String type; final VoidCallback onRemove;
  const _FavoriCard({required this.titre, required this.type, required this.onRemove});
  @override
  Widget build(BuildContext context) => Container(
        width: 150, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Icon(Icons.star, color: AppColors.amber, size: 18),
            GestureDetector(onTap: onRemove, child: const Icon(Icons.close, color: AppColors.grey, size: 16)),
          ]),
          const SizedBox(height: 8),
          Text(titre, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(type, style: AppText.caption),
        ]),
      );
}

class _ProgressionRow extends StatelessWidget {
  final Map<String, dynamic> progression;
  const _ProgressionRow({required this.progression});
  @override
  Widget build(BuildContext context) {
    final type = progression['typeProgression']?.toString() ?? '';
    final isExploitee = type.toLowerCase() == 'exploitee';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Icon(isExploitee ? Icons.play_circle_outline : Icons.bookmark_outline,
            color: isExploitee ? AppColors.green : AppColors.amber, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text('Ressource #${progression['idRessource']}', style: const TextStyle(fontSize: 13, color: AppColors.text))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isExploitee ? AppColors.green.withOpacity(0.1) : AppColors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(isExploitee ? 'Exploitée' : 'Mise de côté',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isExploitee ? AppColors.green : AppColors.amber)),
        ),
      ]),
    );
  }
}

class _DonneesPersonnellesTab extends StatefulWidget {
  final UserModel user;
  const _DonneesPersonnellesTab({required this.user});
  @override
  State<_DonneesPersonnellesTab> createState() => _DonneesPersonnellesTabState();
}

class _DonneesPersonnellesTabState extends State<_DonneesPersonnellesTab> {
  late TextEditingController _prenomCtrl, _nomCtrl, _emailCtrl, _telCtrl, _descCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prenomCtrl = TextEditingController(text: widget.user.firstName);
    _nomCtrl    = TextEditingController(text: widget.user.lastName);
    _emailCtrl  = TextEditingController(text: ApiService.session?.email ?? '');
    _telCtrl    = TextEditingController(text: widget.user.telephone ?? '');
    _descCtrl   = TextEditingController(text: widget.user.description ?? '');
  }

  @override
  void dispose() {
    _prenomCtrl.dispose(); _nomCtrl.dispose(); _emailCtrl.dispose(); _telCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final session = ApiService.session;
    if (session == null) return;
    setState(() => _saving = true);
    try {
      await ApiService.updateUtilisateur(session.id, {
        'prenom': _prenomCtrl.text.trim(), 'nom': _nomCtrl.text.trim(),
        'telephone': _telCtrl.text.trim(), 'description': _descCtrl.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [Icon(Icons.check_circle, color: AppColors.white), SizedBox(width: 8), Text('Profil mis à jour')]),
        backgroundColor: AppColors.green, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle(icon: Icons.person_outline, title: 'Informations personnelles'),
          const SizedBox(height: 16),
          _EditField(label: 'Prénom', controller: _prenomCtrl),
          const SizedBox(height: 12),
          _EditField(label: 'Nom', controller: _nomCtrl),
          const SizedBox(height: 12),
          _EditField(label: 'Email', controller: _emailCtrl, enabled: false),
          const SizedBox(height: 12),
          _EditField(label: 'Téléphone', controller: _telCtrl, type: TextInputType.phone),
          const SizedBox(height: 12),
          _EditField(label: 'Description', controller: _descCtrl, maxLines: 3),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)) : const Icon(Icons.save_outlined, size: 16),
              label: const Text('Enregistrer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLight, foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
              ),
            ),
          ),
        ])),
      );
}

class _EditField extends StatelessWidget {
  final String label; final TextEditingController controller;
  final bool enabled; final int maxLines; final TextInputType type;
  const _EditField({required this.label, required this.controller, this.enabled = true, this.maxLines = 1, this.type = TextInputType.text});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 4),
        TextField(
          controller: controller, enabled: enabled, maxLines: maxLines, keyboardType: type,
          style: const TextStyle(fontSize: 13, color: AppColors.text),
          decoration: InputDecoration(
            filled: true, fillColor: enabled ? AppColors.white : AppColors.greyLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.blueLight, width: 1.5)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
      ]);
}

class _PreferencesTab extends StatelessWidget {
  const _PreferencesTab();
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle(icon: Icons.settings_outlined, title: 'Mes préférences'),
          const SizedBox(height: 16),
          const _PrefSwitch(label: 'Notifications email', value: true),
          const SizedBox(height: 12),
          const _PrefSwitch(label: 'Notifications push', value: false),
          const SizedBox(height: 12),
          const _PrefSwitch(label: 'Profil visible publiquement', value: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined, size: 16),
              label: const Text('Enregistrer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLight, foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
              ),
            ),
          ),
        ])),
      );
}

class _PrefSwitch extends StatefulWidget {
  final String label; final bool value;
  const _PrefSwitch({required this.label, required this.value});
  @override
  State<_PrefSwitch> createState() => _PrefSwitchState();
}
class _PrefSwitchState extends State<_PrefSwitch> {
  late bool _value;
  @override void initState() { super.initState(); _value = widget.value; }
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(widget.label, style: AppText.body),
        Switch(value: _value, onChanged: (v) => setState(() => _value = v), activeColor: AppColors.blueLight),
      ]);
}

class _FilterDropdown extends StatelessWidget {
  final String label; final String value; final List<String> options; final ValueChanged<String> onChanged;
  const _FilterDropdown({required this.label, required this.value, required this.options, required this.onChanged});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(6), color: AppColors.white),
          child: DropdownButton<String>(
            value: value, isExpanded: true, underline: const SizedBox(),
            style: const TextStyle(fontSize: 12, color: AppColors.text),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) { if (v != null) onChanged(v); },
          ),
        ),
      ]);
}