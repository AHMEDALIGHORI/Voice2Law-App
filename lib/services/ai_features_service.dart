import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import 'groq_service.dart';
import 'local_legal_brain.dart';
import 'seena_service.dart';
import 'statute_corpus.dart';

/// Result of a generic AI feature call.
class AiFeatureResult {
  const AiFeatureResult({
    required this.success,
    required this.content,
    this.title,
    this.offline = false,
  });

  final bool success;
  final String content;
  final String? title;
  final bool offline;
}

/// Service powering all AI-driven features: document generation, case
/// intake, rights checking, precedent search, term explanation, scam
/// detection, mediation suggestion, and deadline calculation.
///
/// All features use the same Gemini API (or fall back to LocalLegalBrain).
/// Each feature has its own system prompt that instructs the model to return
/// structured text suitable for the feature's UI.
class AiFeaturesService {
  AiFeaturesService(this._config, {http.Client? client})
    : _client = client ?? http.Client();

  final AppConfig _config;
  final http.Client _client;

  static const String _primaryModel = 'gemini-flash-latest';
  static const String _fallbackModel = 'gemini-flash-lite-latest';

  String? _lastStatus;
  String? get lastStatus => _lastStatus;
  bool get isOffline => _lastStatus != null && _lastStatus != 'ok';

  // ── Core call helper ────────────────────────────────────────────────────
  // Routes to the currently selected AI provider (Gemini, Groq, or Seena).

  Future<AiFeatureResult> _callAi(
    String systemPrompt,
    String userPrompt,
  ) async {
    if (!_config.cloudEnabled) {
      _lastStatus = 'offline';
      return AiFeatureResult(
        success: false,
        content:
            'Cloud AI is not enabled. Enable it in Settings to use '
            'this feature, or use the offline law library.',
        offline: true,
      );
    }

    final List<String> providers = <String>[
      _config.selectedAiProvider,
      'gemini',
      'groq',
    ];
    AiFeatureResult? lastFailure;
    for (final String provider in providers.toSet()) {
      final String apiKey = _keyFor(provider);
      if (apiKey.isEmpty) continue;
      if (provider == 'seena' && _config.seenaBaseUrl.trim().isEmpty) continue;
      final AiFeatureResult result = switch (provider) {
        'groq' => await _callGroq(systemPrompt, userPrompt, apiKey),
        'seena' => await _callSeena(systemPrompt, userPrompt, apiKey),
        _ => await _callGemini(systemPrompt, userPrompt, apiKey),
      };
      if (result.success) return result;
      lastFailure = result;
    }

    if (lastFailure != null) return lastFailure;
    _lastStatus = 'offline';
    return AiFeatureResult(
      success: false,
      content:
          'No AI key is configured. Add one in Settings to use this feature.',
      offline: true,
    );
  }

  String _keyFor(String provider) {
    switch (provider) {
      case 'groq':
        return _config.groqApiKey.trim();
      case 'seena':
        return _config.seenaApiKey.trim();
      case 'gemini':
      default:
        return _config.geminiApiKey.trim();
    }
  }

