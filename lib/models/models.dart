// Dart mirrors of the TypeScript interfaces declared in the Voice2Law web app
// (`src/lib/api.ts`). The JSON keys intentionally match the REST backend /
// Firebase Functions payloads so the same API can serve both clients.

String asString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

List<String> asStringList(dynamic value) {
  if (value is List) {
    return value.map((dynamic item) => item.toString()).toList(growable: false);
  }
  return const <String>[];
}

double asDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int asInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool asBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
  });

  final String id;
  final String email;
  final String role; // 'admin' | 'user'
  final String name;

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: asString(json['id']),
      email: asString(json['email']),
      role: asString(json['role'], 'user'),
      name: asString(json['name'], 'Voice2Law Admin'),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'email': email,
    'role': role,
    'name': name,
  };
}

class Lawyer {
  const Lawyer({
    required this.id,
    required this.name,
    this.nameUrdu = '',
    this.expertise = const <String>[],
    this.courtLocation = '',
    this.city = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.experience = 0,
    this.languages = const <String>[],
    this.phoneNumber = '',
    this.whatsapp = '',
    this.email = '',
    this.image = '',
    this.verified = false,
    this.availability = 'Available Today',
    this.barCouncilNo = '',
  });

  final String id;
  final String name;
  final String nameUrdu;
  final List<String> expertise;
  final String courtLocation;
  final String city;
  final double rating;
  final int reviewCount;
  final int experience;
  final List<String> languages;
  final String phoneNumber;
  final String whatsapp;
  final String email;
  final String image;
  final bool verified;
  final String availability;
  final String barCouncilNo;

