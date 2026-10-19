import 'package:flutter_test/flutter_test.dart';

import 'package:voice2law_app/data/pakistani_law_data.dart';
import 'package:voice2law_app/services/local_legal_brain.dart';

void main() {
  group('Pakistani law library', () {
    test('covers the new categories beyond the original six topics', () {
      final Set<String> categories = <String>{
        for (final LawTopic topic in pakistaniLawTopics) topic.category,
      };
      expect(
        categories,
        containsAll(<String>[
          'Cybercrime',
          'Consumer Law',
          'Labour Law',
          'Property Law',
          'Civil Law',
        ]),
      );
      // 6 original topics + 8 curated ones.
      expect(pakistaniLawTopics.length, greaterThanOrEqualTo(8));
    });

    test(
      'every topic is complete: bilingual text, roadmap, documents, statutes',
      () {
        for (final LawTopic topic in pakistaniLawTopics) {
          expect(topic.id, isNotEmpty, reason: 'topic needs an id');
          expect(
            topic.category,
            isNotEmpty,
            reason: '${topic.id} needs a category',
          );
          expect(
            topic.keywords,
            isNotEmpty,
            reason: '${topic.id} needs keywords',
          );
          expect(
            topic.summary.length,
            greaterThan(80),
            reason: '${topic.id} summary',
          );
          expect(
            topic.summaryUrdu,
            isNotEmpty,
            reason: '${topic.id} Urdu summary',
          );
          expect(topic.courtNote, isNotEmpty, reason: '${topic.id} court note');
          expect(
            topic.steps.length,
            greaterThanOrEqualTo(3),
            reason: '${topic.id} roadmap',
          );
          expect(topic.documents, isNotEmpty, reason: '${topic.id} documents');
          expect(topic.statutes, isNotEmpty, reason: '${topic.id} statutes');
          for (final LawStatute statute in topic.statutes) {
            expect(statute.act, isNotEmpty);
            expect(statute.section, isNotEmpty);
          }
        }
      },
    );

    test('every topic has at least one English and one Urdu keyword', () {
      for (final LawTopic topic in pakistaniLawTopics) {
        bool hasAscii = false;
        bool hasUrdu = false;
        for (final String keyword in topic.keywords) {
          if (keyword.runes.every((int r) => r < 0x0600)) hasAscii = true;
          if (keyword.runes.any((int r) => r >= 0x0600 && r <= 0x06FF)) {
            hasUrdu = true;
          }
        }
        expect(hasAscii, isTrue, reason: '${topic.id} needs English triggers');
        expect(hasUrdu, isTrue, reason: '${topic.id} needs Urdu triggers');
      }
    });

    test('retrieval resolves English questions to the right topic', () {
      final Map<String, String> cases = <String, String>{
        'My bank account was hacked and money was transferred out':
            'cyber-fraud',
        'I want to report domestic violence and need protection':
            'domestic-violence',
        'My landlord raised the rent and I want to complain as a consumer':
            'consumer-protection',
        'My employer has not paid my salary for three months':
            'labour-employment',
        'There is a mutation dispute over my agricultural land':
            'land-property-dispute',
        'My cheque was dishonoured and I did not get my money back':
            'cheque-dishonour',
        'How do I get bail for my brother who is in jail?': 'bail-detention',
        'I need a witness and proof of my documents for a case':
            'evidence-witness',
        'An official asked me for a bribe, who can I complain to?':
            'anti-corruption',
        'I got an e-challan and I want to appeal it': 'traffic-challan',
      };
      cases.forEach((String question, String expectedId) {
        final List<LawTopic> hits = LocalLegalBrain.retrieve(question);
        expect(hits, isNotEmpty, reason: 'no retrieval for: $question');
        expect(hits.first.id, expectedId, reason: 'wrong topic for: $question');
      });
    });

    test('retrieval resolves Urdu questions too', () {
      final List<LawTopic> cyber = LocalLegalBrain.retrieve(
        'میرے بینک اکاؤنٹ سے آن لائن رقم نکل گئی',
      );
      expect(cyber.first.id, 'cyber-fraud');

      final List<LawTopic> dv = LocalLegalBrain.retrieve(
        'گھر میں میرے شوہر نے مار پیٹا',
      );
      expect(dv.first.id, 'domestic-violence');
    });

    test('multi-word keywords outrank a stray single-word hit', () {
      // "pre-emption notice" must beat a topic that only mentions "land".
      final List<LawTopic> hits = LocalLegalBrain.retrieve(
        'how do I serve a pre-emption notice on my neighbour before he sells the land?',
      );
      expect(hits.first.id, 'land-property-dispute');
    });

    test('answer() builds a full card from the curated topics', () {
      final dynamic answer = LocalLegalBrain.answer(
        'My bank account was hacked, I lost money online',
      );
      expect(answer.offline, isTrue);
      expect(answer.category, 'Cybercrime');
      expect(answer.roadmap, isNotEmpty);
      expect(answer.documents, isNotEmpty);
      expect(answer.statutes, isNotEmpty);
      expect(answer.urgencyLevel, 'urgent');
      expect(answer.answerUrdu, isNotEmpty);
    });

    test(
      'retrievalContext is prompt-ready and empty for unrelated questions',
      () {
        final String context = LocalLegalBrain.retrievalContext(
          'cheque bounced, how do I recover?',
        );
        expect(context, contains('Negotiable Instruments Act'));
        expect(
          LocalLegalBrain.retrievalContext('what is the weather today'),
          isEmpty,
        );
      },
    );
  });
}
