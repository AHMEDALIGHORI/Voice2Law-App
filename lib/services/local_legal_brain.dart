import '../data/pakistani_law_data.dart';
import '../models/models.dart';
import 'statute_corpus.dart';

/// Ranking helper for [LocalLegalBrain.retrieve].
class _Scored {
  const _Scored(this.topic, this.score, this.index);

  final LawTopic topic;
  final int score;
  final int index;
}

class _KnowledgeItem {
  const _KnowledgeItem({
    required this.keywords,
    required this.category,
    required this.answer,
    required this.urdu,
    this.empatheticOpening = '',
    this.empatheticOpeningUrdu = '',
    this.courtModeAnswer = '',
    this.courtModeAnswerUrdu = '',
    this.urgencyLevel = 'normal',
    this.suggestedEmergencyHelpline = '',
    this.roadmap = const <LegalJourneyStep>[],
    this.documents = const <RequiredDocumentItem>[],
    this.statutes = const <RelevantStatute>[],
  });

  final List<String> keywords;
  final String category;
  final String answer;
  final String urdu;
  final String empatheticOpening;
  final String empatheticOpeningUrdu;
  final String courtModeAnswer;
  final String courtModeAnswerUrdu;
  final String urgencyLevel;
  final String suggestedEmergencyHelpline;
  final List<LegalJourneyStep> roadmap;
  final List<RequiredDocumentItem> documents;
  final List<RelevantStatute> statutes;
}

/// Offline legal brain upgraded with Google UX / Dual-Stream knowledge:
/// - Empathetic plain Urdu/English for everyday citizens
/// - Formal legal citations & statutes for court appearances
/// - Actionable step-by-step roadmap with timeframes & authorities
/// - Mandatory document checklists
class LocalLegalBrain {
  const LocalLegalBrain._();

  static const String disclaimer =
      '\n\n(یہ عمومی قانونی معلومات ہے۔ کسی بھی مخصوص عدالتی کارروائی کے لیے لائسنس یافتہ وکیل سے مشورہ ضروری ہے۔)';

  /// Re-usable accessor so [StatuteCorpus] can append the same disclaimer.
  static String disclaimerFor() => disclaimer;

  /// Corpus-aware answer path used by every async caller.
  ///
  /// 1. Hand-written curated items (strongest, richest cards),
  /// 2. curated topic set,
  /// 3. the bundled statute corpus (1,500+ sections / lawyer Q&A) — the
  ///    hybrid-RAG layer trained on the datasets in `data/`,
  /// 4. generic guidance.
  static Future<AiAnswer> answerWithCorpus(String question) async {
    final AiAnswer curated = answer(question);
    // Curated matches score 86+; the generic fallback is 60.
    if (curated.confidence >= 70) return curated;

    try {
      final StatuteCorpus? corpus = await StatuteCorpus.instance;
      if (corpus != null) {
        final AiAnswer? corpusAnswer = corpus.composeAnswer(question);
        if (corpusAnswer != null) return corpusAnswer;
      }
    } catch (_) {
      // Corpus is a bonus layer; never let it break answering.
    }
    return curated;
  }

