import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/models.dart';

/// Standard footer attached to offline corpus answers.
const String kCorpusDisclaimer =
    '\n\nNote: This is the exact statutory text bundled inside Voice2Law. For a '
    'complete opinion, verify the current version of the law with a licensed '
    'lawyer (پاکستان کے لائسنس یافتہ وکیل سے تصدیق کریں).';

/// One section of a statute (e.g. PPC Section 302) from the bundled corpus.
class CorpusEntry {
  const CorpusEntry(this.section, this.heading, this.text);

  final String section;
  final String heading;
  final String text;
}

/// One lawyer Q&A pair.
class CorpusQa {
  const CorpusQa(this.question, this.answer);

  final String question;
  final String answer;
}

/// A statute in the federal library (from `pdf_data.json`).
class LibraryStatute {
  const LibraryStatute(this.title, this.charCount, this.text);

  final String title;
  final int charCount;
  final String text;
}

/// A browsable/searchable category of the corpus.
class CorpusCategory {
  const CorpusCategory({
    required this.id,
    required this.kind,
    required this.name,
    required this.nameUrdu,
    required this.group,
    required this.icon,
    required this.accent,
    required this.entries,
    required this.qaEntries,
    required this.library,
    required this.indexTitles,
  });

  final String id;
  final String kind; // 'statute' | 'qa' | 'library'
  final String name;
  final String nameUrdu;
  final String group;
  final String icon;
  final int accent;
  final List<CorpusEntry> entries;
  final List<CorpusQa> qaEntries;
  final List<LibraryStatute> library;
  final List<LibraryStatute> indexTitles;

  int get count => kind == 'statute'
      ? entries.length
      : kind == 'qa'
      ? qaEntries.length
      : library.length + indexTitles.length;
}

/// A ranked search result over statute sections / Q&A pairs.
class CorpusHit {
  const CorpusHit({
    required this.category,
    required this.section,
    required this.heading,
    required this.text,
    required this.score,
    required this.isQa,
  });

  final CorpusCategory category;
  final String section;
  final String heading;
  final String text;
  final double score;
  final bool isQa;
}

/// ---------------------------------------------------------------------------
/// StatuteCorpus – the bundled hybrid-RAG layer.
///
/// "Hybrid" retrieval:
///   1. Urdu query expansion  (طلاق → divorce) so Urdu questions hit the
///      English statute text,
///   2. a legal concept map (murder → qatl, chori → theft, zamanat → bail)
///      bridging everyday user phrasing to the tokens statutes are actually
///      titled with (validated on 27 citizen queries: MRR 0.13 → 0.29),
///   3. BM25-style token scoring over headings (high weight) and body text,
///   4. exact "section 302"-style detection with a strong boost.
///
/// The corpus is parsed once inside a background isolate and reused for the
/// offline brain, the Gemini grounding prompt and the statute library UI.
/// ---------------------------------------------------------------------------
class StatuteCorpus {
  StatuteCorpus._(this.categories, this._index);

  final List<CorpusCategory> categories;

  /// Pre-computed search index: term frequencies for heading + body per doc.
  final List<_DocIndex> _index;

  static StatuteCorpus? _cached;
  static Future<StatuteCorpus?>? _loading;

  static const String assetPath = 'assets/data/legal_corpus.json';

  /// Loads (once) and returns the corpus, or null when the asset is missing.
  static Future<StatuteCorpus?> get instance async {
    if (_cached != null) return _cached;
    return _loading ??= _load();
  }

  /// Optional warm-up so the first user question never waits on parsing.
  static void preload() {
    // ignore: unawaited_futures
    instance;
  }

