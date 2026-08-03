import 'package:flutter/material.dart';
import 'customer_ledger_controller.dart'; // کنٹرولر کی امپورٹ
import '../home_page/transaction_forms/payment_in/payment_in_screen.dart'; // ایڈمن کے لیے پیمنٹ ان اسکرین
import '../home_page/transaction_forms/payment_out/payment_out_screen.dart';
import '../features/pay_now/pay_now_widget.dart'; // کسٹمر کے لیے نیا PayNowWidget

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
          // پہلا بٹن: پیمنٹ آؤٹ / خریداری کی درخواست
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
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentOutScreen(
                        customerId: controller.customerPhone,
                      ),
                    ),
                  );
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
          
          // دوسرا بٹن: ایڈمن کے لیے 'پیمنٹ ان' (PaymentInScreen) اور کسٹمر کے لیے 'قسط ادا کریں' (PayNowWidget)
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
                  // ایڈمن کے لیے پرانی پیمنٹ ان اسکرین کھلے گی
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentInScreen(
                        customerId: controller.customerPhone,
                      ),
                    ),
                  );
                } else {
                  // کسٹمر کے لیے نیا PayNowWidget کھلے گا
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PayNowWidget(),
                    ),
                  );
                }
                controller.loadCustomerTransactions();
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