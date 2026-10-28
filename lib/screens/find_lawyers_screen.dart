import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_config.dart';
import '../core/app_scope.dart';
import '../core/contact_links.dart';
import '../data/content_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/staggered_entrance.dart';
import 'lawyer_detail_screen.dart';

/// `FindLawyersPage.tsx` – searchable, filterable lawyer directory.
class FindLawyersScreen extends StatefulWidget {
  const FindLawyersScreen({super.key});

  @override
  State<FindLawyersScreen> createState() => _FindLawyersScreenState();
}

class _FindLawyersScreenState extends State<FindLawyersScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Lawyer> _lawyers = <Lawyer>[];
  bool _loading = true;
  bool _fromApi = true;
  String _city = 'all';
  String _expertise = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loads demo lawyer profiles from the internet (randomuser.me) and maps
  /// them to [Lawyer] cards. Profiles are clearly labelled as demo data.
  Future<void> _load() async {
    setState(() => _loading = true);
    List<Lawyer> lawyers;
    bool fromApi = true;
    try {
      lawyers = await AppScope.of(context).lawyerDirectory.fetchDemoLawyers();
    } catch (_) {
      lawyers = <Lawyer>[];
      fromApi = false;
    }
    if (!mounted) return;
    setState(() {
      _lawyers = lawyers;
      _fromApi = fromApi;
      _loading = false;
    });
  }

  List<Lawyer> get _filtered {
    final String typed = _searchController.text.trim();
    final String needle = typed.toLowerCase();
    return _lawyers.where((Lawyer lawyer) {
      final bool matchesCity = _city == 'all' || lawyer.city == _city;
      final bool matchesExpertise =
          _expertise == 'all' || lawyer.expertise.contains(_expertise);
      final bool matchesSearch =
          needle.isEmpty ||
          lawyer.name.toLowerCase().contains(needle) ||
          lawyer.nameUrdu.contains(typed) ||
          lawyer.city.toLowerCase().contains(needle) ||
          lawyer.expertise.any(
            (String exp) => exp.toLowerCase().contains(needle),
          );
      return matchesCity && matchesExpertise && matchesSearch;
    }).toList();
  }

  int get _activeFilterCount =>
      (_city == 'all' ? 0 : 1) + (_expertise == 'all' ? 0 : 1);

  Widget _quickChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.darkGreen,
          ),
        ),
        selected: selected,
        selectedColor: AppColors.emeraldDeep,
        backgroundColor: AppColors.lightGreen,
        onSelected: (_) => onTap(),
      ),
    );
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          void select(void Function() change) {
            setSheetState(change);
            setState(() {});
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => select(() {
                          _city = 'all';
                          _expertise = 'all';
                        }),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'City',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ContentData.cities
                        .map(
                          (String city) => ChoiceChip(
                            label: Text(city == 'all' ? 'All cities' : city),
                            labelStyle: TextStyle(
                              color: _city == city
                                  ? AppColors.white
                                  : AppColors.darkGreen,
                              fontWeight: FontWeight.w600,
                            ),
                            selected: _city == city,
                            onSelected: (_) => select(() => _city = city),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Expertise',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ContentData.expertiseAreas
                        .map(
                          (String area) => ChoiceChip(
                            label: Text(area == 'all' ? 'All areas' : area),
                            labelStyle: TextStyle(
                              color: _expertise == area
                                  ? AppColors.white
                                  : AppColors.darkGreen,
                              fontWeight: FontWeight.w600,
                            ),
                            selected: _expertise == area,
                            onSelected: (_) => select(() => _expertise = area),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 22),
                  BrandButton(
                    label: 'Show results',
                    icon: Icons.check,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Lawyer> results = _filtered;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientPage),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Find Lawyers',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                const UrduText(
                  'وکیل تلاش کریں',
                  size: 17,
                  align: TextAlign.left,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name, city or expertise...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      _quickChip(
                        'All',
                        _city == 'all' && _expertise == 'all',
                        () {
                          setState(() {
                            _city = 'all';
                            _expertise = 'all';
                          });
                        },
                      ),
                      _quickChip('Lahore', _city == 'Lahore', () {
                        setState(
                          () => _city = _city == 'Lahore' ? 'all' : 'Lahore',
                        );
                      }),
                      _quickChip('Karachi', _city == 'Karachi', () {
                        setState(
                          () => _city = _city == 'Karachi' ? 'all' : 'Karachi',
                        );
                      }),
                      _quickChip('Islamabad', _city == 'Islamabad', () {
                        setState(
                          () => _city = _city == 'Islamabad'
                              ? 'all'
                              : 'Islamabad',
                        );
                      }),
                      _quickChip('Family', _expertise == 'Family', () {
                        setState(
                          () => _expertise = _expertise == 'Family'
                              ? 'all'
                              : 'Family',
                        );
                      }),
                      _quickChip('Criminal', _expertise == 'Criminal', () {
                        setState(
                          () => _expertise = _expertise == 'Criminal'
                              ? 'all'
                              : 'Criminal',
                        );
                      }),
                      _quickChip('Property', _expertise == 'Property', () {
                        setState(
                          () => _expertise = _expertise == 'Property'
                              ? 'all'
                              : 'Property',
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.darkGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Demo directory — sample profiles from '
                          'randomuser.me. Not real lawyers; photos and '
                          'contact details are not shown.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.darkGreen.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: OutlinedButton.icon(
                        onPressed: _openFilters,
                        icon: const Icon(Icons.tune, size: 18),
                        label: Text(
                          _activeFilterCount == 0
                              ? 'More Filters'
                              : 'Filters ($_activeFilterCount)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_city != 'all' || _expertise != 'all')
                      Expanded(
                        child: Text(
                          <String>[
                            if (_city != 'all') _city,
                            if (_expertise != 'all') _expertise,
                          ].join(' - '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.darkGreen.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    if (_city == 'all' && _expertise == 'all') const Spacer(),
                    Flexible(
                      child: Text(
                        '${results.length} demo profiles',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emeraldDeep,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_fromApi && !_loading) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    'Couldn\'t load the demo directory. Check your internet '
                    'connection and retry.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const SingleChildScrollView(child: LawyerListShimmer())
                : results.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: <Widget>[
                      const StatusBlock(
                        icon: Icons.search_off,
                        title: 'No lawyers found',
                        message:
                            'Try different filters, or retry the demo directory.',
                      ),
                      TextButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry directory'),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: results.length,
                    itemBuilder: (BuildContext context, int index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: StaggeredEntrance(
                        index: index % 5,
                        duration: const Duration(milliseconds: 340),
                        child: LawyerCard(lawyer: results[index]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Lawyer card shared by the directory and the search results.
class LawyerCard extends StatelessWidget {
  const LawyerCard({super.key, required this.lawyer});

  final Lawyer lawyer;

  @override
  Widget build(BuildContext context) {
    final Uri? callUri = ContactLinks.tel(lawyer.phoneNumber);
    final Uri? whatsappUri = ContactLinks.whatsapp(lawyer.whatsapp);

    Widget action(IconData icon, String tooltip, VoidCallback? onPressed) {
      return IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
      );
    }

    void openProfile() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => LawyerDetailScreen(lawyer: lawyer),
        ),
      );
    }

    return BrandCard(
      onTap: openProfile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Hero(
                tag: 'lawyer-avatar-${lawyer.id}',
                child: LawyerAvatar(lawyer: lawyer, radius: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Hero(
                            tag: 'lawyer-name-${lawyer.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                lawyer.name,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (lawyer.verified) ...<Widget>[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: AppColors.emerald),
                        ],
                      ],
                    ),
                    if (lawyer.nameUrdu.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      UrduText(lawyer.nameUrdu, size: 14.5),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.goldText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lawyer.rating.toStringAsFixed(1)} (${lawyer.reviewCount})'
                          ' - ${lawyer.experience} yrs',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (lawyer.courtLocation.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.account_balance_outlined,
                  size: 15,
                  color: AppColors.emerald,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${lawyer.courtLocation} - ${lawyer.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGreen.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: lawyer.expertise
                .map(
                  (String area) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      area,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              StatusChip(label: lawyer.availability),
              const Spacer(),
              action(
                Icons.call,
                'Call',
                callUri == null ? null : () => launchUrl(callUri),
              ),
              const SizedBox(width: 6),
              action(
                Icons.chat,
                'WhatsApp',
                whatsappUri == null
                    ? null
                    : () => launchUrl(
                        whatsappUri,
                        mode: LaunchMode.externalApplication,
                      ),
              ),
              const SizedBox(width: 6),
              action(Icons.arrow_forward, 'View profile', openProfile),
            ],
          ),
        ],
      ),
    );
  }
}

/// Circular avatar: network photo when available, initials otherwise.
class LawyerAvatar extends StatelessWidget {
  const LawyerAvatar({super.key, required this.lawyer, this.radius = 32});

  final Lawyer lawyer;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // Directory data comes from the server: never fetch arbitrary schemes or
    // cleartext hosts into an image widget.
    final String? imageUrl = AppConfig.isAllowedRemoteUrl(lawyer.image)
        ? lawyer.image
        : null;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.lightGreen,
      foregroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
      onForegroundImageError: imageUrl == null ? null : (_, _) {},
      child: Text(
        lawyer.initials,
        style: TextStyle(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}
