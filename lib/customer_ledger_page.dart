import 'package:flutter/material.dart';
import 'customer_ledger/top.dart'; // ٹاپ وزٹ کو امپورٹ کر لیا

class CustomerLedgerPage extends StatelessWidget {
  const CustomerLedgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ٹاپ والا حصہ (ہیڈر، بیلنس، بٹنز)
          LedgerTopWidget(),
          
          // مڈل اور باٹم ابھی خالی ہیں، ان پر بعد میں کام ہوگا
          Expanded(
            child: Center(
              child: Text("مڈل لسٹ کی جگہ (بعد میں بنے گی)"),
            ),
          ),
        ],
      ),
    );
  }
}