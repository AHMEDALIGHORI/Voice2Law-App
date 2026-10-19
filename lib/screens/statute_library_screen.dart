import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/statute_corpus.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';

/// The browsable law library: every statute, section and Q&A pair from the
/// trained corpus (`assets/data/legal_corpus.json`), plus the federal statute
/// index. Opened from Legal Topics and the navigation drawer.
class StatuteLibraryScreen extends StatefulWidget {
  const StatuteLibraryScreen({super.key});

  @override
  State<StatuteLibraryScreen> createState() => _StatuteLibraryScreenState();
}

class _StatuteLibraryScreenState extends State<StatuteLibraryScreen> {
  Future<StatuteCorpus?>? _future;

  @override
  void initState() {
    super.initState();
    _future = StatuteCorpus.instance;
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'gavel':
        return Icons.gavel;
      case 'local_police':
        return Icons.local_police_outlined;
      case 'fact_check':
        return Icons.fact_check_outlined;
      case 'shield':
        return Icons.shield_outlined;
      case 'home_work':
        return Icons.home_work_outlined;
      case 'timer':
        return Icons.timer_outlined;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'question_answer':
        return Icons.question_answer_outlined;
      default:
        return Icons.menu_book_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientPage),
      child: FutureBuilder<StatuteCorpus?>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<StatuteCorpus?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading the law library…',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }
          final StatuteCorpus? corpus = snapshot.data;
          if (corpus == null) {
            return const Center(child: Text('Law library is unavailable.'));
          }
          return CustomScrollView(
            slivers: <Widget>[
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 6),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BrandPill(
                        label: 'Offline Law Library',
                        icon: Icons.menu_book_outlined,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Statute Library',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      SizedBox(height: 6),
                      UrduText(
                        'قانونی لائبریری',
                        size: 18,
                        align: TextAlign.left,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'The complete texts bundled inside Voice2Law — statutes, sections '
                        'and lawyers\' answers, searchable without internet.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((
                    BuildContext context,
                    int index,
                  ) {
                    final CorpusCategory category = corpus.categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CategoryCard(
                        category: category,
                        icon: _iconFor(category.icon),
                      ),
                    );
                  }, childCount: corpus.categories.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.icon});

  final CorpusCategory category;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final Color accent = Color(category.accent);
    final String countLabel = category.kind == 'library'
        ? '${category.count} statutes'
        : category.kind == 'qa'
        ? '${category.count} answered questions'
        : '${category.count} sections';

    return BrandCard(
      padding: const EdgeInsets.all(18),
      onTap: () => _open(context),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 3),
                UrduText(category.nameUrdu, size: 13.5, align: TextAlign.left),
                const SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category.group,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: accent.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      countLabel,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  void _open(BuildContext context) {
    if (category.kind == 'library') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LibraryBrowseScreen(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              StatuteSectionsScreen(category: category),
        ),
      );
    }
  }
}

/// Sections / Q&A list of a single corpus category, with search.
class StatuteSectionsScreen extends StatefulWidget {
  const StatuteSectionsScreen({super.key, required this.category});

  final CorpusCategory category;

  @override
  State<StatuteSectionsScreen> createState() => _StatuteSectionsScreenState();
}

