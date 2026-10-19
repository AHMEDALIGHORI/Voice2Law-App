import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'spring_tap.dart';

/// Urdu text with the bundled Nastaliq font (website `.urdu-text` class).
class UrduText extends StatelessWidget {
  const UrduText(
    this.text, {
    super.key,
    this.size = 18,
    this.color = AppColors.darkGreen,
    this.weight = FontWeight.w500,
    this.align,
    this.maxLines,
    this.height = 2.0,
  });

  final String text;
  final double size;
  final Color color;
  final FontWeight weight;
  final TextAlign? align;
  final int? maxLines;

  /// Line height multiplier. Nastaliq needs generous spacing to avoid the
  /// descenders of one line touching the next.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      textDirection: TextDirection.rtl,
      style: AppText.urdu(
        size: size,
        color: color,
        weight: weight,
        height: height,
      ),
    );
  }
}

enum ButtonStyleKind { primary, gold, light, outline }

/// Gradient / solid buttons used across the website hero and pages.
class BrandButton extends StatelessWidget {
  const BrandButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.kind = ButtonStyleKind.primary,
    this.expand = true,
    this.busy = false,
    this.color,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonStyleKind kind;
  final bool expand;
  final bool busy;

  /// Optional solid background color. When set it overrides the gradient
  /// background (ignored for the outline style).
  final Color? color;

  Color get _foreground =>
      (kind == ButtonStyleKind.light || kind == ButtonStyleKind.outline)
      ? AppColors.darkGreen
      : AppColors.white;

  @override
  Widget build(BuildContext context) {
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (busy)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.white,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 19, color: _foreground),
        if (busy || icon != null) const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );

    final Widget button = kind == ButtonStyleKind.outline
        ? OutlinedButton(onPressed: busy ? null : onPressed, child: child)
        : DecoratedBox(
            decoration: BoxDecoration(
              gradient:
                  (color != null || kind == ButtonStyleKind.light)
                  ? null
                  : _gradientOf(kind),
              color:
                  color ??
                  (kind == ButtonStyleKind.light ? AppColors.white : null),
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: busy ? null : onPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: _foreground,
                      fontWeight: FontWeight.w600,
                    ),
                    child: IconTheme(
                      data: IconThemeData(color: _foreground),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          );

    final Widget tappable = SpringTap(
      onTap: busy ? null : onPressed,
      enabled: !busy && onPressed != null,
      child: button,
    );
    return expand
        ? SizedBox(width: double.infinity, child: tappable)
        : tappable;
  }

  static Gradient _gradientOf(ButtonStyleKind kind) {
    switch (kind) {
      case ButtonStyleKind.gold:
        return AppColors.gradientGold;
      case ButtonStyleKind.primary:
      case ButtonStyleKind.light:
      case ButtonStyleKind.outline:
        return AppColors.gradientEmeraldToDark;
    }
  }
}

/// Small pill label, e.g. "AI-Powered Legal Assistant" on the website header.
class BrandPill extends StatelessWidget {
  const BrandPill({
    super.key,
    required this.label,
    this.icon,
    this.onDark = false,
  });

  final String label;
  final IconData? icon;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: onDark
            ? AppColors.white.withValues(alpha: 0.14)
            : AppColors.emerald.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: onDark
              ? AppColors.white.withValues(alpha: 0.25)
              : AppColors.emerald.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(
              icon,
              size: 16,
              color: onDark ? AppColors.white : AppColors.emerald,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: onDark ? AppColors.white : AppColors.darkGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered section heading (`h2` + Urdu subtitle + description).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.titleUrdu = '',
    this.subtitle = '',
    this.onDark = false,
    this.align = TextAlign.center,
  });

  final String title;
  final String titleUrdu;
  final String subtitle;
  final bool onDark;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = onDark ? AppColors.white : AppColors.darkGreen;
    return Column(
      crossAxisAlignment: align == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          textAlign: align,
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: titleColor,
            height: 1.25,
          ),
        ),
        if (titleUrdu.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          UrduText(
            titleUrdu,
            size: 17,
            color: onDark ? AppColors.gold : AppColors.goldText,
            align: align,
          ),
        ],
        if (subtitle.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: align,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: onDark
                  ? AppColors.white.withValues(alpha: 0.82)
                  : AppColors.darkGreen.withValues(alpha: 0.68),
            ),
          ),
        ],
      ],
    );
  }
}

/// White rounded card with the soft shadow used by every website card.
class BrandCard extends StatelessWidget {
  const BrandCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderColor,
    this.onTap,
    this.gradient,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.white : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? AppColors.darkGreen.withValues(alpha: 0.10),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: null,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap != null) {
      return SpringTap(onTap: onTap, child: card);
    }
    return card;
  }
}

/// Maps [LegalTopic.icon] keys to Material icons.
IconData topicIcon(String key) {
  switch (key) {
    case 'family':
      return Icons.people_outline;
    case 'property':
      return Icons.home_outlined;
    case 'civil':
      return Icons.description_outlined;
    case 'business':
      return Icons.business_center_outlined;
    case 'criminal':
      return Icons.shield_outlined;
    case 'traffic':
      return Icons.directions_car_outlined;
    default:
      return Icons.balance;
  }
}

/// Status chip used by the admin tables (approved / pending / flagged …).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});

  final String label;

  Color get _color {
    switch (label.toLowerCase()) {
      case 'approved':
      case 'resolved':
      case 'published':
      case 'available today':
        // Darker than AppColors.emerald so the 11.5px label clears WCAG AA 4.5:1
        // against its own 12% tint (verified: 5.51:1).
        return const Color(0xFF116B33);
      case 'review':
      case 'pending':
      case 'draft':
      case 'available tomorrow':
        return const Color(0xFF9A4708); // 5.35:1 on its tint
      case 'flagged':
      case 'rejected':
        return const Color(0xFFC41E1E); // 4.85:1 on its tint
      default:
        return AppColors.darkGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

/// Reusable "no data / error / loading" block for API driven screens.
class StatusBlock extends StatelessWidget {
  const StatusBlock({
    super.key,
    required this.icon,
    required this.title,
    this.message = '',
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkGreen.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 34, color: AppColors.emerald),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          if (message.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
