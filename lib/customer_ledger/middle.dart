import 'package:flutter/material.dart';
import 'customer_ledger_controller.dart'; // فولڈر کے اندر ہونے کی وجہ سے سیدھا امپورٹ

class LedgerMiddleWidget extends StatelessWidget {
  final CustomerLedgerController controller;

  const LedgerMiddleWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // کنٹرولر سے فلٹر شدہ لسٹ حاصل کر رہے ہیں
    final transactions = controller.filteredTransactions;

    return Column(
      children: [
        // ۱۔ سرچ بار
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: SizedBox(
            height: 35,
            child: TextField(
              onChanged: (value) => controller.setSearchQuery(value),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "تلاش کریں...",
                hintStyle: const TextStyle(fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ),
        ),

        // ۲۔ ہیڈنگ
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("ملی", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
              SizedBox(width: 45),
              Text("دیے", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
              Spacer(),
              Text("تفصیل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ),
        const Divider(color: Colors.black, thickness: 1.2, height: 1),

        // ۳۔ ٹرانزیکشن لسٹ
        Expanded(
          child: transactions.isEmpty
              ? const Center(
                  child: Text(
                    "کوئی ٹرانزیکشن موجود نہیں",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    bool isReceived = tx['type'] == 'received';
                    Color entryColor = isReceived ? Colors.green : Colors.red;
                    
                    double amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
                    String dateStr = tx['date']?.toString() ?? '';
                    String descStr = tx['description']?.toString() ?? 'تفصیل...';
                    bool hasAttachment = tx['hasAttachment'] ?? false;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 110,
                                    child: Row(
                                      children: [
                                        Expanded(child: Center(child: Text(isReceived ? amount.toStringAsFixed(0) : "", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 17)))),
                                        Container(width: 1.5, height: 20, color: Colors.black38),
                                        Expanded(child: Center(child: Text(isReceived ? "" : amount.toStringAsFixed(0), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 17)))),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      if (hasAttachment) ...[
                                        Icon(Icons.attach_file, size: 14, color: entryColor),
                                        const SizedBox(width: 5),
                                      ],
                                      Text(dateStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      const SizedBox(width: 10),
                                      Text(amount.toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: entryColor)),
                                    ],
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  descStr, 
                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.black12, thickness: 0.5, height: 1),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}