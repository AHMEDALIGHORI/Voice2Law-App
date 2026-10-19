import 'package:flutter/material.dart';

/// Static content + fallback data for the app.
///
/// The website served these values from mock data inside each React page
/// (`FindLawyersPage.tsx`, `LegalTopicsPage.tsx`, `SearchPage.tsx`, …) and used
/// them whenever the REST API was unreachable. The mobile app keeps the exact
/// same content so both clients show identical information.
class InfoCardData {
  const InfoCardData({
    required this.icon,
    required this.title,
    this.titleUrdu = '',
    required this.description,
    this.accent = 0xFF1FAA59,
    this.accentEnd = 0xFF0B3D2E,
    this.badge = '',
    this.items = const <String>[],
  });

  final IconData icon;
  final String title;
  final String titleUrdu;
  final String description;
  final int accent;
  final int accentEnd;
  final String badge;
  final List<String> items;
}

class TeamMemberData {
  const TeamMemberData({
    required this.name,
    required this.role,
    required this.rollNo,
    required this.specialty,
    required this.imageAsset,
  });

  final String name;
  final String role;
  final String rollNo;
  final String specialty;
  final String imageAsset;
}

class FallbackData {
  const FallbackData._();

  // ---------------------------------------------------------------------------
  // Hero (`Hero.tsx`)
  // ---------------------------------------------------------------------------
  static const String heroTagline = 'AI-Powered Legal Assistant';
  static const String heroTitle = 'Voice2Law';
  static const String heroTitleUrdu = 'قانونی معلومات کا اردو اسسٹنٹ';
  static const String heroSubtitle =
      'Get instant legal information in Urdu using voice or text. Simplifying Pakistani law for everyone.';

