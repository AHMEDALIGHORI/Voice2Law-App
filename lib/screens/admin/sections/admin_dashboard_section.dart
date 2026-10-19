import 'package:flutter/material.dart';
import '../../../core/app_scope.dart';
import '../../../models/models.dart';

class AdminDashboardSection extends StatefulWidget {
  const AdminDashboardSection({super.key});
  @override
  State<AdminDashboardSection> createState() => _AdminDashboardSectionState();
}

class _AdminDashboardSectionState extends State<AdminDashboardSection> {
  DashboardSnapshot? _data;
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AppScope.of(context).api.getDashboard();
      if (mounted) setState(() => _data = data);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Dashboard unavailable. Check your server and admin token.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Service overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Live server data. Pull down to refresh.'),
          const SizedBox(height: 20),
          if (_error != null)
            Text(_error!)
          else ...[
            if (_data!.metrics.isEmpty)
              const Text('No metrics have been recorded yet.'),
            ..._data!.metrics.entries.map(
              (m) => Card(
                child: ListTile(
                  title: Text(
                    m.key.replaceAllMapped(
                      RegExp(r'[A-Z]'),
                      (m) => ' ${m[0]!.toLowerCase()}',
                    ),
                  ),
                  trailing: Text(
                    '${m.value}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Recent activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_data!.recentActivities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No recent activity.'),
              ),
            ..._data!.recentActivities.map(
              (q) => Card(
                child: ListTile(
                  title: Text(q.question),
                  subtitle: Text('${q.category} · ${q.status}'),
                ),
              ),
            ),
          ],
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh dashboard'),
          ),
        ],
      ),
    );
  }
}