  static const List<_KnowledgeItem> _items = <_KnowledgeItem>[
    _KnowledgeItem(
      keywords: <String>['divorce', 'talaq', 'khula', 'طلاق', 'خلع'],
      category: 'Family Law',
      urgencyLevel: 'caution',
      suggestedEmergencyHelpline: '1099 (Ministry of Human Rights Helpline)',
      empatheticOpening:
          'We understand that marital disputes are deeply stressful. Rest assured, Pakistani law provides a clear, dignified path protecting your fundamental rights.',
      empatheticOpeningUrdu:
          'ہم سمجھتے ہیں کہ خاندانی اور ازدواجی تنازعات انتہائی پریشان کن ہوتے ہیں۔ تسلی رکھیں، پاکستانی قانون آپ کو مکمل تحفظ اور باعزت طریقہ کار فراہم کرتا ہے۔',
      answer:
          'Divorce in Pakistan is governed by the Muslim Family Laws Ordinance 1961. The husband serves a written '
          'divorce notice to the Union Council chairman, who sends copies to both spouses and forms an Arbitration '
          'Council. A 90 day reconciliation period follows; if it fails the divorce becomes effective and is '
          'registered. A wife can seek Khula through the Family Court, and maintenance (nafaqa), dower (mehr) and '
          'child support can be claimed separately.',
      urdu:
          'پاکستان میں طلاق مسلم فیملی لاز آرڈیننس 1961 کے تحت ہوتی ہے۔ طلاق کا تحریری نوٹس یونین کونسل کے چیئرمین '
          'کو بھیجا جاتا ہے جو دونوں فریقین کو نقل بھیجتا ہے اور ثالثی کونسل بناتا ہے۔ نوے دن تک صلح کی کوشش کی جاتی '
          'ہے، ناکام ہونے پر طلاق مؤثر ہو کر رجسٹر ہو جاتی ہے۔ بیوی فیملی کورٹ سے خلع اور نفقہ، مہر اور بچوں کے '
          'اخراجات کا مطالبہ بھی کر سکتی ہے۔',
      courtModeAnswer:
          'Statutory Basis: Dissolution of Muslim Marriages Act 1939 & Muslim Family Laws Ordinance 1961 (Sec 7 & 8). '
          'Family Courts Act 1964 provides exclusive jurisdiction. Under Section 10(4) FCA 1964, if reconciliation '
          'fails at pre-trial, the Court must pass a decree for dissolution forthwith against surrender of deferred dower.',
      courtModeAnswerUrdu:
          'قانونی دفعات: تنسیخ نکاح مسلم ایکٹ 1939 اور مسلم فیملی لاز آرڈیننس 1961 (دفعہ 7 و 8)۔ فیملی کورٹس ایکٹ 1964 '
          'کی دفعہ 10(4) کے تحت اگر پری ٹرائل مصالحت ناکام ہو جائے تو عدالت فوری طور پر خلع کی ڈگری جاری کرنے کی پابند ہے۔',
      roadmap: <LegalJourneyStep>[
        LegalJourneyStep(
          stepNumber: 1,
          title: 'File Petition / Send Notice',
          titleUrdu: 'درخواست دائر کرنا / نوٹس ارسال',
          description:
              'Wife files family suit in Family Court OR husband sends notice to Chairman Union Council.',
          descriptionUrdu:
              'بیوی متعلقہ فیملی کورٹ میں دعویٰ دائر کرے یا شوہر یونین کونسل کو تحریری نوٹس بھیجے۔',
          estimatedTime: '1 - 2 weeks',
          estimatedTimeUrdu: '1 سے 2 ہفتے',
          courtOrAuthority: 'Family Court / Union Council',
          courtOrAuthorityUrdu: 'فیملی کورٹ / متعلقہ یونین کونسل',
        ),
        LegalJourneyStep(
          stepNumber: 2,
          title: 'Arbitration / Pre-Trial Reconciliation',
          titleUrdu: 'ثالثی کونسل / قبل از سماعت صلح کی کوشش',
          description:
              'Judge holds private reconciliation meeting in chambers to explore settlement.',
          descriptionUrdu:
              'جج چیمبر میں دونوں فریقین کے درمیان مصالحت و صلح کی قانونی کوشش کرتا ہے۔',
          estimatedTime: '30 - 60 days',
          estimatedTimeUrdu: '30 سے 60 دن',
          courtOrAuthority: 'Judge Chamber / Arbitration Council',
          courtOrAuthorityUrdu: 'چیمبر جج فیملی کورٹ / ثالثی کونسل',
        ),
        LegalJourneyStep(
          stepNumber: 3,
          title: 'Decree & NADRA Certificate',
          titleUrdu: 'ڈگری کا اجراء اور نادرا سرٹیفکیٹ',
          description:
              'Court passes decree; Union Council issues official computerized Divorce Effectiveness Certificate.',
          descriptionUrdu:
              'عدالتی ڈگری کی مصدقہ نقل کی بنیاد پر یونین کونسل موثر سرٹیفکیٹ جاری کرتی ہے۔',
          estimatedTime: '90 days statutory wait',
          estimatedTimeUrdu: '90 دن کی قانونی مدت',
          courtOrAuthority: 'Union Council / NADRA',
          courtOrAuthorityUrdu: 'یونین کونسل / نادرا سینٹر',
        ),
      ],
      documents: <RequiredDocumentItem>[
        RequiredDocumentItem(
          name: 'Computerised CNIC Copy',
          nameUrdu: 'قومی شناختی کارڈ کی مصدقہ کاپی',
          isMandatory: true,
          notes: 'Both front and back copies.',
          notesUrdu: 'شناختی کارڈ کے دونوں اطراف کی کاپی۔',
        ),
        RequiredDocumentItem(
          name: 'Original or Certified Nikahnama',
          nameUrdu: 'اصل یا مصدقہ نقل نکاح نامہ',
          isMandatory: true,
          notes: 'Obtainable from Nikah Registrar or Union Council.',
          notesUrdu: 'نکاح رجسٹرار یا یونین کونسل سے مصدقہ نقل حاصل کریں۔',
        ),
        RequiredDocumentItem(
          name: 'Two Passport Sized Photographs',
          nameUrdu: 'دو پاسپورٹ سائز تصاویر',
          isMandatory: true,
          notes: 'Required for court record verification.',
          notesUrdu: 'عدالتی فائل ریکارڈ کے لیے۔',
        ),
      ],
      statutes: <RelevantStatute>[
        RelevantStatute(
          actName: 'Muslim Family Laws Ordinance 1961',
          actNameUrdu: 'مسلم فیملی لاز آرڈیننس 1961',
          section: 'Section 7 & 8',
          courtJurisdiction: 'Union Council / Arbitration Council',
          citation: 'PLD 1984 SC 95 / 2021 SCMR 1420',
        ),
        RelevantStatute(
          actName: 'Family Courts Act 1964',
          actNameUrdu: 'فیملی کورٹس ایکٹ 1964',
          section: 'Section 5 & 10(4)',
          courtJurisdiction: 'Family Court (Senior Civil Judge)',
          citation: 'PLD 2002 Supreme Court 546',
        ),
      ],
    ),
    _KnowledgeItem(
      keywords: <String>[
        'inheritance',
        'wirasat',
        'heir',
        'وراثت',
        'ورثہ',
        'ترکہ',
      ],
      category: 'Property Law',
      urgencyLevel: 'normal',
      empatheticOpening:
          'Inheritance issues can be emotionally exhausting after a bereavement. Pakistan now offers expedited NADRA succession routes.',
      empatheticOpeningUrdu:
          'پیاروں کی وفات کے بعد وراثت کی تقسیم میں الجھنیں عام ہیں۔ حکومت نے نادرا سکسیشن مراکز کے ذریعے یہ عمل بہت آسان بنا دیا ہے۔',
      answer:
          'Inheritance for Muslims follows Islamic succession under the West Pakistan Muslim Personal Law (Shariat) Application Act 1962. '
          'Debts and funeral costs are settled first, then valid wills (up to 1/3rd). The remainder is distributed to statutory legal heirs.',
      urdu:
          'مسلمانوں میں وراثت اسلامی قانون کے مطابق تقسیم ہوتی ہے (شریعت اپلیکیشن ایکٹ 1962)۔ پہلے تجہیز و تکفین، '
          'قرضے اور وصیت (زیادہ سے زیادہ ایک تہائی) ادا کیے جاتے ہیں، پھر جائیداد تقسیم ہوتی ہے۔ بیٹے کو بیٹی سے '
          'دگنا حصہ ملتا ہے، بیوہ، والدین اور دیگر ورثاء کے حصے متعین ہیں۔ تصدیق وراثت نادرا کے سکسیشن سہولت مرکز '
          'یا سول عدالت سے حاصل کی جاتی ہے۔',
      courtModeAnswer:
          'Governed by Letters of Administration & Succession Act 2021 (NADRA route) or Succession Act 1925 (Sec 372). '
          'Non-contentious cases are settled by NADRA within 15 days. Disputed cases fall under Civil Court jurisdiction with declaratory suit under Specific Relief Act 1877 Sec 42.',
      courtModeAnswerUrdu:
          'نادرا سکسیشن سرٹیفکیٹ ایکٹ 2021 اور سکسیشن ایکٹ 1925۔ اگر تمام ورثاء متفق ہوں تو نادرا 15 دن میں سرٹیفکیٹ جاری کرتا ہے۔ '
          'تنازعہ کی صورت میں سول کورٹ میں دعویٰ استقرار حق (سیکشن 42 اسپیسیفک ریلیف ایکٹ) دائر ہوگا۔',
      roadmap: <LegalJourneyStep>[
        LegalJourneyStep(
          stepNumber: 1,
          title: 'Death Certificate & FRC',
          titleUrdu: 'ڈیتھ سرٹیفکیٹ اور نادرا فیملی رجسٹریشن',
          description:
              'Obtain Union Council computerized death certificate and NADRA Family Registration Certificate (FRC).',
          descriptionUrdu:
              'یونین کونسل سے ڈیتھ سرٹیفکیٹ اور نادرا سے خاندانی رجسٹریشن سرٹیفکیٹ (FRC) حاصل کریں۔',
          estimatedTime: '3 - 7 days',
          estimatedTimeUrdu: '3 سے 7 دن',
          courtOrAuthority: 'Union Council / NADRA',
          courtOrAuthorityUrdu: 'یونین کونسل و نادرا مرکز',
        ),
        LegalJourneyStep(
          stepNumber: 2,
          title: 'NADRA Succession Centre',
          titleUrdu: 'نادرا سکسیشن سہولت مرکز میں بائیو میٹرک',
          description:
              'Submit assets list. All legal heirs complete biometric verification or provide power of attorney.',
          descriptionUrdu:
              'تمام قانونی ورثاء نادرا مرکز جا کر بائیو میٹرک تصدیق کروائیں اور جائیداد کی تفصیلات جمع کرائیں۔',
          estimatedTime: '15 - 20 days',
          estimatedTimeUrdu: '15 سے 20 دن',
          courtOrAuthority: 'NADRA Succession Facilitation Unit',
          courtOrAuthorityUrdu: 'نادرا سکسیشن سہولت مرکز',
        ),
        LegalJourneyStep(
          stepNumber: 3,
          title: 'Public Notice & Certificate',
          titleUrdu: 'قومی اخبارات میں اشتہار اور سرٹیفکیٹ کا اجراء',
          description:
              'NADRA publishes public notice in national press; upon no objection within 14 days, certificate is issued.',
          descriptionUrdu:
              'اخبار میں اشتہار کے بعد اگر 14 دن تک کوئی اعتراض نہ آئے تو حتمی سرٹیفکیٹ جاری ہو جاتا ہے۔',
          estimatedTime: '14 days statutory',
          estimatedTimeUrdu: '14 دن کا اشتہار',
          courtOrAuthority: 'NADRA / Civil Court',
          courtOrAuthorityUrdu: 'نادرا سنٹر / سول کورٹ',
        ),
      ],
      documents: <RequiredDocumentItem>[
        RequiredDocumentItem(
          name: 'Computerised Death Certificate',
          nameUrdu: 'کمپیوٹرائزڈ ڈیتھ سرٹیفکیٹ',
          isMandatory: true,
          notes: 'Issued by Union Council with QR code.',
          notesUrdu: 'یونین کونسل کا کیو آر کوڈ والا سرٹیفکیٹ۔',
        ),
        RequiredDocumentItem(
          name: 'NADRA FRC (Family Tree)',
          nameUrdu: 'نادرا ایف آر سی (شجرہ نسب)',
          isMandatory: true,
          notes: 'Shows all surviving sons, daughters and spouses.',
          notesUrdu: 'تمام زندہ ورثاء کی تصدیق کے لیے۔',
        ),
        RequiredDocumentItem(
          name: 'Property / Bank Asset Statements',
          nameUrdu: 'جائیداد کی فرد / بینک اسٹیٹمنٹ',
          isMandatory: true,
          notes: 'Fard Malkiat or bank account balance letters.',
          notesUrdu: 'بینک بیلنس لیٹر یا ریونیو ریکارڈ کی فرد۔',
        ),
      ],
      statutes: <RelevantStatute>[
        RelevantStatute(
          actName: 'Letters of Administration and Succession Act 2021',
          actNameUrdu: 'سکسیشن سرٹیفکیٹ اینڈ ایڈمنسٹریشن ایکٹ 2021',
          section: 'Section 4, 5 & 8',
          courtJurisdiction: 'NADRA Authority (Alternative: Civil Judge)',
          citation: 'PLD 2022 Lahore 315',
        ),
      ],
    ),
    _KnowledgeItem(
      keywords: <String>[
        'fir',
        'police',
        'bail',
        'criminal',
        'arrest',
        'تھانہ',
        'ایف آئی آر',
        'ضمانت',
        'گرفتاری',
      ],
      category: 'Criminal Law',
      urgencyLevel: 'urgent',
      suggestedEmergencyHelpline: '15 (Police Emergency) / 1122',
      empatheticOpening:
          'Facing police or criminal allegations requires calm, rapid legal action. You have constitutional safeguards against unlawful detention.',
      empatheticOpeningUrdu:
          'تھانے یا پولیس کا معاملہ ہو تو گھبرائیں نہیں۔ آئینِ پاکستان کا آرٹیکل 9 اور 10 آپ کو غیر قانونی حراست کے خلاف بنیادی تحفظ فراہم کرتا ہے۔',
      answer:
          'To register an FIR, provide facts of a cognizable offence at the police station under section 154 CrPC. A free copy is mandatory. '
          'If refused, file an application under section 22-A CrPC before the Justice of Peace. Bail is obtained with surety bonds.',
      urdu:
          'ایف آئی آر درج کرانے کے لیے تھانے میں قابلِ دست اندازی جرم کی معلومات دیں؛ ایس ایچ او دفعہ 154 ضابطہ '
          'فوجداری کے تحت تحریری درج کر کے مفت نقل دینے کا پابند ہے۔ انکار پر ایس پی یا مجسٹریٹ کے پاس دفعہ 22-A '
          'کے تحت درخواست دی جا سکتی ہے۔ ضمانت کے لیے عدالت میں مچلکے جمع کرائے جاتے ہیں؛ قابلِ ضمانت جرم میں '
          'ضمانت حق ہے، ناقابلِ ضمانت میں عدالت کی صوابدید، جبکہ قبل از گرفتاری ضمانت دفعہ 498 کے تحت لی جاتی ہے۔',
      courtModeAnswer:
          'Section 154 CrPC (Cognizable report), Section 156 (Investigation), Section 22-A & 22-B CrPC (Ex-officio Justice of Peace). '
          'Bail provisions: Sec 496 (Bailable as of right), Sec 497 (Non-bailable discretionary), Sec 498 (Pre-arrest / anticipatory bail in Sessions / High Court).',
      courtModeAnswerUrdu:
          'ضابطہ فوجداری: دفعہ 154 (درج ایف آئی آر)، دفعہ 22-A (جسٹس آف پیس)، دفعہ 496 (قابل ضمانت جرائم)، '
          'دفعہ 497 (ناقابل ضمانت جرائم میں رعایت) اور دفعہ 498 (قبل از گرفتاری عبوری ضمانت)۔',
      roadmap: <LegalJourneyStep>[
        LegalJourneyStep(
          stepNumber: 1,
          title: 'Written Report to SHO',
          titleUrdu: 'ایس ایچ او کو تحریری درخواست',
          description:
              'Submit signed application detailing date, time, location and accused persons.',
          descriptionUrdu:
              'وقوعہ کی مکمل تاریخ، وقت اور ملزمان کے نام کے ساتھ تحریری درخواست تھانے میں جمع کرائیں۔',
          estimatedTime: 'Immediate (24 hours)',
          estimatedTimeUrdu: 'فوری (24 گھنٹے میں)',
          courtOrAuthority: 'Local Police Station (SHO)',
          courtOrAuthorityUrdu: 'متعلقہ تھانہ (ایس ایچ او)',
        ),
        LegalJourneyStep(
          stepNumber: 2,
          title: 'Petition under 22-A CrPC (If refused)',
          titleUrdu: 'انکار پر دفعہ 22-A کی درخواست',
          description:
              'If SHO refuses FIR, file petition before Sessions Judge (Justice of Peace) to direct registration.',
          descriptionUrdu:
              'ایس ایچ او کے انکار پر سیشن جج / جسٹس آف پیس کو ایف آئی آر درج کرانے کا حکم دینے کی درخواست دیں۔',
          estimatedTime: '3 - 7 days',
          estimatedTimeUrdu: '3 سے 7 دن',
          courtOrAuthority: 'Sessions Court (Justice of Peace)',
          courtOrAuthorityUrdu: 'سیشن کورٹ (جسٹس آف پیس)',
        ),
        LegalJourneyStep(
          stepNumber: 3,
          title: 'Pre-Arrest Bail Application',
          titleUrdu: 'قبل از گرفتاری ضمانت کی درخواست',
          description:
              'Apply under section 498 CrPC to avoid arrest; submit surety bond on ad-interim grant.',
          descriptionUrdu:
              'گرفتاری سے بچنے کے لیے دفعہ 498 کے تحت عبوری ضمانت حاصل کر کے مچلکے جمع کروائیں۔',
          estimatedTime: 'Same day hearing',
          estimatedTimeUrdu: 'اسی دن عبوری ریلیف',
          courtOrAuthority: 'Sessions Court / High Court',
          courtOrAuthorityUrdu: 'سیشن کورٹ / ہائیکورٹ',
        ),
      ],
      documents: <RequiredDocumentItem>[
        RequiredDocumentItem(
          name: 'Written Occurrence Report',
          nameUrdu: 'وقوعہ کی تحریری درخواست',
          isMandatory: true,
          notes: 'Signed with applicant contact details.',
          notesUrdu: 'دستخط شدہ درخواست جس میں سائل کا رابطہ درج ہو۔',
        ),
        RequiredDocumentItem(
          name: 'Medical Legal Certificate (MLC)',
          nameUrdu: 'میڈیکو لیگل سرٹیفکیٹ (اگر چوٹ لگی ہو)',
          isMandatory: false,
          notes:
              'Obtained from DHQ/THQ Govt Hospital if physical injury occurred.',
          notesUrdu: 'لڑائی جھگڑے کی صورت میں سرکاری ہسپتال سے میڈیکل رپورٹ۔',
        ),
        RequiredDocumentItem(
          name: 'Surety Bond & Tax Record',
          nameUrdu: 'ضمانتی مچلکے اور ضامن کا شناختی کارڈ',
          isMandatory: true,
          notes: 'Required for bail confirmation before judge.',
          notesUrdu: 'ضمانت کے وقت مقامی ضامن اور اس کی ملکیت کے کاغذات۔',
        ),
      ],
      statutes: <RelevantStatute>[
        RelevantStatute(
          actName: 'Code of Criminal Procedure 1898 (CrPC)',
          actNameUrdu: 'ضابطہ فوجداری 1898',
          section: 'Section 154, 22-A, 497, 498',
          courtJurisdiction: 'Magistrate 1st Class / Sessions Judge',
          citation: 'PLD 2005 SC 864 / 2020 SCMR 249',
        ),
        RelevantStatute(
          actName: 'Constitution of Pakistan 1973',
          actNameUrdu: 'آئینِ پاکستان 1973',
          section: 'Article 9, 10 & 10-A (Fair Trial)',
          courtJurisdiction: 'High Court / Supreme Court',
          citation: 'Fundamental Rights Chapter',
        ),
      ],
    ),
    _KnowledgeItem(
      keywords: <String>[
        'rent',
        'tenant',
        'landlord',
        'eviction',
        'کرایہ',
        'مکان',
        'دکان',
      ],
      category: 'Property Law',
      urgencyLevel: 'normal',
      empatheticOpening:
          'Tenancy disputes affect your home and peace of mind. Both landlords and tenants have strictly defined protections under provincial tenancy laws.',
      empatheticOpeningUrdu:
          'کرائے کے تنازعات رہائش اور کاروبار کو متاثر کرتے ہیں۔ صوبائی قوانین کے تحت مالک اور کرایہ دار دونوں کے حقوق کا مکمل تحفظ موجود ہے۔',
      answer:
          'Rent matters are regulated by provincial Tenancy Acts. A tenancy agreement should be in writing and registered with the Rent Controller. '
          'A landlord cannot evict without statutory grounds (non-payment, expiry, personal bona fide need) and an order from the Rent Controller.',
      urdu:
          'کرایہ داری کے معاملات صوبائی کرایہ داری آرڈیننس کے تحت آتے ہیں۔ کرایہ نامہ تحریری ہونا چاہیے جس میں '
          'کرایہ، مدت اور نوٹس کی شرائط درج ہوں۔ مالک مکان معقول وجہ اور عدالت کے حکم کے بغیر کرایہ دار کو '
          'نہیں نکال سکتا، اور کرایہ میں اضافے سے پہلے مناسب نوٹس دینا لازم ہے۔ تنازعات ڈسٹرکٹ رینٹ کنٹرولر کے '
          'پاس لے جائے جاتے ہیں۔',
      courtModeAnswer:
          'Punjab Rented Premises Act 2009 / Sindh Rented Premises Ordinance 1979 / ICT Rent Restriction Act. '
          'Mandatory tenancy registration with Rent Registrar. Eviction petition under Section 15 through Rent Tribunal; summary ejectment requires proof of default or bona fide personal need.',
      courtModeAnswerUrdu:
          'پنجاب رینٹڈ پریمائزز ایکٹ 2009 / سندھ رینٹڈ پریمائزز آرڈیننس 1979۔ کرایہ نامے کا رجسٹر ہونا لازمی ہے۔ '
          'بے دخلی کی درخواست اسپیشل رینٹ ٹربیونل میں دائر ہوتی ہے، زبردستی بے دخلی غیر قانونی ہے۔',
      roadmap: <LegalJourneyStep>[
        LegalJourneyStep(
          stepNumber: 1,
          title: 'Registered Tenancy Agreement',
          titleUrdu: 'رجسٹرڈ کرایہ نامہ کی تصدیق',
          description:
              'Agreement on stamp paper registered with Rent Registrar with fixed duration.',
          descriptionUrdu:
              'اسٹامپ پیپر پر تحریر شدہ معاہدہ جو رینٹ رجسٹرار کے پاس باقاعدہ رجسٹر ہو۔',
          estimatedTime: 'Prior to possession',
          estimatedTimeUrdu: 'قبضے سے قبل',
          courtOrAuthority: 'Rent Registrar Office',
          courtOrAuthorityUrdu: 'دفتر رینٹ رجسٹرار',
        ),
        LegalJourneyStep(
          stepNumber: 2,
          title: 'Legal Notice of Default / Termination',
          titleUrdu: 'قانونی نوٹس کی ترسیل',
          description:
              'Written notice delivered via registered post giving statutory cure period.',
          descriptionUrdu:
              'بقایا جات یا معاہدہ ختم کرنے کا نوٹس بذریعہ رجسٹرڈ ڈاک ارسال کریں۔',
          estimatedTime: '30 - 60 days notice',
          estimatedTimeUrdu: '30 سے 60 دن کا قانونی نوٹس',
          courtOrAuthority: 'Registered Post / TCS',
          courtOrAuthorityUrdu: 'رجسٹرڈ ڈاک / کورئیر',
        ),
        LegalJourneyStep(
          stepNumber: 3,
          title: 'Petition to Special Rent Judge',
          titleUrdu: 'اسپیشل رینٹ جج کے پاس درخواست',
          description:
              'Special Rent Tribunal summons tenant; fast-track hearings within 3-6 months.',
          descriptionUrdu:
              'رینٹ ٹربیونل دونوں فریقین کو سن کر بے دخلی یا بقایا کرایہ کی وصولی کا فیصلہ سناتا ہے۔',
          estimatedTime: '3 - 6 months',
          estimatedTimeUrdu: '3 سے 6 ماہ',
          courtOrAuthority: 'Special Rent Tribunal',
          courtOrAuthorityUrdu: 'اسپیشل رینٹ ٹربیونل / سول کورٹ',
        ),
      ],
      documents: <RequiredDocumentItem>[
        RequiredDocumentItem(
          name: 'Registered Tenancy Agreement',
          nameUrdu: 'رجسٹرڈ کرایہ نامہ (اصل یا مصدقہ)',
          isMandatory: true,
          notes: 'Signed on appropriate stamp paper denomination.',
          notesUrdu: 'اسٹامپ پیپر پر درج اور رجسٹرار کی مہر کے ساتھ۔',
        ),
        RequiredDocumentItem(
          name: 'Bank Receipts / Rent Receipts',
          nameUrdu: 'بینک کی رسیدیں یا کرایہ کی رسید بکس',
          isMandatory: true,
          notes: 'Proof of timely or defaulted payment.',
          notesUrdu: 'کرایہ کی ادائیگی یا عدم ادائیگی کا تحریری ثبوت۔',
        ),
      ],
      statutes: <RelevantStatute>[
        RelevantStatute(
          actName: 'Punjab Rented Premises Act 2009',
          actNameUrdu: 'پنجاب رینٹڈ پریمائزز ایکٹ 2009',
          section: 'Section 5 (Registration) & Section 15 (Eviction)',
          courtJurisdiction: 'Special Rent Tribunal',
          citation: 'PLD 2017 SC 187',
        ),
      ],
    ),
    _KnowledgeItem(
      keywords: <String>[
        'nikah',
        'marriage',
        'nikahnama',
        'نکاح',
        'شادی',
        'مہر',
      ],
      category: 'Family Law',
      urgencyLevel: 'normal',
      empatheticOpening:
          'Nikah is a sacred and legally binding contract. Protecting your rights in the Nikahnama ensures future peace of mind.',
      empatheticOpeningUrdu:
          'نکاح ایک مقدس اور باقاعدہ قانونی معاہدہ ہے۔ نکاح نامے کے تمام کالم درست پُر کرنا آپ کے مستقبل کو قانونی تحفظ دیتا ہے۔',
      answer:
          'A valid Nikah requires offer and acceptance before two witnesses, an agreed dower (mehr), and registration with the Union Council. '
          'Key protections include the delegated right of divorce (talaq-e-tafweez in Column 18) and maintenance stipulations.',
      urdu:
          'نکاح کی درستی کے لیے دو گواہوں کی موجودگی میں ایجاب و قبول، دونوں فریقین کی رضامندی سے مہر اور یونین '
          'کونسل میں رجسٹرڈ تحریری نکاح نامہ ضروری ہے۔ نکاح نامہ میں مہر، تفویض طلاق کا حق اور خصوصی شرائط درج '
          'ہوتی ہیں۔ رجسٹریشن سے بیوی کے مالی حقوق، وراثت اور عدالتی کارروائی محفوظ ہوتی ہے۔',
      courtModeAnswer:
          'Muslim Family Laws Ordinance 1961 Section 5. Solemnised by licensed Nikah Registrar under Muslim Marriages Registration Rules. '
          'Clauses 18 to 21 govern Talaq-e-Tafweez and conditional dower, enforceable directly through Family Courts Act 1964.',
      courtModeAnswerUrdu:
          'مسلم فیملی لاز آرڈیننس 1961 کی دفعہ 5۔ کالم نمبر 18 میں تفویضِ طلاق کا حق بیوی کو عدالت جائے بغیر طلاق لینے کا حق دیتا ہے۔ '
          'کالم نمبر 13 تا 16 مہر کی نوعیت (معجل و مؤجل) کا تعین کرتے ہیں۔',
      roadmap: <LegalJourneyStep>[
        LegalJourneyStep(
          stepNumber: 1,
          title: 'Solemnisation with Registered Khateeb',
          titleUrdu: 'رجسٹرڈ نکاح خواں کی موجودگی میں ایجاب و قبول',
          description:
              'Offer and acceptance before two male sane adult Muslim witnesses with CNICs.',
          descriptionUrdu:
              'دو عاقل و بالغ گواہوں کی موجودگی میں ایجاب و قبول اور شناختی کارڈ کی کاپیاں۔',
          estimatedTime: 'Day of Nikah',
          estimatedTimeUrdu: 'نکاح کے وقت',
          courtOrAuthority: 'Licensed Nikah Registrar',
          courtOrAuthorityUrdu: 'لائسنس یافتہ نکاح رجسٹرار',
        ),
        LegalJourneyStep(
          stepNumber: 2,
          title: 'Completing Columns 13 to 21',
          titleUrdu: 'کالم 13 تا 21 (مہر اور تفویضِ طلاق)',
          description:
              'Crucial: fill Column 18 (delegated divorce) and specify Mehr amount with prompt/deferred split.',
          descriptionUrdu:
              'کالم 18 میں حقِ تفویض طلاق اور مہر کی رقم (معجل/مؤجل) واضح لکھیں۔',
          estimatedTime: 'During signing',
          estimatedTimeUrdu: 'دستخط کے دوران',
          courtOrAuthority: 'Nikah Registrar Registry',
          courtOrAuthorityUrdu: 'نکاح رجسٹر',
        ),
        LegalJourneyStep(
          stepNumber: 3,
          title: 'Union Council Registration & NADRA Marriage Certificate',
          titleUrdu: 'یونین کونسل اندراج اور نادرا میرج سرٹیفکیٹ',
          description:
              'Nikah Khawan submits copy to Union Council; couple receives computerized NADRA Marriage Registration Certificate (MRC).',
          descriptionUrdu:
              'نکاح خواں یونین کونسل میں فارم جمع کراتا ہے اور نادرا سے کمپیوٹرائزڈ میرج سرٹیفکیٹ ملتا ہے۔',
          estimatedTime: '3 - 7 days',
          estimatedTimeUrdu: '3 سے 7 دن',
          courtOrAuthority: 'Union Council / NADRA MRC Unit',
          courtOrAuthorityUrdu: 'یونین کونسل و نادرا مرکز',
        ),
      ],
      documents: <RequiredDocumentItem>[
        RequiredDocumentItem(
          name: 'CNIC copies of Bride, Groom & Witnesses',
          nameUrdu: 'دولہا، دلہن اور دونوں گواہوں کے شناختی کارڈ کی کاپیاں',
          isMandatory: true,
          notes: 'Must be valid CNIC/Smart Card.',
          notesUrdu: 'شناختی کارڈز کارآمد اور غیر منقضی ہوں۔',
        ),
        RequiredDocumentItem(
          name: 'Nikahnama Forms in Quadruplicate',
          nameUrdu: 'نکاح نامہ فارم چار کاپیوں میں',
          isMandatory: true,
          notes: 'One for bride, one for groom, one for registrar, one for UC.',
          notesUrdu: 'ایک ایک کاپی فریقین، نکاح خواں اور یونین کونسل کے لیے۔',
        ),
      ],
      statutes: <RelevantStatute>[
        RelevantStatute(
          actName: 'Muslim Family Laws Ordinance 1961',
          actNameUrdu: 'مسلم فیملی لاز آرڈیننس 1961',
          section: 'Section 5 (Registration of Marriages)',
          courtJurisdiction: 'Union Council / Family Court',
          citation: 'PLD 1963 SC 51',
        ),
      ],
    ),
    _KnowledgeItem(
      keywords: <String>['custody', 'guardian', 'تحویل', 'حضانہ', 'بچے'],
      category: 'Family Law',
      urgencyLevel: 'caution',
      empatheticOpening:
          'Child custody cases require the highest level of care. Courts prioritize the child\'s emotional, educational, and moral welfare above all else.',
      empatheticOpeningUrdu:
          'بچوں کی تحویل اور حضانت ایک انتہائی حساس معاملہ ہے۔ پاکستانی عدالتوں کا سب سے پہلا اور بنیادی اصول بچے کی بہترین بہبود اور مستقبل ہے۔',
      answer:
          'In custody matters the Family Court applies the Guardians and Wards Act 1890 and the welfare of the minor principle. '
          'Mothers generally receive physical custody (hizanat) during young years, while the father remains the natural guardian responsible for finances.',
      urdu:
          'حضانہ کے معاملات گارڈینز اینڈ وارڈز ایکٹ 1890 اور بچے کی بہبود کے اصول کے تحت فیملی کورٹ میں دیکھے '
          'جاتے ہیں۔ عام طور پر لڑکوں کی حضانت ماں کے پاس تقریباً سات سال اور لڑکیوں کی بلوغت تک ہوتی ہے، جبکہ '
          'باپ قانونی سرپرست رہتا ہے۔ عارضی حضانت کے لیے فیملی سوٹ میں درخواست دی جا سکتی ہے۔',
      courtModeAnswer:
          'Guardians and Wards Act 1890 (Sec 7, 9, 17, 25). Section 12 allows interim visitation and maintenance. '
          'Supreme Court precedent dictates welfare of minor is paramount consideration, overriding statutory presumptions.',
      courtModeAnswerUrdu:
          'گارڈینز اینڈ وارڈز ایکٹ 1890 کی دفعات 12 (عبوری ملاقات)، 17 و 25۔ سپریم کورٹ کے اصول کے مطابق بچے کی جسمانی، '
          'تعلیمی اور اخلاقی بہبود ہی حتمی فیصلہ طے کرتی ہے۔',
      roadmap: <LegalJourneyStep>[
        LegalJourneyStep(
          stepNumber: 1,
          title: 'Petition for Guardian / Custody',
          titleUrdu: 'گارڈین جج کے پاس درخواستِ حضانت',
          description:
              'File under section 25 of Guardians and Wards Act in the district where the minor ordinarily resides.',
          descriptionUrdu:
              'جہاں بچہ رہائش پذیر ہو، وہاں کے سینئر سول جج / گارڈین جج کے پاس درخواست دائر کریں۔',
          estimatedTime: '1 - 2 weeks',
          estimatedTimeUrdu: '1 سے 2 ہفتے',
          courtOrAuthority: 'Guardian Court (Senior Civil Judge)',
          courtOrAuthorityUrdu: 'گارڈین کورٹ (سینئر سول جج)',
        ),
        LegalJourneyStep(
          stepNumber: 2,
          title: 'Interim Custody & Visitation Application',
          titleUrdu: 'عبوری تحویل اور ملاقات کا شیڈول (دفعہ 12)',
          description:
              'Judge establishes scheduled visitation days (e.g. 2 Saturdays a month) in court or home environment.',
          descriptionUrdu:
              'عدالت عبوری طور پر والد یا والدہ کے لیے مہینے میں ملاقات کا باقاعدہ شیڈول طے کرتی ہے۔',
          estimatedTime: 'Within 30 days',
          estimatedTimeUrdu: '30 دن کے اندر',
          courtOrAuthority: 'Guardian Judge Chambers',
          courtOrAuthorityUrdu: 'چیمبر گارڈین جج',
        ),
        LegalJourneyStep(
          stepNumber: 3,
          title: 'Welfare Evaluation & Final Decree',
          titleUrdu: 'بچے کا انٹرویو اور حتمی فیصلہ',
          description:
              'Judge interviews minor in chambers if minor is of understanding age, evaluating schooling and domestic stability.',
          descriptionUrdu:
              'جج چیمبر میں بچے سے بات چیت کر کے اس کے روشن مستقبل اور بہبود کی بنیاد پر فیصلہ صادر کرتا ہے۔',
          estimatedTime: '4 - 8 months',
          estimatedTimeUrdu: '4 سے 8 ماہ',
          courtOrAuthority: 'Guardian Court / High Court Appeal',
          courtOrAuthorityUrdu: 'گارڈین کورٹ / اپیل ہائیکورٹ',
        ),
      ],
      documents: <RequiredDocumentItem>[
        RequiredDocumentItem(
          name: 'Child NADRA B-Form / Birth Certificate',
          nameUrdu: 'بچے کا کمپیوٹرائزڈ بے فارم یا برتھ سرٹیفکیٹ',
          isMandatory: true,
          notes: 'Confirms age and parentage.',
          notesUrdu: 'بچے کی عمر اور ولدیت کی تصدیق کے لیے۔',
        ),
        RequiredDocumentItem(
          name: 'School / Academic Records',
          nameUrdu: 'اسکول کارڈ اور تعلیمی ریکارڈ',
          isMandatory: true,
          notes: 'Demonstrates educational care and schooling continuity.',
          notesUrdu: 'تعلیمی تسلسل کا عدالتی ثبوت۔',
        ),
      ],
      statutes: <RelevantStatute>[
        RelevantStatute(
          actName: 'Guardians and Wards Act 1890',
          actNameUrdu: 'گارڈینز اینڈ وارڈز ایکٹ 1890',
          section: 'Section 12, 17 & 25',
          courtJurisdiction: 'Guardian Court',
          citation: 'PLD 2014 SC 338 / 2021 SCMR 168',
        ),
      ],
    ),
  ];

