import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../core/shell_controller.dart';
import '../theme/app_theme.dart';
import 'brand.dart';

class _DrawerItem {
  const _DrawerItem({
    required this.label,
    required this.labelUrdu,
    required this.icon,
    this.tabIndex,
    this.route,
  });

  final String label;
  final String labelUrdu;
  final IconData icon;
  final int? tabIndex;
  final String? route;
}

/// App navigation drawer – the mobile version of the website navbar
/// (`Navbar.tsx` mobile menu).
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, this.currentTab});

  /// Highlights the active entry when the drawer is opened from the shell.
  final int? currentTab;

  static const List<_DrawerItem> _items = <_DrawerItem>[
    _DrawerItem(
      label: 'Home',
      labelUrdu: 'ہوم',
      icon: Icons.home_outlined,
      tabIndex: 0,
    ),
    _DrawerItem(
      label: 'Ask a Question',
      labelUrdu: 'سوال پوچھیں',
      icon: Icons.mic,
      tabIndex: 1,
    ),
    _DrawerItem(
      label: 'Find Lawyers',
      labelUrdu: 'وکیل تلاش کریں',
      icon: Icons.gavel,
      tabIndex: 2,
    ),
    _DrawerItem(
      label: 'Legal Topics',
      labelUrdu: 'قانونی موضوعات',
      icon: Icons.menu_book_outlined,
      tabIndex: 3,
    ),
    _DrawerItem(
      label: 'Statute Library',
      labelUrdu: 'قانونی لائبریری',
      icon: Icons.library_books_outlined,
      route: AppRoutes.statuteLibrary,
    ),
    _DrawerItem(
      label: 'AI Legal Tools',
      labelUrdu: 'قانونی ذہانت',
      icon: Icons.auto_awesome_outlined,
      route: AppRoutes.aiFeaturesHub,
    ),
    _DrawerItem(
      label: 'Search',
      labelUrdu: 'تلاش',
      icon: Icons.search,
      route: AppRoutes.search,
    ),
    _DrawerItem(
      label: 'About',
      labelUrdu: 'تعارف',
      icon: Icons.info_outline,
      route: AppRoutes.about,
    ),
    _DrawerItem(
      label: 'How It Works',
      labelUrdu: 'طریقۂ کار',
      icon: Icons.auto_awesome_outlined,
      route: AppRoutes.howItWorks,
    ),
    _DrawerItem(
      label: 'Contact',
      labelUrdu: 'رابطہ',
      icon: Icons.support_agent,
      route: AppRoutes.contact,
    ),
  ];

  void _handleTap(BuildContext context, _DrawerItem item) {
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop(); // close the drawer

    if (item.tabIndex != null) {
      // Back to the shell route (it hosts the tabs), then switch the tab.
      ShellController.goToFromAnyScreen(item.tabIndex!);
      navigator.popUntil((Route<dynamic> route) => route.isFirst);
      return;
    }

    navigator.pushNamed(item.route!);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.gradientGreen),
            padding: const EdgeInsets.fromLTRB(20, 58, 20, 24),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.balance,
                    color: AppColors.emerald,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Voice2Law',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    UrduText('قانونی معاون', size: 13, color: AppColors.gold),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: <Widget>[
                for (final _DrawerItem item in _items)
                  _buildItem(context, item),
                const Divider(height: 24, indent: 20, endIndent: 20),
                _buildAction(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  labelUrdu: 'سیٹنگز',
                  route: AppRoutes.settings,
                ),
                _buildAction(
                  context,
                  icon: Icons.shield_outlined,
                  label: 'Admin Login',
                  labelUrdu: 'ایڈمن لاگ اِن',
                  route: AppRoutes.adminLogin,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.lightGreen,
            child: Text(
              '© 2024 Voice2Law FYP',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkGreen.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, _DrawerItem item) {
    final bool active = currentTab != null && currentTab == item.tabIndex;
    return ListTile(
      leading: Icon(
        item.icon,
        color: active ? AppColors.emerald : AppColors.darkGreen,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? AppColors.emerald : AppColors.darkGreen,
        ),
      ),
      subtitle: UrduText(item.labelUrdu, size: 12.5),
      selected: active,
      selectedTileColor: AppColors.lightGreen,
      onTap: () => _handleTap(context, item),
    );
  }

  Widget _buildAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String labelUrdu,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: UrduText(labelUrdu, size: 12.5),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(route);
      },
    );
  }
}
