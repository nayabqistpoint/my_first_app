import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // پرووائیڈر کو امپورٹ کریں
import 'calculater/calculater_controller.dart'; // کنٹرولر کو امپورٹ کریں
import 'calculater/calculater_header.dart';
import 'calculater/calculater_list.dart';

class InstallmentCalculaterPage extends StatelessWidget {
  const InstallmentCalculaterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // یہاں Provider کو لپیٹنا (Wrap) ضروری ہے تاکہ ڈیٹا کنٹرولر تک پہنچے
    return ChangeNotifierProvider(
      create: (context) => CalculaterController(),
      child: const Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CalculaterHeader(), 
              Expanded(child: CalculaterList()), 
            ],
          ),
        ),
      ),
    );
  }
}