import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_first_app/welcome/login_page.dart';

void main() async {
  // فلیٹر اور پیکیجز کی بائنڈنگز کو یقینی بنانا
  WidgetsFlutterBinding.ensureInitialized();

  // فائر بیس کو انیشلائز کرنا
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization skipped or failed: $e');
  }

  // ہائیو ڈیٹا بیس کو انیشلائز کرنا
  await Hive.initFlutter();

  // 🎯 ویب ڈیوائس پر بلاکنگ سے بچنے کے لیے تمام باکسز کو ایک ایک کر کے اوپن کرنا
  await Hive.openBox('customerBox');
  await Hive.openBox('guarantorBox');
  await Hive.openBox('packageBox');
  await Hive.openBox('stockBox');
  await Hive.openBox('transactionBox');
  await Hive.openBox('expenseBox');
  await Hive.openBox('bankBox');
  await Hive.openBox('financialSummaryBox');
  await Hive.openBox('summaryBox');

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