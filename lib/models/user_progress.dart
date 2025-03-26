import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  String userId;
  Map<String, LanguageProgress> languageProgress;
  int overallLevel;
  int totalExperience;

  UserProgress({
    required this.userId,
    this.languageProgress = const {},
    this.overallLevel = 1,
    this.totalExperience = 0,
  });

  // Convert UserProgress to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'languageProgress': languageProgress.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'overallLevel': overallLevel,
      'totalExperience': totalExperience,
    };
  }

  // Create UserProgress from Firestore data
  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'],
      languageProgress: (map['languageProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              LanguageProgress.fromMap(value as Map<String, dynamic>),
            ),
          ) ??
          {},
      overallLevel: map['overallLevel'] ?? 1,
      totalExperience: map['totalExperience'] ?? 0,
    );
  }
}

class LanguageProgress {
  String languageName;
  int level;
  int experience;
  List<QuizResult> quizHistory;

  LanguageProgress({
    required this.languageName,
    this.level = 1,
    this.experience = 0,
    List<QuizResult>? quizHistory,
  }) : quizHistory = quizHistory ?? [];

  // Convert LanguageProgress to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'languageName': languageName,
      'level': level,
      'experience': experience,
      'quizHistory': quizHistory.map((result) => result.toMap()).toList(),
    };
  }

  // Create LanguageProgress from Firestore data
  factory LanguageProgress.fromMap(Map<String, dynamic> map) {
    return LanguageProgress(
      languageName: map['languageName'],
      level: map['level'] ?? 1,
      experience: map['experience'] ?? 0,
      quizHistory: (map['quizHistory'] as List?)
              ?.map((result) =>
                  QuizResult.fromMap(result as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class QuizResult {
  final DateTime date;
  final String language;
  final int score;
  final int totalQuestions;
  final double percentage;

  QuizResult({
    required this.date,
    required this.language,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
  });

  // Convert QuizResult to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date), // Use Timestamp instead of ISO string
      'language': language,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
    };
  }

  // Create QuizResult from Firestore data
  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      date: (map['date'] as Timestamp).toDate(),
      language: map['language'],
      score: map['score'],
      totalQuestions: map['totalQuestions'],
      percentage: (map['percentage'] as num).toDouble(),
    );
  }
}