  // ---------------------------------------------------------------------------
  // Curated topic retrieval (data/pakistani_law_data.dart)
  // ---------------------------------------------------------------------------

  /// Ranked retrieval over the curated topic set, best match first.
  ///
  /// Multi-word keyword phrases score higher than single words so that, for
  /// example, "pre-emption notice" beats a stray "land" hit. Used for offline
  /// answers and, via [retrievalContext], to ground the cloud model.
  static List<LawTopic> retrieve(String question, {int limit = 3}) {
    final String normalised = question.toLowerCase().trim();
    if (normalised.isEmpty) return const <LawTopic>[];

    final List<_Scored> scored = <_Scored>[];
    for (int index = 0; index < pakistaniLawTopics.length; index++) {
      final LawTopic topic = pakistaniLawTopics[index];
      int score = 0;
      for (final String keyword in topic.keywords) {
        final String needle = keyword.toLowerCase().trim();
        if (needle.isEmpty) continue;
        int hits = 0;
        int at = normalised.indexOf(needle);
        while (at >= 0 && hits < 3) {
          hits++;
          at = normalised.indexOf(needle, at + needle.length);
        }
        if (hits > 0) {
          // Phrases are far stronger evidence of intent than single tokens.
          score += hits * (needle.contains(' ') ? 4 : 1);
        }
      }
      if (score > 0) scored.add(_Scored(topic, score, index));
    }

    scored.sort((_Scored a, _Scored b) {
      final int byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.index.compareTo(b.index);
    });
    if (limit <= 0) return const <LawTopic>[];
    return scored.take(limit).map((_Scored hit) => hit.topic).toList();
  }

