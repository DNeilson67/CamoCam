import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_layout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CamoCam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4A7C59),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A7C59),
          primary: const Color(0xFF4A7C59),
          secondary: const Color(0xFF68B0AB), // Teal color from Figma
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF9F8),
      ),
      home: const SafeArea(child: OnboardingScreen()),
    );
  }
}
