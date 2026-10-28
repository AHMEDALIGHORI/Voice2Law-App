import 'package:flutter/material.dart';
import '../core/app_scope.dart';
import '../core/language_helper.dart';
import '../widgets/brand.dart';
import 'api_key_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _url = TextEditingController();
  final _token = TextEditingController();
  final _key = TextEditingController();
  final _groqKey = TextEditingController();
  final _seenaKey = TextEditingController();
  final _seenaUrl = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  bool _ready = false,
      _cloud = false,
      _direct = true,
      _tts = false,
      _saving = false;
  String _locale = 'auto';
  String _langPref = 'en';
  String _aiProvider = 'gemini';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ready) {
      _read();
      _ready = true;
    }
  }

  void _read() {
    final c = AppScope.of(context).config;
    _url.text = c.apiBaseUrl;
    _token.text = c.apiToken;
    _key.text = c.geminiApiKey;
    _groqKey.text = c.groqApiKey;
    _seenaKey.text = c.seenaApiKey;
    _seenaUrl.text = c.seenaBaseUrl;
    _aiProvider = c.selectedAiProvider;
    _name.text = c.userName;
    _email.text = c.userEmail;
    _cloud = c.cloudEnabled;
    _direct = c.directAiEnabled;
    _tts = c.ttsEnabled;
    _locale = c.sttLocale;
    _langPref = c.languagePreference;
  }

  @override
  void dispose() {
    for (final c in [
      _url,
      _token,
      _key,
      _groqKey,
      _seenaKey,
      _seenaUrl,
      _name,
      _email,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _trimTrailingSlashes(String value) {
    String url = value.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  Future<void> _save() async {
    if (_saving) return;
    final services = AppScope.of(context);
    setState(() => _saving = true);
    try {
      if (_cloud) {
        final String activeKey = _aiProvider == 'groq'
            ? _groqKey.text.trim()
            : _aiProvider == 'seena'
            ? _seenaKey.text.trim()
            : _key.text.trim();
        if (activeKey.isEmpty) {
          throw const FormatException(
            'Add your API key for the selected provider before enabling cloud answers.',
          );
        }
        if (_aiProvider == 'seena' && _seenaUrl.text.trim().isEmpty) {
          throw const FormatException(
            'Add the Seena server URL before enabling cloud answers.',
          );
        }
      }

      final bool serverChanged =
          services.config.apiToken != _token.text.trim() ||
          services.config.apiBaseUrl != _trimTrailingSlashes(_url.text);

      // Persist first. A rejected URL or storage failure throws here, before
      // the admin session is invalidated or private data is cleared, so a
      // failed save no longer logs the user out.
      await services.config.update(
        apiBaseUrl: _url.text,
        apiToken: _token.text,
        geminiApiKey: _key.text,
        groqApiKey: _groqKey.text,
        seenaApiKey: _seenaKey.text,
        seenaBaseUrl: _seenaUrl.text,
        selectedAiProvider: _aiProvider,
        cloudEnabled: _cloud,
        directAiEnabled: _direct,
        ttsEnabled: _tts,
        sttLocale: _locale,
        userName: _name.text,
        userEmail: _email.text,
        languagePreference: _langPref,
      );
      if (serverChanged) services.auth.invalidate();
      await services.clearPrivateSession();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Preferences saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is FormatException
                  ? e.message
                  : 'Could not save securely. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _section(String title, String description, List<Widget> children) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(description),
                const SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
        ),
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences & privacy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section(
            'Your questions. Your choice.',
            'The bundled law library works without sending questions to an AI provider. Cloud answers send your question and up to six previous messages to the selected provider. Avoid names, identity numbers and other sensitive details.',
            [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable cloud answers'),
                subtitle: const Text(
                  'Off by default. Provider retention policies apply.',
                ),
                value: _cloud,
                onChanged: (v) => setState(() => _cloud = v),
              ),
              if (_cloud) ...[
                const Text(
                  'AI provider',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _aiProvider,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Choose AI provider',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'gemini',
                      child: Text('Google Gemini'),
                    ),
                    DropdownMenuItem(value: 'groq', child: Text('Groq')),
                    DropdownMenuItem(value: 'seena', child: Text('Seena')),
                  ],
                  onChanged: (v) => setState(() => _aiProvider = v ?? 'gemini'),
                ),
                const SizedBox(height: 16),
                if (_aiProvider == 'gemini')
                  TextField(
                    controller: _key,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Your Gemini API key',
                      helperText:
                          'Get it from https://makersuite.google.com/app/apikey. Stored securely on mobile; session-only in browsers.',
                      helperMaxLines: 3,
                    ),
                  )
                else if (_aiProvider == 'groq')
                  TextField(
                    controller: _groqKey,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Your Groq API key',
                      helperText:
                          'Get it from https://console.groq.com/keys. Stored securely on mobile; session-only in browsers.',
                      helperMaxLines: 3,
                    ),
                  )
                else if (_aiProvider == 'seena') ...[
                  TextField(
                    controller: _seenaKey,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Your Seena API key',
                      helperText:
                          'Stored securely on mobile; session-only in browsers.',
                      helperMaxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _seenaUrl,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Seena API base URL',
                      hintText: 'https://api.seena.example/v1',
                      helperText:
                          'Required for Seena provider. Leave empty for default.',
                      helperMaxLines: 2,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: const Text('How to get an API key'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Getting an API key'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Google Gemini:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                '1. Go to https://makersuite.google.com/app/apikey\n'
                                '2. Sign in with your Google account\n'
                                '3. Click "Create API key" and copy it\n'
                                '4. Paste it into the field above and save\n',
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Groq:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                '1. Go to https://console.groq.com/keys\n'
                                '2. Sign in or create an account\n'
                                '3. Click "Create API Key" and copy it\n'
                                '4. Paste it into the field above and save\n',
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Seena:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                '1. Get your API key and base URL from your Seena provider\n'
                                '2. Paste both into the fields above and save\n',
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Keys are stored securely on your device and are never shared.',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.vpn_key, size: 18),
                  label: const Text('Manage API keys'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApiKeyManagementScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
          _section(
            'Voice & language',
            'Speech recognition uses your device service, which may send audio to its provider. Urdu playback requires an installed Urdu voice.',
            [
              // --- App language preference ---
              const Text(
                'App language',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              // Use a dropdown for 5 languages — SegmentedButton only fits 3-4
              DropdownButtonFormField<String>(
                initialValue: _langPref,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Display language',
                ),
                items: [
                  ...kSupportedLanguages.map(
                    (LangMeta m) => DropdownMenuItem<String>(
                      value: m.code,
                      child: Row(
                        children: [
                          Text(
                            m.nativeLabel,
                            style: TextStyle(
                              fontFamily: m.fontFamily,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            m.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'auto',
                    child: Text('Device default'),
                  ),
                ],
                onChanged: (String? v) {
                  if (v == null) return;
                  setState(() {
                    _langPref = v;
                    // Auto-sync STT locale
                    if (v == 'auto') {
                      _locale = 'auto';
                    } else {
                      final LangMeta m = LanguageHelper.metaFor(v);
                      _locale = m.bcp47Stt.replaceAll('-', '_');
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              // --- TTS toggle ---
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Read answers aloud'),
                value: _tts,
                onChanged: (v) => setState(() => _tts = v),
              ),
              // --- STT locale ---
              DropdownButtonFormField<String>(
                initialValue: _locale,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Recognition language',
                ),
                items:
                    {
                          ...['auto', 'ur_PK', 'en_US'],
                          _locale,
                        }
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text(
                              {
                                    'auto': 'Device language',
                                    'ur_PK': 'Urdu (ur-PK)',
                                    'en_US': 'English (en-US)',
                                  }[v] ??
                                  v,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _locale = v ?? 'auto'),
              ),
              // --- AI source status ---
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final services = AppScope.of(context);
                  final provider = services.config.selectedAiProvider;
                  final status = switch (provider) {
                    'groq' => services.groq.lastGroqStatus,
                    'seena' => services.seena.lastSeenaStatus,
                    _ => services.gemini.lastGeminiStatus,
                  };
                  final isOffline = switch (provider) {
                    'groq' => services.groq.isOfflineMode,
                    'seena' => services.seena.isOfflineMode,
                    _ => services.gemini.isOfflineMode,
                  };
                  final String source = (status == null || status == 'ok')
                      ? (services.config.cloudEnabled
                            ? '${provider.toUpperCase()} AI (cloud)'
                            : 'Bundled Legal Library')
                      : 'Bundled Legal Library';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current AI source',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            isOffline
                                ? Icons.cloud_off
                                : Icons.cloud_done_outlined,
                            size: 16,
                            color: isOffline
                                ? const Color(0xFF856404)
                                : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(source, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      if (status != null && status != 'ok') ...[
                        const SizedBox(height: 4),
                        Text(
                          'Last ${provider.toUpperCase()} status: $status',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF856404),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
          _section(
            'Connected services',
            'A server supplies the lawyer directory, contact form and admin tools. Leave this blank to use the offline library. Production connections require HTTPS.',
            [
              TextField(
                controller: _url,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'https://your-server.example/api',
                ),
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Administrator & attribution'),
                children: [
                  TextField(
                    controller: _token,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Admin ID token',
                      helperText:
                          'Validated by your server; never grants access locally.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Name for backend queries',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email for backend queries',
                    ),
                  ),
                ],
              ),
            ],
          ),
          _section(
            'Private session',
            'Conversation history stays in app memory until you clear it or close the app. Quick exit clears the session, stops audio and opens a calculator. It cannot delete content already sent to a provider.',
            [
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear conversation now'),
                onPressed: () async {
                  await AppScope.of(context).clearPrivateSession();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conversation cleared on this device.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          BrandButton(
            label: 'Save preferences',
            icon: Icons.check,
            busy: _saving,
            onPressed: _save,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _saving
                ? null
                : () async {
                    final services = AppScope.of(context);
                    services.auth.invalidate();
                    await services.clearPrivateSession();
                    await services.config.reset();
                    if (mounted) setState(_read);
                  },
            child: const Text('Reset preferences & remove saved credentials'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
