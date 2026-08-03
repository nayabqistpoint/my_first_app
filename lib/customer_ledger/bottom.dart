import 'package:flutter/material.dart';
import 'customer_ledger_controller.dart'; // کنٹرولر کی امپورٹ
import '../home_page/transaction_forms/payment_in/payment_in_screen.dart';
import '../home_page/transaction_forms/payment_out/payment_out_screen.dart';

class LedgerBottomWidget extends StatelessWidget {
  final CustomerLedgerController controller;

  const LedgerBottomWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    bool isAdmin = true;
    try {
      isAdmin = (controller as dynamic).isAdmin ?? true;
    } catch (_) {
      isAdmin = true;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          // پہلا بٹن: پیمنٹ آؤٹ
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdmin ? Colors.red : Colors.orange[800],
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const StadiumBorder(),
              ),
              onPressed: () async {
                if (isAdmin) {
                  // 🔑 await لگایا گیا ہے تاکہ واپس آتے ہی ڈیٹا ریفریش ہو جائے
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentOutScreen(
                        customerId: controller.customerPhone,
                      ),
                    ),
                  );
                  // واپس آتے ہی لیجر کا ڈیٹا دوبارہ لوڈ ہو گا
                  controller.loadCustomerTransactions();
                }
              },
              child: Text(
                isAdmin ? "پیمنٹ آؤٹ" : "خریداری کی درخواست",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 15),
          
          // دوسرا بٹن: پیمنٹ ان
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdmin ? Colors.green : Colors.blue[800],
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const StadiumBorder(),
              ),
              onPressed: () async {
                if (isAdmin) {
                  // 🔑 await لگایا گیا ہے تاکہ واپس آتے ہی ڈیٹا ریفریش ہو جائے
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentInScreen(
                        customerId: controller.customerPhone,
                      ),
                    ),
                  );
                  // واپس آتے ہی لیجر کا ڈیٹا دوبارہ لوڈ ہو گا
                  controller.loadCustomerTransactions();
                }
              },
              child: Text(
                isAdmin ? "پیمنٹ ان" : "قسط ادا کریں",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}