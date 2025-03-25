import 'package:flutter/material.dart';
import '../models/word_of_the_day.dart';
import '../services/word_of_the_day_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WordOfDayScreen extends StatefulWidget {
  final String language;
  final String userLanguage;

  const WordOfDayScreen({
    Key? key,
    required this.language,
    this.userLanguage = 'English',
  }) : super(key: key);

  @override
  _WordOfDayScreenState createState() => _WordOfDayScreenState();
}

class _WordOfDayScreenState extends State<WordOfDayScreen> {
  late Future<WordOfDay> _wordOfDayFuture;
  bool _isInFlashcards = false;

  @override
  void initState() {
    super.initState();
    _wordOfDayFuture = _getWordOfDay();
    _checkFlashcardStatus();
  }

  Future<void> _checkFlashcardStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final flashcards =
        prefs.getStringList('flashcards_${widget.language}') ?? [];

    if (flashcards.isNotEmpty) {
      final wordOfDay = await _wordOfDayFuture;
      setState(() {
        _isInFlashcards = flashcards.any((card) {
          final data = jsonDecode(card);
          return data['word'] == wordOfDay.word;
        });
      });
    }
  }

  Future<WordOfDay> _getWordOfDay() async {
    // First check if we have today's word cached
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final cachedWord =
        prefs.getString('word_of_day_${widget.language}_$dateKey');

    if (cachedWord != null) {
      try {
        final json = jsonDecode(cachedWord);
        return WordOfDay.fromJson(json, json['date']);
      } catch (e) {
        print('Error loading cached word: $e');
      }
    }

    // If not cached or error, fetch new word
    try {
      final word = await WordOfDayService.getWordOfDay(
          widget.language, widget.userLanguage);

      // Cache the word
      await prefs.setString(
          'word_of_day_${widget.language}_$dateKey', jsonEncode(word.toJson()));

      return word;
    } catch (e) {
      print('Error fetching word of day: $e');

      // Return a fallback from cache if available
      final fallbackCache =
          prefs.getStringList('word_of_day_${widget.language}_fallbacks');
      if (fallbackCache != null && fallbackCache.isNotEmpty) {
        try {
          final randomIndex = DateTime.now().millisecond % fallbackCache.length;
          final json = jsonDecode(fallbackCache[randomIndex]);
          return WordOfDay.fromJson(json, json['date']);
        } catch (e) {
          print('Error loading fallback word: $e');
        }
      }

      // Create a new fallback - Now using the properly named methods
      return WordOfDayService.getFallbackWordOfDay(widget.language,
          '${today.day} de ${WordOfDayService.getMonthName(today.month, widget.language)}, ${today.year}');
    }
  }

  Future<void> _addToFlashcards(WordOfDay word) async {
    final prefs = await SharedPreferences.getInstance();
    final flashcards =
        prefs.getStringList('flashcards_${widget.language}') ?? [];

    final wordJson = jsonEncode(word.toJson());
    if (!flashcards.contains(wordJson)) {
      flashcards.add(wordJson);
      await prefs.setStringList('flashcards_${widget.language}', flashcards);
      setState(() {
        _isInFlashcards = true;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Added to flashcards!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rest of the build method remains the same
    // ...

    return Scaffold(
      appBar: AppBar(
        title: Text('Word of the Day'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<WordOfDay>(
        future: _wordOfDayFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No word available'));
          }

          final word = snapshot.data!;

          return Container(
            color: Colors.yellow[100],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language selector
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.pink[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.language,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Spacer(),
                        Text(word.date),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Word card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            'WORD OF THE DAY',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                word.word,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[300],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  word.difficulty
                                          .substring(0, 1)
                                          .toUpperCase() +
                                      word.difficulty.substring(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Text(
                            word.pronunciation,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              word.partOfSpeech,
                              style: TextStyle(
                                color: Colors.red[300],
                              ),
                            ),
                          ),

                          Divider(),

                          // Definition
                          Text(
                            'Definition',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(word.definition),
                          ),

                          // Example
                          Text(
                            'Example',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              word.example,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                          // Synonyms
                          Text(
                            'Synonyms',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Wrap(
                            spacing: 8,
                            children: word.synonyms
                                .map((synonym) => Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      margin: EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(synonym),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Spacer(),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.volume_up),
                        label: Text('Listen'),
                        onPressed: () {
                          // Implement text-to-speech functionality
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Text-to-speech not implemented yet')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.bookmark),
                        label: Text('Add to Flashcards'),
                        onPressed: _isInFlashcards
                            ? null
                            : () => _addToFlashcards(word),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
