import 'package:flutter/material.dart';

import '../data/content_data.dart';
import '../models/models.dart';
import '../services/statute_corpus.dart';
import '../theme/app_theme.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/brand.dart';
import 'statute_library_screen.dart';

/// One search result row. [detail] marks results that open the bundled
/// statute text (corpus hits); everything else is informational.
class _SearchHit {
  const _SearchHit({
    required this.title,
    required this.titleUrdu,
    required this.description,
    required this.category,
    this.detailTitle,
    this.detailSubtitle,
    this.detailBody,
  });

  final String title;
  final String titleUrdu;
  final String description;
  final String category;
  final String? detailTitle;
  final String? detailSubtitle;
  final String? detailBody;

  bool get hasDetail => detailBody != null;
}

/// `SearchPage.tsx` – search bar with Urdu trending searches, suggested searches
/// and result cards. On top of the website's canned results the app searches
/// the bundled statute corpus, so queries like "302", "talaq" or "ضمانت"
/// return the actual statutory text.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<_SearchHit> _results = <_SearchHit>[];
  bool _searching = false;
  bool _hasSearched = false;

  static const List<String> _recent = <String>[
    'Divorce procedure in Pakistan',
    'Property inheritance laws',
    'Tenant rights and eviction',
    'Child custody rules',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Topic overview matches + corpus statute/Q&A hits, with the website's
  /// curated results kept at the bottom for parity.
  Future<void> _runSearch() async {
    final String query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
      _hasSearched = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    final String needle = query.toLowerCase();
    final List<_SearchHit> hits = <_SearchHit>[];
    for (final LegalTopic topic in ContentData.legalTopics) {
      final bool hit =
          topic.title.toLowerCase().contains(needle) ||
          topic.titleUrdu.contains(query) ||
          topic.subtopics.any(
            (LegalSubtopic sub) =>
                sub.title.toLowerCase().contains(needle) ||
                sub.urdu.contains(query) ||
                sub.description.toLowerCase().contains(needle),
          );
      if (hit) {
        hits.add(
          _SearchHit(
            title: topic.title,
            titleUrdu: topic.titleUrdu,
            description: topic.subtopics
                .map((LegalSubtopic sub) => sub.title)
                .join(' • '),
            category: 'Topic Overview',
          ),
        );
      }
    }

    // Real statute hits from the trained corpus (works in Urdu too).
    try {
      final StatuteCorpus? corpus = await StatuteCorpus.instance;
      if (corpus != null) {
        for (final CorpusHit hit in corpus.search(query, limit: 6)) {
          final String title = hit.isQa
              ? hit.heading
              : '${hit.category.name} — Section ${hit.section}';
          hits.add(
            _SearchHit(
              title: title,
              titleUrdu: hit.isQa ? hit.category.nameUrdu : hit.heading,
              description: hit.text,
              category: hit.isQa
                  ? 'Lawyers\' Answer'
                  : '${hit.category.group} · Statute',
              detailTitle: hit.isQa
                  ? 'Lawyers\' Q&A'
                  : '${hit.category.name} — Section ${hit.section}',
              detailSubtitle: hit.heading,
              detailBody: hit.text,
            ),
          );
        }
      }
    } catch (_) {
      // Corpus unavailable – topic + curated results still show.
    }

    if (!mounted) return;
    setState(() {
      _results = hits;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Search',
      titleUrdu: 'قانونی معلومات تلاش کریں',
      // The whole page scrolls so the search field, suggestion chips and
      // results remain reachable when accessibility text scaling makes the
      // header taller than the viewport.
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(gradient: AppColors.gradientPage),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _runSearch(),
                  decoration: InputDecoration(
                    hintText: 'Search legal topics, laws or procedures...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            tooltip: 'Search',
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _searching ? null : _runSearch,
                          ),
                  ),
                ),
                if (!_hasSearched) ...<Widget>[
                  const SizedBox(height: 20),
                  _ChipGroup(
                    title: 'Trending searches',
                    urdu: true,
                    values: ContentData.trendingSearches,
                    onSelected: (String value) {
                      _controller.text = value;
                      _runSearch();
                    },
                  ),
                  const SizedBox(height: 18),
                  _ChipGroup(
                    title: 'Recent searches',
                    urdu: false,
                    values: _recent,
                    onSelected: (String value) {
                      _controller.text = value;
                      _runSearch();
                    },
                  ),
                ],
              ],
            ),
          ),
          if (_searching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_results.isEmpty) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: StatusBlock(
                icon: Icons.search,
                title: _hasSearched
                    ? 'No results for "${_controller.text.trim()}"'
                    : 'Search the legal database',
                message: _hasSearched
                    ? 'Try a section number ("302"), a keyword '
                          '("bail") or an Urdu word ("طلاق").'
                    : 'Type a legal question in English or Urdu above. '
                          'Statutes, Q&A and topics are all searched.',
              ),
            ),
            const AppFooter(),
          ] else ...<Widget>[
            const SizedBox(height: 18),
            for (final _SearchHit hit in _results)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: _ResultCard(hit: hit),
              ),
            const AppFooter(),
          ],
        ],
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.title,
    required this.urdu,
    required this.values,
    required this.onSelected,
  });

  final String title;
  final bool urdu;
  final List<String> values;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              urdu ? Icons.trending_up : Icons.history,
              size: 18,
              color: AppColors.emerald,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (String value) => ActionChip(
                  label: urdu
                      ? UrduText(value, size: 14)
                      : Text(value, style: const TextStyle(fontSize: 12.5)),
                  backgroundColor: AppColors.white,
                  side: BorderSide(
                    color: AppColors.emerald.withValues(alpha: 0.3),
                  ),
                  onPressed: () => onSelected(value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.hit});

  final _SearchHit hit;

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CorpusDetailScreen(
          title: hit.detailTitle ?? hit.title,
          subtitle: hit.detailSubtitle ?? '',
          body: hit.detailBody ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      padding: const EdgeInsets.all(16),
      onTap: hit.hasDetail ? () => _open(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  hit.title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
              if (hit.hasDetail)
                const Icon(Icons.chevron_right, color: AppColors.emerald),
            ],
          ),
          const SizedBox(height: 6),
          UrduText(hit.titleUrdu, size: 15),
          const SizedBox(height: 8),
          Text(
            hit.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: AppColors.darkGreen.withValues(alpha: 0.70),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              hit.category,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.emeraldDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
