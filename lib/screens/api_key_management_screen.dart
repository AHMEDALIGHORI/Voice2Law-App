import 'package:flutter/material.dart';
import '../core/app_scope.dart';
import '../widgets/brand.dart';

/// Dedicated screen for managing API keys across all AI providers.
/// Users can add, edit, delete, and switch between Gemini, Groq, and Seena keys.
class ApiKeyManagementScreen extends StatefulWidget {
  const ApiKeyManagementScreen({super.key});

  @override
  State<ApiKeyManagementScreen> createState() => _ApiKeyManagementScreenState();
}

class _ApiKeyManagementScreenState extends State<ApiKeyManagementScreen> {
  final _providers = const [
    {'id': 'gemini', 'name': 'Google Gemini'},
    {'id': 'groq', 'name': 'Groq'},
    {'id': 'seena', 'name': 'Seena'},
  ];

  String? _editingProvider;
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;
  bool _controllersLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppScope.of() cannot be resolved in initState(); load the controllers
    // once dependencies are available.
    if (_controllersLoaded) return;
    _controllersLoaded = true;
    _loadControllers();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadControllers() {
    final c = AppScope.of(context).config;
    for (final p in _providers) {
      final id = p['id'] as String;
      final controller = TextEditingController();
      switch (id) {
        case 'gemini':
          controller.text = c.geminiApiKey;
          break;
        case 'groq':
          controller.text = c.groqApiKey;
          break;
        case 'seena':
          controller.text = c.seenaApiKey;
          break;
      }
      _controllers[id] = controller;
    }
  }

  String _masked(String key) {
    if (key.isEmpty) return '';
    if (key.length <= 8) return '•' * key.length;
    return '••••••••${key.substring(key.length - 4)}';
  }

  Future<void> _saveKey(String providerId) async {
    final controller = _controllers[providerId];
    if (controller == null) return;
    setState(() => _saving = true);
    try {
      switch (providerId) {
        case 'gemini':
          await AppScope.of(
            context,
          ).config.update(geminiApiKey: controller.text.trim());
          break;
        case 'groq':
          await AppScope.of(
            context,
          ).config.update(groqApiKey: controller.text.trim());
          break;
        case 'seena':
          await AppScope.of(
            context,
          ).config.update(seenaApiKey: controller.text.trim());
          break;
      }
      if (mounted) {
        setState(() => _editingProvider = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_providers.firstWhere((p) => p['id'] == providerId)['name']} key saved',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save key')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clearKey(String providerId) async {
    switch (providerId) {
      case 'gemini':
        await AppScope.of(context).config.update(geminiApiKey: '');
        break;
      case 'groq':
        await AppScope.of(context).config.update(groqApiKey: '');
        break;
      case 'seena':
        await AppScope.of(context).config.update(seenaApiKey: '');
        break;
    }
    _controllers[providerId]?.clear();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Key removed')));
    }
  }

  Future<void> _setActiveProvider(String providerId) async {
    await AppScope.of(context).config.update(selectedAiProvider: providerId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Active provider: ${_providers.firstWhere((p) => p['id'] == providerId)['name']}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = AppScope.of(context).config;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage API Keys'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Active Provider',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: config.selectedAiProvider,
            onChanged: (v) {
              if (v != null) _setActiveProvider(v);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._providers.map((p) {
                  final id = p['id'] as String;
                  final isActive = config.selectedAiProvider == id;
                  return ListTile(
                    leading: Radio<String>(value: id),
                    title: Text(p['name'] as String),
                    subtitle: Text(
                      isActive ? 'Currently active' : 'Tap to activate',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: _controllers[id]!.text.isNotEmpty
                        ? Text(
                            'Key: ${_masked(_controllers[id]!.text)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          )
                        : const Text(
                            'No key',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Configure Keys',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ..._providers.map((p) {
            final id = p['id'] as String;
            final controller = _controllers[id]!;
            final isEditing = _editingProvider == id;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (controller.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: () => _clearKey(id),
                          ),
                      ],
                    ),
                    if (controller.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Stored: ${_masked(controller.text)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: controller,
                      obscureText: !isEditing,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: isEditing
                            ? 'New ${p['name']} key'
                            : '${p['name']} key',
                        helperText: isEditing
                            ? 'Enter your API key'
                            : 'Tap edit to change the key',
                        helperMaxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (!isEditing)
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                            onPressed: () =>
                                setState(() => _editingProvider = id),
                          ),
                        if (isEditing) ...[
                          BrandButton(
                            label: 'Save',
                            icon: Icons.check,
                            busy: _saving && _editingProvider == id,
                            onPressed: () => _saveKey(id),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _saving
                                ? null
                                : () => setState(() => _editingProvider = null),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text(
            'Security',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          const Text(
            'API keys are stored using platform secure storage (Keychain/Keystore on mobile, session-only in browsers). '
            'Keys are never transmitted to Voice2Law servers — they are used only to call the AI provider directly from your device.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          BrandButton(
            label: 'Done',
            icon: Icons.check,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
