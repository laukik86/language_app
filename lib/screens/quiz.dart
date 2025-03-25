import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/groq_api_service.dart';

class QuizPage extends StatefulWidget {
  final String language;
  final List<QuizQuestion>? preloadedQuestions;

  const QuizPage({super.key, required this.language, this.preloadedQuestions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _isLoading = true;
  List<QuizQuestion> _questions = [];
  List<QuizQuestion> _incorrectQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  bool _reviewingIncorrect = false;

  @override
  void initState() {
    super.initState();

    // If preloaded questions are available, use them
    if (widget.preloadedQuestions != null &&
        widget.preloadedQuestions!.isNotEmpty) {
      setState(() {
        _questions = widget.preloadedQuestions!;
        _isLoading = false;
      });
    } else {
      // Otherwise load questions as before
      _loadQuestions();
    }
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final questions = await GroqApiService.generateQuiz(widget.language);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _questions = GroqApiService.getFallbackQuiz(widget.language);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load questions: ${e.toString()}")),
        );
      }
    }
  }

  void _checkAnswer(String selectedOption) {
    final currentQuestion = _reviewingIncorrect
        ? _incorrectQuestions[_currentQuestionIndex]
        : _questions[_currentQuestionIndex];

    final correctAnswer = currentQuestion.correctAnswer;
///////////////////////////////////////////
    final explanation = currentQuestion.explanation;
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      setState(() {
        _quizCompleted = true;
      });
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          selectedOption == correctAnswer ? 'Correct!' : 'Incorrect',
          style: TextStyle(
            color: selectedOption == correctAnswer ? Colors.green : Colors.red,
          ),
        ),
        content: Text(explanation),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Continue with the original logic
              _processAnswer(selectedOption);
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

// New method to handle the answer after showing explanation
  void _processAnswer(String selectedOption) {
    final currentQuestion = _reviewingIncorrect
        ? _incorrectQuestions[_currentQuestionIndex]
        : _questions[_currentQuestionIndex];

    final correctAnswer = currentQuestion.correctAnswer;

    if (selectedOption == correctAnswer) {
      setState(() {
        if (!_reviewingIncorrect) {
          _score++;
        } else {
          // Remove from incorrect list if answered correctly during review
          _incorrectQuestions.removeAt(_currentQuestionIndex);
          if (_incorrectQuestions.isEmpty) {
            _reviewingIncorrect = false;
            _quizCompleted = true;
          }
        }
      });
    } else {
      // Add to incorrect questions if not already in review mode
      if (!_reviewingIncorrect) {
        _incorrectQuestions.add(currentQuestion);
      }
    }

    // if (selectedOption == correctAnswer) {
    //   setState(() {
    //     if (!_reviewingIncorrect) {
    //       _score++;
    //     } else {
    //       // Remove from incorrect list if answered correctly during review
    //       _incorrectQuestions.removeAt(_currentQuestionIndex);
    //       if (_incorrectQuestions.isEmpty) {
    //         _reviewingIncorrect = false;
    //         _quizCompleted = true;
    //       }
    //     }
    //   });
    // } else {
    //   // Add to incorrect questions if not already in review mode
    //   if (!_reviewingIncorrect) {
    //     _incorrectQuestions.add(currentQuestion);
    //   }
    // }

    final questionList = _reviewingIncorrect ? _incorrectQuestions : _questions;

    if (_currentQuestionIndex < questionList.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      if (_reviewingIncorrect) {
        // If we've gone through all incorrect questions
        if (_incorrectQuestions.isEmpty) {
          setState(() {
            _quizCompleted = true;
            _reviewingIncorrect = false;
          });
        } else {
          // Reset index to review again
          setState(() {
            _currentQuestionIndex = 0;
          });
        }
      } else if (_incorrectQuestions.isNotEmpty) {
        // Start reviewing incorrect questions
        setState(() {
          _reviewingIncorrect = true;
          _currentQuestionIndex = 0;
        });
      } else {
        // No incorrect questions, complete quiz
        setState(() {
          _quizCompleted = true;
        });
      }
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
      _reviewingIncorrect = false;
      _incorrectQuestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.language} Quiz"),
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF9F871), // Soft Yellow (Background)
              Color(0xFF8BF389), // Green (Positive)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: _quizCompleted
                    ? _buildQuizCompleted()
                    : _buildQuizInProgress(),
              ),
      ),
    );
  }

  Widget _buildQuizInProgress() {
    final currentQuestionList =
        _reviewingIncorrect ? _incorrectQuestions : _questions;

    if (currentQuestionList.isEmpty) {
      return const Center(
        child: Text("No questions available", style: TextStyle(fontSize: 18)),
      );
    }

    final currentQuestion = currentQuestionList[_currentQuestionIndex];
    final options = currentQuestion.options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),

        // Quiz Status
        if (_reviewingIncorrect)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Reviewing Incorrect Answers",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        const SizedBox(height: 15),

        // Progress indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Question ${_currentQuestionIndex + 1}/${currentQuestionList.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / currentQuestionList.length,
          minHeight: 10,
          backgroundColor: Colors.white,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
        ),
        if (!_reviewingIncorrect) ...[
          const SizedBox(height: 5),
          Text(
            "Score: $_score/${_questions.length}",
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 25),

        // Question
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              currentQuestion.question,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 25),

        // Options
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final optionKey = ['A', 'B', 'C', 'D'][index];
              final optionValue = options[optionKey];

              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(optionKey),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "$optionKey: $optionValue",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuizCompleted() {
    final percentage = (_score / _questions.length) * 100;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 20),
          const Text(
            "Quiz Completed!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            "Your Score: $_score/${_questions.length}",
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 10),
          Text(
            "${percentage.toStringAsFixed(0)}%",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: percentage >= 70
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _restartQuiz,
              icon: const Icon(Icons.replay),
              label: const Text("Try Again", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.home),
              label:
                  const Text("Back to Course", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