  static Future<StatuteCorpus?> _load() async {
    try {
      final String raw = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> parsed = await compute(_parseJson, raw);
      final _Parsed parsedCorpus = _Parsed.fromJson(parsed);
      final List<CorpusCategory> categories = parsedCorpus.categories;

      // Build the flat search index.
      final List<_DocIndex> index = <_DocIndex>[];
      for (int c = 0; c < categories.length; c++) {
        final CorpusCategory category = categories[c];
        for (int e = 0; e < category.entries.length; e++) {
          final CorpusEntry entry = category.entries[e];
          index.add(
            _DocIndex(
              category: category,
              section: entry.section,
              heading: entry.heading,
              text: entry.text,
              isQa: false,
              headingFreq: _termFreq('${entry.heading} ${entry.section}'),
              bodyFreq: _termFreq('${entry.text} ${entry.heading}'),
            ),
          );
        }
        for (int e = 0; e < category.qaEntries.length; e++) {
          final CorpusQa qa = category.qaEntries[e];
          index.add(
            _DocIndex(
              category: category,
              section: 'Q&A',
              heading: qa.question,
              text: qa.answer,
              isQa: true,
              headingFreq: _termFreq(qa.question),
              bodyFreq: _termFreq(qa.answer),
            ),
          );
        }
      }
      return _cached = StatuteCorpus._(categories, index);
    } catch (err) {
      debugPrint('[StatuteCorpus] load failed: $err');
      return _cached = null;
    }
  }

  static Map<String, dynamic> _parseJson(String raw) =>
      jsonDecode(raw) as Map<String, dynamic>;

  // -- Retrieval ------------------------------------------------------------

  /// Urdu → English legal vocabulary so spoken Urdu questions can still hit
  /// the (English) statute corpus.
  static const Map<String, List<String>> _urduExpansion =
      <String, List<String>>{
        'طلاق': <String>['divorce', 'talaq'],
        'خلع': <String>['khula'],
        'نکاح': <String>['marriage', 'nikah'],
        'مہر': <String>['dower', 'mehr'],
        'نفقہ': <String>['maintenance'],
        'حضانت': <String>['custody', 'guardian'],
        'وراثت': <String>['inheritance', 'succession'],
        'وصیت': <String>['will'],
        'قتل': <String>['murder', 'culpable homicide', 'qatl'],
        'چوری': <String>['theft'],
        'ڈکیتی': <String>['robbery', 'dacoity'],
        'اغوا': <String>['kidnapping', 'abduction'],
        'جھگڑا': <String>['assault', 'hurt'],
        'ضمانت': <String>['bail'],
        'گرفتاری': <String>['arrest'],
        'تھان': <String>['police', 'fir'],
        'ایفآئیآر': <String>['fir', 'police report'],
        'پولیس': <String>['police'],
        'جیل': <String>['imprisonment'],
        'جرمانہ': <String>['fine', 'punishment'],
        'سزا': <String>['punishment'],
        'گواہ': <String>['witness', 'evidence'],
        'ثبوت': <String>['evidence', 'proof'],
        'جھوٹ': <String>['false', 'fabrication'],
        'بدنامی': <String>['defamation'],
        'جائیداد': <String>['property'],
        'زمین': <String>['land', 'property'],
        'مکان': <String>['house', 'premises'],
        'دکان': <String>['shop', 'premises'],
        'کرایہ': <String>['rent', 'tenancy'],
        'مالک': <String>['landlord', 'owner'],
        'قرض': <String>['debt'],
        'سود': <String>['interest'],
        'دھوکہ': <String>['cheating', 'fraud'],
        'خریداری': <String>['sale', 'transfer'],
        'بیع': <String>['sale', 'transfer'],
        'رجسٹری': <String>['registration'],
        'عدالت': <String>['court'],
        'مقدمہ': <String>['case', 'suit'],
        'وکیل': <String>['advocate'],
        'حق': <String>['right'],
        'آئین': <String>['constitution'],
        'آزادی': <String>['liberty', 'freedom'],
        'عورت': <String>['woman', 'women'],
        'بچہ': <String>['child', 'minor'],
        'حقوق': <String>['rights'],
        'صحافت': <String>['press'],
        'سائبر': <String>['cyber', 'electronic'],
      };

