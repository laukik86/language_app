import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:language_learning_app/screens/select_language.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:language_learning_app/auth/auth_screen.dart';
import 'dart:developer' show log;
import 'firebase_options.dart';
import 'package:language_learning_app/services/groq_api_service.dart';
import 'package:language_learning_app/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      // If you have firebase_options.dart, use it like this:
      // options: DefaultFirebaseOptions.currentPlatform,
    );
    // In your app initialization or debug button handler
    GroqApiService.initialize(
        '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');

    runApp(
      DevicePreview(
        enabled: true,
        builder: (context) => const MyApp(),
      ),
    );
  } catch (error, stackTrace) {
    log('Firebase Initialization Error: $error\n$stackTrace');
    runApp(ErrorApp(error: error));
  }
}

// Added error fallback app
class ErrorApp extends StatelessWidget {
  final dynamic error;

  const ErrorApp({Key? key, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $error'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Language Learning App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
      routes: {
        '/language_select': (context) => const SelectLanguage(),
        '/profile': (context) => const ProfileScreen(), // Add this line
      },
      builder: DevicePreview.appBuilder,
      useInheritedMediaQuery: true,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Log connection state and snapshot data for debugging
        log('Connection State: ${snapshot.connectionState}');
        log('Has Data: ${snapshot.hasData}');
        log('Snapshot Data: ${snapshot.data}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const SelectLanguage();
        }

        return const AuthScreen();
      },
    );
  }
}
