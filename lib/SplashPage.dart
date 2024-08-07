import 'dart:async';
import 'package:flutter/material.dart';
import 'qr_screen.dart'; // Make sure to import the QrScreen file

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Start a timer when the widget is built
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const QrScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset('assets/cn_logo.png'),
      ),
    );
  }
}
