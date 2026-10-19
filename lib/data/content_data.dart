import 'package:flutter/material.dart';

import '../models/models.dart';
import 'fallback_data.dart';

class FaqData {
  const FaqData({
    required this.question,
    required this.questionUrdu,
    required this.answer,
  });

  final String question;
  final String questionUrdu;
  final String answer;
}

class WeekPoint {
  const WeekPoint(this.day, this.voice, this.text);

  final String day;
  final int voice;
  final int text;
}

/// Fallback / demo content that the website shipped inside its React pages.
/// Used whenever the REST API cannot be reached so the mobile app always has
/// something meaningful to display (same behaviour as the web client).
class ContentData {
  const ContentData._();

  static const List<Lawyer> defaultLawyers = <Lawyer>[
    Lawyer(
      id: '1',
      name: 'Advocate Muhammad Ali Khan',
      nameUrdu: 'ایڈووکیٹ محمد علی خان',
      expertise: <String>['Family Law', 'Civil Law', 'Property Law'],
      courtLocation: 'Islamabad High Court',
      city: 'Islamabad',
      rating: 4.8,
      reviewCount: 156,
      experience: 15,
      languages: <String>['Urdu', 'English', 'Punjabi'],
      phoneNumber: '+92 300 1234567',
      whatsapp: '+923001234567',
      email: 'ali.khan@voice2law.pk',
      image:
          'https://images.unsplash.com/photo-1556157382-97eda2d62296?w=400&h=400&fit=crop',
      verified: true,
      availability: 'Available Today',
    ),
    Lawyer(
      id: '2',
      name: 'Advocate Ayesha Malik',
      nameUrdu: 'ایڈووکیٹ عائشہ ملک',
      expertise: <String>['Criminal Law', 'Women Rights', 'Family Law'],
      courtLocation: 'Lahore High Court',
      city: 'Lahore',
      rating: 4.9,
      reviewCount: 203,
      experience: 12,
      languages: <String>['Urdu', 'English'],
      phoneNumber: '+92 301 2345678',
      whatsapp: '+923012345678',
      email: 'ayesha.malik@voice2law.pk',
      image:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=400&fit=crop',
      verified: true,
      availability: 'Available Tomorrow',
    ),
    Lawyer(
      id: '3',
      name: 'Advocate Kashif Ahmed',
      nameUrdu: 'ایڈووکیٹ کاشف احمد',
      expertise: <String>['Business Law', 'Corporate Law', 'Taxation'],
      courtLocation: 'Supreme Court of Pakistan',
      city: 'Islamabad',
      rating: 4.7,
      reviewCount: 178,
      experience: 20,
      languages: <String>['Urdu', 'English'],
      phoneNumber: '+92 302 3456789',
      whatsapp: '+923023456789',
      email: 'kashif.ahmed@voice2law.pk',
      image:
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&h=400&fit=crop',
      verified: true,
      availability: 'Available Today',
    ),
    Lawyer(
      id: '4',
      name: 'Advocate Fatima Noor',
      nameUrdu: 'ایڈووکیٹ فاطمہ نور',
      expertise: <String>['Family Law', 'Child Custody', 'Divorce'],
      courtLocation: 'Karachi High Court',
      city: 'Karachi',
      rating: 4.9,
      reviewCount: 245,
      experience: 10,
      languages: <String>['Urdu', 'English', 'Sindhi'],
      phoneNumber: '+92 303 4567890',
      whatsapp: '+923034567890',
      email: 'fatima.noor@voice2law.pk',
      image:
          'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=400&h=400&fit=crop',
      verified: true,
      availability: 'Available Today',
    ),
    Lawyer(
      id: '5',
      name: 'Advocate Hassan Raza',
      nameUrdu: 'ایڈووکیٹ حسن رضا',
      expertise: <String>['Criminal Law', 'Cyber Law', 'Civil Law'],
      courtLocation: 'Rawalpindi District Court',
      city: 'Rawalpindi',
      rating: 4.6,
      reviewCount: 132,
      experience: 8,
      languages: <String>['Urdu', 'English'],
      phoneNumber: '+92 304 5678901',
      whatsapp: '+923045678901',
      email: 'hassan.raza@voice2law.pk',
      image:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop',
      verified: true,
      availability: 'Available Tomorrow',
    ),
    Lawyer(
      id: '6',
      name: 'Advocate Sana Iqbal',
      nameUrdu: 'ایڈووکیٹ ثناء اقبال',
      expertise: <String>['Property Law', 'Real Estate', 'Inheritance'],
      courtLocation: 'Lahore High Court',
      city: 'Lahore',
      rating: 4.8,
      reviewCount: 189,
      experience: 14,
      languages: <String>['Urdu', 'English', 'Punjabi'],
      phoneNumber: '+92 305 6789012',
      whatsapp: '+923056789012',
      email: 'sana.iqbal@voice2law.pk',
      image:
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400&h=400&fit=crop',
      verified: true,
      availability: 'Available Today',
    ),
  ];

