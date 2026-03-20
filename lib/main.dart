import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eimutksddqrxciwsdpsr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVpbXV0a3NkZHFyeGNpd3NkcHNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNjUzOTAsImV4cCI6MjA4MTc0MTM5MH0.L6V0IpXsJHxfy2X1kuE6ICYjwrM5sF85Vm8Pzt0lWn4',
  );

  await GoogleSignIn.instance.initialize(
    serverClientId:
        '921185889614-hm2ctm2r400ms7204orvgrd2o07mmnna.apps.googleusercontent.com',
  );

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
          secondary: const Color(0xFF68B0AB),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF9F8),
      ),
      home: const SafeArea(child: HomeScreen()),
      routes: {
        '/onboarding': (context) => const SafeArea(child: OnboardingScreen()),
        '/main': (context) => const MainLayout(),
      },
    );
  }
}
