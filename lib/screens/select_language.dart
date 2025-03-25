import 'package:flutter/material.dart';
import 'package:language_learning_app/screens/course_page.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key});

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  String? _selectedLanguage;

  void setLanguage(String language) {
    setState(() {
      //print("Language Updated: $_selectedLanguage");
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFF4285F4),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4285F4), // Top color matches AppBar
              Color(0xFF8BF389), // Green (middle)
              Color(0xFF00E3BD), // Teal (bottom)
            ], // Gradient Colors
            begin: Alignment.topLeft, // Gradient start
            end: Alignment.bottomRight, // Gradient end
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Move Card to the top
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            const SizedBox(height: 50),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Which course would you like to take?',
                    style: TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 90),

            // Language Selection Buttons
            LanguageButton(
              language: 'Hindi',
              flag: 'flags/india.png',
              onSelect: setLanguage,
              isSelected: _selectedLanguage == 'Hindi',
            ),
            const SizedBox(height: 20),
            LanguageButton(
              language: 'English',
              flag: 'flags/gb.png',
              onSelect: setLanguage,
              isSelected: _selectedLanguage == 'English',
            ),
            const SizedBox(height: 20),
            LanguageButton(
              language: 'French',
              flag: 'flags/france.png',
              onSelect: setLanguage,
              isSelected: _selectedLanguage == 'French',
            ),
            const SizedBox(height: 20),
            LanguageButton(
              language: 'Japanese',
              flag: 'flags/japan.png',
              onSelect: setLanguage,
              isSelected: _selectedLanguage == 'Japanese',
            ),
            const SizedBox(height: 20),
            LanguageButton(
              language: 'Spanish',
              flag: 'flags/spain.png',
              onSelect: setLanguage,
              isSelected: _selectedLanguage == 'Spanish',
            ),

            const SizedBox(height: 80),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00ADFF), // Light Green Button
                  foregroundColor: Colors.black, // Text Color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded Corners
                  ),
                ),
                onPressed: () {
                  //print("Selected Language: $_selectedLanguage");
                  if (_selectedLanguage != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CoursePage(selectedLanguage: _selectedLanguage!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Please select a language before starting the course!"),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.play_arrow, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Start Course',
                      style: TextStyle(fontSize: 26),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Language Button Widget
class LanguageButton extends StatelessWidget {
  final String language;
  final String flag;
  final Function(String) onSelect;
  final bool isSelected;

  const LanguageButton(
      {super.key,
      required this.language,
      required this.flag,
      required this.onSelect,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
          onPressed: () {
            //print("Button pressed: $language");
            onSelect(language);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blueAccent : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.black,
            elevation: isSelected ? 8 : 2,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: isSelected
                  ? const BorderSide(color: Colors.blue, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(flag, width: 30, height: 30), // Display flag image
              const SizedBox(width: 100), // Space between flag and text
              Text(language,
                  style: const TextStyle(
                      fontSize: 26,
                      fontFamily: String.fromEnvironment(""))), // Language name
            ],
          )),
    );
  }
}
