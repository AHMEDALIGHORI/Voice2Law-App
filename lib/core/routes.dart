/// Named routes. The public paths are identical to the website router
/// (`src/App.tsx`), including the obscure protected admin path.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String ask = '/ask';
  static const String voice = '/voice';
  static const String text = '/text';
  static const String findLawyers = '/find-lawyers';
  static const String lawyerDetail = '/lawyer';
  static const String legalTopics = '/legal-topics';
  static const String search = '/search';
  static const String about = '/about';
  static const String howItWorks = '/how-it-works';
  static const String contact = '/contact';
  static const String settings = '/settings';
  static const String statuteLibrary = '/statute-library';

  // AI feature routes
  static const String docGenerator = '/doc-generator';
  static const String docScanner = '/doc-scanner';
  static const String deadlineCalc = '/deadline-calc';
  static const String caseIntake = '/case-intake';
  static const String casePrediction = '/case-prediction';
  static const String rightsChecker = '/rights-checker';
  static const String smartReminders = '/smart-reminders';
  static const String precedentSearch = '/precedent-search';
  static const String termExplainer = '/term-explainer';
  static const String statuteAiSearch = '/statute-ai-search';
  static const String emergencySos = '/emergency-sos';
  static const String scamDetector = '/scam-detector';
  static const String mediation = '/mediation';
  static const String aiFeaturesHub = '/ai-tools';

  // Advanced features (hackathon additions)
  static const String documentExplainer = '/document-explainer';
  static const String rightsScenarios = '/rights-scenarios';

  // Admin (mirrors /admin-login and /adminvoice2law001)
  static const String adminLogin = '/admin-login';
  static const String adminPanel = '/adminvoice2law001';
  static const String legacyAdmin = '/admin';
}
