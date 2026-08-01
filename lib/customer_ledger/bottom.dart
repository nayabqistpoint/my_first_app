import 'package:flutter/material.dart';
import 'customer_ledger_controller.dart'; // کنٹرولر کی امپورٹ

class LedgerBottomWidget extends StatelessWidget {
  final CustomerLedgerController controller;

  const LedgerBottomWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          // پیمنٹ آؤٹ بٹن (کیپسول شیپ)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const StadiumBorder(), // یہ کیپسول شیپ بناتا ہے
              ),
              onPressed: () {
                // یہاں ہم بعد میں پیمنٹ آؤٹ کا ڈائیلاگ یا فنکشن کال کریں گے
              },
              child: const Text("پیمنٹ آؤٹ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(width: 15), // بٹنوں کے درمیان فاصلہ
          // پیمنٹ ان بٹن (کیپسول شیپ)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const StadiumBorder(), // یہ کیپسول شیپ بناتا ہے
              ),
              onPressed: () {
                // یہاں ہم بعد میں پیمنٹ ان کا ڈائیلاگ یا فنکشن کال کریں گے
              },
              child: const Text("پیمنٹ ان", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}