  /// Prompt-ready grounding block for the cloud model (RAG). Empty string when
  /// nothing matches, so the caller can skip the section entirely.
  static String retrievalContext(String question, {int limit = 3}) {
    final List<LawTopic> hits = retrieve(question, limit: limit);
    if (hits.isEmpty) return '';
    return hits
        .map((LawTopic topic) => topic.toRetrievalSnippet())
        .join('\n\n');
  }

  /// Maps a curated topic onto the same rich answer shape as the hand-written
  /// items, so every screen renders roadmap/documents/statutes identically.
  static AiAnswer _answerFromTopic(LawTopic topic) {
    return AiAnswer(
      answer: topic.summary + disclaimer,
      answerUrdu: topic.summaryUrdu,
      category: topic.category,
      confidence: 86,
      status: 'approved',
      offline: true,
      empatheticOpening:
          'We understand how stressful a legal problem can feel. The steps below are '
          'based on the law that actually applies in Pakistan, and you can take them '
          'one at a time.',
      empatheticOpeningUrdu:
          'ہم جانتے ہیں کہ قانونی مسئلہ کتنا ذہنی دباؤ کا حامل ہو سکتا ہے۔ نیچے دیے گئے '
          'اقدامات پاکستان میں لاگو ہونے والے قانون کے مطابق ہیں۔',
      courtModeAnswer: topic.courtNote,
      courtModeAnswerUrdu: topic.courtNoteUrdu,
      urgencyLevel: topic.urgency,
      suggestedEmergencyHelpline: topic.helpline,
      roadmap: topic.steps
          .map(
            (LawStep step) => LegalJourneyStep(
              stepNumber: topic.steps.indexOf(step) + 1,
              title: step.title,
              titleUrdu: step.titleUrdu,
              description: step.detail,
              descriptionUrdu: step.detailUrdu,
              estimatedTime: step.time,
              estimatedTimeUrdu: step.timeUrdu,
              courtOrAuthority: step.authority,
              courtOrAuthorityUrdu: step.authorityUrdu,
            ),
          )
          .toList(),
      documents: topic.documents
          .map(
            (String document) => RequiredDocumentItem(
              name: document,
              nameUrdu: document,
              isMandatory: false,
            ),
          )
          .toList(),
      statutes: topic.statutes
          .map(
            (LawStatute statute) => RelevantStatute(
              actName: statute.act,
              actNameUrdu: statute.actUrdu,
              section: statute.section,
              courtJurisdiction: 'Courts of Pakistan',
              citation: statute.note,
            ),
          )
          .toList(),
    );
  }

