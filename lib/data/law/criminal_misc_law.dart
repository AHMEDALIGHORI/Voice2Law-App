import '../pakistani_law_data.dart';

/// Criminal procedure and evidence - the highest-volume citizen questions.
const List<LawTopic> criminalMiscTopics = <LawTopic>[
  LawTopic(
    id: 'bail-detention',
    category: 'Criminal Law',
    keywords: <String>[
      'bail',
      'bail application',
      'arrest',
      'detained',
      'detention',
      'custody',
      'interim bail',
      'pre-arrest bail',
      'remand',
      'habeas corpus',
      'false case',
      'quash',
      'محضضی',
      'گرفتاری',
      'حراست',
      'ضمانت',
      'قبل از گرفتاری',
      'ہابیس کورپس',
      'جھوٹی ایف آئی آر',
    ],
    summary:
        'Bail is a right, and the type depends on the offence and the stage. Police bail '
        'covers cognizable offences up to seven years, and the police must produce you '
        'before a Magistrate within 24 hours under s.167 CrPC. If they refuse, the '
        'Magistrate can grant interim bail. An anticipatory bail under s.498 CrPC can be '
        'moved in the Sessions Court or High Court before arrest. If detention is '
        'unlawful, a habeas corpus writ under Art. 199/491 CrPC is the quickest test.',
    summaryUrdu:
        'ضمانت ایک حق ہے اور اس کی قسم جرم اور کیس کے مرحلے پر منحصر ہے۔ پولیس بیل قابل دست '
        'اندازی جرم کے لیے 7 سال تک ہے اور 24 گھنٹے کے اندر مجسٹریٹ کے سامنے پیش کرنا لازمی ہے۔ '
        'انکار پر مجسٹریٹ عبوری بیل دے سکتی ہے۔ سیشن یا ہائی کورٹ میں دفعہ 498 کے تحت گرفتاری '
        'سے پہلے بیل کی درخواست دی جا سکتی ہے۔',
    courtNote:
        'CrPC 1898: s.167 (remand, 24 hours), s.168-A/B (police and Magistrate bail), '
        's.498 (anticipatory/post-arrest bail), s.491 (habeas corpus), s.561-A '
        '(quashment); Article 10 Constitution 1973 (grounds of arrest, counsel, 24-hour '
        'production). A planted FIR is usually quashed by a s.561-A petition to the High '
        'Court, or s.482 CrPC before the Sessions Court.',
    courtNoteUrdu:
        'ضابطہ فوجداری کی دفعہ 167، 168-A/B، 498، 491 اور 561-A اور آئین کا آرٹیکل 10 لاگو '
        'ہوتے ہیں۔ جھوٹی ایف آئی آر خارج کروانے کے لیے ہائی کورٹ میں دفعہ 561-A کی رٹ عام '
        'رعایت ہے۔',
    urgency: 'urgent',
    helpline: '15 (Police) | 1099 (Human Rights) | 1721 (Punjab Legal Aid)',
    steps: <LawStep>[
      LawStep(
        'Ask for the grounds of arrest',
        'گرفتاری کی وجہ پوچھیں',
        'You must be told the grounds and may call a lawyer; ask which FIR and section.',
        'آپ کو گرفتاری کی وجہ بتائی جانا چاہیے اور وکیل سے رابطہ کا حق ہے۔',
        'Immediately',
        'فوری',
        'Arresting officer',
        'گرفتار کرنے والا افسر',
      ),
      LawStep(
        'Apply for bail before the Magistrate',
        'مجسٹریٹ سے بیل کی درخواست',
        'A bailable offence must be released on bail; otherwise apply for bail and get '
            'an attested copy of the daily diary.',
        'قابل بیل جرم پر بیل پر رہائش لازمی ہے؛ ورنہ بیل کی درخواست اور روزانہ ڈائری کی نقل لیں۔',
        '1-3 days',
        '1 سے 3 دن',
        'Judicial Magistrate',
        'جوڈیشل مجسٹریٹ',
      ),
      LawStep(
        'Escalate to s.498 / habeas corpus',
        'دفعہ 498 یا ہابیس کورپس',
        'If bail is refused or detention is unlawful, move s.498 CrPC in the Sessions or '
            'High Court, or file a habeas corpus writ under Art. 199/491 CrPC.',
        'بیل مسترد ہو تو سیشن/ہائی کورٹ میں دفعہ 498 یا ہابیس کورپس درخواست دیں۔',
        '1-2 weeks',
        '1 سے 2 ہفتے',
        'Sessions Court / High Court',
        'سیشن کورٹ / ہائی کورٹ',
      ),
    ],
    documents: <String>[
      'Arrest memo and copy of the FIR',
      'Remand order / daily diary extract',
      'Character certificates and surety documents',
    ],
    statutes: <LawStatute>[
      LawStatute(
        'Code of Criminal Procedure 1898',
        'ضابطہ فوجداری 1898',
        's.167, s.168-A',
        'Remand, police and Magistrate bail',
      ),
      LawStatute(
        'Code of Criminal Procedure 1898',
        'ضابطہ فوجداری 1898',
        's.498, s.491',
        'Bail and habeas corpus',
      ),
      LawStatute(
        'Constitution of Pakistan 1973',
        'آئین پاکستان 1973',
        'Art. 10',
        'Safeguards as to arrest and detention',
      ),
    ],
  ),
  LawTopic(
    id: 'evidence-witness',
    category: 'Civil Law',
    keywords: <String>[
      'evidence',
      'witness',
      'testimony',
      'affidavit',
      'attesting',
      'thumb impression',
      'qanun-e-shahat',
      'confession',
      'proof',
      'cognizance',
      'document proof',
      'گواہ',
      'شہادت',
      'توثیق',
      'انگوٹھا',
      'اثبات',
      'اقرار',
      'دستخط',
    ],
    summary:
        'Evidence rules in a Pakistani suit are strict: facts are proved by documents '
        'first, and a thumb impression is a valid document once proved by the maker. A '
        'witness who is a party or a close relative carries less weight, hearsay is '
        'generally inadmissible, and courts need a certified copy rather than the '
        'original. Electronic evidence (emails, SMS, CCTV) is admitted under the '
        'Qanun-e-Shahadat Order 1984 (amended 2005), so keep data in original form with '
        'metadata and do not rely on edited screenshots.',
    summaryUrdu:
        'پاکستان میں ثبوت کے قواعد سخت ہیں: پہلے دستاویزی ثبوت دیا جاتا ہے اور انگوٹھہ محض '
        'نشانی کے طور پر قابل قبول ہوتا ہے۔ غیر متعلقہ رشتہ دار کی گوہی کا وزن کم ہوتا ہے اور '
        'سنی سنائی گواہی رد کی جاتی ہے۔ الیکٹرانک ثبوت قانونِ شهادت آرڈر 1984 کے تحت قابل '
        'قبول ہے۔ اصل ڈیٹا محفوظ رکھیں۔',
    courtNote:
        'Qanun-e-Shahadat Order 1984: s.3 documents, s.4 secondary evidence, s.17 burden '
        'of proof, s.22 res gestae, s.61 judge as witness, s.68 confessions, s.91 '
        'signature comparison; s.65A/B (2005 amendment) admit electronic records, with '
        's.24 of the Electronic Transactions Act 2005. Code of Civil Procedure 1908: '
        'Order VII r.11 (rejection of plaint), Order XI discovery, Order XIX inspection, '
        'Order XX r.5-A examination. Hostile and interested witnesses weaken a case, and '
        'oral evidence alone is rarely sufficient for a money or property claim.',
    courtNoteUrdu:
        'قانونِ شهادت آرڈر 1984 کی دفعات 3، 4، 17، 61، 68 اور الیکٹرانک ثبوت کے لیے 65-A/B '
        'لاگو ہوتے ہیں۔ سیول پروسیجر کوڈ 1908 کے آرڈر 7 رول 11 (دعویٰ کی ردی) بھی استعمال '
        'ہوتا ہے۔ عدالتیں دستاویزی ثبوت کو ترجیح دیتی ہیں۔',
    urgency: 'normal',
    helpline: '1099 (Legal aid)',
    steps: <LawStep>[
      LawStep(
        'Preserve the original evidence',
        'اصل ثبوت محفوظ کریں',
        'Keep the original document, register, receipt or CCTV/phone data; do not rely on '
            'edited screenshots alone.',
        'اصل دستاویز، رجسٹر، رسید یا CCTV/فون ڈیٹا محفوظ رکھیں؛ صرف اسکرین شاٹس بے کار ہیں۔',
        'Immediately',
        'فوری',
        'You',
        'آپ',
      ),
      LawStep(
        'Get certified copies',
        'مصدقہ نقل حاصل کریں',
        'Obtain certified copies from the issuing office (municipality, registrar, '
            'police, bank) well before the hearing date.',
        'مصدقہ نقل جاری کرنے والے ادارے سے بہت پہلے حاصل کریں۔',
        '2-6 weeks',
        '2 سے 6 ہفتے',
        'Issuing office',
        'جاری کرنے والا ادارہ',
      ),
      LawStep(
        'File the plaint and list witnesses',
        'دعویٰ درج اور گواہان فہرست',
        'File with copies, list witnesses, and follow the court\'s fee schedule for '
            'issuing summons.',
        'دعویٰ کے ساتھ نقلیں جمع کریں، گواہان فہرست دیں اور گوہی کے لیے fee شیڈول follow کریں۔',
        '1-3 months',
        '1 سے 3 ماہ',
        'Civil court',
        'سول عدالت',
      ),
    ],
    documents: <String>[
      'Original documents with certified copies',
      'Affidavit or power of attorney if a representative appears',
      'CCTV and electronic evidence in original form',
      'List of witnesses with their addresses',
    ],
    statutes: <LawStatute>[
      LawStatute(
        'Qanun-e-Shahadat Order 1984',
        'قانونِ شهادت آرڈر 1984',
        's.3, s.4',
        'Documents and secondary evidence',
      ),
      LawStatute(
        'Qanun-e-Shahadat Order 1984',
        'قانونِ شهادت آرڈر 1984',
        's.65A, s.65B',
        'Electronic evidence (inserted 2005)',
      ),
      LawStatute(
        'Code of Civil Procedure 1908',
        'سیول پروسیجر کوڈ 1908',
        'Order XIX',
        'Inspection of documents',
      ),
    ],
  ),
];
