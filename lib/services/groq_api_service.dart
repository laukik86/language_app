import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz_question.dart';

class GroqApiService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama3-70b-8192'; // Or another available model

  // Your API key should be stored securely, ideally not hardcoded
  static String? _apiKey;

  static void initialize(String apiKey) {
    _apiKey = apiKey;
  }

  static Future<List<QuizQuestion>> generateQuiz(String language,
      {int questionCount = 5}) async {
    if (_apiKey == null) {
      throw Exception(
          'API key not initialized. Call GroqApiService.initialize() first.');
    }

    final prompt = '''
    Create a language learning quiz for beginners learning $language. The user only knows English and is learning $language, so:
    
    1. All questions should be written in English
    2. The quiz should test basic vocabulary, simple phrases, or elementary grammar concepts in $language
    3. Include options that are words or phrases in $language (with English translations when appropriate)
    4. Make the correct answer obvious for someone who has just started learning
    5. Include an explanation in English for why the answer is correct
    
    Create $questionCount multiple-choice questions formatted as JSON with this structure:
    {
      "question": "How do you say 'hello' in $language?",
      "options": {
        "A": "$language word/phrase (English translation)",
        "B": "$language word/phrase (English translation)",
        "C": "$language word/phrase (English translation)",
        "D": "$language word/phrase (English translation)"
      },
      "correctAnswer": "A",
      "explanation": "A clear explanation in English about the correct answer"
    }
    
    Return ONLY the JSON array of questions without any additional text.
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a language learning assistant that creates quizzes for absolute beginners. All questions should be in English, with multiple choice answers in the target language.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 2000,
        'response_format': {'type': 'json_object'}, // Explicitly request JSON
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final content = jsonResponse['choices'][0]['message']['content'];

      try {
        // Try to parse the JSON content
        final List<dynamic> questionsJson = jsonDecode(content);
        return questionsJson
            .map((json) => QuizQuestion.fromJson(json))
            .toList();
      } catch (e) {
        print("Error parsing JSON: $e");
        print("Raw content: $content");

        // Try to extract JSON array as fallback
        return _extractQuestionsFromText(content);
      }
    } else {
      throw Exception('Failed to generate quiz: ${response.body}');
    }
  }

  // More robust JSON extraction from text
  static List<QuizQuestion> _extractQuestionsFromText(String content) {
    try {
      // Try to find a JSON array in the content
      final jsonPattern = RegExp(r'\[\s*{.*}\s*\]', dotAll: true);
      final match = jsonPattern.firstMatch(content);

      if (match != null) {
        final jsonStr = match.group(0)!;
        final List<dynamic> questions = jsonDecode(jsonStr);
        return questions.map((json) => QuizQuestion.fromJson(json)).toList();
      }

      // If still no match, look for individual JSON objects
      final objPattern = RegExp(r'{.*?}', dotAll: true);
      final matches = objPattern.allMatches(content);

      if (matches.isNotEmpty) {
        final List<QuizQuestion> questions = [];
        for (final match in matches) {
          try {
            final json = jsonDecode(match.group(0)!);
            if (json.containsKey('question') &&
                json.containsKey('options') &&
                json.containsKey('correctAnswer')) {
              questions.add(QuizQuestion.fromJson(json));
            }
          } catch (e) {
            // Skip this match if it's not valid JSON
            continue;
          }
        }

        if (questions.isNotEmpty) {
          return questions;
        }
      }

      throw Exception(
          'Could not extract valid JSON questions from API response');
    } catch (e) {
      print("JSON extraction error: $e");
      throw Exception('Failed to parse quiz questions from API response');
    }
  }

  // Improved fallback quiz with better formatting
  static List<QuizQuestion> getFallbackQuiz(String language) {
    if (language == 'Spanish') {
      return [
        QuizQuestion(
          question: 'How do you say "hello" in Spanish?',
          options: {
            'A': 'Hola (Hello)',
            'B': 'Adiós (Goodbye)',
            'C': 'Gracias (Thank you)',
            'D': 'Por favor (Please)'
          },
          correctAnswer: 'A',
          explanation:
              '"Hola" is the Spanish word for "hello" and is used as a common greeting.',
        ),
        QuizQuestion(
          question: 'What is the Spanish word for "book"?',
          options: {
            'A': 'Perro (Dog)',
            'B': 'Libro (Book)',
            'C': 'Casa (House)',
            'D': 'Sol (Sun)'
          },
          correctAnswer: 'B',
          explanation: '"Libro" is the Spanish word for "book".',
        ),
        QuizQuestion(
          question: 'How do you say "thank you" in Spanish?',
          options: {
            'A': 'Por favor (Please)',
            'B': 'Lo siento (Sorry)',
            'C': 'Gracias (Thank you)',
            'D': 'De nada (You\'re welcome)'
          },
          correctAnswer: 'C',
          explanation: '"Gracias" is how you say "thank you" in Spanish.',
        ),
        QuizQuestion(
          question: 'Which Spanish word means "yes"?',
          options: {
            'A': 'No (No)',
            'B': 'Sí (Yes)',
            'C': 'Tal vez (Maybe)',
            'D': 'Nada (Nothing)'
          },
          correctAnswer: 'B',
          explanation: '"Sí" means "yes" in Spanish.',
        ),
        QuizQuestion(
          question: 'What does "buenos días" mean?',
          options: {
            'A': 'Good afternoon',
            'B': 'Good evening',
            'C': 'Good morning',
            'D': 'Good night'
          },
          correctAnswer: 'C',
          explanation:
              '"Buenos días" is the Spanish greeting for "good morning".',
        ),
      ];
    } else if (language == 'French') {
      return [
        QuizQuestion(
          question: 'How do you say "hello" in French?',
          options: {
            'A': 'Au revoir (Goodbye)',
            'B': 'Merci (Thank you)',
            'C': 'Bonjour (Hello)',
            'D': 'S\'il vous plaît (Please)'
          },
          correctAnswer: 'C',
          explanation:
              '"Bonjour" is the French word for "hello" or "good day".',
        ),
        QuizQuestion(
          question: 'What is the French word for "water"?',
          options: {
            'A': 'Pain (Bread)',
            'B': 'Lait (Milk)',
            'C': 'Vin (Wine)',
            'D': 'Eau (Water)'
          },
          correctAnswer: 'D',
          explanation: '"Eau" is the French word for "water".',
        ),
        QuizQuestion(
          question: 'How do you say "thank you" in French?',
          options: {
            'A': 'Merci (Thank you)',
            'B': 'Pardon (Sorry)',
            'C': 'S\'il vous plaît (Please)',
            'D': 'De rien (You\'re welcome)'
          },
          correctAnswer: 'A',
          explanation: '"Merci" is how you say "thank you" in French.',
        ),
        QuizQuestion(
          question: 'What does "au revoir" mean?',
          options: {
            'A': 'Hello',
            'B': 'Please',
            'C': 'Thank you',
            'D': 'Goodbye'
          },
          correctAnswer: 'D',
          explanation: '"Au revoir" is the French phrase for "goodbye".',
        ),
        QuizQuestion(
          question: 'How do you count to three in French?',
          options: {
            'A': 'Un, deux, trois',
            'B': 'Uno, dos, tres',
            'C': 'Eins, zwei, drei',
            'D': 'One, two, three'
          },
          correctAnswer: 'A',
          explanation:
              'In French, you count "un, deux, trois" for one, two, three.',
        ),
      ];
    } else if (language == 'Japanese') {
      return [
        QuizQuestion(
          question: 'How do you say "hello" in Japanese?',
          options: {
            'A': 'Sayōnara (Goodbye)',
            'B': 'Arigatō (Thank you)',
            'C': 'Konnichiwa (Hello)',
            'D': 'Sumimasen (Excuse me)'
          },
          correctAnswer: 'C',
          explanation:
              '"Konnichiwa" is the standard Japanese greeting for "hello".',
        ),
        QuizQuestion(
          question: 'What does "arigatō" mean in Japanese?',
          options: {
            'A': 'Hello',
            'B': 'Thank you',
            'C': 'Goodbye',
            'D': 'Please'
          },
          correctAnswer: 'B',
          explanation: '"Arigatō" means "thank you" in Japanese.',
        ),
        QuizQuestion(
          question: 'Which Japanese word means "yes"?',
          options: {
            'A': 'Iie (No)',
            'B': 'Hai (Yes)',
            'C': 'Wakarimasen (I don\'t understand)',
            'D': 'Ohayō (Good morning)'
          },
          correctAnswer: 'B',
          explanation: '"Hai" is the Japanese word for "yes".',
        ),
        QuizQuestion(
          question: 'How do you say "goodbye" in Japanese?',
          options: {
            'A': 'Sayōnara (Goodbye)',
            'B': 'Konnichiwa (Hello)',
            'C': 'Arigatō (Thank you)',
            'D': 'Hai (Yes)'
          },
          correctAnswer: 'A',
          explanation: '"Sayōnara" is used to say "goodbye" in Japanese.',
        ),
        QuizQuestion(
          question: 'What does "ohayō gozaimasu" mean?',
          options: {
            'A': 'Good afternoon',
            'B': 'Good evening',
            'C': 'Good morning',
            'D': 'Good night'
          },
          correctAnswer: 'C',
          explanation:
              '"Ohayō gozaimasu" is the Japanese greeting for "good morning".',
        ),
      ];
    }

    // Default fallback for any language
    return [
      QuizQuestion(
        question: 'Example Question 1',
        options: {
          'A': 'Option A',
          'B': 'Option B',
          'C': 'Option C',
          'D': 'Option D'
        },
        correctAnswer: 'A',
        explanation: 'This is a fallback question as the API request failed.',
      ),
      QuizQuestion(
        question: 'Example Question 2',
        options: {
          'A': 'Option A',
          'B': 'Option B',
          'C': 'Option C',
          'D': 'Option D'
        },
        correctAnswer: 'B',
        explanation: 'This is a fallback question as the API request failed.',
      ),
      QuizQuestion(
        question: 'Example Question 3',
        options: {
          'A': 'Option A',
          'B': 'Option B',
          'C': 'Option C',
          'D': 'Option D'
        },
        correctAnswer: 'C',
        explanation: 'This is a fallback question as the API request failed.',
      ),
    ];
  }
}