  /// Bidirectional legal concept map: everyday user phrasing (English +
  /// Roman Urdu) → the real corpus tokens the statutes are titled with.
  ///
  /// Grounded against actual corpus headings — PPC 302 is titled
  /// "Punishment of Qatl-i-Amd" and the English word "murder" never appears
  /// in it, so "murder/killing/qatal/khoon" all map to the token `qatl`.
  /// Measured on 27 hand-labelled citizen queries (tool/_bench_concept.py):
  /// MRR 0.13 → 0.29 overall, Roman Urdu 0.17 → 0.75, zero regressions.
  static const Map<String, List<String>> _conceptMap = <String, List<String>>{
    // homicide → PPC 302/300 ("qatl", "amd")
    'murder': <String>['qatl'],
    'kill': <String>['qatl'],
    'killing': <String>['qatl'],
    'killed': <String>['qatl'],
    'homicide': <String>['qatl'],
    'qatal': <String>['qatl'],
    'qatl': <String>['qatl'],
    'khoon': <String>['qatl'],
    'intentionally': <String>['amd'],
    'intentional': <String>['amd'],
    'deliberately': <String>['amd'],
    'deliberate': <String>['amd'],
    // punishment
    'saza': <String>['punishment'],
    'penalty': <String>['punishment'],
    // theft → PPC 378/379 ("theft")
    'stole': <String>['theft'],
    'steal': <String>['theft'],
    'stolen': <String>['theft'],
    'stealing': <String>['theft'],
    'chori': <String>['theft'],
    // robbery → PPC 390/392 ("robbery")
    'robbed': <String>['robbery'],
    'rob': <String>['robbery'],
    'loot': <String>['robbery'],
    'looting': <String>['robbery'],
    'dakaiti': <String>['robbery'],
    'dacoity': <String>['robbery'],
    'dacoit': <String>['robbery'],
    // defamation → PPC 499/500 ("defamation")
    'defame': <String>['defamation'],
    'slander': <String>['defamation'],
    'insult': <String>['defamation'],
    'insulting': <String>['defamation'],
    'badnaami': <String>['defamation'],
    // cheating/fraud → PPC 415/420 ("cheating")
    'fraud': <String>['cheating'],
    'deception': <String>['cheating'],
    'cheat': <String>['cheating'],
    'scam': <String>['cheating'],
    'dhoka': <String>['cheating'],
    'dishonestly': <String>['cheating'],
    // abduction/kidnapping → PPC 359/362 ("abduction")
    'abduct': <String>['abduction'],
    'abducted': <String>['abduction'],
    'abducting': <String>['abduction'],
    'kidnap': <String>['abduction'],
    'kidnapped': <String>['abduction'],
    'kidnapping': <String>['abduction'],
    // family law
    // NOTE: 'talaq' is already a real corpus token (matches MFL §7 directly),
    // so mapping it would only inject noise and demote §7. Only map user
    // words that are ABSENT from the corpus vocabulary.
    'mehr': <String>['dower'],
    'talak': <String>['divorce'],
    'zamanat': <String>['bail'],
    'zamanah': <String>['bail'],
    'nafaqa': <String>['maintenance'],
  };

  static final RegExp _sectionRef = RegExp(
    r'(?:section|sec\.?|دفعہ|دفعۃ)\s*([0-9]{1,3}[a-z]?)',
    caseSensitive: false,
  );

  static const int _maxSectionNum = 999;

  /// Tokenises mixed Urdu/English text into lowercase word tokens.
  static List<String> _tokenise(String input) {
    final List<String> tokens = <String>[];
    final Iterable<String> words = input
        .toLowerCase()
        .replaceAll(RegExp(r"[^0-9a-z\u0600-\u06FF\s]"), ' ')
        .split(RegExp(r'\s+'));
    for (final String word in words) {
      if (word.length < 2 && !RegExp(r'^\d$').hasMatch(word)) continue;
      tokens.add(word);
    }
    return tokens;
  }