class _StatuteSectionsScreenState extends State<StatuteSectionsScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<CorpusEntry> get _filteredEntries {
    if (_query.isEmpty) return widget.category.entries;
    final String q = _query.toLowerCase();
    return widget.category.entries
        .where(
          (CorpusEntry e) =>
              e.section.toLowerCase().contains(q) ||
              e.heading.toLowerCase().contains(q) ||
              e.text.toLowerCase().contains(q),
        )
        .toList();
  }

  List<CorpusQa> get _filteredQa {
    if (_query.isEmpty) return widget.category.qaEntries;
    final String q = _query.toLowerCase();
    return widget.category.qaEntries
        .where(
          (CorpusQa e) =>
              e.question.toLowerCase().contains(q) ||
              e.answer.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isQa = widget.category.kind == 'qa';
    final List<CorpusEntry> entries = isQa
        ? const <CorpusEntry>[]
        : _filteredEntries;
    final List<CorpusQa> qa = isQa ? _filteredQa : const <CorpusQa>[];

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: AppColors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.category.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '${widget.category.count} ${isQa ? 'questions' : 'sections'}',
              style: const TextStyle(fontSize: 11.5, color: AppColors.gold),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientPage),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: _search,
                onChanged: (String value) =>
                    setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: isQa
                      ? 'Search questions…'
                      : 'Search sections, e.g. "302" or "bail"',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.emerald.withValues(alpha: 0.25),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.emerald.withValues(alpha: 0.25),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.emerald),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: <Widget>[
                  for (final CorpusEntry entry in entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SectionTile(
                        leading: '§ ${entry.section}',
                        title: entry.heading.isEmpty
                            ? 'Section ${entry.section}'
                            : entry.heading,
                        preview: entry.text,
                        onTap: () => _openDetail(
                          context,
                          title:
                              '${widget.category.name} — Section ${entry.section}',
                          subtitle: entry.heading,
                          body: entry.text,
                        ),
                      ),
                    ),
                  for (final CorpusQa item in qa)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SectionTile(
                        leading: 'Q',
                        title: item.question,
                        preview: item.answer,
                        onTap: () => _openDetail(
                          context,
                          title: 'Lawyers\' Q&A',
                          subtitle: item.question,
                          body: item.answer,
                        ),
                      ),
                    ),
                  if (entries.isEmpty && qa.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'No matches. Try a different word or section number.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String body,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            CorpusDetailScreen(title: title, subtitle: subtitle, body: body),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.leading,
    required this.title,
    required this.preview,
    this.onTap,
  });

  final String leading;
  final String title;
  final String preview;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return BrandCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (enabled ? AppColors.emerald : AppColors.textSecondary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              leading,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: enabled ? AppColors.emerald : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full text of one corpus entry / library statute, with copy-to-clipboard.
class CorpusDetailScreen extends StatelessWidget {
  const CorpusDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
  });

  final String title;
  final String subtitle;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: AppColors.white,
        title: Text(
          title,
          maxLines: 2,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Copy text',
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '$subtitle\n\n$body'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientPage),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
          child: BrandCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (subtitle.isNotEmpty) ...<Widget>[
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: AppColors.emerald.withValues(alpha: 0.25)),
                  const SizedBox(height: 10),
                ],
                SelectableText(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.75,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Browsable index of the federal statute library (600+ titles).
class LibraryBrowseScreen extends StatefulWidget {
  const LibraryBrowseScreen({super.key});

  @override
  State<LibraryBrowseScreen> createState() => _LibraryBrowseScreenState();
}

class _LibraryBrowseScreenState extends State<LibraryBrowseScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  Future<StatuteCorpus?>? _future;

  @override
  void initState() {
    super.initState();
    _future = StatuteCorpus.instance;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: AppColors.white,
        title: const Text(
          'Federal Statute Library',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientPage),
        child: FutureBuilder<StatuteCorpus?>(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<StatuteCorpus?> snapshot) {
            final StatuteCorpus? corpus = snapshot.data;
            if (corpus == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<LibraryStatute> results = corpus.searchLibrary(
              _query,
              limit: 80,
            );
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: TextField(
                    controller: _search,
                    onChanged: (String value) =>
                        setState(() => _query = value.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search 600+ federal laws…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.emerald.withValues(alpha: 0.25),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.emerald.withValues(alpha: 0.25),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.emerald),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: results.length,
                    itemBuilder: (BuildContext context, int index) {
                      final LibraryStatute statute = results[index];
                      final bool hasText = statute.text.isNotEmpty;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SectionTile(
                          leading: hasText ? 'PDF' : '—',
                          title: statute.title,
                          preview: hasText
                              ? '${statute.charCount.toLocaleString()} characters bundled'
                              : 'Listed in the federal index',
                          onTap: hasText
                              ? () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        CorpusDetailScreen(
                                          title: statute.title,
                                          subtitle: '',
                                          body: statute.text,
                                        ),
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

extension _LocaleFormat on int {
  String toLocaleString() => toString();
}
