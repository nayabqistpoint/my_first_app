import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'balance_helper.dart';
import '../../../customer_ledger_page.dart';

class CustomerRowUI extends StatelessWidget {
  final String name;
  final String phone;
  final String day;
  final String month;
  final String year;
  final String description;

  const CustomerRowUI({
    super.key,
    required this.name,
    required this.phone,
    this.day = "14",
    this.month = "اگست",
    this.year = "2026",
    this.description = "",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, _, _) => CustomerLedgerPage(
              customerData: {
                'name': name,
                'phone': phone,
                'customerName': name,
                'customerPhone': phone,
                'customerAddress': description,
              },
            ),
            transitionDuration: Duration.zero,
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 2.5,
        margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // لائیو ٹرانزیکشن بیلنس
              if (Hive.isBoxOpen('transactionBox'))
                ValueListenableBuilder(
                  valueListenable: Hive.box('transactionBox').listenable(),
                  builder: (context, Box box, _) {
                    double bal = BalanceHelper.calculateCustomerBalance(box, phone);
                    return Text(
                      "Rs ${bal.abs().toStringAsFixed(0)}",
                      style: TextStyle(
                        color: BalanceHelper.getAmountColor(bal),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    );
                  },
                )
              else
                const Text("Rs 0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),

              // کسٹمر تفاصیل + تاریخ + پاسپورٹ فریم
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🎯 دائیں سے بائیں ترتیب: [2026] [اگست] [14] [نام]
                          Text(year, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(width: 3),
                          Text(month, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(width: 3),
                          Text(day, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(width: 8),
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      if (description.isNotEmpty)
                        Text(description, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(width: 10),

                  // پاسپورٹ فریم (سفید بیک گراؤنڈ اور ریڈ لائننگ)
                  Container(
                    width: 40,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade700, width: 1.5),
                    ),
                    child: Icon(Icons.person, size: 28, color: Colors.red.shade700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}