  static Map<String, int> _termFreq(String text) {
    final Map<String, int> freq = <String, int>{};
    for (final String token in _tokenise(text)) {
      freq[token] = (freq[token] ?? 0) + 1;
    }
    return freq;
  }

  /// Hybrid search over every statute section and Q&A pair.
  List<CorpusHit> search(String query, {int limit = 5}) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty || _index.isEmpty) return const <CorpusHit>[];

    // 1) Urdu → English expansion.
    final Set<String> expanded = <String>{};
    _urduExpansion.forEach((String urdu, List<String> english) {
      if (q.contains(urdu)) expanded.addAll(english);
    });

    // 2) Explicit "section 302" reference.
    String? sectionRef;
    for (final RegExpMatch m in _sectionRef.allMatches(query)) {
      final String raw = m.group(1)!.toLowerCase();
      final int n = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), '')) ?? -1;
      if (n > 0 && n <= _maxSectionNum) {
        sectionRef = raw;
        break;
      }
    }

    final List<String> originalTokens = _tokenise(q);
    final List<String> queryTokens = <String>[...originalTokens];
    if (expanded.isNotEmpty) queryTokens.addAll(expanded);

    // 3) Concept expansion: bridge user phrasing (English + Roman Urdu) onto
    //    the real corpus tokens — e.g. "murder"/"qatal" → "qatl" (PPC 302 is
    //    titled "Qatl-i-Amd"; the word "murder" never appears), "chori" →
    //    "theft", "zamanat" → "bail". Applied to the ORIGINAL query tokens
    //    only: Urdu-expanded words are already corpus vocabulary.
    final Set<String> conceptAdded = <String>{};
    for (final String token in originalTokens) {
      final List<String>? targets = _conceptMap[token];
      if (targets != null) conceptAdded.addAll(targets);
    }
    queryTokens.addAll(conceptAdded);
    if (queryTokens.isEmpty) return const <CorpusHit>[];

    final String joined = queryTokens.join(' ');

    final List<_ScoredDoc> scored = <_ScoredDoc>[];
    for (final _DocIndex doc in _index) {
      double score = 0;
      for (final String token in queryTokens) {
        final int inHeading = doc.headingFreq[token] ?? 0;
        final int inBody = doc.bodyFreq[token] ?? 0;
        if (inHeading > 0) {
          score += 5.0 * inHeading.clamp(1, 3);
        }
        if (inBody > 0) {
          score += 0.9 * inBody.clamp(1, 4);
        }
      }
      if (score <= 0) continue;
      // Long statute texts shouldn't drown short, on-point sections.
      score /= 1 + (doc.bodyFreq.length / 400);
      // A full phrase in the heading is the strongest signal of intent.
      if (doc.heading.toLowerCase().contains(joined)) score += 4;
      if (sectionRef != null && doc.section.toLowerCase() == sectionRef) {
        score += 6;
      }
      scored.add(_ScoredDoc(doc, score));
    }

    scored.sort((_ScoredDoc a, _ScoredDoc b) => b.score.compareTo(a.score));

    final List<CorpusHit> hits = <CorpusHit>[];
    for (final _ScoredDoc scoredDoc in scored.take(limit)) {
      final _DocIndex doc = scoredDoc.doc;
      hits.add(
        CorpusHit(
          category: doc.category,
          section: doc.section,
          heading: doc.heading,
          text: doc.text,
          score: scoredDoc.score,
          isQa: doc.isQa,
        ),
      );
    }
    return hits;
  }

  /// Search the federal statute library by title.
  List<LibraryStatute> searchLibrary(String query, {int limit = 30}) {
    final String q = query.trim().toLowerCase();
    Iterable<LibraryStatute> pool = <LibraryStatute>[
      for (final CorpusCategory c in categories)
        if (c.kind == 'library') ...c.library,
    ];
    if (q.isEmpty) {
      return pool.take(limit).toList();
    }
    final List<LibraryStatute> matched = pool
        .where((LibraryStatute s) => s.title.toLowerCase().contains(q))
        .toList();
    if (matched.length < limit) {
      // Fall back to the title-only index so all 600+ statutes are findable.
      final Iterable<LibraryStatute> indexPool = <LibraryStatute>[
        for (final CorpusCategory c in categories)
          if (c.kind == 'library') ...c.indexTitles,
      ];
      matched.addAll(
        indexPool.where(
          (LibraryStatute s) =>
              s.title.toLowerCase().contains(q) &&
              !matched.any((LibraryStatute m) => m.title == s.title),
        ),
      );
    }
    return matched.take(limit).toList();
  }

  /// Prompt-ready grounding block for the cloud model (hybrid RAG). Combines
  /// statute-section hits with the strongest lawyer Q&A precedent.
  String retrievalContext(String question, {int limit = 4}) {
    final List<CorpusHit> hits = search(question, limit: limit + 2);
    if (hits.isEmpty) return '';

    final List<CorpusHit> statutes = hits
        .where((CorpusHit h) => !h.isQa)
        .take(limit - 1)
        .toList();
    final List<CorpusHit> qa = hits
        .where((CorpusHit h) => h.isQa)
        .take(1)
        .toList();

    final List<CorpusHit> selected = <CorpusHit>[...statutes, ...qa];
    if (selected.isEmpty) return '';

    final StringBuffer buffer = StringBuffer();
    for (final CorpusHit hit in selected) {
      if (hit.isQa) {
        buffer.writeln('[Lawyer Q&A precedent]');
        buffer.writeln('Q: ${hit.heading}');
        buffer.writeln('A: ${hit.text}');
      } else {
        buffer.writeln(
          '[${hit.category.name} · Section ${hit.section} · ${hit.heading}]',
        );
        buffer.writeln(hit.text);
      }
      buffer.writeln();
    }
    return buffer.toString().trim();
  }

  /// Builds an offline [AiAnswer] out of the best corpus hits, used when the
  /// curated knowledge base has no match and the cloud is unreachable.
  AiAnswer? composeAnswer(String question) {
    final List<CorpusHit> hits = search(question, limit: 3);
    if (hits.isEmpty) return null;
    final CorpusHit top = hits.first;

    final List<CorpusHit> statuteHits = hits
        .where((CorpusHit h) => !h.isQa)
        .take(3)
        .toList();
    final List<RelevantStatute> statutes = <RelevantStatute>[];
    for (final CorpusHit hit in statuteHits) {
      statutes.add(
        RelevantStatute(
          actName: hit.category.name,
          actNameUrdu: hit.category.nameUrdu,
          section: 'Section ${hit.section}',
          courtJurisdiction: 'Courts of Pakistan',
          citation: hit.heading,
          sourceLabel: 'Bundled Voice2Law corpus · verify current version',
          sourceExcerpt: hit.text,
        ),
      );
    }

    final bool qaOnly = statutes.isEmpty;
    final String englishBody = qaOnly
        ? 'A similar question has been answered by practising lawyers: '
              '"${top.heading}" — ${top.text}'
        : 'According to ${top.category.name}, Section ${top.section} '
              '(${top.heading}): ${top.text}'
              '${statuteHits.length > 1 ? ' Related provision: ${statuteHits[1].category.name} Section ${statuteHits[1].section} (${statuteHits[1].heading}).' : ''}';

    return AiAnswer(
      answer: englishBody + kCorpusDisclaimer,
      answerUrdu:
          'اس سوال کا جواب ${top.category.nameUrdu} کی روشنی میں دیا گیا ہے۔ '
          'متعلقہ دفعہ نمبر ${top.section} ہے اور مکمل قانونی حوالہ "Court Mode" '
          'میں موجود ہے۔ تفصیلی متن انگریزی قانونی wording کے مطابق درج ہے۔',
      category: top.category.group,
      confidence: 76,
      status: 'approved',
      offline: true,
      empatheticOpening:
          'Here is the exact statutory text from the Voice2Law law library.',
      empatheticOpeningUrdu:
          'ویس ٹو لاء کے قانونی ذخیرے سے متعلقہ دفعہ پیش ہے۔',
      courtModeAnswer: statutes
          .map(
            (RelevantStatute s) =>
                '${s.actName} — ${s.section} (${s.citation})',
          )
          .join(' | '),
      courtModeAnswerUrdu: statutes
          .map((RelevantStatute s) => '${s.actNameUrdu} — ${s.section}')
          .join(' | '),
      urgencyLevel: 'normal',
      statutes: statutes,
    );
  }
}

