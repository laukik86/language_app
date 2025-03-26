import 'package:flutter/material.dart';
import '../services/user_progress_service.dart';
import '../models/user_progress.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({Key? key}) : super(key: key);

  @override
  _ProgressTrackingScreenState createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final UserProgressService _progressService = UserProgressService();
  UserProgress? _userProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProgress();
  }

  Future<void> _fetchUserProgress() async {
    try {
      final progress = await _progressService.getUserProgress();
      setState(() {
        _userProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load progress: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: const Color(0xFF4285F4),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProgressContent(),
    );
  }

  Widget _buildProgressContent() {
    if (_userProgress == null) {
      return const Center(child: Text('No progress data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Overall Progress Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      'Lvl ${_userProgress!.overallLevel}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Total XP: ${_userProgress!.totalExperience}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Language-specific Progress
          const Text(
            'Language Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ..._buildLanguageProgressCards(),
        ],
      ),
    );
  }

  List<Widget> _buildLanguageProgressCards() {
    return _userProgress!.languageProgress.values.map((langProgress) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    langProgress.languageName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Level ${langProgress.level}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: (langProgress.experience % 100) / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                minHeight: 10,
              ),
              const SizedBox(height: 10),
              Text(
                'XP: ${langProgress.experience} / 100',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                'Quizzes Taken: ${langProgress.quizHistory.length}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
