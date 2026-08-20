import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_first_app/customer_ledger/customer_ledger_controller.dart';
import 'package:my_first_app/customer_ledger/ledger_middle_helper.dart';

class LedgerMiddleWidget extends StatelessWidget {
  final CustomerLedgerController controller;
  const LedgerMiddleWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('transactionBox').listenable(),
      builder: (context, box, _) {
        final items = LedgerMiddleHelper.processTransactions(
          box: box, customerPhone: controller.customerPhone, isAdmin: controller.isAdmin,
        );

        if (items.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("کوئی ٹرانزیکشن موجود نہیں ہے", style: TextStyle(color: Colors.grey))));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final bool ok = item.isApproved;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: ok ? null : Border.all(color: Colors.green.shade600, width: 1.2),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Opacity(
                    opacity: ok ? 1.0 : 0.35,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Text("Rs. ${item.amount.toStringAsFixed(0)}", style: TextStyle(color: item.amountColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  // 🗓️ RTL ترتیب: (بائیں) year ➔ month ➔ day (دائیں)
                                  Text(item.year, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  const SizedBox(width: 3),
                                  Text(item.month, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  const SizedBox(width: 3),
                                  Text(item.day, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),

                                  const SizedBox(width: 4),
                                  const Icon(Icons.attach_file, size: 12, color: Colors.grey),
                                  const SizedBox(width: 6),

                                  SizedBox(
                                    width: 100, height: 24,
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: item.capColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: item.capColor, width: 1.2),
                                      ),
                                      child: Text(ok ? item.runningBalance.abs().toStringAsFixed(0) : "--", style: TextStyle(color: item.capColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(item.description, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (!ok)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(7))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hourglass_top_rounded, size: 13, color: Colors.green.shade900),
                          const SizedBox(width: 4),
                          Text("تصدیق کی جا رہی ہے، براہِ کرم انتظار فرمائیں...", style: TextStyle(fontSize: 10, color: Colors.green.shade900, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}