class _DocIndex {
  const _DocIndex({
    required this.category,
    required this.section,
    required this.heading,
    required this.text,
    required this.isQa,
    required this.headingFreq,
    required this.bodyFreq,
  });

  final CorpusCategory category;
  final String section;
  final String heading;
  final String text;
  final bool isQa;
  final Map<String, int> headingFreq;
  final Map<String, int> bodyFreq;
}

class _ScoredDoc {
  const _ScoredDoc(this.doc, this.score);

  final _DocIndex doc;
  final double score;
}

/// Plain decode target used inside the parse isolate.
class _Parsed {
  const _Parsed(this.categories);

  final List<CorpusCategory> categories;

  static _Parsed fromJson(Map<String, dynamic> json) {
    final List<CorpusCategory> categories = <CorpusCategory>[];
    for (final dynamic c in json['categories'] as List<dynamic>) {
      final Map<String, dynamic> cat = c as Map<String, dynamic>;
      final String kind = (cat['kind'] ?? 'statute').toString();
      final List<CorpusEntry> entries = <CorpusEntry>[];
      for (final dynamic e
          in (cat['entries'] ?? const <dynamic>[]) as List<dynamic>) {
        final Map<String, dynamic> m = e as Map<String, dynamic>;
        if (kind == 'qa') {
          continue; // handled below via qaEntries
        }
        entries.add(
          CorpusEntry(
            (m['s'] ?? '').toString(),
            (m['h'] ?? '').toString(),
            (m['t'] ?? '').toString(),
          ),
        );
      }
      final List<CorpusQa> qaEntries = <CorpusQa>[];
      if (kind == 'qa') {
        for (final dynamic e
            in (cat['entries'] ?? const <dynamic>[]) as List<dynamic>) {
          final Map<String, dynamic> m = e as Map<String, dynamic>;
          qaEntries.add(
            CorpusQa((m['q'] ?? '').toString(), (m['a'] ?? '').toString()),
          );
        }
      }
      final List<LibraryStatute> library = <LibraryStatute>[];
      for (final dynamic e
          in (cat['fullTexts'] ?? const <dynamic>[]) as List<dynamic>) {
        final Map<String, dynamic> m = e as Map<String, dynamic>;
        library.add(
          LibraryStatute(
            (m['title'] ?? '').toString(),
            ((m['t'] ?? '') as String).length,
            (m['t'] ?? '').toString(),
          ),
        );
      }
      final List<LibraryStatute> indexTitles = <LibraryStatute>[];
      for (final dynamic e
          in (cat['titles'] ?? const <dynamic>[]) as List<dynamic>) {
        final Map<String, dynamic> m = e as Map<String, dynamic>;
        indexTitles.add(
          LibraryStatute(
            (m['title'] ?? '').toString(),
            (m['chars'] ?? 0) as int,
            '',
          ),
        );
      }
      categories.add(
        CorpusCategory(
          id: (cat['id'] ?? '').toString(),
          kind: kind,
          name: (cat['name'] ?? '').toString(),
          nameUrdu: (cat['nameUrdu'] ?? '').toString(),
          group: (cat['group'] ?? '').toString(),
          icon: (cat['icon'] ?? 'menu_book').toString(),
          accent: (cat['accent'] ?? 0xFF1F6E43) as int,
          entries: entries,
          qaEntries: qaEntries,
          library: library,
          indexTitles: indexTitles,
        ),
      );
    }
    return _Parsed(categories);
  }
}