  /// Upgraded answer generator providing Dual-Stream Empathetic + Court output.
  static AiAnswer answer(String question) {
    final String normalised = question.toLowerCase();

    for (final _KnowledgeItem item in _items) {
      for (final String keyword in item.keywords) {
        if (normalised.contains(keyword.toLowerCase())) {
          return AiAnswer(
            answer: item.answer + disclaimer,
            answerUrdu: item.urdu,
            category: item.category,
            confidence: 88,
            status: 'approved',
            offline: true,
            empatheticOpening: item.empatheticOpening,
            empatheticOpeningUrdu: item.empatheticOpeningUrdu,
            courtModeAnswer: item.courtModeAnswer,
            courtModeAnswerUrdu: item.courtModeAnswerUrdu,
            urgencyLevel: item.urgencyLevel,
            suggestedEmergencyHelpline: item.suggestedEmergencyHelpline,
            roadmap: item.roadmap,
            documents: item.documents,
            statutes: item.statutes,
          );
        }
      }
    }
    // Curated topic set (data/pakistani_law_data.dart) widens coverage to
    // cybercrime, domestic violence, consumer rights, labour law, land and
    // revenue, bail/detention, evidence, accountability, traffic and welfare.
    final List<LawTopic> topics = retrieve(question);
    if (topics.isNotEmpty) {
      return _answerFromTopic(topics.first);
    }

    return AiAnswer(
      answer:
          'I could not reach the live Voice2Law AI server, so here is general legal guidance. Pakistani legal matters '
          'fall broadly under Family Law (marriage, divorce, custody, maintenance), Property Law (rent, transfer, inheritance) '
          'and Criminal Law (FIR, bail, detention). You can ask a specific question such as "divorce procedure" or "bail under CrPC".$disclaimer',
      answerUrdu:
          'معذرت، لائیو سرور تک رسائی نہ ہونے پر عمومی رہنمائی پیش کی جا رہی ہے۔ خاندانی قانون، جائیداد اور وراثت، یا فوجداری قانون '
          'سے متعلق کوئی بھی سوال پوچھیں یا قانونی موضوعات کا جائزہ لیں۔',
      category: 'General Law',
      confidence: 60,
      status: 'pending',
      offline: true,
      empatheticOpening:
          'We are here to help guide you through the Pakistani legal landscape step by step.',
      empatheticOpeningUrdu:
          'ہم پاکستانی قانون کے دائرہ کار میں آپ کی مرحلہ وار رہنمائی کے لیے موجود ہیں۔',
      courtModeAnswer:
          'General guidance. For statutory citations, please refer to the relevant Act (PPC 1860, CrPC 1898, MFLO 1961, or Transfer of Property Act 1882).',
      courtModeAnswerUrdu:
          'عمومی رہنمائی: مخصوص دفعات کے لیے پاکستان پینل کوڈ، ضابطہ فوجداری یا مسلم فیملی لاز کا مطالعہ فرمائیں۔',
      urgencyLevel: 'normal',
      roadmap: const <LegalJourneyStep>[
        LegalJourneyStep(
          stepNumber: 1,
          title: 'Identify Jurisdiction & Issue',
          titleUrdu: 'دائرہ اختیار اور نوعیت کا تعین',
          description:
              'Determine whether your matter is Civil, Family, or Criminal.',
          descriptionUrdu:
              'معلوم کریں کہ مسئلہ فیملی کورٹ، سول کورٹ یا تھانے کے دائرہ کار میں آتا ہے۔',
          courtOrAuthority: 'Civil / Family / Police',
          courtOrAuthorityUrdu: 'سول، فیملی یا پولیس اسٹیشن',
        ),
        LegalJourneyStep(
          stepNumber: 2,
          title: 'Gather Baseline Identity & Papers',
          titleUrdu: 'ضروری دستاویزات اور شناختی ثبوت',
          description:
              'Keep your CNIC, relevant agreements, and witness details ready.',
          descriptionUrdu:
              'اپنا شناختی کارڈ، تحریری معاہدے اور ثبوت اپنے پاس محفوظ رکھیں۔',
        ),
      ],
      documents: const <RequiredDocumentItem>[
        RequiredDocumentItem(
          name: 'Valid CNIC copy',
          nameUrdu: 'شناختی کارڈ کی کاپی',
          isMandatory: true,
        ),
      ],
    );
  }
}
