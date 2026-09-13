import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D4D4D),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 16),
          // يمكنك إضافة المزيد من البطاقات هنا
        ],
      ),
    );
  }
} 