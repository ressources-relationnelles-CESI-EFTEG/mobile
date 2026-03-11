import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ministère des Solidarités et de la Santé',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const MinisterePage(),
    );
  }
}

// ─────────────────────────────────────────────
// PAGE PRINCIPALE
// ─────────────────────────────────────────────
class MinisterePage extends StatelessWidget {
  const MinisterePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  _SearchBar(),
                  _CardGrid(),
                  _Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Drapeau tricolore
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      ColoredBox(color: Color(0xFF002395), child: SizedBox(width: 6, height: 28)),
                      ColoredBox(color: Colors.white,      child: SizedBox(width: 6, height: 28)),
                      ColoredBox(color: Color(0xFFED2939), child: SizedBox(width: 6, height: 28)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('LIBERTÉ',    style: TextStyle(fontSize: 7, letterSpacing: 1)),
                  const Text('ÉGALITÉ',    style: TextStyle(fontSize: 7, letterSpacing: 1)),
                  const Text('FRATERNITÉ', style: TextStyle(fontSize: 7, letterSpacing: 1)),
                ],
              ),
              const SizedBox(width: 12),
              // Titre ministère
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MINISTÈRE',        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                    Text('DES SOLIDARITÉS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                    Text('ET DE LA SANTÉ',  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              // Hamburger
              IconButton(
                icon: const Icon(Icons.menu, size: 28),
                onPressed: () => debugPrint('[MENU] pressé'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BARRE DE RECHERCHE
// ─────────────────────────────────────────────
class _SearchBar extends StatefulWidget {
  const _SearchBar({Key? key}) : super(key: key);

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
                ),
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            ColoredBox(
              color: const Color(0xFF1E1E1E),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => debugPrint('[SEARCH] ${_ctrl.text}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GRILLE DE CARDS
// ─────────────────────────────────────────────
class _CardGrid extends StatelessWidget {
  const _CardGrid({Key? key}) : super(key: key);

  static const List<Map<String, String>> _cards = [
    {'title': 'Santé publique',     'label': 'Actualité'},
    {'title': 'Solidarités',        'label': 'Dossier'},
    {'title': 'Protection sociale', 'label': 'Service'},
    {'title': 'Handicap',           'label': 'Actualité'},
    {'title': 'Grand âge',          'label': 'Dossier'},
    {'title': 'Enfance & famille',  'label': 'Service'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) => _DSFRCard(
          title: _cards[index]['title']!,
          label: _cards[index]['label']!,
          onTap: () => debugPrint('[CARD] ${_cards[index]['title']} pressée'),
        ),
      ),
    );
  }
}

class _DSFRCard extends StatelessWidget {
  final String title;
  final String label;
  final VoidCallback onTap;

  const _DSFRCard({
    Key? key,
    required this.title,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder image gris
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ColoredBox(
                  color: const Color(0xFFE5E5E5),
                  child: const Center(
                    child: Icon(Icons.image, color: Color(0xFFAAAAAA), size: 40),
                  ),
                ),
              ),
            ),
            // Texte
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF555555))),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FOOTER
// ─────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer({Key? key}) : super(key: key);

  static const _links = [
    'info.gouv.fr',
    'service-public.fr',
    'legifrance.gouv.fr',
    'data.gouv.fr',
  ];

  static const _legalLinks = [
    'Accessibilité : non/partiellement conforme',
    'Mentions légales',
    'Données personnelles',
    'Gestion des cookies',
    'Plan du site',
    "Paramètres d'affichage",
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + titre
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: const [
                        ColoredBox(color: Color(0xFF002395), child: SizedBox(width: 5, height: 24)),
                        ColoredBox(color: Colors.white,      child: SizedBox(width: 5, height: 24)),
                        ColoredBox(color: Color(0xFFED2939), child: SizedBox(width: 5, height: 24)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text('Liberté',    style: TextStyle(fontSize: 6, color: Colors.white)),
                    const Text('Égalité',    style: TextStyle(fontSize: 6, color: Colors.white)),
                    const Text('Fraternité', style: TextStyle(fontSize: 6, color: Colors.white)),
                  ],
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MINISTÈRE',        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('DES SOLIDARITÉS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('ET DE LA SANTÉ',  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Ce site est géré par le Ministère des solidarités et de la Santé.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Liens gouvernementaux
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _links.map((l) => GestureDetector(
                onTap: () => debugPrint('[FOOTER] $l pressé'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l, style: const TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new, color: Colors.white, size: 12),
                  ],
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),

            // Liens légaux
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _legalLinks.map((l) => GestureDetector(
                onTap: () => debugPrint('[FOOTER LEGAL] $l pressé'),
                child: Text(l, style: const TextStyle(color: Colors.white, fontSize: 11, decoration: TextDecoration.underline, decorationColor: Colors.white)),
              )).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sauf mention contraire, tous les contenus de ce site sont soumis à la',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            GestureDetector(
              onTap: () => debugPrint('[FOOTER] Licence Etalab pressée'),
              child: const Text(
                'licence etalab-2.0',
                style: TextStyle(color: Colors.white, fontSize: 10, decoration: TextDecoration.underline, decorationColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}