  static const List<String> cities = <String>[
    'all',
    'Islamabad',
    'Lahore',
    'Karachi',
    'Rawalpindi',
    'Peshawar',
    'Multan',
  ];

  static const List<String> expertiseAreas = <String>[
    'all',
    'Family Law',
    'Criminal Law',
    'Business Law',
    'Property Law',
    'Civil Law',
    'Corporate Law',
  ];

  // ---------------------------------------------------------------------------
  // Legal topics (`LegalTopicsPage.tsx`)
  // ---------------------------------------------------------------------------
  static const List<LegalTopic> legalTopics = <LegalTopic>[
    LegalTopic(
      title: 'Family Law',
      titleUrdu: 'خاندانی قانون',
      accent: 0xFF1FAA59,
      icon: 'family',
      subtopics: <LegalSubtopic>[
        LegalSubtopic(
          title: 'Marriage & Nikah',
          urdu: 'نکاح اور شادی',
          description: 'Requirements, registration, and legal rights',
        ),
        LegalSubtopic(
          title: 'Divorce & Talaq',
          urdu: 'طلاق',
          description:
              'Procedures, notice requirements, and reconciliation period',
        ),
        LegalSubtopic(
          title: 'Child Custody',
          urdu: 'بچوں کی تحویل',
          description: 'Guardianship rights and custody laws',
        ),
        LegalSubtopic(
          title: 'Maintenance & Nafaqa',
          urdu: 'نفقہ',
          description: 'Financial support obligations',
        ),
      ],
    ),
    LegalTopic(
      title: 'Property Law',
      titleUrdu: 'جائیداد کا قانون',
      accent: 0xFFC5A253,
      icon: 'property',
      subtopics: <LegalSubtopic>[
        LegalSubtopic(
          title: 'Property Transfer',
          urdu: 'جائیداد کی منتقلی',
          description: 'Sale deeds, registration, and documentation',
        ),
        LegalSubtopic(
          title: 'Inheritance & Wirasat',
          urdu: 'وراثت',
          description: 'Islamic inheritance laws and distribution',
        ),
        LegalSubtopic(
          title: 'Rent & Tenancy',
          urdu: 'کرایہ داری',
          description: 'Tenant and landlord rights',
        ),
        LegalSubtopic(
          title: 'Property Disputes',
          urdu: 'جائیداد کے تنازعات',
          description: 'Resolution of property conflicts',
        ),
      ],
    ),
    LegalTopic(
      title: 'Civil Law',
      titleUrdu: 'دیوانی قانون',
      accent: 0xFF1FAA59,
      icon: 'civil',
      subtopics: <LegalSubtopic>[
        LegalSubtopic(
          title: 'Contracts',
          urdu: 'معاہدے',
          description: 'Agreement formation and enforcement',
        ),
        LegalSubtopic(
          title: 'Consumer Rights',
          urdu: 'صارفین کے حقوق',
          description: 'Protection and remedies',
        ),
        LegalSubtopic(
          title: 'Civil Suits',
          urdu: 'دیوانی مقدمات',
          description: 'Filing and procedures',
        ),
        LegalSubtopic(
          title: 'Defamation',
          urdu: 'بہتان',
          description: 'Protection against false statements',
        ),
      ],
    ),
    LegalTopic(
      title: 'Business Law',
      titleUrdu: 'کاروباری قانون',
      accent: 0xFFC5A253,
      icon: 'business',
      subtopics: <LegalSubtopic>[
        LegalSubtopic(
          title: 'Company Registration',
          urdu: 'کمپنی رجسٹریشن',
          description: 'Business formation and licensing',
        ),
        LegalSubtopic(
          title: 'Employment Law',
          urdu: 'ملازمت کا قانون',
          description: 'Worker rights and obligations',
        ),
        LegalSubtopic(
          title: 'Taxation',
          urdu: 'ٹیکس',
          description: 'Business tax requirements',
        ),
        LegalSubtopic(
          title: 'Intellectual Property',
          urdu: 'دانشورانہ ملکیت',
          description: 'Patents, trademarks, copyrights',
        ),
      ],
    ),
    LegalTopic(
      title: 'Criminal Law',
      titleUrdu: 'فوجداری قانون',
      accent: 0xFF1FAA59,
      icon: 'criminal',
      subtopics: <LegalSubtopic>[
        LegalSubtopic(
          title: 'FIR & Complaints',
          urdu: 'ایف آئی آر',
          description: 'Filing police complaints',
        ),
        LegalSubtopic(
          title: 'Bail Procedures',
          urdu: 'ضمانت',
          description: 'Types of bail and procedures',
        ),
        LegalSubtopic(
          title: 'Criminal Trials',
          urdu: 'فوجداری مقدمات',
          description: 'Court proceedings and rights',
        ),
        LegalSubtopic(
          title: 'Victim Rights',
          urdu: 'متاثرین کے حقوق',
          description: 'Protection and compensation',
        ),
      ],
    ),
    LegalTopic(
      title: 'Traffic Law',
      titleUrdu: 'ٹریفک قانون',
      accent: 0xFFC5A253,
      icon: 'traffic',
      subtopics: <LegalSubtopic>[
        LegalSubtopic(
          title: 'License Requirements',
          urdu: 'لائسنس',
          description: 'Driving license procedures',
        ),
        LegalSubtopic(
          title: 'Traffic Violations',
          urdu: 'ٹریفک خلاف ورزیاں',
          description: 'Fines and penalties',
        ),
        LegalSubtopic(
          title: 'Vehicle Registration',
          urdu: 'گاڑی کی رجسٹریشن',
          description: 'Registration and transfer',
        ),
        LegalSubtopic(
          title: 'Accidents',
          urdu: 'حادثات',
          description: 'Legal procedures after accidents',
        ),
      ],
    ),
  ];

