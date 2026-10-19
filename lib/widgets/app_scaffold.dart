import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_drawer.dart';

/// Scaffold used by every pushed page (search, about, contact, …).
/// It reproduces the fixed website navbar as a Material app bar with the
/// navigation drawer attached.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.titleUrdu = '',
    this.floatingActionButton,
  });

  final String title;
  final String titleUrdu;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(title),
            if (titleUrdu.isNotEmpty)
              Text(
                titleUrdu,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gold,
                ),
              ),
          ],
        ),
        actions: actions,
      ),
      drawer: const AppDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