  String get initials {
    final List<String> parts = name
        .replaceAll('Advocate', '')
        .trim()
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'V2L';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    return Lawyer(
      id: asString(json['id']),
      name: asString(json['name'], 'Advocate'),
      nameUrdu: asString(json['nameUrdu']),
      expertise: asStringList(json['expertise']),
      courtLocation: asString(json['courtLocation']),
      city: asString(json['city']),
      rating: asDouble(json['rating']),
      reviewCount: asInt(json['reviewCount']),
      experience: asInt(json['experience']),
      languages: asStringList(json['languages']),
      phoneNumber: asString(json['phoneNumber']),
      whatsapp: asString(json['whatsapp']),
      email: asString(json['email']),
      image: asString(json['image']),
      verified: asBool(json['verified']),
      availability: asString(json['availability'], 'Available Today'),
      barCouncilNo: asString(json['barCouncilNo']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'nameUrdu': nameUrdu,
    'expertise': expertise,
    'courtLocation': courtLocation,
    'city': city,
    'rating': rating,
    'reviewCount': reviewCount,
    'experience': experience,
    'languages': languages,
    'phoneNumber': phoneNumber,
    'whatsapp': whatsapp,
    'email': email,
    'image': image,
    'verified': verified,
    'availability': availability,
    'barCouncilNo': barCouncilNo,
  };
}

class LegalEntry {
  const LegalEntry({
    required this.id,
    required this.category,
    required this.section,
    this.urduSummary = '',
    this.englishSummary = '',
    this.status = 'pending',
    this.lastUpdated = '',
  });

  final String id;
  final String category;
  final String section;
  final String urduSummary;
  final String englishSummary;
  final String status; // approved | pending | review
  final String lastUpdated;

  factory LegalEntry.fromJson(Map<String, dynamic> json) {
    return LegalEntry(
      id: asString(json['id']),
      category: asString(json['category'], 'General Law'),
      section: asString(json['section']),
      urduSummary: asString(json['urduSummary']),
      englishSummary: asString(json['englishSummary']),
      status: asString(json['status'], 'pending'),
      lastUpdated: asString(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'category': category,
    'section': section,
    'urduSummary': urduSummary,
    'englishSummary': englishSummary,
    'status': status,
    'lastUpdated': lastUpdated,
  };
}

class UrduDocument {
  const UrduDocument({
    required this.id,
    required this.title,
    this.titleUrdu = '',
    this.category = 'General',
    this.description = '',
    this.descriptionUrdu = '',
    this.fileName = '',
    this.fileSize = '',
    this.uploadDate = '',
    this.status = 'pending',
    this.content = '',
    this.fileUrl = '',
    this.storagePath = '',
  });

  final String id;
  final String title;
  final String titleUrdu;
  final String category;
  final String description;
  final String descriptionUrdu;
  final String fileName;
  final String fileSize;
  final String uploadDate;
  final String status; // published | draft | pending
  final String content;
  final String fileUrl;
  final String storagePath;

  factory UrduDocument.fromJson(Map<String, dynamic> json) {
    return UrduDocument(
      id: asString(json['id']),
      title: asString(json['title'], 'Untitled document'),
      titleUrdu: asString(json['titleUrdu']),
      category: asString(json['category'], 'General'),
      description: asString(json['description']),
      descriptionUrdu: asString(json['descriptionUrdu']),
      fileName: asString(json['fileName']),
      fileSize: asString(json['fileSize']),
      uploadDate: asString(json['uploadDate']),
      status: asString(json['status'], 'pending'),
      content: asString(json['content']),
      fileUrl: asString(json['fileUrl']),
      storagePath: asString(json['storagePath']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'titleUrdu': titleUrdu,
    'category': category,
    'description': description,
    'descriptionUrdu': descriptionUrdu,
    'fileName': fileName,
    'fileSize': fileSize,
    'uploadDate': uploadDate,
    'status': status,
    'content': content,
    'fileUrl': fileUrl,
    'storagePath': storagePath,
  };
}

class QueryRecord {
  const QueryRecord({
    required this.id,
    this.userName = 'Anonymous',
    this.userEmail = '',
    this.queryType = 'text',
    this.category = 'General Law',
    this.question = '',
    this.questionUrdu = '',
    this.aiResponse = '',
    this.aiResponseUrdu = '',
    this.rating = 0,
    this.feedback = '',
    this.status = 'pending',
    this.timestamp = '',
    this.confidence = 0,
  });

  final String id;
  final String userName;
  final String userEmail;
  final String queryType; // voice | text
  final String category;
  final String question;
  final String questionUrdu;
  final String aiResponse;
  final String aiResponseUrdu;
  final int rating;
  final String feedback;
  final String status; // pending | resolved | flagged
  final String timestamp;
  final double confidence;

  factory QueryRecord.fromJson(Map<String, dynamic> json) {
    return QueryRecord(
      id: asString(json['id']),
      userName: asString(json['userName'], 'Anonymous'),
      userEmail: asString(json['userEmail']),
      queryType: asString(json['queryType'], 'text'),
      category: asString(json['category'], 'General Law'),
      question: asString(json['question']),
      questionUrdu: asString(json['questionUrdu']),
      aiResponse: asString(json['aiResponse']),
      aiResponseUrdu: asString(json['aiResponseUrdu']),
      rating: asInt(json['rating']),
      feedback: asString(json['feedback']),
      status: asString(json['status'], 'pending'),
      timestamp: asString(json['timestamp']),
      confidence: asDouble(json['confidence']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userName': userName,
    'userEmail': userEmail,
    'queryType': queryType,
    'category': category,
    'question': question,
    'questionUrdu': questionUrdu,
    'aiResponse': aiResponse,
    'aiResponseUrdu': aiResponseUrdu,
    'rating': rating,
    'feedback': feedback,
    'status': status,
    'timestamp': timestamp,
    'confidence': confidence,
  };
}

class SystemSettingsData {
  const SystemSettingsData({
    this.siteName = 'Voice2Law',
    this.siteNameUrdu = '',
    this.maintenanceMode = false,
    this.allowRegistration = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.sessionTimeout = 30,
    this.maxLoginAttempts = 5,
    this.backupFrequency = 'daily',
    this.adminEmail = 'admin@voice2law.pk',
    this.supportEmail = 'support@voice2law.pk',
    this.aiConfidenceThreshold = 70,
    this.urduAccuracyThreshold = 85,
  });

  final String siteName;
  final String siteNameUrdu;
  final bool maintenanceMode;
  final bool allowRegistration;
  final bool emailNotifications;
  final bool smsNotifications;
  final int sessionTimeout;
  final int maxLoginAttempts;
  final String backupFrequency;
  final String adminEmail;
  final String supportEmail;
  final double aiConfidenceThreshold;
  final double urduAccuracyThreshold;

  factory SystemSettingsData.fromJson(Map<String, dynamic> json) {
    return SystemSettingsData(
      siteName: asString(json['siteName'], 'Voice2Law'),
      siteNameUrdu: asString(json['siteNameUrdu']),
      maintenanceMode: asBool(json['maintenanceMode']),
      allowRegistration: asBool(json['allowRegistration'], true),
      emailNotifications: asBool(json['emailNotifications'], true),
      smsNotifications: asBool(json['smsNotifications']),
      sessionTimeout: asInt(json['sessionTimeout'], 30),
      maxLoginAttempts: asInt(json['maxLoginAttempts'], 5),
      backupFrequency: asString(json['backupFrequency'], 'daily'),
      adminEmail: asString(json['adminEmail'], 'admin@voice2law.pk'),
      supportEmail: asString(json['supportEmail'], 'support@voice2law.pk'),
      aiConfidenceThreshold: asDouble(json['aiConfidenceThreshold'], 70),
      urduAccuracyThreshold: asDouble(json['urduAccuracyThreshold'], 85),
    );
  }

  SystemSettingsData copyWith({
    String? siteName,
    String? siteNameUrdu,
    bool? maintenanceMode,
    bool? allowRegistration,
    bool? emailNotifications,
    bool? smsNotifications,
    int? sessionTimeout,
    int? maxLoginAttempts,
    String? backupFrequency,
    String? adminEmail,
    String? supportEmail,
    double? aiConfidenceThreshold,
    double? urduAccuracyThreshold,
  }) {
    return SystemSettingsData(
      siteName: siteName ?? this.siteName,
      siteNameUrdu: siteNameUrdu ?? this.siteNameUrdu,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      allowRegistration: allowRegistration ?? this.allowRegistration,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      maxLoginAttempts: maxLoginAttempts ?? this.maxLoginAttempts,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      adminEmail: adminEmail ?? this.adminEmail,
      supportEmail: supportEmail ?? this.supportEmail,
      aiConfidenceThreshold:
          aiConfidenceThreshold ?? this.aiConfidenceThreshold,
      urduAccuracyThreshold:
          urduAccuracyThreshold ?? this.urduAccuracyThreshold,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'siteName': siteName,
    'siteNameUrdu': siteNameUrdu,
    'maintenanceMode': maintenanceMode,
    'allowRegistration': allowRegistration,
    'emailNotifications': emailNotifications,
    'smsNotifications': smsNotifications,
    'sessionTimeout': sessionTimeout,
    'maxLoginAttempts': maxLoginAttempts,
    'backupFrequency': backupFrequency,
    'adminEmail': adminEmail,
    'supportEmail': supportEmail,
    'aiConfidenceThreshold': aiConfidenceThreshold,
    'urduAccuracyThreshold': urduAccuracyThreshold,
  };
}

class LegalJourneyStep {
  const LegalJourneyStep({
    required this.stepNumber,
    required this.title,
    required this.titleUrdu,
    required this.description,
    required this.descriptionUrdu,
    this.estimatedTime = '',
    this.estimatedTimeUrdu = '',
    this.courtOrAuthority = '',
    this.courtOrAuthorityUrdu = '',
  });

  final int stepNumber;
  final String title;
  final String titleUrdu;
  final String description;
  final String descriptionUrdu;
  final String estimatedTime;
  final String estimatedTimeUrdu;
  final String courtOrAuthority;
  final String courtOrAuthorityUrdu;

  factory LegalJourneyStep.fromJson(Map<String, dynamic> json) {
    return LegalJourneyStep(
      stepNumber: asInt(json['stepNumber'], 1),
      title: asString(json['title']),
      titleUrdu: asString(json['titleUrdu']),
      description: asString(json['description']),
      descriptionUrdu: asString(json['descriptionUrdu']),
      estimatedTime: asString(json['estimatedTime']),
      estimatedTimeUrdu: asString(json['estimatedTimeUrdu']),
      courtOrAuthority: asString(json['courtOrAuthority']),
      courtOrAuthorityUrdu: asString(json['courtOrAuthorityUrdu']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'stepNumber': stepNumber,
    'title': title,
    'titleUrdu': titleUrdu,
    'description': description,
    'descriptionUrdu': descriptionUrdu,
    'estimatedTime': estimatedTime,
    'estimatedTimeUrdu': estimatedTimeUrdu,
    'courtOrAuthority': courtOrAuthority,
    'courtOrAuthorityUrdu': courtOrAuthorityUrdu,
  };
}

class RequiredDocumentItem {
  const RequiredDocumentItem({
    required this.name,
    required this.nameUrdu,
    required this.isMandatory,
    this.notes = '',
    this.notesUrdu = '',
  });

  final String name;
  final String nameUrdu;
  final bool isMandatory;
  final String notes;
  final String notesUrdu;

  factory RequiredDocumentItem.fromJson(Map<String, dynamic> json) {
    return RequiredDocumentItem(
      name: asString(json['name']),
      nameUrdu: asString(json['nameUrdu']),
      isMandatory: asBool(json['isMandatory'], true),
      notes: asString(json['notes']),
      notesUrdu: asString(json['notesUrdu']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'nameUrdu': nameUrdu,
    'isMandatory': isMandatory,
    'notes': notes,
    'notesUrdu': notesUrdu,
  };
}

class RelevantStatute {
  const RelevantStatute({
    required this.actName,
    required this.actNameUrdu,
    required this.section,
    required this.courtJurisdiction,
    this.citation = '',
    this.sourceLabel = 'Reference to verify · source version unavailable',
    this.sourceExcerpt = '',
  });

  final String actName;
  final String actNameUrdu;
  final String section;
  final String courtJurisdiction;
  final String citation;
  final String sourceLabel;
  final String sourceExcerpt;

  factory RelevantStatute.fromJson(Map<String, dynamic> json) {
    return RelevantStatute(
      actName: asString(json['actName']),
      actNameUrdu: asString(json['actNameUrdu']),
      section: asString(json['section']),
      courtJurisdiction: asString(json['courtJurisdiction']),
      citation: asString(json['citation']),
      sourceLabel: asString(
        json['sourceLabel'],
        'Reference to verify · source version unavailable',
      ),
      sourceExcerpt: asString(json['sourceExcerpt']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'actName': actName,
    'actNameUrdu': actNameUrdu,
    'section': section,
    'courtJurisdiction': courtJurisdiction,
    'citation': citation,
    'sourceLabel': sourceLabel,
    'sourceExcerpt': sourceExcerpt,
  };
}

/// Response of `POST /ai/text-query` and `POST /ai/voice-query`.
class AiAnswer {
  const AiAnswer({
    this.id = '',
    required this.answer,
    this.answerUrdu = '',
    this.answerPunjabi = '',
    this.answerSindhi = '',
    this.answerPashto = '',
    this.category = 'General Law',
    this.confidence = 0,
    this.status = 'pending',
    this.transcript = '',
    this.offline = false,
    this.empatheticOpening = '',
    this.empatheticOpeningUrdu = '',
    this.courtModeAnswer = '',
    this.courtModeAnswerUrdu = '',
    this.urgencyLevel = 'normal',
    this.roadmap = const <LegalJourneyStep>[],
    this.documents = const <RequiredDocumentItem>[],
    this.statutes = const <RelevantStatute>[],
    this.suggestedEmergencyHelpline = '',
  });

  final String id;
  final String answer;
  final String answerUrdu;

  /// Regional language answer fields (Tier-1: text only).
  final String answerPunjabi; // Shahmukhi script (Arabic-based Punjabi)
  final String answerSindhi; // Sindhi Arabic script
  final String answerPashto; // Pashto (Naskh/Nastaliq Arabic script)

  final String category;
  final double confidence;
  final String status;
  final String transcript;
  final bool offline;

  // Google UX / Empathetic AI additions
  final String empatheticOpening;
  final String empatheticOpeningUrdu;
  final String courtModeAnswer;
  final String courtModeAnswerUrdu;
  final String urgencyLevel; // 'urgent' | 'caution' | 'normal'
  final List<LegalJourneyStep> roadmap;
  final List<RequiredDocumentItem> documents;
  final List<RelevantStatute> statutes;
  final String suggestedEmergencyHelpline;

  AiAnswer copyWith({
    String? answerUrdu,
    String? answerPunjabi,
    String? answerSindhi,
    String? answerPashto,
    String? courtModeAnswerUrdu,
    String? courtModeAnswer,
  }) {
    return AiAnswer(
      id: id,
      answer: answer,
      answerUrdu: answerUrdu ?? this.answerUrdu,
      answerPunjabi: answerPunjabi ?? this.answerPunjabi,
      answerSindhi: answerSindhi ?? this.answerSindhi,
      answerPashto: answerPashto ?? this.answerPashto,
      category: category,
      confidence: confidence,
      status: status,
      transcript: transcript,
      offline: offline,
      empatheticOpening: empatheticOpening,
      empatheticOpeningUrdu: empatheticOpeningUrdu,
      courtModeAnswer: courtModeAnswer ?? this.courtModeAnswer,
      courtModeAnswerUrdu: courtModeAnswerUrdu ?? this.courtModeAnswerUrdu,
      urgencyLevel: urgencyLevel,
      roadmap: roadmap,
      documents: documents,
      statutes: statutes,
      suggestedEmergencyHelpline: suggestedEmergencyHelpline,
    );
  }

  factory AiAnswer.fromJson(Map<String, dynamic> json) {
    List<LegalJourneyStep> parseRoadmap(dynamic v) {
      if (v is List) {
        return v
            .map(
              (dynamic e) => LegalJourneyStep.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(growable: false);
      }
      return const <LegalJourneyStep>[];
    }

    List<RequiredDocumentItem> parseDocs(dynamic v) {
      if (v is List) {
        return v
            .map(
              (dynamic e) => RequiredDocumentItem.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(growable: false);
      }
      return const <RequiredDocumentItem>[];
    }

    List<RelevantStatute> parseStatutes(dynamic v) {
      if (v is List) {
        return v
            .map(
              (dynamic e) =>
                  RelevantStatute.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList(growable: false);
      }
      return const <RelevantStatute>[];
    }

    return AiAnswer(
      id: asString(json['id']),
      answer: asString(json['answer'], 'No answer returned by the AI service.'),
      answerUrdu: asString(json['answerUrdu']),
      answerPunjabi: asString(json['answerPunjabi']),
      answerSindhi: asString(json['answerSindhi']),
      answerPashto: asString(json['answerPashto']),
      category: asString(json['category'], 'General Law'),
      confidence: asDouble(json['confidence']),
      status: asString(json['status'], 'pending'),
      offline: json['offline'] == true,
      transcript: asString(json['transcript']),
      empatheticOpening: asString(json['empatheticOpening']),
      empatheticOpeningUrdu: asString(json['empatheticOpeningUrdu']),
      courtModeAnswer: asString(json['courtModeAnswer']),
      courtModeAnswerUrdu: asString(json['courtModeAnswerUrdu']),
      urgencyLevel: asString(json['urgencyLevel'], 'normal'),
      roadmap: parseRoadmap(json['roadmap']),
      documents: parseDocs(json['documents']),
      statutes: parseStatutes(json['statutes']),
      suggestedEmergencyHelpline: asString(json['suggestedEmergencyHelpline']),
    );
  }
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    DateTime? timestamp,
    this.answerUrdu = '',
    this.answerPunjabi = '',
    this.answerSindhi = '',
    this.answerPashto = '',
    this.category = '',
    this.confidence = 0,
    this.offline = false,
    this.empatheticOpening = '',
    this.empatheticOpeningUrdu = '',
    this.courtModeAnswer = '',
    this.courtModeAnswerUrdu = '',
    this.urgencyLevel = 'normal',
    this.roadmap = const <LegalJourneyStep>[],
    this.documents = const <RequiredDocumentItem>[],
    this.statutes = const <RelevantStatute>[],
    this.suggestedEmergencyHelpline = '',
  }) : timestamp = timestamp ?? DateTime.now();

  final String id;
  final bool isUser;
  final String text;
  final String answerUrdu;
  final String answerPunjabi;
  final String answerSindhi;
  final String answerPashto;
  final String category;
  final double confidence;
  final bool offline;
  final DateTime timestamp;

  final String empatheticOpening;
  final String empatheticOpeningUrdu;
  final String courtModeAnswer;
  final String courtModeAnswerUrdu;
  final String urgencyLevel;
  final List<LegalJourneyStep> roadmap;
  final List<RequiredDocumentItem> documents;
  final List<RelevantStatute> statutes;
  final String suggestedEmergencyHelpline;
}

/// `GET /admin/dashboard`
class DashboardSnapshot {
  const DashboardSnapshot({
    this.metrics = const <String, num>{},
    this.recentActivities = const <QueryRecord>[],
    this.offline = false,
  });

  final Map<String, num> metrics;
  final List<QueryRecord> recentActivities;
  final bool offline;

  num metric(String key) => metrics[key] ?? 0;
}

class LegalSubtopic {
  const LegalSubtopic({
    required this.title,
    required this.urdu,
    required this.description,
  });

  final String title;
  final String urdu;
  final String description;
}

class LegalTopic {
  const LegalTopic({
    required this.title,
    required this.titleUrdu,
    required this.accent,
    required this.icon,
    required this.subtopics,
  });

  final String title;
  final String titleUrdu;

  /// Brand colour used by the topic icon block (mirrors the Tailwind gradient
  /// pairs used in `LegalTopicsPage.tsx`).
  final int accent;
  final String icon;
  final List<LegalSubtopic> subtopics;
}

class SearchResult {
  const SearchResult({
    required this.title,
    required this.titleUrdu,
    required this.description,
    required this.category,
  });

  final String title;
  final String titleUrdu;
  final String description;
  final String category;
}
