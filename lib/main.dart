import 'package:flutter/material.dart';
import 'home_page.dart'; // ہوم پیج کو یہاں امپورٹ کریں

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Installment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(), // کنٹرول سیدھا ہوم پیج فائل کو دے دیا
    );
  }
}