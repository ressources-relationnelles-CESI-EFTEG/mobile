import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../shared/app_scaffold.dart';
import '../shared/api_service.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});
  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navIndex: 0,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildGrid(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ressources Relationnelles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Votre espace personnel',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              if (ApiService.session == null)
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(fontSize: 13, color: AppColors.blueLight),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 20),
          const Text(
            'Bienvenue sur la plateforme de ressources relationnelles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Accédez à vos ressources, échangez avec vos contacts '
            'et gérez votre espace personnel.',
            style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─── GRILLE DE CARDS ───────────────────────────────────────────────────────
  Widget _buildGrid() {
    final cards = [
      _CardData(
        icon: Icons.explore_outlined,
        color: const Color(0xFF3B82F6),
        surface: const Color(0xFFEFF6FF),
        title: 'Découvrir mes ressources',
        description:
            'Parcourez l\'ensemble des ressources disponibles sur la plateforme.',
        label: 'Explorer',
        onTap: () => Navigator.pushNamed(context, '/ressources'),
      ),
      _CardData(
        icon: Icons.fiber_new_outlined,
        color: const Color(0xFF10B981),
        surface: const Color(0xFFECFDF5),
        title: 'Dernières ressources',
        description:
            'Consultez les ressources ajoutées récemment par la communauté.',
        label: 'Voir les nouveautés',
        onTap: () => Navigator.pushNamed(context, '/ressources'),
      ),
      _CardData(
        icon: Icons.search_outlined,
        color: const Color(0xFF8B5CF6),
        surface: const Color(0xFFF5F3FF),
        title: 'Rechercher une ressource',
        description:
            'Trouvez rapidement une ressource par mot-clé, titre ou thème.',
        label: 'Lancer une recherche',
        onTap: () => Navigator.pushNamed(context, '/ressources'),
      ),
      _CardData(
        icon: Icons.thumb_up_alt_outlined,
        color: const Color(0xFFF59E0B),
        surface: const Color(0xFFFFFBEB),
        title: 'Ressources recommandées',
        description:
            'Des ressources sélectionnées pour vous selon votre profil.',
        label: 'Voir les recommandations',
        onTap: () => Navigator.pushNamed(context, '/ressources'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: cards
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionCard(data: c),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── MODÈLE CARD ──────────────────────────────────────────────────────────────
class _CardData {
  final IconData icon;
  final Color color;
  final Color surface;
  final String title;
  final String description;
  final String label;
  final VoidCallback onTap;

  const _CardData({
    required this.icon,
    required this.color,
    required this.surface,
    required this.title,
    required this.description,
    required this.label,
    required this.onTap,
  });
}

// ─── WIDGET CARD ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final _CardData data;
  const _SectionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône colorée
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: data.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon, color: data.color, size: 24),
            ),
            const SizedBox(width: 14),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Label lien
                  Row(
                    children: [
                      Text(
                        data.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: data.color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: data.color, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
