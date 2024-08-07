import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'SplashPage.dart'; // Import your SplashPage file
import 'firebase_options.dart'; // Import your Firebase options file

void main() async {
  // Ensure that plugin services are initialized before calling `runApp`
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
