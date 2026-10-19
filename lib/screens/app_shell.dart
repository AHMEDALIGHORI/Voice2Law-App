import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/routes.dart';
import '../core/shell_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/brand.dart';
import 'ask_question_screen.dart';
import 'find_lawyers_screen.dart';
import 'home_screen.dart';
import 'legal_topics_screen.dart';
import 'more_screen.dart';

import '../widgets/legal_ux_components.dart';

/// Main shell: the brand app bar + drawer + bottom navigation hosting the five
/// most used destinations. This replaces the desktop navbar of the website.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = ShellController.instance.index;

  static const List<String> _labels = <String>[
    'Home',
    'Ask',
    'Lawyers',
    'Topics',
    'More',
  ];

  static const List<IconData> _icons = <IconData>[
    Icons.home_outlined,
    Icons.mic_outlined,
    Icons.gavel_outlined,
    Icons.menu_book_outlined,
    Icons.more_horiz,
  ];

  static const List<IconData> _selectedIcons = <IconData>[
    Icons.home,
    Icons.mic,
    Icons.gavel,
    Icons.menu_book,
    Icons.more_horiz,
  ];

  @override
  void initState() {
    super.initState();
    ShellController.instance.addListener(_onShellChanged);
  }

  @override
  void dispose() {
    ShellController.instance.removeListener(_onShellChanged);
    super.dispose();
  }

  void _onShellChanged() {
    if (!mounted) return;
    setState(() => _index = ShellController.instance.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        toolbarHeight: MediaQuery.textScalerOf(context).scale(24) + 42,
        backgroundColor: AppColors.darkGreen,
        title: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/voice2law_logo.png',
                width: 40,
                height: 40,
                semanticLabel: 'Voice2Law',
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Voice2Law',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  UrduText(
                    'قانونی معاون',
                    size: 10.5,
                    color: AppColors.gold,
                    height: 1.6,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'AI Legal Tools',
            icon: const Icon(Icons.auto_awesome_outlined, color: AppColors.gold),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.aiFeaturesHub),
          ),
          IconButton(
            tooltip: 'Quick exit to calculator',
            icon: const Icon(Icons.shield_outlined, color: AppColors.gold),
            onPressed: () => DiscreetModeDialog.triggerPanicExit(context),
          ),
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search, color: AppColors.white),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
          ),
        ],
      ),
      drawer: AppDrawer(currentTab: _index),
      body: <Widget>[
        const HomeScreen(),
        const AskQuestionScreen(),
        const FindLawyersScreen(),
        const LegalTopicsScreen(),
        const MoreScreen(),
      ][_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) {
          HapticFeedback.selectionClick();
          ShellController.instance.goTo(value);
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.emerald.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: AppColors.darkGreen.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: <NavigationDestination>[
          for (int index = 0; index < _labels.length; index++)
            NavigationDestination(
              icon: Icon(_icons[index], color: AppColors.navUnselected),
              selectedIcon: Icon(
                _selectedIcons[index],
                color: Theme.of(context).colorScheme.primary,
              ),
              label: _labels[index],
            ),
        ],
      ),
    );
  }
}
