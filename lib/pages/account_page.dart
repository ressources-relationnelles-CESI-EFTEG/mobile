import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../core/app_theme.dart';
import '../shared/app_scaffold.dart';
import '../shared/components.dart';
import '../shared/models.dart';
import '../shared/api_service.dart';

// ─── PAGE PRINCIPALE ──────────────────────────────────────────────────────────

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _user;
  List<Map<String, dynamic>> _mesFavoris = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
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
        ApiService.fetchFavoris(session.id),
      ]);
      if (!mounted) return;
      setState(() {
        _user = UserModel.fromJson(results[0] as Map<String, dynamic>);
        _mesFavoris = List<Map<String, dynamic>>.from(results[1] as List);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _user = UserModel.placeholder();
        _loading = false;
      });
    }
  }

  void _logout() {
    ApiService.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navIndex: 4,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blueLight),
            )
          : Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _DonneesPersonnellesTab(
                        user: _user!,
                        onRefresh: _load,
                        onLogout: _logout,
                      ),
                      const _PreferencesTab(),
                      _buildRessourcesTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    final avatarPath = _user?.avatarUrl;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.blueSurface,
            backgroundImage: avatarPath != null
                ? NetworkImage('${ApiService.baseUrl}$avatarPath')
                : null,
            child: avatarPath == null
                ? const Icon(Icons.person, color: AppColors.blue, size: 30)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mon Compte', style: AppText.h1),
                const SizedBox(height: 4),
                Text(
                  _user?.fullName ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout, color: AppColors.grey),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

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
        Tab(
          icon: Icon(Icons.folder_outlined, size: 18),
          text: 'Mes ressources',
        ),
      ],
    ),
  );

  Widget _buildRessourcesTab() {
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mes ressources favorites', style: AppText.h2),
            const SizedBox(height: 16),
            if (_mesFavoris.isEmpty)
              _AlertBanner(
                type: _BannerType.info,
                title: 'Aucun favori',
                message:
                    "Vous n'avez pas encore ajouté de ressource à vos favoris. Explorez les ressources disponibles pour en ajouter.",
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mesFavoris.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _FavoriRichCard(favori: _mesFavoris[i]),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── ONGLET MES DONNÉES ───────────────────────────────────────────────────────

class _DonneesPersonnellesTab extends StatefulWidget {
  final UserModel user;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;
  const _DonneesPersonnellesTab({
    required this.user,
    required this.onRefresh,
    required this.onLogout,
  });
  @override
  State<_DonneesPersonnellesTab> createState() =>
      _DonneesPersonnellesTabState();
}

class _DonneesPersonnellesTabState extends State<_DonneesPersonnellesTab> {
  late TextEditingController _prenomCtrl;
  late TextEditingController _nomCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _phraseAccrocheCtrl;
  late TextEditingController _descCtrl;

  String? _region;
  List<String> _regions = [];
  bool _loadingRegions = false;

  String? _photoUrl;
  File? _photoLocal;

  String? _prenomError;
  String? _nomError;
  String? _emailError;
  String? _apiError;
  String? _successMessage;
  bool _saving = false;

  static const _fallbackRegions = [
    'Auvergne-Rhône-Alpes',
    'Bourgogne-Franche-Comté',
    'Bretagne',
    'Centre-Val de Loire',
    'Corse',
    'Grand Est',
    'Hauts-de-France',
    'Île-de-France',
    'Normandie',
    'Nouvelle-Aquitaine',
    'Occitanie',
    'Pays de la Loire',
    "Provence-Alpes-Côte d'Azur",
    'Guadeloupe',
    'Guyane',
    'Martinique',
    'Mayotte',
    'La Réunion',
  ];

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _prenomCtrl = TextEditingController(text: u.firstName);
    _nomCtrl = TextEditingController(text: u.lastName);
    _emailCtrl = TextEditingController(text: ApiService.session?.email ?? '');
    _telCtrl = TextEditingController(text: u.telephone ?? '');
    _phraseAccrocheCtrl = TextEditingController(text: u.phraseAccroche ?? '');
    _descCtrl = TextEditingController(text: u.description ?? '');
    _region = u.region;
    if (u.avatarUrl != null) {
      _photoUrl = '${ApiService.baseUrl}${u.avatarUrl}';
    }
    _fetchRegions();
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _phraseAccrocheCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchRegions() async {
    setState(() => _loadingRegions = true);
    try {
      final res = await http.get(
        Uri.parse('https://geo.api.gouv.fr/regions?fields=nom'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        final list =
            data
                .map((e) => (e as Map<String, dynamic>)['nom'] as String)
                .toList()
              ..sort((a, b) => a.compareTo(b));
        if (mounted)
          setState(() {
            _regions = list;
            _loadingRegions = false;
          });
      } else {
        if (mounted)
          setState(() {
            _regions = _fallbackRegions;
            _loadingRegions = false;
          });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _regions = _fallbackRegions;
          _loadingRegions = false;
        });
    }
  }

  Future<void> _pickPhoto() async {
    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 90,
    );
    if (xfile == null) return;
    final file = File(xfile.path);
    if (file.lengthSync() > 5 * 1024 * 1024) {
      setState(() => _apiError = "L'image ne doit pas dépasser 5 Mo.");
      return;
    }
    setState(() {
      _photoLocal = file;
      _apiError = null;
    });
    final session = ApiService.session;
    if (session == null) return;
    try {
      final data = await ApiService.uploadPhoto(session.id, xfile.path);
      if (!mounted) return;
      setState(() {
        _photoUrl = '${ApiService.baseUrl}${data['photoProfil']}';
        _photoLocal = null;
      });
      widget.onRefresh();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiError = "Erreur lors de l'envoi de la photo.";
        _photoLocal = null;
      });
    }
  }

  Future<void> _removePhoto() async {
    final session = ApiService.session;
    if (session == null) return;
    try {
      await ApiService.deletePhoto(session.id);
      if (!mounted) return;
      setState(() {
        _photoUrl = null;
        _photoLocal = null;
      });
      widget.onRefresh();
    } catch (_) {
      if (!mounted) return;
      setState(() => _apiError = 'Erreur lors de la suppression de la photo.');
    }
  }

  bool _validateForm() {
    setState(() {
      _prenomError = null;
      _nomError = null;
      _emailError = null;
      _apiError = null;
      _successMessage = null;
    });
    bool valid = true;
    if (_prenomCtrl.text.trim().isEmpty) {
      _prenomError = 'Veuillez renseigner votre prénom.';
      valid = false;
    }
    if (_nomCtrl.text.trim().isEmpty) {
      _nomError = 'Veuillez renseigner votre nom.';
      valid = false;
    }
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _emailError = 'Veuillez renseigner votre adresse e-mail.';
      valid = false;
    } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _emailError = 'Veuillez saisir une adresse e-mail valide.';
      valid = false;
    }
    return valid;
  }

  Future<void> _save() async {
    if (!_validateForm()) return;
    final session = ApiService.session;
    if (session == null) return;
    setState(() => _saving = true);
    try {
      final data = await ApiService.updateUtilisateur(session.id, {
        'prenom': _prenomCtrl.text.trim(),
        'nom': _nomCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'telephone': _telCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'phraseAccroche': _phraseAccrocheCtrl.text.trim(),
        if (_region != null) 'region': _region,
      });
      ApiService.refreshSession(
        firstname: data['prenom'] as String?,
        lastname: data['nom'] as String?,
        email: data['email'] as String?,
      );
      if (!mounted) return;
      setState(
        () => _successMessage =
            'Vos informations ont été mises à jour avec succès.',
      );
      widget.onRefresh();
    } catch (e) {
      if (!mounted) return;
      String message = 'La mise à jour du profil a échoué. Veuillez réessayer.';
      if (e is ApiException) message = e.message;
      setState(() => _apiError = message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _photoLocal != null || _photoUrl != null;
    final ImageProvider? photoProvider = _photoLocal != null
        ? FileImage(_photoLocal!)
        : (_photoUrl != null ? NetworkImage(_photoUrl!) : null);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  icon: Icons.person_outline,
                  title: 'Informations personnelles',
                ),
                const SizedBox(height: 16),
                // ── Photo de profil ──────────────────────────────────────────────
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.blueSurface,
                      backgroundImage: photoProvider,
                      child: photoProvider == null
                          ? const Icon(
                              Icons.person,
                              color: AppColors.blue,
                              size: 32,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickPhoto,
                          icon: const Icon(
                            Icons.photo_camera_outlined,
                            size: 16,
                          ),
                          label: const Text(
                            'Choisir une photo',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.blueLight,
                            side: const BorderSide(color: AppColors.blueLight),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        if (hasPhoto) ...[
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: _removePhoto,
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 14,
                              color: AppColors.red,
                            ),
                            label: const Text(
                              'Supprimer',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.red,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ── Champs ──────────────────────────────────────────────────────
                _EditFieldWithError(
                  label: 'Prénom',
                  controller: _prenomCtrl,
                  errorText: _prenomError,
                ),
                const SizedBox(height: 12),
                _EditFieldWithError(
                  label: 'Nom',
                  controller: _nomCtrl,
                  errorText: _nomError,
                ),
                const SizedBox(height: 12),
                _EditFieldWithError(
                  label: 'Adresse e-mail',
                  controller: _emailCtrl,
                  errorText: _emailError,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _EditFieldWithError(
                  label: 'Téléphone',
                  controller: _telCtrl,
                  type: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _EditFieldWithError(
                  label: "Phrase d'accroche",
                  controller: _phraseAccrocheCtrl,
                ),
                const SizedBox(height: 12),
                _EditFieldWithError(
                  label: 'Description',
                  controller: _descCtrl,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                // ── Région ──────────────────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Région', style: AppText.caption),
                    const SizedBox(height: 4),
                    if (_loadingRegions)
                      const SizedBox(
                        height: 44,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.blueLight,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.white,
                        ),
                        child: DropdownButton<String>(
                          value: _regions.contains(_region) ? _region : null,
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text(
                            'Sélectionnez une région',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.grey,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.text,
                          ),
                          items: _regions
                              .map(
                                (r) =>
                                    DropdownMenuItem(value: r, child: Text(r)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _region = v),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                // ── Alertes ─────────────────────────────────────────────────────
                if (_apiError != null) ...[
                  _AlertBanner(
                    type: _BannerType.error,
                    title: 'Mise à jour impossible',
                    message: _apiError!,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_successMessage != null) ...[
                  _AlertBanner(
                    type: _BannerType.success,
                    title: 'Profil mis à jour',
                    message: _successMessage!,
                  ),
                  const SizedBox(height: 12),
                ],
                // ── Bouton Enregistrer ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined, size: 16),
                    label: Text(
                      _saving
                          ? 'Enregistrement...'
                          : 'Enregistrer les modifications',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueLight,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ── Carte profil / déconnexion ───────────────────────────────────────
          _ProfileAside(
            photoProvider: photoProvider,
            fullName: '${_prenomCtrl.text} ${_nomCtrl.text}'.trim(),
            email: _emailCtrl.text,
            telephone: _telCtrl.text,
            phraseAccroche: _phraseAccrocheCtrl.text,
            onLogout: widget.onLogout,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── ONGLET PRÉFÉRENCES (stub conservé) ──────────────────────────────────────

class _PreferencesTab extends StatelessWidget {
  const _PreferencesTab();
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            icon: Icons.settings_outlined,
            title: 'Mes préférences',
          ),
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
                backgroundColor: AppColors.blueLight,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
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
        activeThumbColor: AppColors.blueLight,
      ),
    ],
  );
}

// ─── WIDGETS PARTAGÉS ─────────────────────────────────────────────────────────

class _EditFieldWithError extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final int maxLines;
  final TextInputType type;

  const _EditFieldWithError({
    required this.label,
    required this.controller,
    this.errorText,
    this.maxLines = 1,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppText.caption),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: type,
        style: const TextStyle(fontSize: 13, color: AppColors.text),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: errorText != null ? AppColors.red : AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: errorText != null ? AppColors.red : AppColors.blueLight,
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
      if (errorText != null) ...[
        const SizedBox(height: 4),
        Text(
          errorText!,
          style: const TextStyle(fontSize: 11, color: AppColors.red),
        ),
      ],
    ],
  );
}

enum _BannerType { info, error, success }

class _AlertBanner extends StatelessWidget {
  final _BannerType type;
  final String title;
  final String message;
  const _AlertBanner({
    required this.type,
    required this.title,
    required this.message,
  });

  Color get _bg => switch (type) {
    _BannerType.error => AppColors.red.withValues(alpha: 0.08),
    _BannerType.success => AppColors.green.withValues(alpha: 0.08),
    _BannerType.info => AppColors.blueLight.withValues(alpha: 0.08),
  };
  Color get _border => switch (type) {
    _BannerType.error => AppColors.red,
    _BannerType.success => AppColors.green,
    _BannerType.info => AppColors.blueLight,
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _bg,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _border.withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _border,
          ),
        ),
        const SizedBox(height: 4),
        Text(message, style: TextStyle(fontSize: 12, color: _border)),
      ],
    ),
  );
}

class _ProfileAside extends StatelessWidget {
  final ImageProvider? photoProvider;
  final String fullName;
  final String email;
  final String telephone;
  final String phraseAccroche;
  final VoidCallback onLogout;

  const _ProfileAside({
    required this.photoProvider,
    required this.fullName,
    required this.email,
    required this.telephone,
    required this.phraseAccroche,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.greyLight,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.blueSurface,
          backgroundImage: photoProvider,
          child: photoProvider == null
              ? const Icon(Icons.person, color: AppColors.blue, size: 32)
              : null,
        ),
        const SizedBox(height: 10),
        Text(fullName, style: AppText.h3, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        if (email.isNotEmpty) _AsideRow(icon: Icons.mail_outline, text: email),
        if (telephone.isNotEmpty)
          _AsideRow(icon: Icons.phone_outlined, text: telephone),
        if (phraseAccroche.isNotEmpty)
          _AsideRow(icon: Icons.chat_bubble_outline, text: phraseAccroche),
        const Divider(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, size: 16, color: AppColors.red),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(color: AppColors.red, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.red),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _AsideRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AsideRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppText.body,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class _FavoriRichCard extends StatelessWidget {
  final Map<String, dynamic> favori;
  const _FavoriRichCard({required this.favori});

  @override
  Widget build(BuildContext context) {
    final r = favori['ressource'] as Map<String, dynamic>? ?? favori;
    final titre = r['titre'] as String? ?? 'Ressource';
    final description = r['description'] as String?;
    final categorie =
        (r['categorie'] as Map<String, dynamic>?)?['nom'] as String?;
    final typeRessource = r['typeRessource'] as String?;
    final auteur = (r['utilisateur'] as Map<String, dynamic>?) != null
        ? '${(r['utilisateur'] as Map<String, dynamic>)['prenom']} ${(r['utilisateur'] as Map<String, dynamic>)['nom']}'
        : null;
    final dateAjout = favori['dateAjoutFavori'] != null
        ? DateFormat(
            'dd/MM/yyyy',
          ).format(DateTime.parse(favori['dateAjoutFavori'] as String))
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: AppText.h3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: AppText.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (categorie != null || typeRessource != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                if (categorie != null) _Chip(label: categorie),
                if (typeRessource != null) _Chip(label: typeRessource),
              ],
            ),
          ],
          if (auteur != null || dateAjout != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (auteur != null) ...[
                  const Icon(
                    Icons.person_outline,
                    size: 13,
                    color: AppColors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(auteur, style: AppText.caption),
                  const SizedBox(width: 12),
                ],
                if (dateAjout != null) ...[
                  const Icon(
                    Icons.calendar_today,
                    size: 13,
                    color: AppColors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text('Ajouté le $dateAjout', style: AppText.caption),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.blueSurface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.blueLight,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
