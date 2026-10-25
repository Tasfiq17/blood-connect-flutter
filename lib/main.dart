import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth_wrapper.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BloodConnect());
}

class BloodConnect extends StatelessWidget {
  const BloodConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}