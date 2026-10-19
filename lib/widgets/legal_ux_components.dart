import 'package:flutter/material.dart';
import '../core/haptics.dart';
import '../core/app_scope.dart';
import '../core/language_helper.dart';
import '../core/shell_controller.dart';
import '../models/models.dart';
import '../screens/calculator_camo_screen.dart';
import '../theme/app_theme.dart';

/// Interactive visual timeline representing a procedural legal journey.
/// Translates complex, opaque civil/criminal procedures into digestible steps.
class ProceduralRoadmapWidget extends StatelessWidget {
  const ProceduralRoadmapWidget({
    super.key,
    required this.steps,
    this.isUrdu = false,
  });

  final List<LegalJourneyStep> steps;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.2)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timeline,
                  color: AppColors.emerald,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isUrdu
                          ? 'قانونی کارروائی کا طریقہ کار'
                          : 'Procedural Legal Roadmap',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Text(
                      isUrdu
                          ? 'مرحلہ وار عدالتی ٹائم لائن'
                          : 'Step-by-step judicial timeline',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List<Widget>.generate(steps.length, (int index) {
            final LegalJourneyStep step = steps[index];
            final bool isLast = index == steps.length - 1;
            final String title = isUrdu && step.titleUrdu.isNotEmpty
                ? step.titleUrdu
                : step.title;
            final String desc = isUrdu && step.descriptionUrdu.isNotEmpty
                ? step.descriptionUrdu
                : step.description;
            final String time = isUrdu && step.estimatedTimeUrdu.isNotEmpty
                ? step.estimatedTimeUrdu
                : step.estimatedTime;
            final String auth = isUrdu && step.courtOrAuthorityUrdu.isNotEmpty
                ? step.courtOrAuthorityUrdu
                : step.courtOrAuthority;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? AppColors.emerald
                              : AppColors.darkGreen,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color:
                                  (index == 0
                                          ? AppColors.emerald
                                          : AppColors.darkGreen)
                                      .withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${step.stepNumber}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.emerald.withValues(alpha: 0.35),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 4 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: AppColors.darkGreen.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                          if (time.isNotEmpty || auth.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: <Widget>[
                                if (time.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.gold.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Icon(
                                          Icons.schedule,
                                          size: 12,
                                          color: AppColors.gold,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            time,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.darkGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (auth.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGreen,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Icon(
                                          Icons.account_balance,
                                          size: 12,
                                          color: AppColors.emerald,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            auth,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.emerald,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Interactive checklist for legal consultation readiness.
class DocumentChecklistWidget extends StatefulWidget {
  const DocumentChecklistWidget({
    super.key,
    required this.documents,
    this.isUrdu = false,
  });

  final List<RequiredDocumentItem> documents;
  final bool isUrdu;

  @override
  State<DocumentChecklistWidget> createState() =>
      _DocumentChecklistWidgetState();
}

class _DocumentChecklistWidgetState extends State<DocumentChecklistWidget> {
  final Set<int> _checkedIndices = <int>{};

  @override
  Widget build(BuildContext context) {
    if (widget.documents.isEmpty) return const SizedBox.shrink();

    final int total = widget.documents.length;
    final int readyCount = _checkedIndices.length;
    final double progress = total == 0 ? 0 : readyCount / total;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checklist_rtl,
                  color: AppColors.goldText,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.isUrdu
                          ? 'دستاویزات کی چیک لسٹ'
                          : 'Document Readiness Checklist',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Text(
                      widget.isUrdu
                          ? 'وکیل سے مشاورت سے پہلے مطلوبہ کاغذات تیار کریں'
                          : 'Verify your paperwork before consultation',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: readyCount == total
                      ? AppColors.emerald
                      : AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$readyCount / $total',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: readyCount == total
                        ? AppColors.white
                        : AppColors.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.offWhite,
              valueColor: AlwaysStoppedAnimation<Color>(
                readyCount == total ? AppColors.emerald : AppColors.gold,
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 14),
          ...List<Widget>.generate(widget.documents.length, (int index) {
            final RequiredDocumentItem doc = widget.documents[index];
            final bool isChecked = _checkedIndices.contains(index);
            final String name = widget.isUrdu && doc.nameUrdu.isNotEmpty
                ? doc.nameUrdu
                : doc.name;
            final String notes = widget.isUrdu && doc.notesUrdu.isNotEmpty
                ? doc.notesUrdu
                : doc.notes;

            return InkWell(
              onTap: () {
                setState(() {
                  if (isChecked) {
                    _checkedIndices.remove(index);
                  } else {
                    _checkedIndices.add(index);
                  }
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      isChecked
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: isChecked
                          ? AppColors.emerald
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                    color: isChecked
                                        ? AppColors.textSecondary
                                        : AppColors.darkGreen,
                                    decoration: isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              if (doc.isMandatory)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.isUrdu ? 'لازمی' : 'Mandatory',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (notes.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              notes,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Statues citation card showing formal section and jurisdiction references.
class StatutoryCitationsCard extends StatelessWidget {
  const StatutoryCitationsCard({
    super.key,
    required this.statutes,
    this.isUrdu = false,
  });

  final List<RelevantStatute> statutes;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    if (statutes.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkGreen.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.gavel, color: AppColors.darkGreen, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isUrdu
                      ? 'متعلقہ پاکستانی قوانین و دفعات'
                      : 'Evidence-backed references',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...statutes.map((RelevantStatute s) {
            final String act = isUrdu && s.actNameUrdu.isNotEmpty
                ? s.actNameUrdu
                : s.actName;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: AppColors.gold, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    act,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.section,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.emeraldDeep,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.courtJurisdiction,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    s.sourceLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (s.citation.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    SelectableText(
                      s.citation,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (s.sourceExcerpt.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        s.sourceExcerpt,
                        maxLines: 6,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class LegalTriageBanner extends StatelessWidget {
  const LegalTriageBanner({
    super.key,
    required this.urgency,
    this.isUrdu = false,
  });

  final String urgency;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    final String normalized = urgency.toLowerCase();
    final bool critical = normalized == 'critical';
    final bool urgent = critical || normalized == 'urgent';
    final bool caution = normalized == 'caution';
    if (!urgent && !caution) return const SizedBox.shrink();

    final Color color = urgent ? AppColors.danger : AppColors.warning;
    final String title = isUrdu
        ? (urgent ? 'فوری توجہ درکار ہو سکتی ہے' : 'یہ معاملہ وقت طلب ہے')
        : (urgent
              ? 'Immediate attention may be needed'
              : 'This matter may be time-sensitive');
    final String body = isUrdu
        ? (urgent
              ? 'اگر آپ کو خطرہ ہو تو پہلے محفوظ جگہ جائیں، پھر مقامی ہنگامی مدد یا وکیل سے رابطہ کریں۔'
              : 'اہم تاریخیں اور دستاویزات محفوظ کریں اور جلد قانونی رائے حاصل کریں۔')
        : (urgent
              ? 'If you are in danger, move somewhere safe first, then contact local emergency support or a lawyer.'
              : 'Save important dates and documents, and seek legal guidance soon.');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.priority_high_rounded, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    body,
                    style: const TextStyle(
                      height: 1.4,
                      color: AppColors.darkGreen,
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
}

/// Discreet / Quick Exit dialog and helper.
/// Crucial Google UX addition for vulnerable family / domestic abuse litigants.
class DiscreetModeDialog {
  DiscreetModeDialog._();

  static void triggerPanicExit(BuildContext context) {
    final services = AppScope.of(context);
    // Invalidate pending results synchronously, and stop both audio engines.
    services.clearPrivateSession();
    services.auth.invalidate();
    ShellController.instance.goTo(0);
    AppHaptics.panicExit();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const CalculatorCamoScreen()),
      (_) => false,
    );
  }
}

// ---------------------------------------------------------------------------
// OfflineBanner
// ---------------------------------------------------------------------------

/// Persistent non-dismissible banner shown when Voice2Law is serving answers
/// from the bundled legal library (LocalLegalBrain) because the Gemini API
/// is unavailable or not configured.
///
/// [isUrdu] switches the banner text to Urdu with RTL layout.
/// [statusCode] is an optional technical detail (e.g. 'http_429', 'timeout')
/// shown in a small sub-line for self-diagnosis.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.isUrdu = false, this.statusCode});

  final bool isUrdu;
  final String? statusCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFFFCC00), width: 1.5),
        ),
      ),
      child: Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.cloud_off, size: 18, color: Color(0xFF856404)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isUrdu
                        ? 'آف لائن: جوابات بنڈل قانونی لائبریری سے ہیں'
                        : 'Offline: answers from bundled legal library',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF856404),
                      fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                      height: isUrdu ? 1.8 : 1.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUrdu
                        ? 'یہ معلومات تازہ ترین قانون کے مطابق تصدیق شدہ نہیں ہے۔ براہ کرم لائسنس یافتہ وکیل سے رجوع کریں۔'
                        : 'Not verified against the latest law. Consult a licensed lawyer before acting.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: const Color(0xFF664D03),
                      fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                      height: isUrdu ? 1.8 : 1.4,
                    ),
                  ),
                  if (statusCode != null && statusCode!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      'Status: $statusCode',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF856404),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LanguageSwitcherChip
// ---------------------------------------------------------------------------

/// A compact dropdown chip that lets the user pick from all supported
/// Pakistani languages. Calls [onChanged] with the selected language code.
class LanguageSwitcherChip extends StatelessWidget {
  const LanguageSwitcherChip({
    super.key,
    required this.current,
    required this.onChanged,
    this.light = false,
  });

  /// Current preference code: 'en', 'ur', 'pa', 'sd', 'ps', or 'auto'.
  final String current;
  final void Function(String lang) onChanged;

  /// When true, renders with a white outline suitable for use on a dark
  /// (green gradient) background.
  final bool light;

  @override
  Widget build(BuildContext context) {
    final String resolved = LanguageHelper.resolve(current);
    final LangMeta meta = LanguageHelper.metaFor(resolved);
    final bool isRtl = meta.rtl;

    return PopupMenuButton<String>(
      tooltip: 'Change language',
      onSelected: onChanged,
      itemBuilder: (_) => kSupportedLanguages
          .map(
            (LangMeta m) => PopupMenuItem<String>(
              value: m.code,
              child: Row(
                children: <Widget>[
                  Text(
                    m.nativeLabel,
                    style: TextStyle(
                      fontFamily: m.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    m.label,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (m.code == resolved) ...<Widget>[
                    const Spacer(),
                    const Icon(Icons.check, size: 16),
                  ],
                ],
              ),
            ),
          )
          .toList(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: light
              ? (isRtl
                    ? AppColors.gold
                    : AppColors.white.withValues(alpha: 0.18))
              : (isRtl
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : AppColors.lightGreen),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: light
                ? AppColors.white.withValues(alpha: 0.5)
                : (isRtl
                      ? AppColors.gold
                      : AppColors.emerald.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.translate,
              size: 14,
              color: light ? AppColors.white : AppColors.darkGreen,
            ),
            const SizedBox(width: 5),
            Text(
              meta.nativeLabel,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: light ? AppColors.white : AppColors.darkGreen,
                fontFamily: meta.fontFamily,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: light ? AppColors.white : AppColors.darkGreen,
            ),
          ],
        ),
      ),
    );
  }
}
