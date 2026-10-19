import '../pakistani_law_data.dart';

/// Accountability and traffic law.
const List<LawTopic> welfareMiscTopics = <LawTopic>[
  LawTopic(
    id: 'anti-corruption',
    category: 'Criminal Law',
    keywords: <String>[
      'corruption',
      'corrupt',
      'bribe',
      'bribery',
      'nab',
      'nra',
      'extortion',
      'embezzlement',
      'fraud by official',
      'negligence of duty',
      'ombudsman',
      'whistleblower',
      'accountability',
      'رشوت',
      'بدعنوانی',
      'امانت داری',
      'فساد',
      'عوامی افسر',
      'حسابداری',
    ],
    summary:
        'Corruption by a public official is dealt with under the National Accountability '
        'Ordinance 1999 (NAB Act 1999). You may complain to the NAB chairman, the '
        'provincial ombudsman or the district controller; the complaint is examined in 30 '
        'days, the accused must be cleared in 60 days, and indictment must be within six '
        'months. Whistle-blowers are protected under s.19. Bribery by a private person is '
        'tried under the PPC, and most of these matters are time-bound, so complain early '
        'and in writing.',
    summaryUrdu:
        'عوامی افسر کی بدعنوانی نیب ایکٹ 1999 کے تحت dealt ہوتی ہے۔ شکایت نیب چیئرمین، صوبہی '
        'ombudsman یا ضلع کنٹرولر سے کر سکتے ہیں؛ 30 دن میں جائزہ، 60 دن میں کلیئرنس اور چھ ماہ '
        'میں راستہ زاری کی میعاد ہے۔ سیکشن 19 کے تحت ڈنبل لوگر کی حفاظت ہوتی ہے۔ نیب کی '
        'کارروائی مختصر میعاد کے اندر ہوتی ہے، اس لیے جلد تحریری شکایت کریں۔',
    courtNote:
        'National Accountability Ordinance 1999: s.4 offences and penalties, s.6 bail '
        '(discretionary; s.498 CrPC does not bar NAB), s.7A bail conditions, s.9 trial in '
        'the High Court, s.19 protection of witnesses and anonymity, s.40 limitation '
        '(three years). The Supreme Court holds that an NAB s.4 reference does not '
        'replace prosecution under the PCCA 1997, where the 14-day notice applies.',
    courtNoteUrdu:
        'نیب ایکٹ 1999 کی دفعہ 4 (جرامات و سزا)، 6 اور 7-A (ضمانت)، 9 (ہائی کورٹ میں کارروائی)، '
        '19 (گواہوں کی حفاظت) اور 40 (تین سال کی میعاد)۔ سپریم کورٹ کے مطابق نیب کا سیکشن 4 '
        'PCCA 1997 کی میعاد کا متبادل نہیں ہے۔',
    urgency: 'caution',
    helpline: '1099 (Human Rights) | Provincial ombudsman | NAB complaint cell',
    steps: <LawStep>[
      LawStep(
        'Preserve the evidence',
        'ثبوت محفوظ کریں',
        'Keep any demand for a bribe, receipts, official letters, lawfully obtained '
            'recordings and witness details.',
        'رشوت کا مطالبہ، رسیدیں، سرکاری خط، قانونی طریقے سے حاصل کردہ ریکارڈنگ اور گواہان محفوظ کریں۔',
        'Immediately',
        'فوری',
        'You',
        'آپ',
      ),
      LawStep(
        'Complaint to the authority',
        'متعلقہ ادارے میں شکایت',
        'File with the NAB chairman, provincial ombudsman or controller, and keep a '
            'diarised copy for yourself.',
        'نیب چیئرمین، صوبہی ombudsman یا کنٹرولر کے پاس تحریری شکایت جمع کروائیں اور نقل رکھیں۔',
        'Within 1-2 months',
        '1 سے 2 ماہ',
        'NAB / Ombudsman',
        'نیب / ombudsman',
      ),
      LawStep(
        'Cooperate and follow up',
        'تعاون اور فالو اپ',
        'Provide documents, appear when summoned, and note the inquiry reference number.',
        'دستاویزات فراہم کریں، طلب پر حاضر ہوں اور انکوائری ریفرنس نمبر محفوظ رکھیں۔',
        '3-12 months',
        '3 سے 12 ماہ',
        'Investigating authority',
        'تحقیقاتی ادارہ',
      ),
    ],
    documents: <String>[
      'Written complaint with dates and names of officials',
      'Proof of bribe demand, receipts or bank transfers',
      'Official letters, notifications or service records',
      'Witness names and contact details',
    ],
    statutes: <LawStatute>[
      LawStatute(
        'National Accountability Ordinance 1999',
        'نیب ایکٹ 1999',
        's.4, s.6, s.19',
        'Offences, bail and witness protection',
      ),
      LawStatute(
        'Prevention of Corruption Act 1997',
        'فسد سے تحفظ ایکٹ 1997',
        's.4',
        'Public servant offences and the 14-day notice',
      ),
      LawStatute(
        'Anti-Corruption Establishment Act 1944',
        'بدعنوانی ادارہ ایکٹ 1944',
        's.3',
        'Public servants under the provincial regime',
      ),
    ],
  ),
  LawTopic(
    id: 'traffic-challan',
    category: 'Civil Law',
    keywords: <String>[
      'traffic',
      'challan',
      'e-challan',
      'licence',
      'license',
      'driving licence',
      'vehicle',
      'road accident',
      'accident',
      'speed',
      'helmet',
      'number plate',
      'fine',
      'traffic police',
      'وہاڑی',
      'چالان',
      'لائسنس',
      'ڈرائیونگ لائسنس',
      'گاڑی',
      'ایکسیڈنٹ',
      'جرمانہ',
    ],
    summary:
        'Traffic offences are mostly enforced through e-challans, payable online or at a '
        'designated bank. If you disagree with a challan, the Motor Vehicle Rules allow '
        'an appeal to the Traffic Commissioner within 15 days, with further recourse to '
        'the ombudsman. Repeated unpaid challans can lead to licence suspension. In an '
        'accident, call 15 and rescue 1122, photograph the scene, get the FIR and MLC '
        'made, and do not settle privately before both exist.',
    summaryUrdu:
        'ٹریفک جرمانے اب زیادہ تر الیکٹرانک چالان کے ذریعے وصول کیے جاتے ہیں اور رقم آن لائن یا '
        'متعینہ بینک میں جمع کی جاتی ہے۔ چالان پر اعتراض ہو تو جاری ہونے کے 15 دن کے اندر ٹریفک '
        'کمشنر کو اپیل کریں۔ حادثے میں 15 اور 1122 پر کال کریں، تصاویر لیں، ایف آئی آر اور ایم ایل '
        'سی ہوں تب ہی باہمی طور پر معاملہ طے کریں۔',
    courtNote:
        'National Highway Safety Ordinance 2000 (amended 2018) and the Motor Vehicle '
        'Rules 2005: Rule 10 (payment of challan), Rule 11 (appeal within 15 days), s.39 '
        'penalties and compounding. Accidents engage PPC 279 (rash and negligent driving) '
        'and s.337/338 (death or grievous hurt). Compensation claims run against the '
        'insurer/owner under the provincial Motor Vehicles (Transport) Act and the '
        'compulsory third-party insurance scheme.',
    courtNoteUrdu:
        'نیشنل ہائی وے سیفٹی آرڈیننس 2000 اور موٹر وہیکل رولز 2005 کے رول 10 (چالن ادائیگی) اور '
        'رول 11 (15 دن میں اپیل) لاگو ہوتے ہیں۔ حادثے میں PPC 279 اور 337/338 بھی لاگو ہوتے ہیں۔',
    urgency: 'caution',
    helpline: '15 (Police) | 1122 (Rescue) | 9911 (e-Challan)',
    steps: <LawStep>[
      LawStep(
        'Pay or appeal the challan',
        'چالن ادا کریں یا اپیل کریں',
        'Pay online/at the designated bank, or appeal in writing to the Traffic '
            'Commissioner within 15 days with a copy of the challan.',
        'آن لائن یا متعینہ بینک میں رقم جمع کروائیں، یا 15 دن کے اندر تحریری اپیل کریں۔',
        'Within 15 days',
        '15 دن میں',
        'Traffic police / Traffic Commissioner',
        'ٹریفک پولیس / ٹریفک کمشنر',
      ),
      LawStep(
        'In an accident: call and document',
        'حادثے میں کال کریں اور ثبوت جمع کریں',
        'Call 15 and 1122, photograph the scene and vehicles, note witness numbers, and '
            'do not hand over money on the spot.',
        '15 اور 1122 پر کال کریں، تصاویر لیں، گواہان کے نمبر لیں اور موقع پر رقم نہ دیں۔',
        'Immediately',
        'فوری',
        'Police / Rescue 1122',
        'پولیس / 1122',
      ),
      LawStep(
        'Claim compensation',
        'معاوضہ طلب کریں',
        'After the FIR and MLC, claim for injuries, repair and loss of income with '
            'medical and expense bills.',
        'ایف آئی آر اور ایم ایل سی کے بعد انشورر/مالک سے زخم، مرمت اور آمدنی کی نقصان کا دعویٰ کریں۔',
        '1-12 months',
        '1 سے 12 ماہ',
        'Insurance / civil court',
        'انشورنس / سول عدالت',
      ),
    ],
    documents: <String>[
      'Original driving licence and vehicle registration (C-Form)',
      'E-challan notice and payment receipt',
      'FIR, MLC and insurance policy number',
      'Photos, witness contacts, medical and repair bills',
    ],
    statutes: <LawStatute>[
      LawStatute(
        'National Highway Safety Ordinance 2000',
        'ہائی وے سیفٹی آرڈیننس 2000',
        's.39, Rule 11',
        'Penalties and appeal against a challan',
      ),
      LawStatute(
        'Pakistan Penal Code 1860',
        'مجموعہ تعزیرات پاکستان 1860',
        's.279, s.337',
        'Rash driving and causing death',
      ),
      LawStatute(
        'Motor Vehicles (Transport) Act (provincial)',
        'موٹر وہیکل ایکٹ',
        'Licensing and registration',
        'Licence suspension and third-party insurance',
      ),
    ],
  ),
];
