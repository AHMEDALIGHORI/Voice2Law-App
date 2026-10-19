import '../pakistani_law_data.dart';

/// Cybercrime, online fraud and domestic violence.
const List<LawTopic> cyberFamilyTopics = <LawTopic>[
  LawTopic(
    id: 'cyber-fraud',
    category: 'Cybercrime',
    keywords: <String>[
      'cyber',
      'hacking',
      'hacked',
      'phishing',
      'fraud',
      'scam',
      'online fraud',
      'atm',
      'upi',
      'easypaisa',
      'jazzcash',
      'otp',
      'ptec',
      'peca',
      'impersonation',
      'blackmail',
      'fake account',
      'data breach',
      'سائبر',
      'آن لائن دھوکہ',
      'ہیکنگ',
      'او ٹی پی',
      'بینک اکاؤنٹ',
      'دھوکہ',
      'جھوٹا پیغام',
      'رقم کی نقل',
      'بلیک میل',
    ],
    summary:
        'If money or data was stolen online there are three fast tracks: stop the '
        'transaction, alert the bank, and report to the FIA Cyber Crime Wing. Under '
        'the PECA 2016, phishing, unauthorised electronic transfers, fake identity and '
        'blackmail material are criminal offences and the court may award the victim '
        'compensation under section 66C. Act within weeks - banks can often reverse a '
        'transfer for about 30 days and call/CCTV records disappear quickly.',
    summaryUrdu:
        'آن لائن دھوکے یا سائبر حملے میں تین فوری اقدامات ہیں: ٹرانزیکشن روکیں، بینک کو مطلع '
        'کریں، اور ایف آئی اے سائبر کرائم ونگ میں رپورٹ کریں۔ PECA 2016 کے تحت فشنگ، غیر مجاز '
        'الیکٹرانک منتقلی، جعلی شناخت اور بلیک میل ایکسچینج تمام جرائم ہیں اور متاثرہ کو کورٹ '
        'کمپنیشن دیا جا سکتا ہے۔ چند ہفتوں میں کارروائی کریں۔',
    courtNote:
        'PE CA 2016 (amended by the Anti-Terrorism Act 2014) read with CrPC 1898. Key '
        'sections: s.36 unauthorised access, s.43 spoofing/fake identity, s.63 cyber '
        'stalking and vulgar material, s.66A-D compulsory decryption, s.66C victim '
        'compensation, s.66D aggravated offences up to 7 years. The FIA Cyber Crime '
        'Wing (0405-111-444) has jurisdiction. Pleading only under s.498 PPC (cheating) '
        'instead of PECA is a common defect.',
    courtNoteUrdu:
        'PE CA 2016 کے تحت رپورٹ درج کروائیں۔ اہم دفعات: 36، 43، 63، 66C (متاثرہ کا معاوضہ) '
        'اور 66D (شدید جرم تا 7 سال)۔ ایف آئی اے کا سائبر کرائم ونگ اس معاملے کے لیے ہے۔',
    urgency: 'urgent',
    helpline:
        'FIA Cyber Crime Wing: 0405-111-444 | Cybercrime complaints: 9911',
    steps: <LawStep>[
      LawStep(
        'Call the bank fraud desk',
        'بینک فراڈ ڈیسک کو کال کریں',
        'Block the account/card, request a reversal and note the reference number. '
            'Keep the SMS or push notification as evidence.',
        'اکاؤنٹ/کارڈ بلاک کروائیں، واپسی منگوائیں اور حوالہ نمبر نوٹ کریں۔ پیغام محفوظ رکھیں۔',
        'Within 1 hour',
        'ایک گھنٹے کے اندر',
        'Bank fraud desk',
        'بینک فراڈ ڈیسک',
      ),
      LawStep(
        'Report to the Cyber Crime Wing',
        'سائبر کرائم ونگ میں رپورٹ',
        'File a written complaint with the FIA Cyber Crime Centre with screenshots '
            'and transaction IDs.',
        'اسکرین شاٹس اور ٹرانزیکشن ID کے ساتھ تحریری شکایت درج کروائیں۔',
        'Within 24-48 hours',
        '24-48 گھنٹے میں',
        'FIA Cyber Crime Wing',
        'ایف آئی اے سائبر کرائم ونگ',
      ),
      LawStep(
        'Claim compensation in court',
        'عدالت میں معاوضہ طلب کریں',
        'Petition for compensation under s.66C PECA, attaching the bank letter, '
            'transaction trace and FIR copy.',
        'دفعہ 66C کے تحت دعویٰ دائر کریں اور بینک کی خط، ٹرانزیکشن ریکارڈ اور ایف آئی آر منسلک کریں۔',
        '1-6 months',
        '1 سے 6 ماہ',
        'Court of competent jurisdiction',
        'مختص عدالت',
      ),
    ],
    documents: <String>[
      'Bank transaction slip and reference number',
      'Screenshots of chats, fake profiles and OTP prompts',
      'CNIC copy and SIM ownership record',
    ],
    statutes: <LawStatute>[
      LawStatute(
        'Prevention of Electronic Crimes Act 2016',
        'الیکٹرانک جرم ایکٹ 2016',
        's.36, s.43, s.63',
        'Unauthorised access, spoofing, cyber stalking',
      ),
      LawStatute(
        'Prevention of Electronic Crimes Act 2016',
        'الیکٹرانک جرم ایکٹ 2016',
        's.66C',
        'Compensation to the victim of a cyber crime',
      ),
      LawStatute(
        'Code of Criminal Procedure 1898',
        'ضابطہ فوجداری 1898',
        's.154',
        'FIR registration is mandatory for cognizable offences',
      ),
    ],
  ),
  LawTopic(
    id: 'domestic-violence',
    category: 'Family Law',
    keywords: <String>[
      'domestic violence',
      'domestic abuse',
      'beating wife',
      'husband beats',
      'violence at home',
      'molest',
      'molestation',
      'protection order',
      'threaten',
      'strangulation',
      'economic abuse',
      'گھریلو تشدد',
      'مار پیٹ',
      'بدسلوکی',
      'ہراسانی',
      'نکاح مبارک',
      'دھمکی',
      'خوف',
      'محفوظ جگہ',
      'دستک',
    ],
    summary:
        'Domestic violence is a legal matter in Pakistan, not a private one. The '
        'Protection from Domestic Violence Act 2016 covers physical, sexual, psychological '
        'and economic abuse of a woman, her child or a relative living in the household. '
        'You may ask the Protection Committee (at the Union Council or police station) '
        'for a protection order, a residence order, custody and maintenance; the '
        'committee must act within 3 days and the order lasts 6 months. Criminal remedies '
        'under the PPC can run in parallel.',
    summaryUrdu:
        'گھریلو تشدد پاکستان میں قانونی معاملہ ہے۔ گھریلو تشدد سے تحفظ ایکٹ 2016 کے تحت '
        'جسمانی، جنسی، نفسیاتی اور معاشی بدسلوکی کا احاطہ ہوتا ہے۔ آپ یونین کونسل یا تھانے کے '
        'تحفظ کمیٹی سے تحفظ، رہائش، بچوں کی تحویل اور نفقہ کے لیے درخواست کر سکتی ہیں۔ کمیٹی 3 '
        'دن میں کارروائی کرے گی اور آرڈر 6 ماہ کے لیے مؤثر ہے۔',
    courtNote:
        'Protection from Domestic Violence Act 2016: s.7 Protection Committee, s.8 '
        'interim protection order, s.9 final protection order, s.12 custody, s.13 '
        'residence, s.16 maintenance, s.17 compensation, s.19 breach of an order (up to '
        '2 years). Run with PPC 375(d)/376(A), 354, 339-A/339-C and the Protection of '
        'Women and Children Against Violence Act 2016.',
    courtNoteUrdu:
        'گھریلو تشدد سے تحفظ ایکٹ 2016، دفعات 8، 9 (تحفظی آرڈر)، 12 (تحویل)، 13 (رہائش)، '
        '16 (نفقہ) اور 17 (معاوضہ)۔ PPC 375(d)، 354، 339-A اور 339-C بھی ایک ساتھ استعمال '
        'کیے جا سکتے ہیں۔',
    urgency: 'critical',
    helpline: '1713 / 1737 (Punjab Umang) | 1099 (Human Rights) | 15 (Police)',
    steps: <LawStep>[
      LawStep(
        'Reach safety and preserve evidence',
        'محفوظ جگہ اور ثبوت',
        'Go to a relative, shelter or police; photograph injuries and get an MLC / '
            'medical report the same day.',
        'کسی رشتہ دار یا پولیس کے پاس جائیں۔ زخم کی تصاویر اور میڈیکل رپورٹ لیں۔',
        'Immediately',
        'فوری',
        'Family / shelter / police',
        'خاندان / پناہ گاہ / پولیس',
      ),
      LawStep(
        'Apply to the Protection Committee',
        'تحفظ کمیٹی میں درخواست',
        'Submit a written application with CNIC and evidence; a women\'s officer or '
            'police officer may register it for you.',
        'تحریری درخواست CNIC اور ثبوت کے ساتھ جمع کروائیں؛ افسر آپ کی درخواست درج کرے گا۔',
        'Within 3 days of hearing',
        'سننے کے 3 دن میں',
        'DV Protection Committee',
        'تحفظ کمیٹی',
      ),
      LawStep(
        'Register the criminal case',
        'جرمی کیفیت درج کروائیں',
        'Violence is cognizable - registration is mandatory under s.154 CrPC.',
        'تشدد قابل دست اندازی جرم ہے - ایف آئی آر درج کرنا لازمی ہے۔',
        'Within 1 week',
        '1 ہفتے میں',
        'Police station / Women\'s cell',
        'تھانہ / خواتین سیل',
      ),
    ],
    documents: <String>[
      'CNIC (or any identity document) of the complainant',
      'MLC / medical report and dated injury photos',
      'Witness statements, call and message logs',
      'Any earlier FIR or DV Committee application',
    ],
    statutes: <LawStatute>[
      LawStatute(
        'Protection from Domestic Violence Act 2016',
        'گھریلو تشدد سے تحفظ ایکٹ 2016',
        's.8, s.9',
        'Interim and final protection orders',
      ),
      LawStatute(
        'Protection of Women and Children Against Violence Act 2016',
        'عورتوں کے تحفظ ایکٹ 2016',
        's.6',
        'Femicide and grievous hurt',
      ),
      LawStatute(
        'Pakistan Penal Code 1860',
        'مجموعہ تعزیرات پاکستان 1860',
        's.354, s.339-C',
        'Cruelty and coercion of a woman',
      ),
    ],
  ),
];
