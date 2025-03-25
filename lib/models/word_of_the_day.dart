class WordOfDay {
  final String word;
  final String pronunciation;
  final String partOfSpeech;
  final String definition;
  final String example;
  final List<String> synonyms;
  final String difficulty;
  final String date;

  WordOfDay({
    required this.word,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.definition,
    required this.example,
    required this.synonyms,
    required this.difficulty,
    required this.date,
  });

  factory WordOfDay.fromJson(Map<String, dynamic> json, String date) {
    // Convert synonyms to List<String>
    List<String> synonymsList = [];
    if (json['synonyms'] is List) {
      synonymsList = List<String>.from(json['synonyms']);
    } else if (json['synonyms'] is String) {
      // In case the API returns a comma-separated string
      synonymsList = json['synonyms'].split(',').map((s) => s.trim()).toList();
    }

    return WordOfDay(
      word: json['word'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      partOfSpeech: json['partOfSpeech'] ?? '',
      definition: json['definition'] ?? '',
      example: json['example'] ?? '',
      synonyms: synonymsList,
      difficulty: json['difficulty'] ?? 'intermediate',
      date: date,
    );
  }

  // Add method to save to local storage if needed
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'pronunciation': pronunciation,
      'partOfSpeech': partOfSpeech,
      'definition': definition,
      'example': example,
      'synonyms': synonyms,
      'difficulty': difficulty,
      'date': date,
    };
  }
}
