import '../pakistani_law_data.dart';

/// Property, land revenue, banking and financial recovery.
const List<LawTopic> propertyFinanceTopics = <LawTopic>[
  LawTopic(
    id: 'land-property-dispute',
    category: 'Property Law',
    keywords: <String>[
      'land',
      'property dispute',
      'mutation',
      'fard',
      'intiqa',
      'ownership',
      'possession',
      'pre-emption',
      'shamilat',
      'dakhil kharcha',
      'registry',
      'sale deed',
      'transfer deed',
      'pai',
      'kabristan',
      'land mafia',
      'boundary',
      'زمین',
      'جائیداد',
      'سند',
      'رجسٹری',
      'تملک',
      'قبضہ',
      'شاملیت',
      'داخلہ خرچہ',
    ],
    summary:
        'Most land disputes in Pakistan concern mutation, possession or pre-emption, and '
        'the first document to obtain is the Fard (khasra and khatauni copy). Mutation is '
        'granted by the Revenue Officer after notice to adjoining owners; a wrong or '
        'delayed mutation is appealed to the Commissioner within 30 days. A pre-emption '
        'notice under s.148(3) must be served within one month of learning of the '
        'proposed sale, otherwise the right is lost.',
    summaryUrdu:
        'پاکستان میں زمین کے زیادہ تر تنازعات میوتیشن، قبضہ یا پیمانہ فیس سے متعلق ہوتے '
        'ہیں اور پہلا کاغذ فرد ہے۔ میوتیشن ریونیو افسر سے ملتے اضلاع کو نوٹس دے کر دی جاتی ہے؛ '
        '30 دن کے اندر کمشنر کو اپیل ہوتی ہے۔ پیمانہ فیس کا نوٹس (s.148) ایک مہینے کے اندر '
        'پہنچانا لازمی ہے ورنہ حق ختم ہو جاتا ہے۔',
    courtNote:
        'Punjab Land Revenue Act 1887 (provincial equivalents apply elsewhere): s.148 '
        'pre-emption and the one-month notice, s.150 register of mutations, s.159 orders '
        'of the Commissioner, s.9 khasra entry as evidence of title. Civil suit for '
        'declaration, possession and permanent injunction; a Commissioner\'s order is '
        'revisional. Where force or fraud is used, PPC 420/447/468 and the Land Revenue '
        'Act apply alongside. Always attach the Fard, mutation order and revenue history.',
    courtNoteUrdu:
        'پنجاب لینڈ ریونیو ایکٹ 1887 کی دفعہ 148 (پیمانہ فیس)، 150 (میوتیشن رجسٹر) اور 159 '
        '(کمشنر کے احکام) قابل اطلاق ہیں۔ اعلان، قبضہ اور مستقل پابندی کے لیے سول دعویٰ دائر '
        'کریں اور فرد، میوتیشن آرڈر اور ریونیو ہسٹری منسلک کریں۔',
    urgency: 'caution',
    helpline: 'DCO / Revenue office | 1099 (Legal aid)',
    steps: <LawStep>[
      LawStep(
        'Get the Fard and mutation record',
        'فرد اور میوتیشن ریکارڈ حاصل کریں',
        'Request the khasra and khatauni copy plus the patta and 30 years of mutation '
            'entries for your khasra number.',
        'کھسرا/خاتونی کاپی، پٹہ اور 30 سال کی میوتیشن اندراجات اپنے کھسرا نمبر کے لیے حاصل کریں۔',
        '1-3 weeks',
        '1 سے 3 ہفتے',
        'Revenue office / Patwari',
        'ریونیو آفس / پتواری',
      ),
      LawStep(
        'Apply for mutation / pre-emption',
        'میوتیشن یا پیمانہ فیس درخواست',
        'File the mutation application, and serve a pre-emption notice within one month '
            'of a proposed neighbouring sale.',
        'میوتیشن درخواست جمع کروائیں اور ایک مہینے کے اندر پیمانہ فیس نوٹس پہنچائیں۔',
        'Within 1 month',
        '1 مہینے میں',
        'Revenue Officer / Patwari',
        'ریونیو افسر / پتواری',
      ),
      LawStep(
        'Appeal the revenue decision',
        'ریونیو فیصلے کی اپیل',
        'Appeal to the Commissioner within 30 days, then to the Board of Revenue; sue in '
            'civil court if the title itself is disputed.',
        '30 دن میں کمشنر کو اپیل، پھر بورڈ آف ریونیو؛ اصل ملکیت کے dispute میں سول دعویٰ۔',
        '1-12 months',
        '1 سے 12 ماہ',
        'Revenue Commissioner / Civil court',
        'ریونیو کمشنر / سول عدالت',
      ),
    ],
    documents: <String>[
      'Fard / khasra khatauni copy and patta',
      'Mutation order or receipt of application',
      'Sale deed and pre-emption notice with proof of service',
      'Property tax receipts and previous owner documents',
    ],
    statutes: <LawStatute>[
      LawStatute(
        'Punjab Land Revenue Act 1887',
        'پنجاب لینڈ ریونیو ایکٹ 1887',
        's.148, s.150',
        'Pre-emption notice and mutation register',
      ),
      LawStatute(
        'Punjab Land Revenue Act 1887',
        'پنجاب لینڈ ریونیو ایکٹ 1887',
        's.9',
        'Khasra entry as evidence of title',
      ),
      LawStatute(
        'Registration Act 1908',
        'رجسٹریشن ایکٹ 1908',
        's.17',
        'Registration of deeds and mutation record',
      ),
    ],
  ),
  LawTopic(
    id: 'cheque-dishonour',
    category: 'Civil Law',
    keywords: <String>[
      'cheque',
      'bounced',
      'dishonour',
      'dishonored',
      'returned cheque',
      'post dated cheque',
      'loan recovery',
      'suit recovery',
      'debt recovery',
      'چیک',
      'چیک واپس',
      'قرضہ',
      'واپسی طلب',
      'قرض',
    ],
    summary:
        'A dishonoured cheque is both a civil debt and a criminal offence in Pakistan. The '
        'payee must collect the returned cheque from the bank within 15 days of expiry, '
        'send a written demand notice within one month of receiving it, and then file a '
        'criminal complaint under s.138 of the Negotiable Instruments Act 1881 or a '
        'summary civil suit (up to Rs 20,000). The cheque itself is good evidence of the '
        'debt, so keep it with the notice proof.',
    summaryUrdu:
        'واپس شدہ چیک پاکستان میں سائل بھی ہے اور جرم بھی۔ وصول کنندہ کو چیک رجوع ہونے کے 15 '
        'دن کے اندر بینک سے وصول کر کے ایک مہینے کے اندر تحریری نوٹس بھیجنا ہوتا ہے، پھر '
        'دفعہ 138 کے تحت شکایت یا سول دعویٰ درج کرنی ہوتی ہے۔ چیک خود قرض کا ثبوت ہے۔',
    courtNote:
        'Negotiable Instruments Act 1881: s.138 (punishable up to 2 years with fine; '
        'Magistrate trial, non-bailable and non-compoundable), s.138A (summary procedure '
        'for cheques issued for consideration), s.139 (compounding), s.141 (company '
        'liability), read with General Clauses Act 1897 s.17(e) on the date of receipt. '
        'Limitation: complaint within one month of the notice; the civil suit is barred '
        'after three years.',
    courtNoteUrdu:
        'قابل قبول کاغذات ایکٹ 1881 کی دفعہ 138 (اور 138-A، 139، 141)۔ شکایت نوٹس ملنے کے ایک '
        'مہینے کے اندر درج ہونی چاہیے، ورنہ میعاد ختم۔ سول دعویٰ تین سال میں کالعدم ہو جاتی ہے۔',
    urgency: 'caution',
    helpline: '15 (Police) | 1099 (Legal aid)',
    steps: <LawStep>[
      LawStep(
        'Collect the returned cheque',
        'واپس شدہ چیک وصول کریں',
        'Take the cheque memo from the bank within 15 days of expiry, noting the '
            'banker\'s remarks.',
        'چیک کی تاریخ ختم ہونے کے 15 دن کے اندر بینک سے چیک اور وجہِ رد کی یادداشت لکھی وصول کریں۔',
        'Within 15 days',
        '15 دن میں',
        'Bank branch',
        'بینک برانچ',
      ),
      LawStep(
        'Send the demand notice',
        'مطالباتی نوٹس بھیجیں',
        'Send a registered notice or SMS/email demanding the exact cheque amount within '
            '15 days of the notice.',
        'رجسٹرڈ یا ای میل/SMS نوٹس بھیجیں جس میں رقم 15 دن میں طلب کی جائے۔',
        'Within 1 month of receipt',
        'وصولی کے ایک مہینے میں',
        'Registered post / email',
        'رجسٹرڈ پوسٹ / ای میل',
      ),
      LawStep(
        'File the complaint or suit',
        'شکایت یا دعویٰ دائر کریں',
        'After 15 days from the notice file the s.138 complaint; for small amounts use a '
            'summary suit in the banking court.',
        'نوٹس کے 15 دن بعد شکایت درج کریں؛ چھوٹی رقم کے لیے بینکنگ کورٹ میں مختصر دعویٰ۔',
        '1-9 months',
        '1 سے 9 ماہ',
        'Magistrate / Civil court',
        'ماجسٹریٹ / سول عدالت',
      ),
    ],
    documents: <String>[
      'Original dishonoured cheque and bank return memo',
      'Proof of the demand notice (registered receipt / SMS printout)',
      'Agreement, invoice or other evidence of the debt',
      'CNIC copies of the drawer and the payee',
    ],
    statutes: <LawStatute>[
      LawStatute(
        'Negotiable Instruments Act 1881',
        'قابل قبول کاغذات ایکٹ 1881',
        's.138',
        'Dishonour of a cheque for insufficiency of funds',
      ),
      LawStatute(
        'Negotiable Instruments Act 1881',
        'قابل قبول کاغذات ایکٹ 1881',
        's.138A',
        'Summary procedure for cheques issued for consideration',
      ),
      LawStatute(
        'Pakistan Penal Code 1860',
        'مجموعہ تعزیرات پاکستان 1860',
        's.420',
        'Cheating and dishonest inducement',
      ),
    ],
  ),
];
