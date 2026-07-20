import 'package:flutter/material.dart';
import 'customer_ledger/top.dart';    // ٹاپ فائل امپورٹڈ
import 'customer_ledger/middle.dart'; // مڈل فائل امپورٹڈ

class CustomerLedgerPage extends StatelessWidget {
  const CustomerLedgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ۱۔ ٹاپ والا حصہ (ہیڈر، بیلنس، بٹنز)
          LedgerTopWidget(),
          
          // ۲۔ مڈل والا حصہ (سرچ، ہیڈر اور لسٹ)
          // Expanded استعمال کیا ہے تاکہ لسٹ باقی ساری جگہ لے لے
          Expanded(
            child: LedgerMiddleWidget(),
          ),
          
          // نوٹ: باٹم (bottom.dart) ابھی باقی ہے، وہ بعد میں یہاں لگے گا
        ],
      ),
    );
  }
}