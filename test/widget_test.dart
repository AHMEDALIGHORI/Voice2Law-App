import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice2law_app/app.dart';
import 'package:voice2law_app/core/app_config.dart';
import 'package:voice2law_app/core/app_scope.dart';
import 'package:voice2law_app/core/auth_controller.dart';
import 'package:voice2law_app/data/content_data.dart';
import 'package:voice2law_app/models/models.dart';
import 'package:voice2law_app/services/api_service.dart';
import 'package:voice2law_app/services/local_legal_brain.dart';
import 'package:voice2law_app/services/speech_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('home screen renders the Voice2Law hero and the ask buttons', (
    WidgetTester tester,
  ) async {
    final AppConfig config = AppConfig.instance;
    final ApiService api = ApiService(config);

    await tester.pumpWidget(
      Voice2LawApp(
        services: AppServices(
          config: config,
          api: api,
          auth: AuthController(api),
          speech: SpeechService(),
        ),
      ),
    );
    // The hero animates forever, so pump a fixed number of frames instead of
    // calling pumpAndSettle().
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Voice2Law'), findsWidgets);
    expect(find.text('Ask by Voice'), findsOneWidget);
    expect(find.text('Ask by Text'), findsOneWidget);
    expect(find.text('Start with your question'), findsOneWidget);
    // The home page is a lazy list, so only the hero is built on the first frame.
    expect(find.text('Home'), findsOneWidget); // bottom navigation label
  });

  test('models parse the website JSON payloads', () {
    final Lawyer lawyer = Lawyer.fromJson(<String, dynamic>{
      'id': '2',
      'name': 'Advocate Ayesha Malik',
      'nameUrdu': 'ایڈووکیٹ عائشہ ملک',
      'expertise': <String>['Family Law'],
      'city': 'Lahore',
      'rating': 4.9,
      'reviewCount': 203,
      'verified': true,
    });

    expect(lawyer.city, 'Lahore');
    expect(lawyer.expertise, contains('Family Law'));
    expect(lawyer.verified, isTrue);
    expect(lawyer.initials, 'AM');
  });

  test('offline legal brain answers divorce questions in Urdu and English', () {
    final AiAnswer answer = LocalLegalBrain.answer(
      'How does talaq work in Pakistan?',
    );

    expect(answer.category, 'Family Law');
    expect(answer.answer, contains('Union Council'));
    expect(answer.answerUrdu, isNotEmpty);
    expect(answer.offline, isTrue);
  });
  test(
    'enhanced legal brain produces Dual-Perspective answers with roadmaps and checklists',
    () {
      final AiAnswer answer = LocalLegalBrain.answer(
        'What is the procedure for khula or divorce?',
      );

      expect(answer.category, 'Family Law');
      expect(answer.courtModeAnswer, isNotEmpty);
      expect(answer.courtModeAnswerUrdu, isNotEmpty);
      expect(answer.empatheticOpening, isNotEmpty);
      expect(answer.roadmap, isNotEmpty);
      expect(answer.roadmap.length, greaterThanOrEqualTo(2));
      expect(answer.documents, isNotEmpty);
      expect(answer.statutes, isNotEmpty);
      expect(answer.suggestedEmergencyHelpline, contains('1099'));
    },
  );

  test('content data ships the same topics as the website', () {
    expect(ContentData.legalTopics, isNotEmpty);
    expect(ContentData.legalTopics.first.title, 'Family Law');
    expect(ContentData.defaultLawyers.length, greaterThanOrEqualTo(6));
  });
}
