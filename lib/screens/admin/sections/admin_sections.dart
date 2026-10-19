import 'package:flutter/material.dart';

import '../../../core/app_scope.dart';
import '../../../data/content_data.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/brand.dart';
export 'live_query_section.dart';

/// Shared header for every admin section.
class AdminSectionHeader extends StatelessWidget {
  const AdminSectionHeader({
    super.key,
    required this.title,
    required this.titleUrdu,
    this.actions = const <Widget>[],
  });

  final String title;
  final String titleUrdu;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                UrduText(
                  titleUrdu,
                  size: 14,
                  align: TextAlign.left,
                  height: 1.8,
                ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// `LegalKnowledgeBase.tsx` – the RAG knowledge entries with their status.
class KnowledgeBaseSection extends StatefulWidget {
  const KnowledgeBaseSection({super.key});

  @override
  State<KnowledgeBaseSection> createState() => _KnowledgeBaseSectionState();
}

class _KnowledgeBaseSectionState extends State<KnowledgeBaseSection> {
  List<LegalEntry> _entries = [];
  bool _demo = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final List<LegalEntry> entries = await AppScope.of(
        context,
      ).api.getKnowledgeBase();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _demo = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _demo = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: <Widget>[
        AdminSectionHeader(
          title: 'Legal Knowledge Base',
          titleUrdu: 'قانونی معلومات',
          actions: <Widget>[
            IconButton(
              tooltip: 'Refresh',
              onPressed: () {
                setState(() => _loading = true);
                _load();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        if (_demo)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: StatusBlock(
              icon: Icons.cloud_off,
              title: 'Knowledge base unavailable',
              message:
                  'Check your server connection and administrator access, then refresh.',
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: _entries.isEmpty ? 1 : _entries.length,
            itemBuilder: (BuildContext context, int index) {
              if (_entries.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No records to display.'),
                );
              }
              final LegalEntry entry = _entries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BrandCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              entry.section,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),
                          StatusChip(label: entry.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emeraldDeep,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        entry.englishSummary,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.darkGreen.withValues(alpha: 0.72),
                        ),
                      ),
                      if (entry.urduSummary.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        UrduText(entry.urduSummary, size: 14),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Updated ${entry.lastUpdated}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// `UrduContentManagement.tsx` – published / draft Urdu documents.
class UrduContentSection extends StatefulWidget {
  const UrduContentSection({super.key});

  @override
  State<UrduContentSection> createState() => _UrduContentSectionState();
}

class _UrduContentSectionState extends State<UrduContentSection> {
  List<UrduDocument> _documents = [];
  bool _demo = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final List<UrduDocument> documents = await AppScope.of(
        context,
      ).api.getUrduDocuments();
      if (!mounted) return;
      setState(() {
        _documents = documents;
        _demo = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _demo = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: <Widget>[
        AdminSectionHeader(
          title: 'Urdu Law Content',
          titleUrdu: 'اردو قانونی مواد',
          actions: <Widget>[
            IconButton(
              tooltip: 'Refresh',
              onPressed: () {
                setState(() => _loading = true);
                _load();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        if (_demo)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: StatusBlock(
              icon: Icons.cloud_off,
              title: 'Documents unavailable',
              message:
                  'Check your server connection and administrator access, then refresh.',
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: _documents.isEmpty ? 1 : _documents.length,
            itemBuilder: (BuildContext context, int index) {
              if (_documents.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No records to display.'),
                );
              }
              final UrduDocument document = _documents[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BrandCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.danger,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              document.title,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),
                          StatusChip(label: document.status),
                        ],
                      ),
                      if (document.titleUrdu.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        UrduText(document.titleUrdu, size: 14),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${document.category} • ${document.fileName} • ${document.fileSize}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// `UserQueriesFeedback.tsx` – every question asked by users, with the status
/// controls the website provides (resolve / flag).
class UserQueriesSection extends StatefulWidget {
  const UserQueriesSection({super.key});

  @override
  State<UserQueriesSection> createState() => _UserQueriesSectionState();
}

class _UserQueriesSectionState extends State<UserQueriesSection> {
  List<QueryRecord> _queries = [];
  bool _demo = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final List<QueryRecord> queries = await AppScope.of(
        context,
      ).api.getQueries();
      if (!mounted) return;
      setState(() {
        _queries = queries;
        _demo = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _demo = true;
        _loading = false;
      });
    }
  }

  Future<void> _update(QueryRecord query, String status) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final List<QueryRecord> updated = _queries
        .map(
          (QueryRecord item) => item.id == query.id
              ? QueryRecord(
                  id: item.id,
                  userName: item.userName,
                  userEmail: item.userEmail,
                  queryType: item.queryType,
                  category: item.category,
                  question: item.question,
                  aiResponse: item.aiResponse,
                  status: status,
                  timestamp: item.timestamp,
                  confidence: item.confidence,
                )
              : item,
        )
        .toList();

    try {
      await AppScope.of(context).api.updateQuery(
        query.id,
        updated.firstWhere((QueryRecord item) => item.id == query.id),
      );
      if (mounted) setState(() => _queries = updated);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not sync the change (offline).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: <Widget>[
        const AdminSectionHeader(
          title: 'User Queries & Feedback',
          titleUrdu: 'صارفین کے سوالات',
        ),
        if (_demo)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: StatusBlock(
              icon: Icons.cloud_off,
              title: 'Queries unavailable',
              message:
                  'Check your server connection and administrator access, then refresh.',
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: _queries.isEmpty ? 1 : _queries.length,
            itemBuilder: (BuildContext context, int index) {
              if (_queries.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No records to display.'),
                );
              }
              final QueryRecord query = _queries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BrandCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            query.queryType == 'voice'
                                ? Icons.mic
                                : Icons.description_outlined,
                            size: 18,
                            color: AppColors.emerald,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${query.userName} • ${query.category}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),
                          StatusChip(label: query.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        query.question,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        query.aiResponse,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Text(
                            '${query.confidence.toStringAsFixed(0)}% confidence',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _update(query, 'resolved'),
                            child: const Text('Resolve'),
                          ),
                          TextButton(
                            onPressed: () => _update(query, 'flagged'),
                            child: const Text('Flag'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AddLawyerSection extends StatefulWidget {
  const AddLawyerSection({super.key});

  @override
  State<AddLawyerSection> createState() => _AddLawyerSectionState();
}

class _AddLawyerSectionState extends State<AddLawyerSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nameUrdu = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _whatsapp = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _court = TextEditingController();
  final TextEditingController _experience = TextEditingController(text: '5');

  final Set<String> _expertise = <String>{'Family Law'};
  String _city = 'Islamabad';
  bool _verified = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _nameUrdu.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _email.dispose();
    _court.dispose();
    _experience.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final Lawyer lawyer = Lawyer(
      id: '',
      name: _name.text.trim(),
      nameUrdu: _nameUrdu.text.trim(),
      expertise: _expertise.toList(),
      courtLocation: _court.text.trim(),
      city: _city,
      rating: 0,
      experience: int.tryParse(_experience.text.trim()) ?? 0,
      languages: const <String>['Urdu', 'English'],
      phoneNumber: _phone.text.trim(),
      whatsapp: _whatsapp.text.trim(),
      email: _email.text.trim(),
      verified: _verified,
      availability: 'Available Today',
    );

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    String message;
    try {
      await AppScope.of(context).api.createLawyer(lawyer);
      message = 'Lawyer saved to the backend.';
    } catch (error) {
      message =
          'Not saved. ${error is ApiException ? error.message : "Please try again."}';
    }
    if (!mounted) return;
    setState(() => _saving = false);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final List<String> areas = ContentData.expertiseAreas
        .where((String a) => a != 'all')
        .toList();
    final List<String> cities = ContentData.cities
        .where((String c) => c != 'all')
        .toList();

    return Column(
      children: <Widget>[
        const AdminSectionHeader(
          title: 'Add Lawyer',
          titleUrdu: 'وکیل شامل کریں',
        ),
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: <Widget>[
                BrandCard(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                        ),
                        validator: (String? value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameUrdu,
                        decoration: const InputDecoration(
                          labelText: 'Name (Urdu)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _whatsapp,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'WhatsApp',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _court,
                        decoration: const InputDecoration(
                          labelText: 'Court / chamber',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _experience,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Years of experience',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _verified,
                        activeThumbColor: AppColors.emerald,
                        title: const Text(
                          'Bar council verified',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        onChanged: (bool value) =>
                            setState(() => _verified = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                BrandCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'City',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: cities
                            .map(
                              (String city) => ChoiceChip(
                                label: Text(city),
                                labelStyle: TextStyle(
                                  color: _city == city
                                      ? AppColors.white
                                      : AppColors.darkGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                                selected: _city == city,
                                onSelected: (_) => setState(() => _city = city),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Expertise',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: areas
                            .map(
                              (String area) => FilterChip(
                                label: Text(area),
                                labelStyle: TextStyle(
                                  color: _expertise.contains(area)
                                      ? AppColors.white
                                      : AppColors.darkGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                                selected: _expertise.contains(area),
                                onSelected: (bool selected) => setState(() {
                                  if (selected) {
                                    _expertise.add(area);
                                  } else {
                                    _expertise.remove(area);
                                  }
                                }),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                BrandButton(
                  label: 'Save lawyer',
                  icon: Icons.save_outlined,
                  busy: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// `SystemSettings.tsx` – the platform configuration form
/// (`GET/PUT /system-settings`).
class SystemSettingsSection extends StatefulWidget {
  const SystemSettingsSection({super.key});

  @override
  State<SystemSettingsSection> createState() => _SystemSettingsSectionState();
}

class _SystemSettingsSectionState extends State<SystemSettingsSection> {
  SystemSettingsData _settings = const SystemSettingsData();
  bool _loading = true;
  bool _saving = false;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final SystemSettingsData data = await AppScope.of(
        context,
      ).api.getSystemSettings();
      if (!mounted) return;
      setState(() {
        _settings = data;
        _offline = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _offline = true;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    String message;
    try {
      await AppScope.of(context).api.updateSystemSettings(_settings);
      message = 'Settings updated.';
    } catch (error) {
      message =
          'Not synced - ${error is ApiException ? error.message : "Please try again."}';
    }
    if (!mounted) return;
    setState(() => _saving = false);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: <Widget>[
        const AdminSectionHeader(title: 'System Settings', titleUrdu: 'سیٹنگز'),
        if (_offline)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: StatusBlock(
              icon: Icons.cloud_off,
              title: 'Server settings unavailable',
              message: 'The values shown are defaults until your server can be reached.',
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: <Widget>[
              BrandCard(
                child: Column(
                  children: <Widget>[
                    _toggle(
                      'Maintenance mode',
                      _settings.maintenanceMode,
                      (bool value) => setState(
                        () => _settings = _settings.copyWith(
                          maintenanceMode: value,
                        ),
                      ),
                    ),
                    _toggle(
                      'Allow registration',
                      _settings.allowRegistration,
                      (bool value) => setState(
                        () => _settings = _settings.copyWith(
                          allowRegistration: value,
                        ),
                      ),
                    ),
                    _toggle(
                      'Email notifications',
                      _settings.emailNotifications,
                      (bool value) => setState(
                        () => _settings = _settings.copyWith(
                          emailNotifications: value,
                        ),
                      ),
                    ),
                    _toggle(
                      'SMS notifications',
                      _settings.smsNotifications,
                      (bool value) => setState(
                        () => _settings = _settings.copyWith(
                          smsNotifications: value,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _sliders(),
              const SizedBox(height: 18),
              BrandButton(
                label: 'Save settings',
                icon: Icons.save_outlined,
                busy: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sliders() {
    return BrandCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'AI confidence threshold',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
          Slider(
            value: _settings.aiConfidenceThreshold.clamp(0, 100),
            max: 100,
            divisions: 20,
            label: _settings.aiConfidenceThreshold.toStringAsFixed(0),
            onChanged: (double value) => setState(
              () =>
                  _settings = _settings.copyWith(aiConfidenceThreshold: value),
            ),
          ),
          const Text(
            'Urdu accuracy threshold',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
          Slider(
            value: _settings.urduAccuracyThreshold.clamp(0, 100),
            max: 100,
            divisions: 20,
            label: _settings.urduAccuracyThreshold.toStringAsFixed(0),
            onChanged: (double value) => setState(
              () =>
                  _settings = _settings.copyWith(urduAccuracyThreshold: value),
            ),
          ),
          Row(
            children: <Widget>[
              const Text(
                'Session timeout',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text('${_settings.sessionTimeout} min'),
            ],
          ),
          Slider(
            value: _settings.sessionTimeout.toDouble().clamp(5, 120),
            max: 120,
            divisions: 23,
            label: '${_settings.sessionTimeout}',
            onChanged: (double value) => setState(
              () =>
                  _settings = _settings.copyWith(sessionTimeout: value.round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      activeThumbColor: AppColors.emerald,
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: AppColors.darkGreen),
      ),
      onChanged: onChanged,
    );
  }
}