  // ---------------------------------------------------------------------------
  // Search page (`SearchPage.tsx`)
  // ---------------------------------------------------------------------------
  static const List<String> trendingSearches = <String>[
    'طلاق کا طریقہ کار',
    'وراثت کی تقسیم',
    'کرایہ دار کے حقوق',
    'نکاح نامہ',
    'FIR کیسے درج کروائیں',
    'جائیداد کی رجسٹری',
  ];

  static const List<String> recentSearches = <String>[
    'Divorce procedure in Pakistan',
    'Property inheritance laws',
    'Tenant rights and eviction',
    'Child custody rules',
  ];

  static const List<SearchResult> mockSearchResults = <SearchResult>[
    SearchResult(
      title: 'Muslim Family Law Ordinance 1961 - Divorce',
      titleUrdu: 'مسلم فیملی لاء آرڈیننس 1961 - طلاق',
      description:
          'Complete guide to divorce procedures under Pakistani law including notice requirements, reconciliation period, and legal documentation.',
      category: 'Family Law',
    ),
    SearchResult(
      title: 'Divorce Notice to Union Council',
      titleUrdu: 'یونین کونسل کو طلاق کا نوٹس',
      description:
          'Learn about the mandatory 90-day notice period and reconciliation procedures as required by law.',
      category: 'Family Law',
    ),
    SearchResult(
      title: 'Rights After Divorce - Maintenance and Mehr',
      titleUrdu: 'طلاق کے بعد حقوق - نفقہ اور مہر',
      description:
          'Understanding financial rights including maintenance, dower (mehr), and child support after divorce.',
      category: 'Family Law',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Assistants (`TextBot.tsx`)
  // ---------------------------------------------------------------------------
  static const List<String> quickQuestions = <String>[
    'What is the procedure for divorce in Pakistan?',
    'What are tenant rights?',
    'How is inheritance divided?',
    'What is the importance of Nikah Nama?',
  ];

  static const String assistantGreeting =
      'Assalam o Alaikum! I am the Voice2Law legal assistant. Ask a legal question in Urdu or English.';

  static const String voicePromptTranscript =
      'Please provide general legal information about divorce procedure in Pakistan.';

  static const String assistantDisclaimer =
      'This is general legal information, not legal advice. Consult a lawyer for specific matters.';

  static const String voiceDisclaimer =
      'This is general legal information, not legal advice. Please consult a lawyer for your specific situation.';

  // ---------------------------------------------------------------------------
  // Contact page (`ContactPage.tsx`)
  // ---------------------------------------------------------------------------
  static const String contactEmail = 'info@voice2law.pk';
  static const String contactPhone = '+92 (300) 1234567';
  static const String contactAddress = 'Islamabad, Pakistan';
  static const String footerEmail = 'voice2law@example.com';
  static const String footerPhone = '+92 XXX XXXXXXX';
  static const String footerAddress = 'University Campus, Pakistan';

  static const List<FaqData> faqs = <FaqData>[
    FaqData(
      question: 'Is Voice2Law free to use?',
      questionUrdu: 'کیا Voice2Law استعمال کرنا مفت ہے؟',
      answer:
          'Yes, Voice2Law is completely free for all users. Our mission is to make legal information accessible to everyone.',
    ),
    FaqData(
      question: 'Can I get legal advice from Voice2Law?',
      questionUrdu: 'کیا میں Voice2Law سے قانونی مشورہ حاصل کر سکتا ہوں؟',
      answer:
          'Voice2Law provides legal information, not legal advice. For specific legal matters, please consult a qualified lawyer.',
    ),
    FaqData(
      question: 'Which languages are supported?',
      questionUrdu: 'کون سی زبانیں معاون ہیں؟',
      answer:
          'Currently, Voice2Law supports Urdu and English. We plan to add more regional languages in the future.',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Uploaded Urdu documents (`LegalTopicsPage.tsx` fallback)
  // ---------------------------------------------------------------------------
  static const List<UrduDocument> sampleDocuments = <UrduDocument>[
    UrduDocument(
      id: 'doc-1',
      title: 'Muslim Family Laws Ordinance 1961 (Urdu)',
      titleUrdu: 'مسلم فیملی لاز آرڈیننس 1961',
      category: 'Family Law',
      description: 'Complete Urdu translation of the family law ordinance.',
      descriptionUrdu: 'خاندانی قانون کے آرڈیننس کا مکمل اردو ترجمہ',
      fileName: 'family-law-1961-urdu.pdf',
      fileSize: '1.24 MB',
      uploadDate: '2024-11-02',
      status: 'published',
    ),
    UrduDocument(
      id: 'doc-2',
      title: 'Rent Restriction Act Summary (Urdu)',
      titleUrdu: 'کرایہ داری ایکٹ کا خلاصہ',
      category: 'Property Law',
      description: 'Tenant and landlord rights explained in simple Urdu.',
      descriptionUrdu: 'کرایہ دار اور مالک کے حقوق آسان اردو میں',
      fileName: 'rent-restriction-act-urdu.pdf',
      fileSize: '860 KB',
      uploadDate: '2024-11-18',
      status: 'published',
    ),
    UrduDocument(
      id: 'doc-3',
      title: 'FIR Filing Guide (Urdu)',
      titleUrdu: 'ایف آئی آر درج کرنے کی رہنمائی',
      category: 'Criminal Law',
      description:
          'Step by step procedure to register an FIR at a police station.',
      descriptionUrdu: 'تھانے میں ایف آئی آر درج کرنے کا مکمل طریقہ',
      fileName: 'fir-guide-urdu.pdf',
      fileSize: '540 KB',
      uploadDate: '2024-12-01',
      status: 'published',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Admin panel demo data (`AdminDashboard.tsx`, `LegalKnowledgeBase.tsx`, …)
  // ---------------------------------------------------------------------------
  static const Map<String, num> demoMetrics = <String, num>{
    'totalQueries': 12847,
    'voiceQueries': 7234,
    'textQueries': 5613,
    'activeUsers': 3892,
    'flaggedQueries': 128,
    'resolvedQueries': 11890,
    'lawyers': 6,
    'documents': 3,
    'avgConfidence': 86,
  };

  static const Map<String, String> demoMetricChanges = <String, String>{
    'totalQueries': '+12.5%',
    'voiceQueries': '+8.3%',
    'textQueries': '+16.2%',
    'activeUsers': '-2.1%',
  };

  static const List<WeekPoint> weeklyUsage = <WeekPoint>[
    WeekPoint('Mon', 850, 620),
    WeekPoint('Tue', 920, 680),
    WeekPoint('Wed', 1050, 720),
    WeekPoint('Thu', 980, 790),
    WeekPoint('Fri', 1150, 850),
    WeekPoint('Sat', 890, 680),
    WeekPoint('Sun', 760, 590),
  ];

  static const List<InfoCardData> topicShare = <InfoCardData>[
    InfoCardData(
      icon: Icons.people_outline,
      title: 'Family Law',
      description: '',
      badge: '2847',
      accent: 0xFF1FAA59,
      accentEnd: 0xFF1FAA59,
    ),
    InfoCardData(
      icon: Icons.home_outlined,
      title: 'Property Law',
      description: '',
      badge: '2234',
      accent: 0xFFC5A253,
      accentEnd: 0xFFC5A253,
    ),
    InfoCardData(
      icon: Icons.gavel,
      title: 'Criminal Law',
      description: '',
      badge: '1876',
      accent: 0xFF0B3D2E,
      accentEnd: 0xFF0B3D2E,
    ),
    InfoCardData(
      icon: Icons.business_center_outlined,
      title: 'Business Law',
      description: '',
      badge: '1456',
      accent: 0xFF60A5FA,
      accentEnd: 0xFF60A5FA,
    ),
    InfoCardData(
      icon: Icons.more_horiz,
      title: 'Other',
      description: '',
      badge: '1234',
      accent: 0xFFA78BFA,
      accentEnd: 0xFFA78BFA,
    ),
  ];

  static const List<LegalEntry> sampleKnowledge = <LegalEntry>[
    LegalEntry(
      id: 'kb-1',
      category: 'Family Law',
      section: 'Muslim Family Laws Ordinance 1961, Section 7',
      urduSummary: 'طلاق کے نوٹس کا طریقہ اور ثالثی کونسل کا کردار',
      englishSummary:
          'Divorce notice must be sent to the Union Council chairman; a 90 day reconciliation process follows.',
      status: 'approved',
      lastUpdated: '2024-12-08',
    ),
    LegalEntry(
      id: 'kb-2',
      category: 'Property Law',
      section: 'Transfer of Property Act 1882, Section 54',
      urduSummary: 'جائیداد کی فروخت اور رجسٹریشن کی شرائط',
      englishSummary:
          'Sale of immovable property requires a registered instrument for value above 100 rupees.',
      status: 'approved',
      lastUpdated: '2024-12-06',
    ),
    LegalEntry(
      id: 'kb-3',
      category: 'Criminal Law',
      section: 'Criminal Procedure Code, Section 154',
      urduSummary: 'ایف آئی آر درج کرنے کا طریقہ کار',
      englishSummary:
          'Information about a cognizable offence is recorded in writing by the officer in charge.',
      status: 'review',
      lastUpdated: '2024-12-02',
    ),
    LegalEntry(
      id: 'kb-4',
      category: 'Property Law',
      section: 'Rent Restriction Act',
      urduSummary: 'کرایہ دار اور مالک کے حقوق',
      englishSummary:
          'Protection of tenants against unfair eviction and unreasonable rent increases.',
      status: 'pending',
      lastUpdated: '2024-11-28',
    ),
  ];

  static const List<QueryRecord> sampleQueries = <QueryRecord>[
    QueryRecord(
      id: 'q-1',
      userName: 'Ahmed Raza',
      userEmail: 'ahmed@example.com',
      queryType: 'voice',
      category: 'Family Law',
      question: 'طلاق کا طریقہ کار کیا ہے؟',
      aiResponse:
          'Under the Muslim Family Laws Ordinance 1961 a divorce notice must be sent to the Union Council chairman, followed by a 90 day reconciliation period.',
      status: 'resolved',
      timestamp: '2024-12-09T08:40:00.000Z',
      confidence: 92,
    ),
    QueryRecord(
      id: 'q-2',
      userName: 'Sadia Khan',
      userEmail: 'sadia@example.com',
      queryType: 'text',
      category: 'Property Law',
      question: 'How is inheritance divided among children?',
      aiResponse:
          'Under Islamic law a son receives twice the share of a daughter, and the estate is distributed after debts and funeral expenses.',
      status: 'pending',
      timestamp: '2024-12-09T07:15:00.000Z',
      confidence: 84,
    ),
    QueryRecord(
      id: 'q-3',
      userName: 'Bilal Hussain',
      userEmail: 'bilal@example.com',
      queryType: 'voice',
      category: 'Criminal Law',
      question: 'ضمانت کیسے حاصل کریں؟',
      aiResponse:
          'Bail can be applied for through a surety bond before the relevant court; bailable and non-bailable offences have different procedures.',
      status: 'flagged',
      timestamp: '2024-12-08T18:05:00.000Z',
      confidence: 61,
    ),
    QueryRecord(
      id: 'q-4',
      userName: 'Hina Aslam',
      userEmail: 'hina@example.com',
      queryType: 'text',
      category: 'Family Law',
      question: 'What is the importance of Nikah Nama?',
      aiResponse:
          'The Nikah Nama is the legal marriage contract registered with the Union Council and protects the rights of both spouses.',
      status: 'resolved',
      timestamp: '2024-12-08T12:30:00.000Z',
      confidence: 90,
    ),
  ];
}
