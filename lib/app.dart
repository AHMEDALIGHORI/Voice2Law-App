import 'package:flutter/material.dart';

import 'core/app_scope.dart';
import 'core/routes.dart';
import 'models/models.dart';
import 'screens/about_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'screens/app_shell.dart';
import 'screens/contact_screen.dart';
import 'screens/document_explainer_screen.dart';
import 'screens/how_it_works_screen.dart';
import 'screens/lawyer_detail_screen.dart';
import 'screens/rights_scenarios_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statute_library_screen.dart';
import 'screens/text_assistant_screen.dart';
import 'screens/voice_assistant_screen.dart';
import 'screens/ai_feature_screens.dart';
import 'theme/app_theme.dart';

/// Root widget: owns [AppScope] and maps the website routes to Flutter ones.
class Voice2LawApp extends StatelessWidget {
  const Voice2LawApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: MaterialApp(
        title: 'Voice2Law',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.home,
        onGenerateRoute: _onGenerateRoute,
        builder: (context, child) => TickerMode(
          enabled: !MediaQuery.disableAnimationsOf(context),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const AppShell(),
        );
      case AppRoutes.ask:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const AppShell(),
        );
      case AppRoutes.lawyerDetail:
        final Object? argument = settings.arguments;
        final Lawyer lawyer = argument is Lawyer
            ? argument
            : ContentDataFallback.lawyer;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => LawyerDetailScreen(lawyer: lawyer),
        );
      case AppRoutes.search:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const SearchScreen(),
        );
      case AppRoutes.about:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const AboutScreen(),
        );
      case AppRoutes.howItWorks:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const HowItWorksScreen(),
        );
      case AppRoutes.contact:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const ContactScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const SettingsScreen(),
        );
      case AppRoutes.statuteLibrary:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const StatuteLibraryScreen(),
        );
      case AppRoutes.adminLogin:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const AdminLoginScreen(),
        );
      case AppRoutes.adminPanel:
      case AppRoutes.legacyAdmin:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const AdminPanelScreen(),
        );
      // Voice / text assistants are opened as full screen dialogs.
      case '/voice':
        return MaterialPageRoute<void>(
          fullscreenDialog: true,
          settings: settings,
          builder: (BuildContext context) => const VoiceAssistantScreen(),
        );
      case '/text':
        return MaterialPageRoute<void>(
          fullscreenDialog: true,
          settings: settings,
          builder: (BuildContext context) => const TextAssistantScreen(),
        );
      // AI feature routes
      case AppRoutes.docGenerator:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DocGeneratorScreen(),
        );
      case AppRoutes.docScanner:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DocScannerScreen(),
        );
      case AppRoutes.deadlineCalc:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DeadlineCalcScreen(),
        );
      case AppRoutes.caseIntake:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CaseIntakeScreen(),
        );
      case AppRoutes.casePrediction:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CasePredictionScreen(),
        );
      case AppRoutes.rightsChecker:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RightsCheckerScreen(),
        );
      case AppRoutes.smartReminders:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SmartRemindersScreen(),
        );
      case AppRoutes.precedentSearch:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const PrecedentSearchScreen(),
        );
      case AppRoutes.termExplainer:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const TermExplainerScreen(),
        );
      case AppRoutes.statuteAiSearch:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const StatuteAiSearchScreen(),
        );
      case AppRoutes.emergencySos:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const EmergencySosScreen(),
        );
      case AppRoutes.scamDetector:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ScamDetectorScreen(),
        );
      case AppRoutes.mediation:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MediationScreen(),
        );
      case AppRoutes.aiFeaturesHub:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AiFeaturesHubScreen(),
        );
      case AppRoutes.documentExplainer:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DocumentExplainerScreen(),
        );
      case AppRoutes.rightsScenarios:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RightsScenariosScreen(),
        );
      default:
        // The website redirects unknown routes to "/" – do the same.
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const AppShell(),
        );
    }
  }
}

/// Placeholder used when `/lawyer` is opened without an argument.
class ContentDataFallback {
  const ContentDataFallback._();

  static const Lawyer lawyer = Lawyer(
    id: '',
    name: 'Voice2Law Lawyer',
    courtLocation: 'Voice2Law Directory',
    city: 'Islamabad',
    availability: 'Available Today',
  );
}
