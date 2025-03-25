import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_of_the_day.dart';
//import 'groq_api_service.dart';

class WordOfDayService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama3-70b-8192'; // Same model as quiz service
  static const String _apiKey =
      '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';
  // Re-use the API key from GroqApiService
  //static String? get _apiKey => GroqApiService._apiKey;

  static Future<WordOfDay> getWordOfDay(
      String language, String userLanguage) async {
    if (_apiKey == null) {
      throw Exception(
          'API key not initialized. Call GroqApiService.initialize() first.');
    }

    final currentDate = DateTime.now();
    final dateString =
        '${currentDate.day} de ${getMonthName(currentDate.month, language)}, ${currentDate.year}';

    final prompt = '''
    Generate a "Word of the Day" for language learners studying $language.
    The user's native language is $userLanguage.
    
    Choose an interesting, useful, and moderately challenging word in $language.
    
    Format the response as JSON with this structure:
    {
      "word": "The word in $language",
      "pronunciation": "Phonetic pronunciation",
      "partOfSpeech": "Part of speech in $userLanguage",
      "definition": "Clear definition in $userLanguage",
      "example": "An example sentence using the word in $language",
      "synonyms": ["3-5 synonyms in $language"],
      "difficulty": "beginner|intermediate|advanced"
    }
    
    Return ONLY the JSON without any additional text.
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
                'You are a language learning assistant that provides daily vocabulary words. Choose interesting and useful words that would benefit language learners.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 800,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final content = jsonResponse['choices'][0]['message']['content'];

      try {
        final wordData = jsonDecode(content);
        return WordOfDay.fromJson(wordData, dateString);
      } catch (e) {
        print("Error parsing JSON: $e");
        print("Raw content: $content");
        return getFallbackWordOfDay(language, dateString);
      }
    } else {
      throw Exception('Failed to fetch word of the day: ${response.body}');
    }
  }

  // Changed from _getMonthName to getMonthName to match the call in the screen
  static String getMonthName(int month, String language) {
    if (language == 'Spanish') {
      final months = [
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre'
      ];
      return months[month - 1];
    } else if (language == 'French') {
      final months = [
        'janvier',
        'février',
        'mars',
        'avril',
        'mai',
        'juin',
        'juillet',
        'août',
        'septembre',
        'octobre',
        'novembre',
        'décembre'
      ];
      return months[month - 1];
    } else {
      // Default to English month names
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return months[month - 1];
    }
  }

  // Changed from _getFallbackWordOfDay to getFallbackWordOfDay to match the call in the screen
  static WordOfDay getFallbackWordOfDay(String language, String dateString) {
    // Provide fallback words for common languages
    if (language == 'Spanish') {
      return WordOfDay(
        word: 'Serendipia',
        pronunciation: '/se.ren.ˈdi.pja/',
        partOfSpeech: 'sustantivo femenino',
        definition:
            'Hallazgo afortunado e inesperado que se produce cuando se está buscando otra cosa distinta.',
        example: 'El descubrimiento de la penicilina fue una serendipia.',
        synonyms: ['casualidad', 'chiripa', 'carambola'],
        difficulty: 'advanced',
        date: dateString,
      );
    } else if (language == 'French') {
      return WordOfDay(
        word: 'Sérendipité',
        pronunciation: '/se.ʁɑ̃.di.pi.te/',
        partOfSpeech: 'nom féminin',
        definition:
            'Découverte heureuse faite par hasard alors qu\'on cherchait autre chose.',
        example:
            'La découverte de la pénicilline est un exemple de sérendipité.',
        synonyms: ['hasard', 'chance', 'coïncidence'],
        difficulty: 'advanced',
        date: dateString,
      );
    } else if (language == 'Japanese') {
      return WordOfDay(
        word: '偶然',
        pronunciation: 'ぐうぜん (gūzen)',
        partOfSpeech: 'noun',
        definition: 'Coincidence, chance, accident',
        example:
            '彼との出会いは偶然でした。 (Kare to no deai wa gūzen deshita - Meeting him was a coincidence.)',
        synonyms: ['運命', '巡り合わせ', '出会い'],
        difficulty: 'intermediate',
        date: dateString,
      );
    }

    // Default fallback
    return WordOfDay(
      word: 'Example',
      pronunciation: '/ɪɡˈzæmpəl/',
      partOfSpeech: 'noun',
      definition: 'A sample word as API request failed.',
      example: 'This is an example sentence.',
      synonyms: ['sample', 'specimen', 'case'],
      difficulty: 'beginner',
      date: dateString,
    );
  }
}
