import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'welcome/login_page.dart';

void main() async {
  // فلاتر اور پیکیجز کی بائنڈنگز کو یقینی بنانا
  WidgetsFlutterBinding.ensureInitialized();

  // فائر بیس کو انیشلائز کرنا
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization skipped or failed: $e');
  }

  // ہائیو ڈیٹا بیس کو انیشلائز کرنا
  await Hive.initFlutter();

  // 🎯 تمام باکسز بشمول نیا summaryBox ایک ساتھ (Parallel) کھولنا
  await Future.wait([
    Hive.openBox('customerBox'),
    Hive.openBox('guarantorBox'),
    Hive.openBox('packageBox'),
    Hive.openBox('stockBox'),
    Hive.openBox('transactionBox'),
    Hive.openBox('expenseBox'),
    Hive.openBox('bankBox'),
    Hive.openBox('financialSummaryBox'),
    Hive.openBox('summaryBox'), // 🎯 نیا سمری باکس یہاں شامل کر دیا گیا ہے
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نایاب قسط پوائنٹ',
      theme: ThemeData(
        primaryColor: Colors.red[800],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red[800]!,
          primary: Colors.red[800],
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}