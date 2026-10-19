import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../core/app_config.dart';
import '../models/models.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isNetworkError => statusCode == null;

  @override
  String toString() => message;
}

/// Thin Dart port of the website API client (`src/lib/api.ts`).
///
/// Every path, query parameter and payload key is identical to the web app so
/// the same Firebase Functions / Express backend can serve the mobile app.
class ApiService {
  ApiService([AppConfig? config, http.Client? client])
    : _config = config ?? AppConfig.instance,
      _client = client ?? http.Client();

  final AppConfig _config;
  http.Client _client;
  void cancelPending() {
    _client.close();
    _client = http.Client();
  }

  Future<void> clearToken() => _config.update(apiToken: '');
  static const Duration _timeout = Duration(seconds: 15);

  String get baseUrl => _config.apiBaseUrl;

  /// True when an admin API token was configured on the Settings screen.
  bool get hasToken => _config.apiToken.isNotEmpty;

  /// Convenience helper for "best effort" calls: never throws, returns null
  /// when the backend is unreachable. Used for analytics/audit style requests.
  Future<T?> trySilently<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }

  Map<String, String> get _headers {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };
    if (_config.apiToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${_config.apiToken}';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final Uri base = Uri.parse('${_config.apiBaseUrl}$path');
    if (query == null || query.isEmpty) return base;
    return base.replace(
      queryParameters: <String, String>{...base.queryParameters, ...query},
    );
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    if (path.startsWith('/ai/') && !_config.cloudEnabled) {
      throw ApiException('Cloud answers are disabled.');
    }
    if (_config.apiBaseUrl.isEmpty) {
      throw ApiException(
        'Configure your server in Settings to use this feature.',
      );
    }
    final Uri uri = _uri(path, query);
    if (uri.scheme != 'https' && !(kDebugMode && uri.scheme == 'http')) {
      throw ApiException('A secure HTTPS server is required.');
    }
    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: _headers)
              .timeout(_timeout);
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: _headers,
                body: jsonEncode(body ?? <String, dynamic>{}),
              )
              .timeout(_timeout);
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: _headers,
                body: jsonEncode(body ?? <String, dynamic>{}),
              )
              .timeout(_timeout);
        case 'DELETE':
          response = await _client
              .delete(uri, headers: _headers)
              .timeout(_timeout);
        default:
          throw ApiException('Unsupported method $method');
      }
    } on TimeoutException {
      throw ApiException(
        'The request to ${_config.apiBaseUrl} timed out. Is the backend running?',
      );
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException(
        'Cannot reach the Voice2Law API at ${_config.apiBaseUrl}.',
      );
    }

    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String message = decoded is Map && decoded['error'] != null
          ? decoded['error'].toString()
          : 'Request failed with status ${response.statusCode}';
      throw ApiException(message, statusCode: response.statusCode);
    }

    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{'data': decoded};
  }

  // ---------------------------------------------------------------------------
  // AI assistant endpoints
  // ---------------------------------------------------------------------------

  Future<AiAnswer> askText({
    required String question,
    List<ChatMessage> history = const [],
  }) async {
    final Map<String, dynamic> json = await _send(
      'POST',
      '/ai/text-query',
      body: <String, dynamic>{
        'question': question,
        'conversation': history
            .where((m) => m.id != 'greeting')
            .toList()
            .reversed
            .take(6)
            .toList()
            .reversed
            .map(
              (m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text.length > 2000
                    ? m.text.substring(0, 2000)
                    : m.text,
              },
            )
            .toList(),
        'userName': _config.userName,
        'userEmail': _config.userEmail,
      },
    );
    return AiAnswer.fromJson(json);
  }

  Future<AiAnswer> askVoice({
    String? transcript,
    String? audioData,
    String? outputLanguage,
    String? userName,
    String? userEmail,
  }) async {
    final Map<String, dynamic> json = await _send(
      'POST',
      '/ai/voice-query',
      body: <String, dynamic>{
        'transcript': ?transcript,
        'audioData': ?audioData,
        'outputLanguage': ?outputLanguage,
        'userName': userName ?? _config.userName,
        'userEmail': userEmail ?? _config.userEmail,
      },
    );
    return AiAnswer.fromJson(<String, dynamic>{
      ...json,
      if (asString(json['transcript']).isEmpty) 'transcript': transcript ?? '',
    });
  }

  // ---------------------------------------------------------------------------
  // Public content endpoints
  // ---------------------------------------------------------------------------

  Future<List<Lawyer>> getLawyers({
    String? city,
    String? expertise,
    String? availability,
    double? minRating,
    String? search,
  }) async {
    final Map<String, String> query = <String, String>{};
    if (city != null && city.isNotEmpty && city != 'all') query['city'] = city;
    if (expertise != null && expertise.isNotEmpty && expertise != 'all') {
      query['expertise'] = expertise;
    }
    if (availability != null &&
        availability.isNotEmpty &&
        availability != 'all') {
      query['availability'] = availability;
    }
    if (minRating != null) query['minRating'] = minRating.toString();

    final Map<String, dynamic> json = await _send(
      'GET',
      '/lawyers',
      query: query,
    );
    List<Lawyer> lawyers = (json['lawyers'] as List<dynamic>? ?? <dynamic>[])
        .map(
          (dynamic item) =>
              Lawyer.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    // Free-text search is applied on the client, matching the website
    // behaviour of `FindLawyersPage.tsx`.
    if (search != null && search.trim().isNotEmpty) {
      final String needle = search.trim().toLowerCase();
      lawyers = lawyers.where((Lawyer lawyer) {
        return lawyer.name.toLowerCase().contains(needle) ||
            lawyer.nameUrdu.contains(search.trim()) ||
            lawyer.city.toLowerCase().contains(needle) ||
            lawyer.expertise.any(
              (String exp) => exp.toLowerCase().contains(needle),
            );
      }).toList();
    }
    return lawyers;
  }

  Future<List<UrduDocument>> getUrduDocuments({bool publicOnly = false}) async {
    final Map<String, dynamic> json = await _send(
      'GET',
      publicOnly ? '/legal-topics' : '/urdu-documents',
    );
    return (json['documents'] as List<dynamic>? ?? <dynamic>[])
        .map(
          (dynamic item) =>
              UrduDocument.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<String> submitContact({
    required String name,
    required String email,
    String phone = '',
    required String subject,
    required String message,
  }) async {
    final Map<String, dynamic> json = await _send(
      'POST',
      '/contact',
      body: <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
        'subject': subject,
        'message': message,
      },
    );
    return asString(json['id']);
  }

  // ---------------------------------------------------------------------------
  // Admin / auth endpoints (identical to api.ts)
  // ---------------------------------------------------------------------------

  Future<UserProfile> authMe() async {
    final Map<String, dynamic> json = await _send('GET', '/auth/me');
    return UserProfile.fromJson(Map<String, dynamic>.from(json['user'] as Map));
  }

  /// Mirrors `api.recordFailedLogin` – the backend counts failures and returns
  /// `lockedUntil` once the 5-attempt / 15-minute lock kicks in.
  Future<String?> recordFailedLogin(String email) async {
    final Map<String, dynamic> json = await _send(
      'POST',
      '/auth/login',
      body: <String, dynamic>{'email': email, 'result': 'failed'},
    );
    return json['lockedUntil']?.toString();
  }

  Future<void> logoutRequest() async {
    await _send('POST', '/auth/logout');
  }

  Future<DashboardSnapshot> getDashboard() async {
    final Map<String, dynamic> json = await _send('GET', '/admin/dashboard');
    final Map<String, dynamic> rawMetrics = Map<String, dynamic>.from(
      (json['metrics'] as Map?) ?? <String, dynamic>{},
    );
    return DashboardSnapshot(
      metrics: rawMetrics.map<String, num>(
        (String key, dynamic value) =>
            MapEntry<String, num>(key, value is num ? value : 0),
      ),
      recentActivities:
          (json['recentActivities'] as List<dynamic>? ?? <dynamic>[])
              .map(
                (dynamic item) => QueryRecord.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(),
    );
  }

  Future<List<QueryRecord>> getQueries() async {
    final Map<String, dynamic> json = await _send('GET', '/queries');
    return (json['queries'] as List<dynamic>? ?? <dynamic>[])
        .map(
          (dynamic item) =>
              QueryRecord.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<QueryRecord> updateQuery(String id, QueryRecord query) async {
    final Map<String, dynamic> json = await _send(
      'PUT',
      '/queries/$id',
      body: query.toJson(),
    );
    return QueryRecord.fromJson(
      Map<String, dynamic>.from(json['query'] as Map),
    );
  }

  Future<void> deleteQuery(String id) => _send('DELETE', '/queries/$id');

  Future<List<LegalEntry>> getKnowledgeBase() async {
    final Map<String, dynamic> json = await _send('GET', '/knowledge-base');
    return (json['entries'] as List<dynamic>? ?? <dynamic>[])
        .map(
          (dynamic item) =>
              LegalEntry.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<LegalEntry> createKnowledgeEntry(LegalEntry entry) async {
    final Map<String, dynamic> json = await _send(
      'POST',
      '/knowledge-base',
      body: entry.toJson(),
    );
    return LegalEntry.fromJson(Map<String, dynamic>.from(json['entry'] as Map));
  }

  Future<LegalEntry> updateKnowledgeEntry(String id, LegalEntry entry) async {
    final Map<String, dynamic> json = await _send(
      'PUT',
      '/knowledge-base/$id',
      body: entry.toJson(),
    );
    return LegalEntry.fromJson(Map<String, dynamic>.from(json['entry'] as Map));
  }

  Future<void> deleteKnowledgeEntry(String id) =>
      _send('DELETE', '/knowledge-base/$id');

  Future<UrduDocument> createUrduDocument(UrduDocument document) async {
    final Map<String, dynamic> json = await _send(
      'POST',
      '/urdu-documents',
      body: document.toJson(),
    );
    return UrduDocument.fromJson(
      Map<String, dynamic>.from(json['document'] as Map),
    );
  }

  Future<UrduDocument> updateUrduDocument(
    String id,
    UrduDocument document,
  ) async {
    final Map<String, dynamic> json = await _send(
      'PUT',
      '/urdu-documents/$id',
      body: document.toJson(),
    );
    return UrduDocument.fromJson(
      Map<String, dynamic>.from(json['document'] as Map),
    );
  }

  Future<void> deleteUrduDocument(String id) =>
      _send('DELETE', '/urdu-documents/$id');

  Future<Lawyer> createLawyer(Lawyer lawyer) async {
    final Map<String, dynamic> json = await _send(
      'POST',
      '/lawyers',
      body: lawyer.toJson(),
    );
    return Lawyer.fromJson(Map<String, dynamic>.from(json['lawyer'] as Map));
  }

  Future<SystemSettingsData> getSystemSettings() async {
    final Map<String, dynamic> json = await _send('GET', '/system-settings');
    return SystemSettingsData.fromJson(
      Map<String, dynamic>.from(
        (json['settings'] as Map?) ?? <String, dynamic>{},
      ),
    );
  }

  Future<SystemSettingsData> updateSystemSettings(
    SystemSettingsData settings,
  ) async {
    final Map<String, dynamic> json = await _send(
      'PUT',
      '/system-settings',
      body: settings.toJson(),
    );
    return SystemSettingsData.fromJson(
      Map<String, dynamic>.from(
        (json['settings'] as Map?) ?? <String, dynamic>{},
      ),
    );
  }
}
