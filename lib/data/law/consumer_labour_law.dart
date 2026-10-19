import '../pakistani_law_data.dart';

/// Consumer rights and employment/labour law.
const List<LawTopic> consumerLabourTopics = <LawTopic>[
  LawTopic(
    id: 'consumer-protection',
    category: 'Consumer Law',
    keywords: <String>[
      'consumer',
      'refund',
      'defective product',
      'warranty',
      'fake product',
      'e-commerce',
      'online shopping',
      'utility bill',
      'electricity bill',
      'gas bill',
      'overcharged',
      'bill dispute',
      'food adulteration',
      'telecom complaint',
      'paisay bache',
      'warranty',
      'utility',
      'کنزیمر',
      'رقم واپسی',
      'خراب سامان',
      'وارنٹی',
      'بجلی کا بل',
      'گیس کا بل',
      'زیادہ وصولی',
      'آن لائن خریداری',
      'غذائی آلودگی',
    ],
    summary:
        'If a shop, company or utility provider has billed you wrongly, sold a defective '
        'item or refused a refund, the remedy is cheap and fast: a written complaint to '
        'the seller first, then the provincial consumer protection authority or the '
        'sector regulator (PTA for telecom, NEPRA/dispute committees for power, IEEA for '
        'electricity, DRAA for gas). Most consumer statutes require a dispute to be '
        'escalated formally before litigation, and they cap how long the process should '
        'take. Utility bills can be challenged before the issuing company within 15 days '
        'of receipt, and the authority can order refunds with compensation.',
    summaryUrdu:
        'اگر دکاندار، کمپنی یا یوٹیلٹی نے غلط بل دیا، خراب سامان فروخت کیا یا رقم واپس نہیں '
        'کی تو پہلے تحریری شکایت کریں، پھر صوبہی کنزیمر پروٹیکشن اتھارٹی یا ریگولیٹر (PTA، '
        'NEPRA، DRAA) کے پاس جائیں۔ بجلی یا گیس کے بل کی 15 دن کے اندر کلیم کی جا سکتی ہے اور '
        'اتھارٹی رقم کی واپسی اور معاوضے کا حکم دے سکتی ہے۔',
    courtNote:
        'Complaint ladder matters: written notice to the seller -> provincial Consumer '
        'Protection Authority under the relevant provincial statute (e.g. Punjab Consumer '
        'Protection Act) or sector ombudsman (PTA s.29, NEPRA, DRAA, IEEA) -> civil suit '
        'in the consumer/pecuniary court. Maintain the notice, invoice, warranty card and '
        'payment proof; claims for deficiency in service seek damages plus compensation '
        'and a civil suit cannot be filed while the forum appeal is pending.',
    courtNoteUrdu:
        'شکایت کا ترتیب اہم ہے: فروخت کنندہ کو تحریری اطلاع، پھر صوبہی کنزیمر اتھارٹی یا '
        'سیکٹرombudsman (PTA، NEPRA، DRAA)، پھر مدعیہ عدالت۔ بل، انوائس، وارنٹی کارڈ اور ادائیگی '
        'کی ثبوت محفوظ رکھیں۔',
    urgency: 'normal',
    helpline: 'PTA complaints: 0800-55055 | 1099 (General)',
    steps: <LawStep>[
      LawStep(
        'Write to the seller or provider',
        'فروخت کنندہ کو تحریری شکایت',
        'Send a registered/email notice with the invoice, asking for a refund or '
            'correction within 15 days. Keep proof of delivery.',
        'انوائس کے ساتھ اندراج/ای میل شکایت بھیجیں اور 15 دن میں اصلاح یا واپسی طلب کریں۔',
        '15 days',
        '15 دن',
        'Seller / utility company',
        'فروخت کنندہ / یوٹیلٹی کمپنی',
      ),
      LawStep(
        'Escalate to the regulator',
        'ریگولیٹر کے پاس شکایت',
        'File with the sector regulator (PTA/NEPRA/DRAA) or the provincial consumer '
            'authority, attaching the notice and its non-delivery proof.',
        'سیکٹر ریگولیٹر یا کنزیمر اتھارٹی میں شکایت جمع کروائیں اور اطلاع نہ ملنے کا ثبوت لگائیں۔',
        '1-8 weeks',
        '1 سے 8 ہفتے',
        'Regulator / consumer authority',
        'ریگولیٹر / کنزیمر اتھارٹی',
      ),
      LawStep(
        'Approach the consumer court',
        'مدعیہ عدالت',
        'If unresolved, file a civil suit in the consumer/pecuniary court for refund, '
            'damages and compensation.',
        'حل نہ ہو تو رقم، نقصان اور معاوضے کے لیے مدعیہ عدالت میں دعویٰ دائر کریں۔',
        '1-6 months',
        '1 سے 6 ماہ',
        'Consumer court',
        'کنزیمر کورٹ',
      ),
    ],
    documents: <String>[
      'Purchase invoice, warranty card and receipts',
      'Written complaint with proof of delivery',
      'Utility bill copy and previous bills for comparison',
      'Photos of the defective item and any written replies',
    ],
    statutes: <LawStatute>[
      LawStatute(
        'Consumer protection statute (provincial)',
        'صوبہی کنزیمر پروٹیکشن ایکٹ',
        'Deficiency in service',
        'Refund, replacement and compensation',
      ),
      LawStatute(
        'Negotiable Instruments Act 1881',
        'قابل قبول کاغذات ایکٹ 1881',
        's.138',
        'Dishonest cheque and recovery of the amount',
      ),
    ],
  ),
  LawTopic(
    id: 'labour-employment',
    category: 'Labour Law',
    keywords: <String>[
      'job',
      'salary',
      'unpaid salary',
      'overtime',
      'fired',
      'termination',
      'dismissal',
      'notice period',
      'leave',
      'provident fund',
      'eobi',
      'pension',
      'labour court',
      'harassment at work',
      'maternity',
      'contract',
      'employer',
      'wages',
      'weekly off',
      'ملازمت',
      'تنخواہ',
      'ٹائم اوور ٹائم',
      'نوکری',
      'برطرفی',
      'ملازمتی عدالت',
      'ای او بی آئی',
      'چھٹی',
      'میٹرنٹی',
      'تنخواہ نہ دینا',
    ],
    summary:
        'Unpaid wages, arbitrary firing and unpaid overtime are the most common '
        'employment disputes, and Pakistan has a dedicated forum for them. Under the '
        'provincial Labour Force Acts and the Shops and Establishments Acts, wages must '
        'be paid by the agreed date, overtime is payable, and an employee generally '
        'cannot be dismissed without notice or a valid reason and a standing certificate '
        'of service. Female employees have a statutory right to a written appointment '
        'letter and to a safe workplace, and sexual harassment is a criminal offence as '
        'well as a labour matter. A complaint goes to the provincial Labour Inspector '
        'and then to the Labour Court.',
    summaryUrdu:
        'غیر ادا شدہ تنخواہ، بغیر وجہ برطرفی اور غیر ادا شدہ اوور ٹائم ملازمت کے سب سے عام '
        'تنازعات ہیں اور ان کے لیے الگ عدالت ہے۔ صوبہی لیبر فورس ایکٹ اور شاپس اینڈ '
        'ایسٹابلشمنٹس ایکٹ کے تحت تنخواہ مقررہ تاریخ پر، اوور ٹائم قابل ادا اور نوکری کی خاتمہ '
        'وجہ اور نوٹس کے بغیر نہیں کی جا سکتی۔ خواتین کو تحریری appointment لیٹر کا حق حاصل ہے اور '
        'جنسی ہراسانی جرم بھی ہے۔ شکایت لیبر انسپکٹر اور پھر لیبر کورٹ میں ہوتی ہے۔',
    courtNote:
        'Provincial Labour Force (Amendment) Acts (Punjab 2011 as amended 2017/2018, KP '
        '2017), Shops and Establishments Acts, and the Standing Orders of the '
        'establishment fix: 8/12/48 hours per week depending on the trade, minimum '
        'wages notification, 1/12 of the annual wage for one month\'s notice (or 2 months '
        'during the probationary period under most Punjab establishments), maternity '
        'leave, and EOBI contributions. Sexual harassment: Punjab Protection of Women '
        'against Sexual Harassment at Workplace Act 2018 (committee at the workplace) read '
        'with PPC 354/354-A/509; complaints may also go to the Ombudsman. Reinstatement '
        'with back wages is the usual remedy where dismissal is unlawful.',
    courtNoteUrdu:
        'صوبہی لیبر فورس ایکٹ، شاپس اینڈ ایسٹابلشمنٹس ایکٹ اور اسٹینڈنگ آرڈرز ملازم کے '
        'اوقات کار، کم از کم تنخواہ، ایک ماہ نوٹس (پروbation پر دو ماہ)، میٹرنٹی لیو اور EOBI '
        'کے رعایتات مقرر کرتے ہیں۔ پنجاب میں ہراسانی کے خلاف خواتین کا تحفظ ایکٹ 2018 اور '
        'PPC 354-A بھی لاگو ہوتے ہیں۔ غیر قانونی برطرفی پر بحالی اور بیک ویجز ملنے ہیں۔',
    urgency: 'caution',
    helpline: 'Labour Inspectorate (provincial) | 1098 (Punjab Labour)',
    steps: <LawStep>[
      LawStep(
        'Collect your employment proof',
        'ملازمت کے ثبوت جمع کریں',
        'Keep the appointment letter, contract, attendance record, salary slips and '
            'any written warning or termination letter.',
        'appointment لیٹر، معاہدہ، حاضری ریکارڈ، تنخواہ کی رسیدیں اور برطرفی خط محفوظ رکھیں۔',
        'Immediately',
        'فوری',
        'You',
        'آپ',
      ),
      LawStep(
        'Complain to the Labour Inspector',
        'لیبر انسپکٹر کو شکایت',
        'File a written complaint about unpaid wages, unlawful termination or '
            'harassment; inspection and conciliation are faster than a suit.',
        'تنخواہ، برطرفی یا ہراسانی کی تحریری شکایت درج کروائیں؛ تفتیش اور سودھیولیشن تیز ہے۔',
        '1-3 months',
        '1 سے 3 ماہ',
        'Labour Inspector / Directorate',
        'لیبر ڈائریکٹوریٹ',
      ),
      LawStep(
        'File the reference in Labour Court',
        'لیبر کورٹ میں درخواست',
        'After conciliation fails, file a claim for reinstatement, unpaid wages and '
            'overtime in the Labour Court of the area.',
        'سودھیولیشن ناکام ہونے پر بحالی، غیر ادا شدہ تنخواہ اور اوور ٹائم کے لیے لیبر کورٹ میں '
            'دعویٰ دائر کریں۔',
        '3-12 months',
        '3 سے 12 ماہ',
        'Labour Court',
        'لیبر کورٹ',
      ),
    ],
    documents: <String>[
      'Appointment letter, contract and CNIC copy',
      'Attendance register / biometric or HR records',
      'Salary slips, bank statements and EOBI card',
      'Termination letter, warning letters or HR emails',
    ],
    statutes: <LawStatute>[
      LawStatute(
        'Labour Force Act (Punjab, amended)',
        'لیبر فورس ایکٹ (پنجاب)',
        'ss.15-21, s.30',
        'Wages, hours, overtime, termination, complaints',
      ),
      LawStatute(
        'Protection of Women against Sexual Harassment at Workplace Act 2018',
        'کام پر جنسی ہراسانی سے تحفظ ایکٹ 2018',
        's.3',
        'Workplace harassment committee and protection',
      ),
      LawStatute(
        'Pakistan Penal Code 1860',
        'مجموعہ تعزیرات پاکستان 1860',
        's.354-A',
        'Harassment of a woman at the workplace',
      ),
    ],
  ),
];
