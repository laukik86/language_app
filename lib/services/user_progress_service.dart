import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:language_learning_app/models/user_progress.dart';

class UserProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save or update user progress
  Future<void> saveUserProgress(UserProgress progress) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }
      await _firestore
          .collection('user_progress')
          .doc(user.uid)
          .set(progress.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving user progress: $e');
      rethrow;
    }
  }

  // Fetch user progress
  Future<UserProgress?> getUserProgress() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docSnapshot =
          await _firestore.collection('user_progress').doc(user.uid).get();

      if (docSnapshot.exists) {
        return UserProgress.fromMap(docSnapshot.data()!);
      }

      // If no progress exists, create a new one
      final newProgress = UserProgress(userId: user.uid);
      await saveUserProgress(newProgress);
      return newProgress;
    } catch (e) {
      print('Error fetching user progress: $e');
      return null;
    }
  }

  // Update progress after quiz
  Future<UserProgress> updateProgressAfterQuiz({
    required String language,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      UserProgress? userProgress = await getUserProgress();
      if (userProgress == null) {
        userProgress = UserProgress(userId: _auth.currentUser!.uid);
      }

      // Get or create language progress
      LanguageProgress languageProgress =
          userProgress.languageProgress[language] ??
              LanguageProgress(languageName: language);

      // Calculate quiz result details
      final percentage = (score / totalQuestions) * 100;
      final quizResult = QuizResult(
        date: DateTime.now(),
        language: language,
        score: score,
        totalQuestions: totalQuestions,
        percentage: percentage,
      );

      // Calculate experience gain (10 XP per correct answer)
      final experienceGained = (score * 10).toInt();
      languageProgress.experience += experienceGained;
      languageProgress.quizHistory.add(quizResult);

      // Level up logic for language
      if (languageProgress.experience >= languageProgress.level * 100) {
        languageProgress.level++;
      }

      // Update user progress
      userProgress.languageProgress[language] = languageProgress;
      userProgress.totalExperience += experienceGained;

      // Overall user level up logic
      if (userProgress.totalExperience >= userProgress.overallLevel * 500) {
        userProgress.overallLevel++;
      }

      // Save updated progress
      await saveUserProgress(userProgress);
      return userProgress;
    } catch (e) {
      print('Error updating quiz progress: $e');
      rethrow;
    }
  }

  // Get progress for a specific language
  Future<LanguageProgress?> getLanguageProgress(String language) async {
    final userProgress = await getUserProgress();
    return userProgress?.languageProgress[language];
  }

  // Get recent quiz history for a language
  Future<List<QuizResult>> getRecentQuizHistory(String language,
      {int limit = 5}) async {
    final languageProgress = await getLanguageProgress(language);
    return (languageProgress?.quizHistory ?? [])
        .sorted((a, b) => b.date.compareTo(a.date))
        .take(limit)
        .toList();
  }
}

// Extension to help sort quiz results
extension Sorted<T> on List<T> {
  List<T> sorted(int Function(T, T) compare) {
    final copy = [...this];
    copy.sort(compare);
    return copy;
  }
}
