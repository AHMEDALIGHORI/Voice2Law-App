import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/auth_controller.dart';
import '../../core/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand.dart';
import 'admin_login_screen.dart';
import 'sections/admin_dashboard_section.dart';
import 'sections/admin_sections.dart';

class _AdminNavItem {
  const _AdminNavItem({
    required this.id,
    required this.label,
    required this.labelUrdu,
    required this.icon,
  });

  final String id;
  final String label;
  final String labelUrdu;
  final IconData icon;
}

/// `AdminPanelPage.tsx` – protected admin area guarded by [AuthController]
/// (the mobile equivalent of `ProtectedRoute`).
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  String _view = 'dashboard';

  static const List<_AdminNavItem> _navItems = <_AdminNavItem>[
    _AdminNavItem(
      id: 'dashboard',
      label: 'Dashboard',
      labelUrdu: 'ڈیش بورڈ',
      icon: Icons.dashboard_outlined,
    ),
    _AdminNavItem(
      id: 'knowledge-base',
      label: 'Legal Knowledge Base',
      labelUrdu: 'قانونی معلومات',
      icon: Icons.menu_book_outlined,
    ),
    _AdminNavItem(
      id: 'urdu-content',
      label: 'Urdu Law Content',
      labelUrdu: 'اردو قانونی مواد',
      icon: Icons.translate,
    ),
    _AdminNavItem(
      id: 'voice-nlp',
      label: 'Voice & NLP Monitoring',
      labelUrdu: 'آواز کی نگرانی',
      icon: Icons.mic_outlined,
    ),
    _AdminNavItem(
      id: 'ai-review',
      label: 'AI Response Review',
      labelUrdu: 'AI جائزہ',
      icon: Icons.smart_toy_outlined,
    ),
    _AdminNavItem(
      id: 'queries-feedback',
      label: 'User Queries & Feedback',
      labelUrdu: 'صارفین کے سوالات',
      icon: Icons.forum_outlined,
    ),
    _AdminNavItem(
      id: 'add-lawyer',
      label: 'Add Lawyer',
      labelUrdu: 'وکیل شامل کریں',
      icon: Icons.person_add_alt,
    ),
    _AdminNavItem(
      id: 'analytics',
      label: 'Analytics & Reports',
      labelUrdu: 'رپورٹس',
      icon: Icons.bar_chart_outlined,
    ),
    _AdminNavItem(
      id: 'settings',
      label: 'System Settings',
      labelUrdu: 'سیٹنگز',
      icon: Icons.settings_outlined,
    ),
    _AdminNavItem(
      id: 'logs',
      label: 'Logs & Security',
      labelUrdu: 'سیکیورٹی',
      icon: Icons.shield_outlined,
    ),
  ];

  String get _title =>
      _navItems.firstWhere((_AdminNavItem item) => item.id == _view).label;

  Future<void> _logout() async {
    await AppScope.of(context).auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const AdminLoginScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppScope.of(context).auth,
      builder: (context, _) => _authorizedBody(context),
    );
  }

  Widget _authorizedBody(BuildContext context) {
    final AuthController auth = AppScope.of(context).auth;

    // Guard: same behaviour as the website `ProtectedRoute`.
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkGreen,
          title: const Text('Admin'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Access Denied',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You need to sign in with an admin account to open this area.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.darkGreen.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 22),
                BrandButton(
                  label: 'Admin Login',
                  icon: Icons.login,
                  onPressed: () => Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRoutes.adminLogin),
                ),
                const SizedBox(height: 10),
                BrandButton(
                  label: 'Go to Home',
                  icon: Icons.home_outlined,
                  kind: ButtonStyleKind.outline,
                  onPressed: () =>
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (Route<dynamic> route) => false,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text(_title),
        actions: <Widget>[
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppColors.white),
          ),
        ],
      ),
      drawer: _drawer(auth),
      body: _body(),
    );
  }

  Drawer _drawer(AuthController auth) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.gradientGreen),
            padding: const EdgeInsets.fromLTRB(20, 58, 20, 22),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: AppColors.emerald,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Voice2Law',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        auth.user?.name ?? 'Admin',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: <Widget>[
                for (final _AdminNavItem item in _navItems)
                  ListTile(
                    leading: Icon(item.icon),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: _view == item.id
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    subtitle: UrduText(item.labelUrdu, size: 12),
                    selected: _view == item.id,
                    selectedTileColor: AppColors.lightGreen,
                    onTap: () {
                      setState(() => _view = item.id);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_view) {
      case 'knowledge-base':
        return const KnowledgeBaseSection();
      case 'urdu-content':
        return const UrduContentSection();
      case 'ai-review':
        return const AiReviewSection();
      case 'queries-feedback':
        return const UserQueriesSection();
      case 'add-lawyer':
        return const AddLawyerSection();
      case 'settings':
        return const SystemSettingsSection();
      case 'voice-nlp':
        return const VoiceNlpSection();
      case 'analytics':
        return const AnalyticsSection();
      case 'logs':
        return const LogsSecuritySection();
      case 'dashboard':
      default:
        return const AdminDashboardSection();
    }
  }
}
