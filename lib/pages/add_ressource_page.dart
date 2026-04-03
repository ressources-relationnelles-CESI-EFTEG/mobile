import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../shared/app_scaffold.dart';
import '../shared/components.dart';
import '../shared/api_service.dart';

class AddRessourcePage extends StatefulWidget {
  const AddRessourcePage({super.key});

  @override
  State<AddRessourcePage> createState() => _AddRessourcePageState();
}

class _AddRessourcePageState extends State<AddRessourcePage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _titreCtrl       = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _contenuCtrl     = TextEditingController();
  final _lienCtrl        = TextEditingController();

  // Valeurs des dropdowns
  String _typeRessource    = 'article';
  String _niveauDifficulte = 'debutant';
  String _visibilite       = 'public';
  String? _categorie;

  bool _isLoading = false;

  List<Map<String, String>> _categories = [];

  Future<void> _loadCategories() async {
    try {
      final data = await ApiService.fetchCategories();
      setState(() {
        _categories = data.map((c) => {
          'id': c['idCategorie'].toString(),
          'nom': c['nom'].toString(),
        }).toList();
      });
    } catch (_) {}
  }

  final List<Map<String, String>> _types = const [
    {'value': 'article',     'label': 'Article'},
    {'value': 'video',       'label': 'Vidéo'},
    {'value': 'podcast',     'label': 'Podcast'},
    {'value': 'infographie', 'label': 'Infographie'},
    {'value': 'livre',       'label': 'Livre'},
    {'value': 'exercice',    'label': 'Exercice pratique'},
  ];

  final List<Map<String, String>> _niveaux = const [
    {'value': 'debutant',      'label': 'Débutant'},
    {'value': 'intermediaire', 'label': 'Intermédiaire'},
    {'value': 'avance',        'label': 'Avancé'},
  ];

  final List<Map<String, String>> _visibilites = const [
    {'value': 'public',  'label': 'Public — visible par tous'},
    {'value': 'prive',   'label': 'Privé — visible par moi seul'},
    {'value': 'partage', 'label': 'Partagé — visible par mes amis'},
  ];

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    _contenuCtrl.dispose();
    _lienCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // [BDD] POST /ressources avec le body suivant :
    // {
    //   "titre":            _titreCtrl.text,
    //   "description":      _descCtrl.text,
    //   "contenu":          _contenuCtrl.text,
    //   "lien_partage":     _lienCtrl.text,
    //   "type_ressource":   _typeRessource,
    //   "niveau_difficulte":_niveauDifficulte,
    //   "visibilite":       _visibilite,
    //   "id_categorie":     int.parse(_categorie!),
    // }

    try {
      await ApiService.createRessource({
        'idUtilisateur': ApiService.session!.id,
        'idCategorie': int.parse(_categorie!),
        'titre': _titreCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'contenu': _contenuCtrl.text.trim().isEmpty ? _titreCtrl.text.trim() : _contenuCtrl.text.trim(),
        'typeRessource': _typeRessource.toUpperCase(),
        'niveauDifficulte': _niveauDifficulte.toUpperCase(),
        'visibilite': _visibilite == 'public' ? 'PUBLIQUE' : _visibilite == 'partage' ? 'PARTAGEE' : 'PRIVEE',
        if (_lienCtrl.text.trim().isNotEmpty) 'lienPartage': _lienCtrl.text.trim(),
      });
      if (!mounted) return;
      _showSuccessAndPop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.message}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessAndPop() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: AppColors.white),
          SizedBox(width: 10),
          Text('Ressource ajoutée avec succès !'),
        ]),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navIndex: -1, // Pas d'onglet actif
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Informations principales ──────────────────────────
                    _SectionCard(
                      title: 'Informations principales',
                      icon: Icons.info_outline,
                      children: [
                        _FieldLabel('Titre *'),
                        _buildTextField(
                          controller: _titreCtrl,
                          hint: 'Ex : Guide pour gérer le stress au travail',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Le titre est obligatoire'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _FieldLabel('Description'),
                        _buildTextField(
                          controller: _descCtrl,
                          hint: 'Décrivez brièvement le contenu de la ressource...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        _FieldLabel('Catégorie *'),
                        _buildDropdown<String>(
                          value: _categorie,
                          hint: 'Choisir une catégorie',
                          items: _categories.map((c) => DropdownMenuItem(
                            value: c['id'],
                            child: Text(c['nom']!),
                          )).toList(),
                          onChanged: (v) => setState(() => _categorie = v),
                          validator: (v) => v == null ? 'Choisissez une catégorie' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Type & niveau ─────────────────────────────────────
                    _SectionCard(
                      title: 'Type & niveau',
                      icon: Icons.tune_outlined,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('Type de ressource'),
                                _buildDropdown<String>(
                                  value: _typeRessource,
                                  items: _types.map((t) => DropdownMenuItem(
                                    value: t['value'],
                                    child: Text(t['label']!),
                                  )).toList(),
                                  onChanged: (v) => setState(() => _typeRessource = v!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('Niveau'),
                                _buildDropdown<String>(
                                  value: _niveauDifficulte,
                                  items: _niveaux.map((n) => DropdownMenuItem(
                                    value: n['value'],
                                    child: Text(n['label']!),
                                  )).toList(),
                                  onChanged: (v) => setState(() => _niveauDifficulte = v!),
                                ),
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        _FieldLabel('Visibilité'),
                        ..._visibilites.map((vis) => _VisibiliteOption(
                          value: vis['value']!,
                          label: vis['label']!,
                          selected: _visibilite == vis['value'],
                          onTap: () => setState(() => _visibilite = vis['value']!),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Contenu & lien ────────────────────────────────────
                    _SectionCard(
                      title: 'Contenu & lien',
                      icon: Icons.link_outlined,
                      children: [
                        _FieldLabel('Lien externe'),
                        _buildTextField(
                          controller: _lienCtrl,
                          hint: 'https://...',
                          keyboardType: TextInputType.url,
                          prefix: const Icon(Icons.link, size: 18, color: AppColors.grey),
                          validator: (v) {
                            if (v != null && v.isNotEmpty &&
                                !v.startsWith('http://') &&
                                !v.startsWith('https://')) {
                              return 'Le lien doit commencer par http:// ou https://';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _FieldLabel('Contenu textuel'),
                        _buildTextField(
                          controller: _contenuCtrl,
                          hint: 'Rédigez ici le contenu de la ressource...',
                          maxLines: 6,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Boutons ───────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: AppColors.blueLight))
                          : ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Publier la ressource',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blueLight,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.grey,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Annuler', style: TextStyle(fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) => Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppColors.blue),
          ),
          const SizedBox(width: 14),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ajouter une ressource', style: AppText.h1),
            SizedBox(height: 2),
            Text('Partagez du contenu avec la communauté',
                style: TextStyle(fontSize: 12, color: AppColors.grey)),
          ]),
        ]),
      );

  // ── HELPERS UI ───────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? prefix,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 13, color: AppColors.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
          prefixIcon: prefix,
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.blueLight, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      );

  Widget _buildDropdown<T>({
    required T? value,
    String? hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) =>
      DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        style: const TextStyle(fontSize: 13, color: AppColors.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.blueLight, width: 1.5),
          ),
        ),
      );
}

// ─── SECTION CARD ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: AppColors.blue, size: 18),
            const SizedBox(width: 8),
            Text(title, style: AppText.sectionTitle),
          ]),
          const SizedBox(height: 16),
          ...children,
        ]),
      );
}

// ─── FIELD LABEL ──────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            )),
      );
}

// ─── VISIBILITE OPTION ────────────────────────────────────────────────────────
class _VisibiliteOption extends StatelessWidget {
  final String value;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _VisibiliteOption({
    required this.value,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  IconData get _icon => switch (value) {
        'public'  => Icons.public,
        'prive'   => Icons.lock_outline,
        'partage' => Icons.group_outlined,
        _         => Icons.circle_outlined,
      };

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.blueSurface : AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.blueLight : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Icon(_icon,
              size: 18,
              color: selected ? AppColors.blueLight : AppColors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label.split(' — ')[0],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.blueLight : AppColors.text,
                  )),
            ),
            if (label.contains(' — '))
              Text(label.split(' — ')[1],
                  style: const TextStyle(fontSize: 11, color: AppColors.grey)),
            if (selected)
              const Icon(Icons.check_circle, size: 18, color: AppColors.blueLight),
          ]),
        ),
      );
}