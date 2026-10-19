import 'package:flutter/material.dart';
import '../../../core/app_scope.dart';
import '../../../models/models.dart';

/// Counts and review queues are derived only from records returned by the server.
class LiveQuerySection extends StatefulWidget {
  const LiveQuerySection({super.key, required this.mode});
  final String mode;
  @override
  State<LiveQuerySection> createState() => _LiveQuerySectionState();
}

class _LiveQuerySectionState extends State<LiveQuerySection> {
  List<QueryRecord> _records = [];
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
      final records = await AppScope.of(context).api.getQueries();
      if (mounted) setState(() => _records = records);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Live records could not be loaded. Check the server connection and admin access.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final selected = _records
        .where(
          (r) => widget.mode == 'review'
              ? r.status == 'flagged' || r.status == 'pending'
              : widget.mode == 'voice'
              ? r.queryType == 'voice'
              : true,
        )
        .toList();
    final counts = <String, int>{};
    for (final r in selected) {
      counts.update(r.category, (n) => n + 1, ifAbsent: () => 1);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.mode == 'review'
                ? 'Answers awaiting review'
                : widget.mode == 'voice'
                ? 'Voice activity'
                : 'Query analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Text(_error!)
          else ...[
            Text(
              '${selected.length} records in the current server response. Offline and direct Gemini sessions are not included.',
            ),
            const SizedBox(height: 20),
            if (selected.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No matching records yet.'),
                ),
              ),
            if (widget.mode == 'analytics')
              ...counts.entries.map(
                (e) => Card(
                  child: ListTile(
                    title: Text(e.key),
                    trailing: Text('${e.value}'),
                  ),
                ),
              )
            else
              ...selected.map(
                (r) => Card(
                  child: ExpansionTile(
                    title: Text(r.question),
                    subtitle: Text('${r.category} · ${r.status}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SelectableText(r.aiResponse),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.mode == 'voice')
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Recognition accuracy is not measured by this API. Query volume is not an accuracy score.',
                ),
              ),
          ],
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh live records'),
          ),
        ],
      ),
    );
  }
}

class AiReviewSection extends StatelessWidget {
  const AiReviewSection({super.key});
  @override
  Widget build(BuildContext context) => const LiveQuerySection(mode: 'review');
}

class VoiceNlpSection extends StatelessWidget {
  const VoiceNlpSection({super.key});
  @override
  Widget build(BuildContext context) => const LiveQuerySection(mode: 'voice');
}

class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({super.key});
  @override
  Widget build(BuildContext context) =>
      const LiveQuerySection(mode: 'analytics');
}

class LogsSecuritySection extends StatelessWidget {
  const LogsSecuritySection({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: const [
      Icon(Icons.shield_outlined, size: 48),
      SizedBox(height: 20),
      Text(
        'Server audit logs',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      ),
      SizedBox(height: 12),
      Text(
        'The current backend contract does not provide an audit-log endpoint. Review access events in your server console. This app does not fabricate activity or security status.',
      ),
      SizedBox(height: 20),
      Text(
        'Local protections: server-validated administrator role, timed sessions, protected mobile credential storage, and HTTPS in release builds.',
      ),
    ],
  );
}
