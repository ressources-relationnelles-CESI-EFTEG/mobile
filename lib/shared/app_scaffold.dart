import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:mobile/shared/api_service.dart';
import '../core/app_theme.dart';

// ─── Routes centralisées ──────────────────────────────────────────────────────
class AppRoutes {
  static const dashboard  = '/dashboard';
  static const account    = '/account';
  static const messages   = '/messages';
  static const ressources = '/ressources';
  static const accueil    = '/accueil';
}

// ─── Items de navigation ──────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}

const _navItems = [
  _NavItem(icon: Icons.home_outlined,           label: 'Accueil',         route: AppRoutes.accueil),
  _NavItem(icon: Icons.dashboard_outlined,      label: 'Tableau de bord', route: AppRoutes.dashboard),
  _NavItem(icon: Icons.mail_outline,            label: 'Messagerie',      route: AppRoutes.messages),
  _NavItem(icon: Icons.library_books_outlined,  label: 'Ressources',      route: AppRoutes.ressources),
  _NavItem(icon: Icons.account_circle_outlined, label: 'Mon compte',      route: AppRoutes.account),
];

// ─── SCAFFOLD PARTAGÉ ────────────────────────────────────────────────────────
class AppScaffold extends StatelessWidget {
  final Widget body;
  final int navIndex;

  const AppScaffold({super.key, required this.body, required this.navIndex});

  void _navigate(BuildContext context, String route) {
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          Expanded(child: body),
          const AppFooter(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      surfaceTintColor: AppColors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(children: [
        Image.asset('assets/logo_etat.png', height: 40),
        const SizedBox(width: 12),
        const Text('(RE)SOURCES\nRELATIONNELLES',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                color: AppColors.blue, height: 1.3)),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.blue),
          onPressed: () {},
        ),
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.blue),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── DRAWER ───────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            color: AppColors.blue,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                SizedBox(
                  width: 16, height: 22,
                  child: Row(children: [
                    Expanded(child: Container(color: AppColors.blue)),
                    Expanded(child: Container(color: AppColors.white)),
                    Expanded(child: Container(color: AppColors.red)),
                  ]),
                ),
                const SizedBox(width: 10),
                const Text('(RE)SOURCES\nRELATIONNELLES',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                        color: AppColors.white, height: 1.3)),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.blueSurface,
                  child: Icon(Icons.person, color: AppColors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    '${ApiService.session?.firstname ?? ''} ${ApiService.session?.lastname ?? ''}'.trim(),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                  Text(
                    ApiService.session != null ? 'Connecté(e)' : 'Non connecté(e)',
                    style: TextStyle(fontSize: 12, color: AppColors.white.withOpacity(0.7)),
                  ),
                ]),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          ..._navItems.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final selected = navIndex == i;
            return _DrawerItem(
              icon: item.icon,
              label: item.label,
              selected: selected,
              onTap: () {
                Navigator.pop(context);
                _navigate(context, item.route);
              },
            );
          }),
          const Spacer(),
          const Divider(color: AppColors.border),
          _DrawerItem(
            icon: Icons.logout,
            label: 'Se déconnecter',
            selected: false,
            textColor: Colors.red[600]!,
            iconColor: Colors.red[600]!,
            onTap: () {
              ApiService.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  // ── BOTTOM NAV ───────────────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: _navItems.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = navIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _navigate(context, item.route),
                  behavior: HitTestBehavior.opaque,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(item.icon, size: 22,
                        color: selected ? AppColors.blueLight : AppColors.grey),
                    const SizedBox(height: 3),
                    Text(item.label.split(' ').first,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          color: selected ? AppColors.blueLight : AppColors.grey,
                        )),
                    if (selected)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 20, height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.blueLight,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── FOOTER ──────────────────────────────────────────────────────────────────
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(height: 1, color: Color(0xFF1C3177), thickness: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Ligne principale : logo + texte ─────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Ministère
                    Expanded(
                      flex: 2,
                      child: Image.asset('assets/logo_etat.png', height: 100),
                    ),
                    const SizedBox(width: 16),
                    // Texte + liens
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Ce site est géré par le Ministère des solidarités et de la santé',
                            style: TextStyle(fontSize: 10, color: Color(0xFF333333), height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: [
                              _FooterLink(label: 'info.gouv.fr', url: 'https://info.gouv.fr'),
                              _FooterLink(label: 'service-public.fr', url: 'https://www.service-public.fr'),
                              _FooterLink(label: 'legifrance.gouv.fr', url: 'https://www.legifrance.gouv.fr'),
                              _FooterLink(label: 'data.gouv.fr', url: 'https://www.data.gouv.fr'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFDDDDDD)),
                const SizedBox(height: 12),
                // ── Liens bas de page ────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _FooterSmallLink(label: 'Accessibilité'),
                    const _FooterSep(),
                    _FooterSmallLink(label: 'Mentions légales'),
                    const _FooterSep(),
                    _FooterSmallLink(label: 'Données personnelles'),
                    const _FooterSep(),
                    _FooterSmallLink(label: 'Gestion des cookies'),
                    const _FooterSep(),
                    _FooterSmallLink(label: 'Plan du site'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final String url;
  const _FooterLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF1C3177),
                  decoration: TextDecoration.underline,
                )),
            const SizedBox(width: 2),
            const Icon(Icons.open_in_new, size: 10, color: Color(0xFF1C3177)),
          ],
        ),
      );
}

class _FooterSmallLink extends StatelessWidget {
  final String label;
  const _FooterSmallLink({required this.label});

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
        fontSize: 9,
        color: Color(0xFF1C3177),
        decoration: TextDecoration.underline,
      ));
}

class _FooterSep extends StatelessWidget {
  const _FooterSep();

  @override
  Widget build(BuildContext context) =>
      const Text('|', style: TextStyle(fontSize: 9, color: Color(0xFF999999)));
}

// ─── DRAWER ITEM ─────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.blueSurface : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            Icon(icon, size: 20,
                color: iconColor ?? (selected ? AppColors.blueLight : AppColors.grey)),
            const SizedBox(width: 16),
            Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: textColor ?? (selected ? AppColors.blueLight : AppColors.text),
                )),
            if (selected) ...[
              const Spacer(),
              Container(width: 4, height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.blueLight, shape: BoxShape.circle)),
            ],
          ]),
        ),
      ),
    );
  }
}