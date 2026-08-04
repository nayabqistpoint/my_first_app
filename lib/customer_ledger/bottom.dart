import 'package:flutter/material.dart';
import 'customer_ledger_controller.dart';
import '../home_page/transaction_forms/payment_in/payment_in_screen.dart';
import '../home_page/transaction_forms/payment_out/payment_out_screen.dart';
import '../features/pay_now/pay_now_widget.dart';
import '../features/purchase_now/purchase_now.dart';

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
          // پہلا بٹن: ایڈمن کے لیے 'پیمنٹ آؤٹ' اور کسٹمر کے لیے 'خریداری کی درخواست'
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
                } else {
                  // کسٹمر کے لیے خریداری کی درخواست (اب یہاں درست طریقے سے موبائل نمبر پاس ہو رہا ہے)
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PurchaseNow(
                        customerMobileNumber: controller.customerPhone,
                      ),
                    ),
                  );
                }
                controller.loadCustomerTransactions();
              },
              child: Text(
                isAdmin ? "پیمنٹ آؤٹ" : "خریداری کی درخواست",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 15),
          
          // دوسرا بٹن: ایڈمن کے لیے 'پیمنٹ ان' اور کسٹمر کے لیے 'قسط ادا کریں'
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
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentInScreen(
                        customerId: controller.customerPhone,
                      ),
                    ),
                  );
                } else {
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