import 'package:flutter/material.dart';

import '../data/fallback_data.dart';
import '../theme/app_theme.dart';
import 'brand.dart';

/// Renders one `InfoCardData` entry, either on a light card (About, Tech) or
/// inside the dark gradient sections (Features, SDG).
class InfoCardTile extends StatelessWidget {
  const InfoCardTile({
    super.key,
    required this.data,
    this.onDark = false,
    this.showTopAccent = false,
  });

  final InfoCardData data;
  final bool onDark;
  final bool showTopAccent;

  LinearGradient get _gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(data.accent), Color(data.accentEnd)],
  );

  @override
  Widget build(BuildContext context) {
    final Color titleColor = onDark ? AppColors.white : AppColors.darkGreen;
    final Color bodyColor = onDark
        ? AppColors.white.withValues(alpha: 0.82)
        : AppColors.darkGreen.withValues(alpha: 0.72);

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: onDark
                ? AppColors.white.withValues(alpha: 0.10)
                : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: onDark
                  ? AppColors.white.withValues(alpha: 0.20)
                  : AppColors.darkGreen.withValues(alpha: 0.10),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: onDark
                    ? Colors.black.withValues(alpha: 0.18)
                    : AppColors.darkGreen.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, showTopAccent ? 22 : 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(data.icon, color: AppColors.white, size: 27),
                    ),
                    const Spacer(),
                    if (data.badge.isNotEmpty)
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(data.accent),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          data.badge,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    height: 1.3,
                  ),
                ),
                if (data.titleUrdu.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  UrduText(
                    data.titleUrdu,
                    size: 16,
                    color: onDark ? AppColors.gold : AppColors.goldText,
                  ),
                ],
                if (data.description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    data.description,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: bodyColor,
                    ),
                  ),
                ],
                if (data.items.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  for (final String item in data.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(data.accent),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 13,
                                color: onDark
                                    ? AppColors.white.withValues(alpha: 0.85)
                                    : AppColors.darkGreen.withValues(
                                        alpha: 0.8,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (showTopAccent)
          Positioned(
            top: 0,
            left: 20,
            right: 20,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: _gradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
