import 'package:flutter_test/flutter_test.dart';

import 'package:voice2law_app/services/statute_corpus.dart';

/// End-to-end validation of the bidirectional legal concept map added to
/// [StatuteCorpus.search] (English + Roman Urdu → real corpus tokens).
///
/// The map was measured offline on 27 hand-labelled citizen queries
/// (tool/_bench_concept.py): MRR 0.13 → 0.29, Roman Urdu 0.17 → 0.75,
/// zero regressions. These tests pin the headline wins against the real
/// bundled corpus so a future refactor can't silently drop them.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StatuteCorpus corpus;

  setUpAll(() async {
    final StatuteCorpus? loaded = await StatuteCorpus.instance;
    expect(
      loaded,
      isNotNull,
      reason: 'assets/data/legal_corpus.json must load inside flutter test',
    );
    corpus = loaded!;
  });

  List<String> sectionsOf(List<CorpusHit> hits) => <String>[
    for (final CorpusHit hit in hits) hit.section,
  ];

  group('StatuteCorpus concept-map retrieval', () {
    test('Roman Urdu "qatal ki saza" reaches PPC 302 (qatal → qatl)', () {
      // PPC 302 is titled "Punishment of qatl-i-amd"; the user word "qatal"
      // is absent from that heading, so only the concept map can bridge it.
      final List<CorpusHit> hits = corpus.search('qatal ki saza kya hai');
      expect(hits, isNotEmpty);
      expect(
        sectionsOf(hits),
        contains('302'),
        reason: 'concept map must bridge qatal → qatl (PPC 302) in top 5',
      );
    });

    test('English "killing" phrasing reaches PPC 302 within top 5', () {
      // The English word "killing" never appears in the §302 heading either.
      final List<CorpusHit> hits = corpus.search(
        'punishment for intentionally killing someone',
      );
      expect(sectionsOf(hits), contains('302'));
    });

    test('Roman Urdu "mehr" reaches Muslim Family Laws §10 (Dower)', () {
      final List<CorpusHit> hits = corpus.search('mehr kitni honi chahiye');
      expect(hits, isNotEmpty);
      expect(hits.first.section, '10');
      expect(hits.first.heading.toLowerCase(), contains('dower'));
    });

    test('Roman Urdu "zamanat" reaches the bail provisions', () {
      // "zamanat" is not corpus vocabulary; the map bridges it to "bail".
      final List<CorpusHit> hits = corpus.search('zamanat kaise milti hai');
      expect(
        sectionsOf(hits),
        anyOf(contains('496'), contains('497')),
        reason: 'zamanat → bail must surface CrPC bail sections',
      );
    });

    test('Roman Urdu "chori" surfaces theft sections', () {
      final List<CorpusHit> hits = corpus.search(
        'meri chori ho gayi kya karun',
      );
      expect(
        sectionsOf(hits),
        anyOf(
          contains('378'),
          contains('379'),
          contains('381'),
          contains('382'),
        ),
        reason: 'chori → theft must surface PPC theft sections in top 5',
      );
    });

    test('regression guard: "talaq" still hits MFL §7 directly', () {
      // "talaq" is deliberately NOT concept-mapped (it is already a corpus
      // token) — mapping it to "divorce" demoted §7 in the benchmark.
      final List<CorpusHit> hits = corpus.search('talaq ka tareeqa kya hai');
      expect(hits, isNotEmpty);
      expect(hits.first.section, '7');
    });

    test('Urdu script ضمانت reaches the bail provisions', () {
      final List<CorpusHit> hits = corpus.search('ضمانت کب مل سکتی ہے');
      expect(sectionsOf(hits), anyOf(contains('496'), contains('497')));
    });
  });
}
