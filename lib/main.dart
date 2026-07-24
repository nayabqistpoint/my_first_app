import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ہائیو کا پیکیج
import 'home_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ہائیو کو انیشیلائز کیا
  await Hive.initFlutter(); 

  // اسٹاک کے لیے ڈیٹا بیس کا باکس کھول رہے ہیں
  await Hive.openBox('stockBox');

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
      home: const HomePage(), 
    );
  }
}