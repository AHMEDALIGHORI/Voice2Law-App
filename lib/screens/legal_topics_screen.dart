import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../core/routes.dart';
import '../data/content_data.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';

/// `LegalTopicsPage.tsx` – expandable topic cards + published Urdu documents.
class LegalTopicsScreen extends StatefulWidget {
  const LegalTopicsScreen({super.key});

  @override
  State<LegalTopicsScreen> createState() => _LegalTopicsScreenState();
}

class _LegalTopicsScreenState extends State<LegalTopicsScreen> {
  int? _expanded;
  List<UrduDocument> _documents = <UrduDocument>[];
  bool _loadingDocuments = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDocuments());
  }

  /// `GET /legal-topics` – published Urdu documents, with the bundled samples
  /// as fallback when the API is not reachable.
  Future<void> _loadDocuments() async {
    List<UrduDocument> documents;
    try {
      documents = await AppScope.of(
        context,
      ).api.getUrduDocuments(publicOnly: true);
    } on ApiException {
      documents = <UrduDocument>[];
    }
    if (!mounted) return;
    setState(() {
      _documents = documents;
      _loadingDocuments = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientPage),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        children: <Widget>[
          const BrandPill(
            label: 'Comprehensive Legal Knowledge',
            icon: Icons.balance,
          ),
          const SizedBox(height: 14),
          const Text(
            'Legal Topics',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          const UrduText('قانونی موضوعات', size: 18, align: TextAlign.left),
          const SizedBox(height: 10),
          Text(
            'Explore different areas of Pakistani law. Tap any topic to see its sub-topics.',
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppColors.darkGreen.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 22),
          // Flagship entry into the bundled statute corpus.
          BrandCard(
            padding: const EdgeInsets.all(18),
            gradient: AppColors.gradientGreen,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.statuteLibrary),
            child: Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.library_books,
                    color: AppColors.emerald,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Statute Library',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const UrduText(
                        'مکمل قانونی لائبریری — آف لائن',
                        size: 13.5,
                        color: AppColors.gold,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '1,500+ sections, 900 answered questions and 600+ federal '
                        'statutes bundled inside the app.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.white),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (int index = 0; index < ContentData.legalTopics.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TopicCard(
                topic: ContentData.legalTopics[index],
                expanded: _expanded == index,
                onToggle: () => setState(
                  () => _expanded = _expanded == index ? null : index,
                ),
              ),
            ),
          const SizedBox(height: 14),
          const Text(
            'Urdu Legal Documents',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 4),
          const UrduText(
            'اردو قانونی دستاویزات',
            size: 15,
            align: TextAlign.left,
          ),
          const SizedBox(height: 14),
          if (_loadingDocuments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else
            for (final UrduDocument document in _documents)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DocumentCard(document: document),
              ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.expanded,
    required this.onToggle,
  });

  final LegalTopic topic;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final Color accent = Color(topic.accent);
    return BrandCard(
      padding: EdgeInsets.zero,
      onTap: onToggle,
      borderColor: expanded ? accent : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(topicIcon(topic.icon), color: accent, size: 25),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      UrduText(topic.titleUrdu, size: 14.5),
                    ],
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: accent,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Divider(color: accent.withValues(alpha: 0.25)),
                  const SizedBox(height: 8),
                  for (final LegalSubtopic sub in topic.subtopics)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.circle, size: 7, color: accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  sub.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sub.description,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.45,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                UrduText(
                                  sub.urdu,
                                  size: 13,
                                  color: AppColors.goldText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document});

  final UrduDocument document;

  @override
  Widget build(BuildContext context) {
    Text meta(String value) => Text(
      value,
      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
    );

    return BrandCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.picture_as_pdf,
                color: AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  document.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
              StatusChip(label: document.status),
            ],
          ),
          if (document.titleUrdu.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            UrduText(document.titleUrdu, size: 14),
          ],
          if (document.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              document.description,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.darkGreen.withValues(alpha: 0.68),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Flexible(child: meta(document.fileName)),
              if (document.fileSize.isNotEmpty) meta(' • ${document.fileSize}'),
              const Spacer(),
              if (document.uploadDate.isNotEmpty) meta(document.uploadDate),
            ],
          ),
        ],
      ),
    );
  }
}