  static const List<InfoCardData> heroOrbitWords = <InfoCardData>[
    InfoCardData(icon: Icons.balance, title: 'قانون', description: 'Top'),
    InfoCardData(
      icon: Icons.gavel,
      title: 'انصاف',
      description: 'Upper Right',
      accent: 0xFFC5A253,
      accentEnd: 0xFFD4B76E,
    ),
    InfoCardData(
      icon: Icons.menu_book,
      title: 'معلومات',
      description: 'Lower Right',
    ),
    InfoCardData(
      icon: Icons.volunteer_activism,
      title: 'مدد',
      description: 'Lower Left',
      accent: 0xFFC5A253,
      accentEnd: 0xFFD4B76E,
    ),
    InfoCardData(
      icon: Icons.verified_user,
      title: 'حقوق',
      description: 'Upper Left',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Home sections
  // ---------------------------------------------------------------------------
  static const List<InfoCardData> aboutCards = <InfoCardData>[
    InfoCardData(
      icon: Icons.error_outline,
      title: 'Problem Statement',
      titleUrdu: 'مسئلہ',
      description:
          'Limited access to legal information in Urdu creates barriers for millions. Legal jargon and language complexity prevent ordinary citizens from understanding their rights.',
    ),
    InfoCardData(
      icon: Icons.lightbulb_outline,
      title: 'Proposed Solution',
      titleUrdu: 'حل',
      description:
          'Voice2Law provides an AI-powered assistant that converts voice queries in Urdu to simple, understandable legal information, making law accessible to everyone.',
      accent: 0xFF1FAA59,
      accentEnd: 0xFF0B3D2E,
    ),
    InfoCardData(
      icon: Icons.track_changes,
      title: 'Scope',
      titleUrdu: 'دائرہ کار',
      description:
          'Focused on Family Law, Rent/Property Law, and Criminal Law basics. Designed specifically for the Pakistani legal system with Urdu language support.',
      accent: 0xFFC5A253,
      accentEnd: 0xFFD4B76E,
    ),
    InfoCardData(
      icon: Icons.hub,
      title: 'Technologies',
      titleUrdu: 'ٹیکنالوجی',
      description:
          'Built with React, Node.js, MongoDB, Whisper AI for speech recognition, and advanced NLP models for understanding Urdu legal queries.',
      accent: 0xFF0B3D2E,
      accentEnd: 0xFFC5A253,
    ),
  ];

  static const List<InfoCardData> howItWorksSteps = <InfoCardData>[
    InfoCardData(
      icon: Icons.mic,
      badge: '01',
      title: 'Speak in Urdu',
      titleUrdu: 'اردو میں بولیں',
      description:
          'Use your voice to ask legal questions in natural Urdu language',
    ),
    InfoCardData(
      icon: Icons.description_outlined,
      badge: '02',
      title: 'AI Speech-to-Text',
      titleUrdu: 'تقریر سے متن',
      description: 'Whisper AI converts your voice to text with high accuracy',
      accent: 0xFF0B3D2E,
      accentEnd: 0xFF0B3D2E,
    ),
    InfoCardData(
      icon: Icons.storage,
      badge: '03',
      title: 'NLP & Legal Database',
      titleUrdu: 'قانونی ڈیٹابیس',
      description:
          'Advanced NLP searches the comprehensive legal knowledge base',
      accent: 0xFFC5A253,
      accentEnd: 0xFFC5A253,
    ),
    InfoCardData(
      icon: Icons.forum,
      badge: '04',
      title: 'Clear Urdu Answers',
      titleUrdu: 'واضح جوابات',
      description:
          'Get simplified legal information in easy-to-understand Urdu',
    ),
  ];

  static const List<InfoCardData> features = <InfoCardData>[
    InfoCardData(
      icon: Icons.mic,
      title: 'Urdu Voice Recognition',
      titleUrdu: 'اردو آواز کی شناخت',
      description:
          'Advanced speech-to-text powered by Whisper AI, optimized for Urdu language with high accuracy.',
    ),
    InfoCardData(
      icon: Icons.storage,
      title: 'Legal Knowledge Base',
      titleUrdu: 'قانونی علم کا ذخیرہ',
      description:
          'Comprehensive database covering Pakistani laws, regulations, and legal procedures.',
      accent: 0xFF0B3D2E,
      accentEnd: 0xFF1FAA59,
    ),
    InfoCardData(
      icon: Icons.psychology,
      title: 'NLP Understanding',
      titleUrdu: 'زبان کی سمجھ',
      description:
          'Natural language processing to understand context and intent behind your legal questions.',
      accent: 0xFFC5A253,
      accentEnd: 0xFFD4B76E,
    ),
    InfoCardData(
      icon: Icons.balance,
      title: 'Family Law',
      titleUrdu: 'خاندانی قانون',
      description:
          'Expert guidance on marriage, divorce, inheritance, custody, and family-related legal matters.',
      accent: 0xFF1FAA59,
      accentEnd: 0xFFC5A253,
    ),
    InfoCardData(
      icon: Icons.people_outline,
      title: 'Rent & Property Law',
      titleUrdu: 'کرایہ اور جائیداد',
      description:
          'Information on rental agreements, property rights, tenant laws, and real estate regulations.',
      accent: 0xFF0B3D2E,
      accentEnd: 0xFFC5A253,
    ),
    InfoCardData(
      icon: Icons.cloud_outlined,
      title: 'Cloud Hosted',
      titleUrdu: 'کلاؤڈ پر محفوظ',
      description:
          'Deployed on Render and Firebase for reliable, scalable, and fast access anytime, anywhere.',
      accent: 0xFFC5A253,
      accentEnd: 0xFF1FAA59,
    ),
  ];

  static const List<InfoCardData> techStack = <InfoCardData>[
    InfoCardData(
      icon: Icons.code,
      title: 'Frontend',
      description: 'Client applications',
      items: <String>['React.js', 'Tailwind CSS', 'TypeScript', 'Flutter'],
    ),
    InfoCardData(
      icon: Icons.dns_outlined,
      title: 'Backend',
      description: 'REST services',
      items: <String>['Node.js', 'Express.js', 'RESTful API'],
      accent: 0xFF0B3D2E,
      accentEnd: 0xFF0B3D2E,
    ),
    InfoCardData(
      icon: Icons.storage,
      title: 'Database',
      description: 'Persistent storage',
      items: <String>['MongoDB', 'PostgreSQL', 'Vector DB'],
      accent: 0xFFC5A253,
      accentEnd: 0xFFC5A253,
    ),
    InfoCardData(
      icon: Icons.psychology,
      title: 'AI & NLP',
      description: 'Language intelligence',
      items: <String>['HuggingFace', 'Transformers', 'Urdu NLP'],
    ),
    InfoCardData(
      icon: Icons.mic,
      title: 'Speech',
      description: 'Voice pipeline',
      items: <String>['Whisper AI', 'Speech-to-Text', 'Audio Processing'],
      accent: 0xFF0B3D2E,
      accentEnd: 0xFF0B3D2E,
    ),
    InfoCardData(
      icon: Icons.cloud_outlined,
      title: 'Deployment',
      description: 'Hosting & CI/CD',
      items: <String>['Render', 'Firebase', 'CI/CD'],
      accent: 0xFFC5A253,
      accentEnd: 0xFFC5A253,
    ),
  ];

  static const List<String> techBadges = <String>[
    'REST API',
    'JWT Auth',
    'Docker',
    'Git',
    'Postman',
  ];

  static const List<InfoCardData> sdgGoals = <InfoCardData>[
    InfoCardData(
      icon: Icons.school_outlined,
      badge: '4',
      title: 'Quality Education',
      titleUrdu: 'معیاری تعلیم',
      description:
          'Providing accessible legal education to Urdu-speaking communities',
      accent: 0xFFC5192D,
      accentEnd: 0xFFC5192D,
    ),
    InfoCardData(
      icon: Icons.people_outline,
      badge: '10',
      title: 'Reduced Inequalities',
      titleUrdu: 'عدم مساوات میں کمی',
      description:
          'Bridging the legal knowledge gap for underserved populations',
      accent: 0xFFDD1367,
      accentEnd: 0xFFDD1367,
    ),
    InfoCardData(
      icon: Icons.balance,
      badge: '16',
      title: 'Peace, Justice & Institutions',
      titleUrdu: 'امن، انصاف اور ادارے',
      description: 'Promoting access to justice and legal awareness for all',
      accent: 0xFF00689D,
      accentEnd: 0xFF00689D,
    ),
    InfoCardData(
      icon: Icons.track_changes,
      badge: '9',
      title: 'Industry & Innovation',
      titleUrdu: 'صنعت اور جدت',
      description: 'Leveraging AI and technology for legal innovation',
      accent: 0xFFFD6925,
      accentEnd: 0xFFFD6925,
    ),
  ];

  static const TeamMemberData supervisor = TeamMemberData(
    name: 'ABDUL WAHAB KHAN',
    role: 'Project Supervisor',
    rollNo: 'MS, Computer Science',
    specialty: 'Department of FEST',
    imageAsset: '',
  );

  static const List<TeamMemberData> team = <TeamMemberData>[
    TeamMemberData(
      name: 'AHMED ALI GHORI',
      role: 'AI Engineer',
      rollNo: 'Reg Id: BS(SE) 60117',
      specialty: 'AI / NLP Engineer',
      imageAsset: 'assets/images/ali.jpeg',
    ),
  ];
}
