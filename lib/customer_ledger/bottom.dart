import 'package:flutter/material.dart';
import 'customer_ledger_controller.dart'; // کنٹرولر کی امپورٹ
// درست پاتھ: کسٹمر لیجر فولڈر سے نکل کر ہوم پیج اور پھر پیمنٹ ان اور پیمنٹ آؤٹ تک پہنچنے کا طریقہ
import '../home_page/transaction_forms/payment_in/payment_in_screen.dart';
import '../home_page/transaction_forms/payment_out/payment_out_screen.dart';

class LedgerBottomWidget extends StatelessWidget {
  final CustomerLedgerController controller;

  const LedgerBottomWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // یہ چیک کرتا ہے کہ آیا ایڈمن ہے یا کسٹمر (کنٹرولر کے مطابق)
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
          // پہلا بٹن (ایڈمن کے لیے: پیمنٹ آؤٹ | کسٹمر کے لیے: خریداری کی درخواست)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdmin ? Colors.red : Colors.orange[800],
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                if (isAdmin) {
                  // یہاں ایڈمن کے لیے پیمنٹ آؤٹ اسکرین اوپن ہو گی
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentOutScreen(),
                    ),
                  );
                } else {
                  // کسٹمر کے لیے خریداری کی درخواست (Purchase Request) کا فنکشن
                }
              },
              child: Text(
                isAdmin ? "پیمنٹ آؤٹ" : "خریداری کی درخواست",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 15), // بٹنوں کے درمیان فاصلہ
          
          // دوسرا بٹن (ایڈمن کے لیے: پیمنٹ ان | کسٹمر کے لیے: قسط ادا کریں)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdmin ? Colors.green : Colors.blue[800],
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                if (isAdmin) {
                  // یہاں ایڈمن کے لیے پیمنٹ ان اسکرین اوپن ہو گی
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentInScreen(),
                    ),
                  );
                } else {
                  // کسٹمر کے لیے قسط ادا کرنے کا بٹن
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