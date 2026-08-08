import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ہائیو فلٹر کا پیکیج
import 'package:firebase_core/firebase_core.dart'; // فائر بیس کور کا پیکیج
import 'welcome/login_page.dart'; // لاگ ان پیج کا امپورٹ راستہ

void main() async {
  // فلاتر اور پیکیجز کی بائنڈنگز کو یقینی بنانا
  WidgetsFlutterBinding.ensureInitialized();

  // فائر بیس کو محفوظ طریقے سے انیشلائز کرنا
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization skipped or failed: $e');
  }

  // ہائیو ڈیٹا بیس کو انیشلائز کرنا
  await Hive.initFlutter();

  // ⚠️ تمام 7 باکسز کو انیشلائز کرنا تاکہ ڈیٹا بیس مانیٹر میں ریڈ اسکرین ایرر نہ آئے
  await Hive.openBox('customerBox');
  await Hive.openBox('guarantorBox');
  await Hive.openBox('packageBox');
  await Hive.openBox('stockBox');
  await Hive.openBox('transactionBox');
  await Hive.openBox('expenseBox');
  await Hive.openBox('bankBox');

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
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginPage(),
    );
  }
}