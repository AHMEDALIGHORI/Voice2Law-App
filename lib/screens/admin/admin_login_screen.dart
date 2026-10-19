import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../../core/routes.dart';
import '../../widgets/brand.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    return Scaffold(
      appBar: AppBar(title: const Text('Administrator access')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListenableBuilder(
              listenable: auth,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/voice2law_logo.png',
                        width: 96,
                        height: 96,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Secure admin access',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Configure your server and admin ID token in Preferences. Your server must confirm the admin role. Sessions expire after 30 minutes.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (auth.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        auth.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (auth.isLocked)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Access checks are paused for 15 minutes after repeated failures.',
                      ),
                    ),
                  BrandButton(
                    label: 'Verify & sign in',
                    busy: auth.isLoading,
                    icon: Icons.lock_outline,
                    onPressed: auth.isLocked
                        ? null
                        : () async {
                            final ok = await auth.login('', '');
                            if (ok && context.mounted) {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed(AppRoutes.adminPanel);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.settings),
                    child: const Text('Open connection preferences'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
