import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../core/language_helper.dart';
import '../services/ai_features_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/legal_ux_components.dart';

/// My Rights — offline-first quick-reference cards for common legal
/// situations in Pakistan. Each card lists your rights, immediate next
/// steps, and which lawyer type to see. Works without internet; tapping
/// "Ask AI for details" sends the situation to the cloud AI for a fuller
/// answer (uses existing AiFeaturesService.checkRights).
class RightsScenariosScreen extends StatefulWidget {
  const RightsScenariosScreen({super.key});

  @override
  State<RightsScenariosScreen> createState() => _RightsScenariosScreenState();
}

class _RightsScenario {
  const _RightsScenario({
    required this.id,
    required this.title,
    required this.titleUrdu,
    required this.icon,
    required this.color,
    required this.rights,
    required this.rightsUrdu,
    required this.nextSteps,
    required this.nextStepsUrdu,
    required this.lawyerType,
    required this.lawyerTypeUrdu,
    required this.helpline,
    this.aiPrompt,
  });

  final String id;
  final String title;
  final String titleUrdu;
  final IconData icon;
  final Color color;
  final String rights; // plain English
  final String rightsUrdu;
  final String nextSteps;
  final String nextStepsUrdu;
  final String lawyerType;
  final String lawyerTypeUrdu;
  final String helpline;
  final String? aiPrompt; // if provided, sent to AiFeaturesService.checkRights
}

class _RightsScenariosScreenState extends State<RightsScenariosScreen> {
  AiFeaturesService? _ai;
  final Map<String, bool> _loading = <String, bool>{};
  final Map<String, String> _aiResults = <String, String>{};

  /// First card open by default so the screen is useful at a glance; the
  /// others stay collapsed to keep the list scannable.
  final Set<String> _expanded = <String>{'police-stop'};

