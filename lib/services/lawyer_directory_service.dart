import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/content_data.dart';
import '../models/models.dart';

/// Demo lawyer directory backed by the free, keyless [randomuser.me] API.
///
/// The profiles are **not real lawyers**: names come from the randomuser.me
/// sample database and city, court, expertise, rating and languages are
/// derived deterministically from each record's UUID. Photos, phone numbers,
/// WhatsApp numbers, email addresses and bar council numbers are deliberately
/// left empty so no real person's photo or contact details are ever shown.
/// The directory screen labels the list as demo data.
class LawyerDirectoryService {
  LawyerDirectoryService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://randomuser.me/api/';
  static const Duration _timeout = Duration(seconds: 20);
  static const int _defaultCount = 30;

  /// Real first-instance courts for the cities used in [ContentData.cities].
  static const Map<String, String> _cityCourts = <String, String>{
    'Islamabad': 'Islamabad High Court',
    'Lahore': 'Lahore High Court',
    'Karachi': 'Sindh High Court',
    'Rawalpindi': 'Lahore High Court (Rawalpindi Bench)',
    'Peshawar': 'Peshawar High Court',
    'Multan': 'Lahore High Court (Multan Bench)',
  };

  static const Map<String, String> _cityLanguages = <String, String>{
    'Karachi': 'Sindhi',
    'Lahore': 'Punjabi',
    'Peshawar': 'Pashto',
    'Multan': 'Saraiki',
  };

  /// Fetches [count] demo profiles and maps them to [Lawyer] cards.
  Future<List<Lawyer>> fetchDemoLawyers({int count = _defaultCount}) async {
    final Uri uri = Uri.parse(
      '$_baseUrl?results=$count&inc=login,name,id,location',
    );
    final http.Response res;
    try {
      res = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw Exception('The demo directory request timed out.');
    } catch (_) {
      throw Exception('Could not reach randomuser.me for the demo directory.');
    }
    if (res.statusCode != 200) {
      throw Exception('The demo directory returned HTTP ${res.statusCode}.');
    }
    final dynamic decoded = jsonDecode(utf8.decode(res.bodyBytes));
    final List<dynamic>? results = decoded['results'] as List<dynamic>?;
    if (results == null) {
      throw Exception('The demo directory returned an unexpected payload.');
    }
    return results
        .whereType<Map>()
        .map((dynamic item) => _toLawyer(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Lawyer _toLawyer(Map<String, dynamic> item) {
    final Map<String, dynamic> login = Map<String, dynamic>.from(
      item['login'] as Map? ?? const <String, dynamic>{},
    );
    final Map<String, dynamic> name = Map<String, dynamic>.from(
      item['name'] as Map? ?? const <String, dynamic>{},
    );
    final String uuid = (login['uuid'] ?? '').toString();
    final int h = _hash(uuid);
    final List<String> cities = ContentData.cities
        .where((String city) => city != 'all')
        .toList();
    final List<String> areas = ContentData.expertiseAreas
        .where((String area) => area != 'all')
        .toList();
    final String city = cities[h % cities.length];
    final String firstArea = areas[h % areas.length];
    final String secondArea = areas[(h ~/ 3) % areas.length];
    final List<String> expertise = <String>[
      firstArea,
      if (secondArea != firstArea) secondArea,
    ];
    final List<String> languages = <String>[
      'Urdu',
      'English',
      if (_cityLanguages[city] != null) _cityLanguages[city]!,
    ];
    return Lawyer(
      id: uuid.isEmpty ? 'demo-${item.hashCode}' : uuid,
      name: '${(name['first'] ?? '').toString()} '
              '${(name['last'] ?? '').toString()}'
          .trim(),
      expertise: expertise,
      courtLocation: _cityCourts[city] ?? '',
      city: city,
      rating: 3.6 + (h % 14) / 10,
      reviewCount: 4 + (h ~/ 11) % 240,
      experience: 2 + (h ~/ 13) % 27,
      languages: languages,
      // Intentionally empty: no real photos, phone numbers, emails or bar
      // council numbers are attached to these demo profiles.
      phoneNumber: '',
      whatsapp: '',
      email: '',
      image: '',
      barCouncilNo: '',
    );
  }

  /// Small deterministic 32-bit hash (FNV-1a) so the same UUID always maps to
  /// the same profile across reloads.
  static int _hash(String input) {
    int hash = 0x811c9dc5;
    for (final int code in input.codeUnits) {
      hash = (hash ^ code) & 0xffffffff;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    // Avoid negative values on web (where ints are doubles).
    return hash & 0x7fffffff;
  }
}
