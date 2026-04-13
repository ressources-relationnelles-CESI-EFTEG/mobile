import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// ─── Routes centralisées ──────────────────────────────────────────────────────
class AppRoutes {
  static const dashboard  = '/dashboard';
  static const account    = '/account';
  static const messages   = '/messages';    // à venir
  static const findMentor = '/find-mentor';
  static const accueil    = '/accueil'; // à venir
}

// ─── Items de navigation ──────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}

const _navItems = [
  _NavItem(icon: Icons.home_outlined,           label: 'Accueil',        route: AppRoutes.accueil),
  _NavItem(icon: Icons.dashboard_outlined,      label: 'Tableau de bord',route: AppRoutes.dashboard),
  _NavItem(icon: Icons.mail_outline,            label: 'Messagerie',     route: AppRoutes.messages),
  _NavItem(icon: Icons.person_search_outlined,  label: 'Trouver un mentor', route: AppRoutes.findMentor),
  _NavItem(icon: Icons.account_circle_outlined, label: 'Mon compte',     route: AppRoutes.account),
];

// ─── SCAFFOLD PARTAGÉ ────────────────────────────────────────────────────────
class AppScaffold extends StatelessWidget {
  final Widget body;
  final int navIndex;

  const AppScaffold({super.key, required this.body, required this.navIndex});

  void _navigate(BuildContext context, String route) {
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) {
      Navigator.pop(context); // ferme le drawer si ouvert
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
      body: body,
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
        // Drapeau FR
        SizedBox(
          width: 16, height: 22,
          child: Row(children: [
            Expanded(child: Container(color: AppColors.blue)),
            Expanded(child: Container(color: AppColors.white)),
            Expanded(child: Container(color: AppColors.red)),
          ]),
        ),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MINISTÈRE', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.5)),
          Text('DES SOLIDARITÉS', style: TextStyle(fontSize: 6, fontWeight: FontWeight.w500, color: AppColors.blue)),
          Text('ET DE LA SANTÉ',  style: TextStyle(fontSize: 6, fontWeight: FontWeight.w500, color: AppColors.blue)),
        ]),
        const SizedBox(width: 12),
        Container(width: 1, height: 30, color: AppColors.border),
        const SizedBox(width: 12),
        const Text('(RE)SOURCES\nRELATIONNELLES',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.blue, height: 1.3)),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.blue),
          onPressed: () {}, // [NAV] → SearchPage à venir
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
          // En-tête drawer
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
              // Avatar + nom utilisateur
              Row(children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.blueSurface,
                  child: Icon(Icons.person, color: AppColors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Marie D.',        // [BDD] user.fullName
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white)),
                  Text('Connectée',
                      style: TextStyle(fontSize: 12, color: AppColors.white.withOpacity(0.7))),
                ]),
              ]),
            ]),
          ),

          // Items de navigation
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
                Navigator.pop(context); // ferme le drawer
                _navigate(context, item.route);
              },
            );
          }),

          const Spacer(),
          const Divider(color: AppColors.border),

          // Déconnexion
          _DrawerItem(
            icon: Icons.logout,
            label: 'Se déconnecter',
            selected: false,
            textColor: Colors.red[600]!,
            iconColor: Colors.red[600]!,
            onTap: () {
              Navigator.pop(context);
              // [BDD] AuthService.logout() puis redirect login
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
                    Text(item.label.split(' ').first, // label court
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