  static const List<_RightsScenario> _scenarios = <_RightsScenario>[
    _RightsScenario(
      id: 'police-stop',
      title: 'Stopped by Police',
      titleUrdu: 'پولیس نے روک لیا',
      icon: Icons.local_police_outlined,
      color: Color(0xFF1565C0),
      rights:
          'Under Article 10 of the Constitution and the CrPC, police must tell you the grounds of arrest, let you consult a lawyer, and produce you before a magistrate within 24 hours. You cannot be forced to confess (Article 13), and you may remain silent.',
      rightsUrdu:
          'آپ کے پاس خاموش رہنے، حراست کی وجہ پوچھنے اور وکیل سے رابطہ کرنے کا حق ہے۔ پولیس زبردستی اعتراف نہیں کروا سکتی اور 24 گھنٹے کے اندر آپ کو مجسٹریٹ کے سامنے پیش کرنے کی پابند ہے۔',
      nextSteps:
          '1. Ask politely: “Am I under arrest? What is the charge?”\n2. Ask for the officer’s name and badge number.\n3. Say: “I want to speak to a lawyer.”\n4. Do not sign anything without legal advice.\n5. Call family and note the time, place and officer details.',
      nextStepsUrdu:
          '1. شائستگی سے پوچھیں: “کیا میری گرفتاری ہوئی ہے؟ الزام کیا ہے؟”\n2. افسر کا نام اور بیج نمبر مانگیں۔\n3. کہیں: “میں وکیل سے بات کرنا چاہتا ہوں۔”\n4. وکیل کے مشورے کے بغیر کسی کاغذ پر دستخط نہ کریں۔\n5. گھر والوں کو فون کریں اور وقت، مقام اور افسر کی تفصیلات نوٹ کریں۔',
      lawyerType: 'Criminal Lawyer',
      lawyerTypeUrdu: 'فوجداری وکیل',
      helpline: '15 (Police) / 1099 (Human Rights)',
      aiPrompt:
          'A person was stopped by police in Pakistan. List their legal rights under CrPC and Constitution, and immediate next steps.',
    ),
    _RightsScenario(
      id: 'landlord-notice',
      title: 'Landlord Eviction Notice',
      titleUrdu: 'مکان مالک کا نوٹس',
      icon: Icons.house_outlined,
      color: Color(0xFF2E7D32),
      rights:
          'A landlord cannot evict you without statutory grounds and an order from the Rent Controller or Special Rent Tribunal. You are entitled to written notice and a chance to respond.',
      rightsUrdu:
          'مالک مکان معقول قانونی وجہ اور رینٹ کنٹرولر یا اسپیشل رینٹ ٹربیونل کے حکم کے بغیر آپ کو نکال نہیں سکتا۔ آپ کو تحریری نوٹس اور جواب دینے کا موقع ملنا لازمی ہے۔',
      nextSteps:
          '1. Check if your tenancy agreement is registered.\n2. Read the notice carefully — note the date and reason.\n3. Do not vacate without legal advice.\n4. Respond in writing within the notice period.\n5. File a petition with the Rent Controller if the notice is unjustified.',
      nextStepsUrdu:
          '1. چیک کریں کہ کرایہ نامہ رجسٹرڈ ہے یا نہیں۔\n2. نوٹس اچھی طرح پڑھیں — تاریخ اور وجہ نوٹ کریں۔\n3. وکیل کے مشورے کے بغیر مکان خالی نہ کریں۔\n4. نوٹس کی مدت کے اندر تحریری جواب دیں۔\n5. اگر نوٹس ناانصاف ہے تو رینٹ کنٹرولر کے پاس درخواست دائر کریں۔',
      lawyerType: 'Property Lawyer',
      lawyerTypeUrdu: 'جائیداد کے وکیل',
      helpline: 'Rent Controller / Special Rent Tribunal',
      aiPrompt:
          'A tenant in Pakistan received an eviction notice from their landlord. Explain tenant rights under provincial Tenancy Acts and immediate next steps.',
    ),
    _RightsScenario(
      id: 'cyber-harassment',
      title: 'Cyber Harassment / Online Abuse',
      titleUrdu: 'سائبر ہراسانی / آن لائن بدتمیزی',
      icon: Icons.phone_android_outlined,
      color: Color(0xFF6A1B9A),
      rights:
          'Under PECA 2016, cyber harassment, online stalking, and sharing private images without consent are criminal offences. You can report to the FIA Cyber Crime Wing and seek removal of content.',
      rightsUrdu:
          'پی ای سی اے 2016 کے تحت سائبر ہراسانی، آن لائن پیچھا کرنا اور اجازت کے بغیر نجی تصاویر شیئر کرنا مجرمانہ جرم ہے۔ آپ ایف آئی اے سائبر کرائم ونگ میں رپورٹ کر سکتے ہیں اور مواد ہٹوانے کی درخواست دے سکتے ہیں۔',
      nextSteps:
          '1. Do not delete messages, screenshots or profiles — preserve evidence.\n2. Note URLs, usernames, dates and times.\n3. Block and report the account on the platform.\n4. File a complaint with FIA Cyber Crime Wing.\n5. Consider a protection order from the court.',
      nextStepsUrdu:
          '1. پیغامات، اسکرین شاٹس یا پروفائلز حذف نہ کریں — ثبوت محفوظ رکھیں۔\n2. URLs، یوزر نیمز، تاریخیں اور وقت نوٹ کریں۔\n3. پلیٹ فارم پر اکاؤنٹ بلاک اور رپورٹ کریں۔\n4. ایف آئی اے سائبر کرائم ونگ میں شکایت درج کرائیں۔\n5. عدالت سے تحفظ کا حکم لینے پر غور کریں۔',
      lawyerType: 'Cybercrime Lawyer',
      lawyerTypeUrdu: 'سائبر کرائم وکیل',
      helpline: 'FIA Cyber Crime Wing / 1099',
      aiPrompt:
          'A person in Pakistan is facing cyber harassment or online abuse. Explain their rights under PECA 2016 and how to report to FIA Cyber Crime Wing.',
    ),
    _RightsScenario(
      id: 'divorce-khula',
      title: 'Divorce / Khula',
      titleUrdu: 'طلاق / خلع',
      icon: Icons.favorite_outline,
      color: Color(0xFFC62828),
      rights:
          'Under the Muslim Family Laws Ordinance 1961, divorce follows a 90-day reconciliation process through the Union Council. A wife can seek Khula through the Family Court and claim maintenance, dower and child support.',
      rightsUrdu:
          'مسلم فیملی لاز آرڈیننس 1961 کے تحت طلاق میں یونین کونسل کے ذریعے نوے دن کا مصالحتی عمل شامل ہے۔ بیوی فیملی کورٹ سے خلع لے سکتی ہے اور نفقہ، مہر اور بچوں کے اخراجات کا مطالبہ کر سکتی ہے۔',
      nextSteps:
          '1. Husband: send written divorce notice to Union Council Chairman.\n2. Wife: file Khula petition in Family Court.\n3. Attend Arbitration Council reconciliation meetings.\n4. Claim mehr, nafaqa and child support in writing.\n5. Obtain NADRA Divorce Effectiveness Certificate after decree.',
      nextStepsUrdu:
          '1. شوہر: یونین کونسل چیئرمین کو تحریری طلاق نوٹس بھیجیں۔\n2. بیوی: فیملی کورٹ میں خلع کا دعویٰ دائر کریں۔\n3. ثالثی کونسل کے مصالحتی اجلاسوں میں حاضر ہوں۔\n4. مہر، نفقہ اور بچوں کے اخراجات کا تحریری مطالبہ کریں۔\n5. ڈگری کے بعد نادرا سے طلاق کے اثرات کا سرٹیفکیٹ حاصل کریں۔',
      lawyerType: 'Family Lawyer',
      lawyerTypeUrdu: 'خاندانی وکیل',
      helpline: '1099 (Human Rights Helpline)',
      aiPrompt:
          'A person in Pakistan wants to know about divorce or khula procedure under Muslim Family Laws Ordinance 1961. Explain rights, steps, and documents needed.',
    ),
    _RightsScenario(
      id: 'workplace-harassment',
      title: 'Workplace Harassment',
      titleUrdu: 'کام کی جگہ پر ہراسانی',
      icon: Icons.business_outlined,
      color: Color(0xFF880E4F),
      rights:
          'The Protection Against Harassment of Women at the Workplace Act 2010 requires every organisation to have an inquiry committee. You can file a complaint internally or with the Ombudsperson.',
      rightsUrdu:
          'کام کی جگہ پر خواتین کی ہراسانی کے خلاف تحفظ ایکٹ 2010 کے تحت ہر تنظیم کو انکوائری کمیٹی لازمی بنانا ہوتی ہے۔ آپ اندرونی شکایت یا اومبڈزمین کے پاس شکایت دے سکتے ہیں۔',
      nextSteps:
          '1. Check your organisation’s harassment policy.\n2. Save emails, messages and witnesses.\n3. Submit a written complaint to the inquiry committee.\n4. If unresolved, contact the Ombudsperson.\n5. You cannot be fired for filing in good faith.',
      nextStepsUrdu:
          '1. اپنے ادارے کی ہراسانی پالیسی چیک کریں۔\n2. ای میلز، پیغامات اور گواہ محفوظ رکھیں۔\n3. انکوائری کمیٹی کو تحریری شکایت دیں۔\n4. اگر حل نہ ہو تو اومبڈزمین سے رابطہ کریں۔\n5. ایمانداری سے شکایت کرنے پر آپ کو ملازمت سے نکالا نہیں جا سکتا۔',
      lawyerType: 'Labour / Employment Lawyer',
      lawyerTypeUrdu: 'ملازمت / لیبر وکیل',
      helpline: 'Ombudsperson / 1099',
      aiPrompt:
          'A person in Pakistan is facing workplace harassment. Explain rights under the Protection Against Harassment of Women at the Workplace Act 2010 and how to file a complaint.',
    ),
  ];

