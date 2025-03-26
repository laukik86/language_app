import 'package:flutter/material.dart';
import 'package:language_learning_app/screens/word_of_day.dart';
import 'package:language_learning_app/screens/quiz.dart';
import 'package:language_learning_app/services/user_progress_service.dart';
import 'package:language_learning_app/models/user_progress.dart';

class CoursePage extends StatefulWidget {
  final String selectedLanguage;

  const CoursePage({super.key, required this.selectedLanguage});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final UserProgressService _progressService = UserProgressService();
  LanguageProgress? _languageProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLanguageProgress();
  }

  Future<void> _fetchLanguageProgress() async {
    try {
      final progress =
          await _progressService.getLanguageProgress(widget.selectedLanguage);
      setState(() {
        _languageProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading progress: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.selectedLanguage} Course"),
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4285F4),
              Color(0xFF8BF389),
              Color(0xFF00E3BD),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(),
                      const SizedBox(height: 20),
                      _buildProgressCard(),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        title: "Word of the Day",
                        description:
                            "Learn a new word every day to expand your vocabulary.",
                        icon: Icons.lightbulb_outline,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordOfDayScreen(
                                language: widget.selectedLanguage),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        title: "Take a Quiz",
                        description:
                            "Test your knowledge and improve your skills.",
                        icon: Icons.quiz,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizPage(language: widget.selectedLanguage),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              Icons.language,
              size: 50,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              "Welcome to ${widget.selectedLanguage}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Master ${widget.selectedLanguage} with our interactive lessons and quizzes",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Your Progress",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Level: ${_languageProgress?.level ?? 1}",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Experience: ${_languageProgress?.experience ?? 0} XP",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: ((_languageProgress?.experience ?? 0) % 100) / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Next Level: ${((_languageProgress?.experience ?? 0) % 100)} / 100 XP",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber.shade600,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue.shade700, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
