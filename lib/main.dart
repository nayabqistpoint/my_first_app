import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ہائیو فلٹر کا پیکیج
import 'package:firebase_core/firebase_core.dart'; // فائر بیس کور کا پیکیج
import 'welcome/login_page.dart'; // لاگ ان پیج کا امپورٹ راستہ

void main() async {
  // فلاتر اور پیکیجز کی بائنڈنگز کو یقینی بنانا
  WidgetsFlutterBinding.ensureInitialized();

  // فائر بیس کو محفوظ طریقے سے انیشلائز کرنا (تاکہ براؤزر یا کسی بھی ڈیوائس پر ایپ رکے نہیں)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization skipped or failed: $e');
  }

  // ہائیو ڈیٹا بیس کو انیشلائز کرنا
  await Hive.initFlutter();

  // ملٹی باکسز کا نظام (اسٹاک، بینک، کسٹمر اور ٹرانزیکشنز کے لیے)
  await Hive.openBox('stockBox');
  await Hive.openBox('bankBox');
  await Hive.openBox('customerBox');
  await Hive.openBox('transactionBox');

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