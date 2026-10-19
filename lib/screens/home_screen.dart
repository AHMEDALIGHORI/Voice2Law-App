import 'package:flutter/material.dart';
import '../core/app_scope.dart';
import '../core/routes.dart';
import '../core/shell_controller.dart';
import '../widgets/brand.dart';
import '../theme/app_theme.dart';

/// A task-focused mobile home, with the current answer source visible up front.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final config = AppScope.of(context).config;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: config,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Row(
            children: [
              Icon(
                config.cloudEnabled
                    ? Icons.cloud_outlined
                    : Icons.offline_bolt_outlined,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  config.cloudEnabled
                      ? 'Cloud enabled · offline backup available'
                      : 'Offline library · questions stay on this device',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Understand your rights.\nChoose your next step.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          UrduText(
            'اپنے حقوق جانیں، اپنا راستہ چنیں',
            size: 19,
            color: scheme.onSurface,
            align: TextAlign.left,
          ),
          const SizedBox(height: 12),
          Text(
            'Explore Pakistani law in English and Urdu, with clear explanations and practical checklists.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF053425),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.graphic_eq, color: AppColors.gold, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Start with your question',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Speak naturally, or take your time and type.',
                  style: TextStyle(color: Color(0xFFD2E4DA), height: 1.5),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE8C978),
                    foregroundColor: const Color(0xFF053425),
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  onPressed: () => Navigator.of(context).pushNamed('/voice'),
                  icon: const Icon(Icons.mic_none),
                  label: const Text('Ask by Voice'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF8DAF9C)),
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  onPressed: () => Navigator.of(context).pushNamed('/text'),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Ask by Text'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Explore at your pace',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _ExploreTile(
            icon: Icons.library_books_outlined,
            title: 'Law library',
            subtitle: 'Read the bundled statute texts',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.statuteLibrary),
          ),
          _ExploreTile(
            icon: Icons.search,
            title: 'Find a legal topic',
            subtitle: 'Search in English, Urdu or Roman Urdu',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
          ),
          _ExploreTile(
            icon: Icons.people_outline,
            title: 'Find a lawyer',
            subtitle: 'Browse your connected directory',
            onTap: () => ShellController.instance.goTo(2),
          ),
          const SizedBox(height: 22),
          // AI Legal Tools section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.gradientEmeraldToDark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'AI Legal Tools',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '15 AI-powered features to guide you',
                            style: TextStyle(
                              color: Color(0xFFD2E4DA),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _AiToolChip(
                      icon: Icons.photo_camera_outlined,
                      label: 'Snap & Explain',
                      highlight: true,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.documentExplainer),
                    ),
                    _AiToolChip(
                      icon: Icons.verified_user_outlined,
                      label: 'My Rights',
                      highlight: true,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.rightsScenarios),
                    ),
                    _AiToolChip(
                      icon: Icons.description_outlined,
                      label: 'Doc Generator',
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.docGenerator),
                    ),
                    _AiToolChip(
                      icon: Icons.analytics_outlined,
                      label: 'Case Prediction',
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.casePrediction),
                    ),
                    _AiToolChip(
                      icon: Icons.verified_user_outlined,
                      label: 'Rights Checker',
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.rightsChecker),
                    ),
                    _AiToolChip(
                      icon: Icons.warning_amber_outlined,
                      label: 'Scam Detector',
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.scamDetector),
                    ),
                    _AiToolChip(
                      icon: Icons.emergency_outlined,
                      label: 'Emergency SOS',
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.emergencySos),
                    ),
                    _AiToolChip(
                      icon: Icons.grid_view,
                      label: 'View all 15 →',
                      highlight: true,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.aiFeaturesHub),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Card(
            elevation: 0,
            color: scheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: scheme.primary, size: 21),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A starting point, with sources to check. This app provides general information. A qualified lawyer can advise on your facts and the current law.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Manage privacy & answer sources'),
          ),
        ],
      ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _AiToolChip extends StatelessWidget {
  const _AiToolChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: highlight
              ? AppColors.gold
              : AppColors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlight
                ? AppColors.gold
                : AppColors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 16,
              color: highlight ? AppColors.darkGreen : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: highlight ? AppColors.darkGreen : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
