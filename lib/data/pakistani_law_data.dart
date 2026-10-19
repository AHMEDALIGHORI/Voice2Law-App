/// Curated Pakistani-law knowledge used in two places:
///  1. `LocalLegalBrain` - offline answers (rich cards with roadmap/documents/
///     statutes, same shape as the original hand-written topics).
///  2. `DirectGeminiService` - retrieved context ("RAG") injected into the
///     Gemini prompt so cloud answers cite the same verified statutes.
///
/// Every entry is deliberately written against the statute that actually
/// governs the subject in Pakistan (Punjab/KP/Sindh/Balochistan aware where
/// the law is provincial) so the answers stay actionable rather than generic.
library;

import 'law/consumer_labour_law.dart';
import 'law/criminal_misc_law.dart';
import 'law/cyber_family_law.dart';
import 'law/property_finance_law.dart';
import 'law/welfare_misc_law.dart';

/// One actionable step of a legal roadmap.
class LawStep {
  const LawStep(
    this.title,
    this.titleUrdu,
    this.detail,
    this.detailUrdu,
    this.time,
    this.timeUrdu,
    this.authority,
    this.authorityUrdu,
  );

  final String title;
  final String titleUrdu;
  final String detail;
  final String detailUrdu;
  final String time;
  final String timeUrdu;
  final String authority;
  final String authorityUrdu;
}

/// A statute/section reference shown in "Court mode".
class LawStatute {
  const LawStatute(this.act, this.actUrdu, this.section, this.note);

  final String act;
  final String actUrdu;
  final String section;
  final String note;
}

/// A single curated topic of Pakistani law.
class LawTopic {
  const LawTopic({
    required this.id,
    required this.category,
    required this.keywords,
    required this.summary,
    required this.summaryUrdu,
    this.courtNote = '',
    this.courtNoteUrdu = '',
    this.urgency = 'normal',
    this.helpline = '',
    this.steps = const <LawStep>[],
    this.documents = const <String>[],
    this.statutes = const <LawStatute>[],
  });

  /// Stable id, e.g. `cyber-fraud`.
  final String id;
  final String category;

  /// Trigger words, English **and** Urdu, matched case-insensitively.
  final List<String> keywords;

  /// Citizen-level explanation, no jargon.
  final String summary;
  final String summaryUrdu;

  /// Advocate-level answer with sections/precedents.
  final String courtNote;
  final String courtNoteUrdu;

  final String urgency;
  final String helpline;
  final List<LawStep> steps;
  final List<String> documents;
  final List<LawStatute> statutes;

  /// Compact, prompt-friendly text injected into the Gemini request so the
  /// model grounds its answer in the curated law instead of guessing.
  String toRetrievalSnippet() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('[${category.toUpperCase()}] $id')
      ..writeln('Citizen summary: $summary')
      ..writeln('Urdu summary: $summaryUrdu');
    if (courtNote.isNotEmpty) {
      buffer.writeln('Legal analysis: $courtNote');
    }
    for (final LawStatute statute in statutes) {
      buffer.writeln(
        '- Statute: ${statute.act} ${statute.section} - ${statute.note}',
      );
    }
    if (steps.isNotEmpty) {
      buffer.writeln(
        'Roadmap: ${steps.map((LawStep s) => '${s.title} (${s.time})').join('; ')}',
      );
    }
    if (documents.isNotEmpty) {
      buffer.writeln('Documents: ${documents.join('; ')}');
    }
    return buffer.toString().trim();
  }
}

/// Every curated topic, grouped by domain file so the data stays reviewable.
const List<LawTopic> pakistaniLawTopics = <LawTopic>[
  ...cyberFamilyTopics,
  ...consumerLabourTopics,
  ...propertyFinanceTopics,
  ...criminalMiscTopics,
  ...welfareMiscTopics,
];

/// All distinct categories covered by the curated data, useful for the
/// "browse by topic" screens and for validating coverage in tests.
List<String> get pakistaniLawCategories {
  final Set<String> categories = <String>{};
  for (final LawTopic topic in pakistaniLawTopics) {
    categories.add(topic.category);
  }
  final List<String> sorted = categories.toList()..sort();
  return sorted;
}
