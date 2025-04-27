import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Cor de fundo
      body: Center(
        child: Image.asset(
          'assets/logo.png', // sua logo
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