  Future<AiFeatureResult> _callGemini(
    String systemPrompt,
    String userPrompt,
    String apiKey,
  ) async {
    for (final String model in [_primaryModel, _fallbackModel]) {
      try {
        final http.Response res = await _client
            .post(
              Uri.parse(
                'https://generativelanguage.googleapis.com/v1beta/models/'
                '$model:generateContent',
              ),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=utf-8',
                'x-goog-api-key': apiKey,
              },
              body: jsonEncode(<String, dynamic>{
                'systemInstruction': {
                  'parts': <Map<String, String>>[
                    {'text': systemPrompt},
                  ],
                },
                'contents': <Map<String, dynamic>>[
                  {
                    'role': 'user',
                    'parts': <Map<String, String>>[
                      {'text': userPrompt},
                    ],
                  },
                ],
                'generationConfig': <String, dynamic>{
                  'responseMimeType': 'text/plain',
                  'temperature': 0.3,
                  'thinkingConfig': <String, dynamic>{'thinkingBudget': 128},
                },
              }),
            )
            .timeout(const Duration(seconds: 60));

        if (res.statusCode != 200) {
          _lastStatus = 'http_${res.statusCode}';
          continue;
        }

        final dynamic decoded = jsonDecode(utf8.decode(res.bodyBytes));
        final List<dynamic>? candidates =
            decoded['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) continue;

        final Map<String, dynamic>? content =
            (candidates[0] as Map<String, dynamic>?)?['content']
                as Map<String, dynamic>?;
        final List<dynamic>? parts = content?['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) continue;

        // Gemini 2.5 may emit thinking parts; only use the visible answer.
        final StringBuffer answer = StringBuffer();
        for (final dynamic part in parts) {
          if (part is! Map<String, dynamic>) continue;
          if (part['thought'] == true) continue;
          final String piece = (part['text'] ?? '').toString().trim();
          if (piece.isEmpty) continue;
          if (answer.isNotEmpty) answer.write('\n');
          answer.write(piece);
        }
        final String text = answer.toString().trim();
        if (text.isEmpty) continue;

        _lastStatus = 'ok';
        return AiFeatureResult(success: true, content: text);
      } catch (err) {
        if (err.toString().toLowerCase().contains('timeout')) {
          _lastStatus = 'timeout';
        }
        continue;
      }
    }

    _lastStatus ??= 'offline';
    return AiFeatureResult(
      success: false,
      content:
          'Could not reach the AI service. Please check your internet '
          'connection and try again.',
      offline: true,
    );
  }

  Future<AiFeatureResult> _callGroq(
    String systemPrompt,
    String userPrompt,
    String apiKey,
  ) async {
    for (final String model in [
      GroqService.primaryModel,
      GroqService.fallbackModel,
    ]) {
      try {
        final http.Response res = await _client
            .post(
              Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=utf-8',
                'Authorization': 'Bearer $apiKey',
              },
              body: jsonEncode(<String, dynamic>{
                'model': model,
                'messages': <Map<String, dynamic>>[
                  {'role': 'system', 'content': systemPrompt},
                  {'role': 'user', 'content': userPrompt},
                ],
                'temperature': 0.3,
              }),
            )
            .timeout(const Duration(seconds: 60));

        if (res.statusCode != 200) {
          _lastStatus = 'http_${res.statusCode}';
          continue;
        }

        final dynamic decoded = jsonDecode(utf8.decode(res.bodyBytes));
        final List<dynamic>? choices = decoded['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) continue;

        final String text =
            (choices.first['message'] as Map?)?['content'] as String? ??
            ''.trim();
        if (text.isEmpty) continue;

        _lastStatus = 'ok';
        return AiFeatureResult(success: true, content: text);
      } catch (err) {
        if (err.toString().toLowerCase().contains('timeout')) {
          _lastStatus = 'timeout';
        }
        continue;
      }
    }

    _lastStatus ??= 'offline';
    return AiFeatureResult(
      success: false,
      content:
          'Could not reach the AI service. Please check your internet '
          'connection and try again.',
      offline: true,
    );
  }

  Future<AiFeatureResult> _callSeena(
    String systemPrompt,
    String userPrompt,
    String apiKey,
  ) async {
    final String baseUrl = _config.seenaBaseUrl.trim();
    if (baseUrl.isEmpty) {
      _lastStatus = 'offline';
      return AiFeatureResult(
        success: false,
        content: 'Seena base URL not configured. Please set it in Settings.',
        offline: true,
      );
    }
    if (!AppConfig.isAllowedRemoteUrl(baseUrl)) {
      _lastStatus = 'insecure_url';
      return const AiFeatureResult(
        success: false,
        content: 'Seena base URL must use HTTPS. Please update it in Settings.',
        offline: true,
      );
    }

    final Uri uri = Uri.parse(
      baseUrl.endsWith('/')
          ? '${baseUrl}chat/completions'
          : '$baseUrl/chat/completions',
    );

    try {
      final http.Response res = await _client
          .post(
            uri,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode(<String, dynamic>{
              'model': SeenaService.model,
              'messages': <Map<String, dynamic>>[
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
              'temperature': 0.3,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (res.statusCode != 200) {
        _lastStatus = 'http_${res.statusCode}';
        return AiFeatureResult(
          success: false,
          content: 'Seena API error: HTTP ${res.statusCode}',
          offline: true,
        );
      }

      final dynamic decoded = jsonDecode(utf8.decode(res.bodyBytes));
      final List<dynamic>? choices = decoded['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        _lastStatus = 'offline';
        return AiFeatureResult(
          success: false,
          content: 'No response from Seena API.',
          offline: true,
        );
      }

      final String text =
          (choices.first['message'] as Map?)?['content'] as String? ??
          ''.trim();
      if (text.isEmpty) {
        _lastStatus = 'offline';
        return AiFeatureResult(
          success: false,
          content: 'Empty response from Seena API.',
          offline: true,
        );
      }

      _lastStatus = 'ok';
      return AiFeatureResult(success: true, content: text);
    } catch (err) {
      if (err.toString().toLowerCase().contains('timeout')) {
        _lastStatus = 'timeout';
      }
      _lastStatus ??= 'offline';
      return AiFeatureResult(
        success: false,
        content:
            'Could not reach Seena API. Please check your internet '
            'connection and try again.',
        offline: true,
      );
    }
  }

  // ── Feature 1: Legal Document Generator ─────────────────────────────────

  static const String _docGenPrompt = '''
You are Voice2Law's Legal Document Generator for Pakistan.
Generate a formal legal document based on the user's description.
Rules:
- Use correct Pakistani legal format and section references.
- Include placeholders in [SQUARE BRACKETS] for information the user must fill
  (names, dates, CNIC, addresses, amounts).
- Structure: Title, To (authority), Subject, Body, Prayer/Relief, Date, Signature.
- Write in clear formal English. Add an Urdu translation after if possible.
- Do not give legal advice — only generate the document draft.
''';

  Future<AiFeatureResult> generateDocument(String description) async {
    // Build RAG context from local corpus
    final String curated = LocalLegalBrain.retrievalContext(description);
    String corpusContext = '';
    try {
      final StatuteCorpus? corpus = await StatuteCorpus.instance;
      if (corpus != null) corpusContext = corpus.retrievalContext(description);
    } catch (_) {}

    final StringBuffer buf = StringBuffer()
      ..write('Generate a legal document for this situation:\n\n$description')
      ..writeln()
      ..writeln('Reference notes (use relevant sections only):')
      ..writeln(curated)
      ..writeln(corpusContext);

    return _callAi(_docGenPrompt, buf.toString());
  }

  // ── Feature 2: Document Scanner & Explainer ─────────────────────────────

  static const String _docScanPrompt = '''
You are Voice2Law's Document Explainer for Pakistan.
The user has provided the text of a legal document (court order, FIR, notice, etc.).
Explain it in plain language:
1. What type of document is this?
2. What does it say, in simple terms?
3. What are the key dates, deadlines, and obligations?
4. What should the user do next?
5. Are there any red flags or unusual clauses?
Write in clear English. Add an Urdu summary at the end.
''';

  Future<AiFeatureResult> explainDocument(String documentText) async {
    return _callAi(
      _docScanPrompt,
      'Explain this legal document:\n\n$documentText',
    );
  }

  /// Explains a photographed legal document directly, without OCR on the
  /// device. The image is sent to Gemini's vision model only when the user
  /// taps "Explain"; nothing is stored by Voice2Law.
  ///
  /// Only Gemini supports image input among the configured providers. For
  /// other providers we return a clear message asking the user to paste the
  /// text instead of silently failing.
  Future<AiFeatureResult> explainDocumentImage(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
    String extraContext = '',
  }) async {
    if (!_config.cloudEnabled || _config.activeAiApiKey.trim().isEmpty) {
      _lastStatus = 'offline';
      return const AiFeatureResult(
        success: false,
        content:
            'Cloud AI is not enabled. Enable it in Settings to read a photo, '
            'or paste the document text for an offline answer.',
        offline: true,
      );
    }
    if (_config.selectedAiProvider != 'gemini') {
      _lastStatus = 'vision_unavailable';
      return const AiFeatureResult(
        success: false,
        content:
            'Photo reading is available with Gemini. Switch the AI provider '
            'to Gemini in Settings, or paste the document text instead.',
        offline: true,
      );
    }
    // Gemini inline data limit is ~20 MB; keep a safety margin so the
    // base64 encoding cannot blow up the request.
    if (imageBytes.lengthInBytes > 8 * 1024 * 1024) {
      return const AiFeatureResult(
        success: false,
        content:
            'This photo is too large. Please choose a smaller image or paste '
            'the document text instead.',
        offline: false,
      );
    }

    final StringBuffer promptBuffer = StringBuffer()
      ..writeln(
        'Read the legal document in this photo. Transcribe the important '
        'text, then explain it using the instructions below.',
      )
      ..writeln(
        'If the photo is blurry or incomplete, say exactly which parts you '
        'could not read instead of guessing.',
      )
      ..writeln(_docScanPrompt);
    if (extraContext.trim().isNotEmpty) {
      promptBuffer.writeln('User context: ${extraContext.trim()}');
    }

    return _callGeminiVision(
      _docScanPrompt,
      promptBuffer.toString(),
      _config.activeAiApiKey.trim(),
      imageBytes,
      mimeType,
    );
  }

  Future<AiFeatureResult> _callGeminiVision(
    String systemPrompt,
    String userPrompt,
    String apiKey,
    Uint8List imageBytes,
    String mimeType,
  ) async {
    final String encoded = base64Encode(imageBytes);
    for (final String model in [_primaryModel, _fallbackModel]) {
      try {
        final http.Response res = await _client
            .post(
              Uri.parse(
                'https://generativelanguage.googleapis.com/v1beta/models/'
                '$model:generateContent',
              ),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=utf-8',
                'x-goog-api-key': apiKey,
              },
              body: jsonEncode(<String, dynamic>{
                'systemInstruction': {
                  'parts': <Map<String, String>>[
                    {'text': systemPrompt},
                  ],
                },
                'contents': <Map<String, dynamic>>[
                  {
                    'role': 'user',
                    'parts': <Map<String, dynamic>>[
                      {'text': userPrompt},
                      {
                        'inlineData': {'mimeType': mimeType, 'data': encoded},
                      },
                    ],
                  },
                ],
                'generationConfig': <String, dynamic>{
                  'responseMimeType': 'text/plain',
                  'temperature': 0.2,
                  'thinkingConfig': <String, dynamic>{'thinkingBudget': 128},
                },
              }),
            )
            .timeout(const Duration(seconds: 60));

        if (res.statusCode != 200) {
          _lastStatus = 'http_${res.statusCode}';
          continue;
        }

        final dynamic decoded = jsonDecode(utf8.decode(res.bodyBytes));
        final List<dynamic>? candidates =
            decoded['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) continue;

        final Map<String, dynamic>? content =
            (candidates[0] as Map<String, dynamic>?)?['content']
                as Map<String, dynamic>?;
        final List<dynamic>? parts = content?['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) continue;

        // Gemini 2.5 may emit thinking parts; only use the visible answer.
        final StringBuffer answer = StringBuffer();
        for (final dynamic part in parts) {
          if (part is! Map<String, dynamic>) continue;
          if (part['thought'] == true) continue;
          final String piece = (part['text'] ?? '').toString().trim();
          if (piece.isEmpty) continue;
          if (answer.isNotEmpty) answer.write('\n');
          answer.write(piece);
        }
        final String text = answer.toString().trim();
        if (text.isEmpty) continue;

        _lastStatus = 'ok';
        return AiFeatureResult(success: true, content: text);
      } catch (err) {
        if (err.toString().toLowerCase().contains('timeout')) {
          _lastStatus = 'timeout';
        }
        continue;
      }
    }

    _lastStatus ??= 'offline';
    return const AiFeatureResult(
      success: false,
      content:
          'Could not read this photo. Check your internet connection, or '
          'paste the document text and try again.',
      offline: true,
    );
  }

  // ── Feature 3: Legal Deadline Calculator ────────────────────────────────

  static const String _deadlinePrompt = '''
You are Voice2Law's Legal Deadline Calculator for Pakistan.
Calculate all relevant legal deadlines and limitation periods for the user's situation.
Rules:
- Reference the Limitation Act 1908 and relevant statutes.
- List each deadline with: the action required, the time limit, the statutory basis,
  and the calculated date (if the user provides a trigger date).
- If no date is provided, state the time limit from the triggering event.
- Format as a clear numbered list.
- Add an Urdu summary.
''';

  Future<AiFeatureResult> calculateDeadlines(String situation) async {
    return _callAi(_deadlinePrompt, situation);
  }

  // ── Feature 4: Multi-turn Case Intake ────────────────────────────────────

  static const String _intakePrompt = '''
You are Voice2Law's Case Intake Assistant for Pakistan.
Ask follow-up questions one at a time to gather all relevant facts for a legal matter.
Rules:
- Ask only ONE question at a time.
- Keep questions short and specific.
- After 3-5 questions, or when you have enough facts, produce a structured
  case summary with: Facts, Legal Issue, Applicable Law, Recommended Action.
- Write in clear English with Urdu translations for key points.
''';

  Future<AiFeatureResult> continueIntake(String conversationSoFar) async {
    return _callAi(_intakePrompt, conversationSoFar);
  }

  // ── Feature 5: Case Outcome Prediction ──────────────────────────────────

  static const String _predictionPrompt = '''
You are Voice2Law's Case Outcome Predictor for Pakistan.
Based on the described facts, predict likely outcomes.
Rules:
- Give a confidence estimate (low/medium/high) with reasoning.
- List factors that favour the user and factors against.
- Reference relevant case law patterns and statutory provisions.
- Clearly state this is an estimate, not a guarantee.
- Format: Prediction, Confidence, Favourable Factors, Unfavourable Factors,
  Key Statutes, Recommendation.
- Add an Urdu summary.
''';

  Future<AiFeatureResult> predictOutcome(String caseDescription) async {
    final String curated = LocalLegalBrain.retrievalContext(caseDescription);
    return _callAi(
      _predictionPrompt,
      '$caseDescription\n\nReference: $curated',
    );
  }

  // ── Feature 6: Legal Rights Checker ─────────────────────────────────────

  static const String _rightsPrompt = '''
You are Voice2Law's Legal Rights Checker for Pakistan.
Based on the user's situation, list which legal rights apply and which don't.
Format each right as:
✅ Right: [name] — [explanation with statute reference]
❌ Does NOT apply: [name] — [reason]
Also list rights the user may not know they have.
Add an Urdu summary.
''';

  Future<AiFeatureResult> checkRights(String situation) async {
    final String curated = LocalLegalBrain.retrievalContext(situation);
    return _callAi(_rightsPrompt, '$situation\n\nReference: $curated');
  }

  // ── Feature 7: Smart Follow-up Reminders ─────────────────────────────────

  static const String _reminderPrompt = '''
You are Voice2Law's Smart Reminder Generator for Pakistan.
Based on the user's legal situation and current progress, generate a timeline
of action items with deadlines.
Format as:
Day/Date: [action required] — [why] — [authority to contact]
Include court dates, document submission deadlines, and procedural milestones.
Add an Urdu summary.
''';

  Future<AiFeatureResult> generateReminders(String situation) async {
    return _callAi(_reminderPrompt, situation);
  }

  // ── Feature 8: Precedent Search ──────────────────────────────────────────

  static const String _precedentPrompt = '''
You are Voice2Law's Precedent Search Assistant for Pakistan.
Find and describe relevant Pakistani case law precedents for the user's situation.
Rules:
- Only cite real, well-known Pakistani Supreme Court and High Court cases.
- If you are not confident about a specific case citation, say so.
- For each precedent: Case name, citation (if known), court, key holding,
  and how it relates to the user's situation.
- Suggest 3-5 relevant precedents.
- Add an Urdu summary.
''';

  Future<AiFeatureResult> searchPrecedents(String caseDescription) async {
    return _callAi(_precedentPrompt, caseDescription);
  }

  // ── Feature 9: Legal Term Explainer ──────────────────────────────────────

  static const String _termPrompt = '''
You are Voice2Law's Legal Term Explainer for Pakistan.
Explain the legal term in plain, simple language that a citizen can understand.
Rules:
- Give a 1-2 sentence plain-English explanation.
- Add the Urdu equivalent term and explanation.
- Add the statutory context where the term is used.
- Add a simple example.
- If the term has multiple legal meanings, list each briefly.
''';

  Future<AiFeatureResult> explainTerm(String term) async {
    return _callAi(_termPrompt, 'Explain: $term');
  }

  // ── Feature 10: Statute AI Search ───────────────────────────────────────

  Future<AiFeatureResult> searchStatutes(String query) async {
    // Try local corpus first — it's instant and doesn't need the cloud.
    try {
      final StatuteCorpus? corpus = await StatuteCorpus.instance;
      if (corpus != null) {
        final String context = corpus.retrievalContext(query);
        if (context.isNotEmpty) {
          return AiFeatureResult(
            success: true,
            content: context,
            title: 'Bundled statute results',
            offline:
                false, // local corpus is a valid source, not an error state
          );
        }
      }
    } catch (_) {}

    // Fall back to Gemini for a natural-language answer.
    return _callAi(
      'You are Voice2Law\'s Statute Search for Pakistan. '
      'Find and explain the relevant statutes, sections, and provisions '
      'for the user\'s query. Cite exact section numbers. Add Urdu summary.',
      query,
    );
  }

  // ── Feature 11: Emergency Legal SOS ──────────────────────────────────────

  static const String _sosPrompt = '''
You are Voice2Law's Emergency Legal SOS for Pakistan.
The user is in an urgent legal situation. Provide:
1. Immediate steps to take RIGHT NOW (safety first).
2. Emergency numbers to call (15 Police, 1099 Women Helpline, 1042 HRCP, etc.).
3. What to document/preserve immediately.
4. What NOT to do.
5. Nearest likely help (police station, women shelter, legal aid).
Keep it brief and action-oriented. Add Urdu.
''';

  Future<AiFeatureResult> emergencySos(String situation) async {
    return _callAi(_sosPrompt, situation);
  }

  // ── Feature 12: Scam & Fraud Detector ───────────────────────────────────

  static const String _scamPrompt = '''
You are Voice2Law's Legal Scam Detector for Pakistan.
Analyze the described situation for common legal scams and fraud patterns.
Check for:
- Property fraud (fake registries, double sales, encroachment)
- Fake FIR extortion
- Dowry harassment misuse
- Cheque dishonour fraud (Section 489-F PPC misuse)
- Cyber fraud impersonation
- Touts posing as lawyers/agents
Rate the scam risk: ⚠️ LOW / 🔶 MEDIUM / 🔴 HIGH
Explain why and what to do. Add Urdu.
''';

  Future<AiFeatureResult> detectScam(String situation) async {
    return _callAi(_scamPrompt, situation);
  }

  // ── Feature 13: Mediation Suggestion ────────────────────────────────────

  static const String _mediationPrompt = '''
You are Voice2Law's Mediation Advisor for Pakistan.
Before recommending court action, suggest alternative dispute resolution.
Check if the situation is suitable for:
1. Union Council Arbitration (MFLO 1961 Section 7)
2. Panchayat / Jirga (informal, where appropriate)
3. Court-annexed mediation
4. Ombudsman complaints (banking, insurance, Wafaqi Mohtasib)
5. Consumer dispute resolution
Rate suitability: ✅ RECOMMENDED / ⚠️ POSSIBLE / ❌ NOT SUITABLE
Explain why and give next steps. Add Urdu.
''';

  Future<AiFeatureResult> suggestMediation(String situation) async {
    return _callAi(_mediationPrompt, situation);
  }
}