  Future<void> _askAI(_RightsScenario scenario) async {
    if (_ai == null || scenario.aiPrompt == null) return;
    setState(() => _loading[scenario.id] = true);
    try {
      final AiFeatureResult res = await _ai!.checkRights(scenario.aiPrompt!);
      if (!mounted) return;
      setState(() {
        _loading[scenario.id] = false;
        _aiResults[scenario.id] = res.success
            ? res.content
            : 'AI unavailable: ${res.content}';
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _loading[scenario.id] = false;
        _aiResults[scenario.id] = 'AI error: $err';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = LanguageHelper.isRtl(
      LanguageHelper.resolve(AppScope.of(context).config.languagePreference),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'My Rights',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              'Quick legal rights for Pakistan',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.gold),
            ),
          ],
        ),
        actions: <Widget>[
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: LanguageSwitcherChip(
              current: AppScope.of(context).config.languagePreference,
              light: true,
              onChanged: (String lang) async {
                await AppScope.of(
                  context,
                ).config.update(languagePreference: lang);
                if (mounted) setState(() {});
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: <Widget>[
            const Text(
              'Choose your situation',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Works offline · Tap “Ask AI” for a fuller explanation (needs cloud AI)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ..._scenarios.map((s) => _scenarioCard(context, s, isRtl)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'General legal information, not legal advice. Laws differ '
                      'by province and change over time — verify with a licensed '
                      'lawyer before acting.',
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
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

  Widget _scenarioCard(BuildContext context, _RightsScenario s, bool isRtl) {
    final bool isLoading = _loading[s.id] == true;
    final String? aiText = _aiResults[s.id];
    final bool isExpanded = _expanded.contains(s.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header (tap to expand/collapse)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              if (isExpanded) {
                _expanded.remove(s.id);
              } else {
                _expanded.add(s.id);
              }
            }),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: s.color.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(17),
                  topRight: Radius.circular(17),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(s.icon, color: s.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          s.title,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 3),
                        UrduText(
                          s.titleUrdu,
                          size: 11.5,
                          color: AppColors.goldText,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          // Body
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Your rights',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.rights,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                  if (isRtl && s.rightsUrdu.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    UrduText(s.rightsUrdu, size: 13.5, height: 1.7),
                  ],
                  const SizedBox(height: 14),
                  const Text(
                    'What to do now',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.nextSteps,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                  if (isRtl && s.nextStepsUrdu.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    UrduText(s.nextStepsUrdu, size: 13.5, height: 1.7),
                  ],
                  const SizedBox(height: 14),
                  // Lawyer + helpline row
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: _infoChip(
                          icon: Icons.person_outline,
                          label: s.lawyerType,
                          labelUrdu: s.lawyerTypeUrdu,
                          color: AppColors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _infoChip(
                          icon: Icons.phone_in_talk,
                          label: 'Helpline',
                          labelUrdu: 'ہیلپ لائن',
                          sub: s.helpline,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // AI expand
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: BrandButton(
                          label: isLoading
                              ? 'Asking AI...'
                              : 'Ask AI for details',
                          icon: Icons.auto_awesome_outlined,
                          onPressed: isLoading ? null : () => _askAI(s),
                          color: AppColors.deepPurple.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                  if (aiText != null && aiText.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.deepPurple.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.deepPurple.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const Icon(
                                Icons.auto_awesome,
                                color: AppColors.deepPurple,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'AI detail',
                                style: TextStyle(
                                  color: AppColors.deepPurple,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            aiText,
                            style: const TextStyle(fontSize: 13, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required String labelUrdu,
    String? sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (labelUrdu.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            UrduText(labelUrdu, size: 10, color: AppColors.goldText),
          ],
          if (sub != null && sub.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
