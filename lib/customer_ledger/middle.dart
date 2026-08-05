import 'package:flutter/material.dart';
import 'customer_ledger_controller.dart';

class LedgerMiddleWidget extends StatelessWidget {
  final CustomerLedgerController controller;

  const LedgerMiddleWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
              Text("ملی", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
              SizedBox(width: 25),
              Text("دیے", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
              Spacer(),
              Text("بقایا / ٹوٹل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
              SizedBox(width: 15),
              Text("تفصیل اور تاریخ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

                    String type = 'get';
                    double amount = 0.0;
                    String dateStr = '';
                    String descStr = 'تفصیل...';
                    bool hasAttachment = false;
                    bool isPending = false; // پینڈنگ سٹیٹس چیک

                    if (tx is Map) {
                      type = tx['type']?.toString() ?? 'get';
                      amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
                      dateStr = tx['date']?.toString() ?? '';
                      descStr = tx['description']?.toString() ?? 'تفصیل...';
                      hasAttachment = tx['hasAttachment'] ?? false;
                      
                      // چیک کریں آیا انٹری پینڈنگ ہے
                      String status = tx['status']?.toString() ?? '';
                      if (status == 'pending' || tx['isApproved'] == false) {
                        isPending = true;
                      }
                    } else {
                      try {
                        type = tx.type?.toString() ?? 'get';
                        amount = double.tryParse(tx.amount?.toString() ?? '0') ?? 0.0;
                        dateStr = tx.date?.toString() ?? '';
                        descStr = tx.description?.toString() ?? 'تفصیل...';
                        hasAttachment = tx.hasAttachment ?? false;
                        
                        if (tx.status == 'pending' || tx.isApproved == false) {
                          isPending = true;
                        }
                      } catch (_) {}
                    }

                    bool isReceived = (type == 'received' || type == 'get' || type == 'paid');

                    // رننگ بیلنس کا حساب لگاتے ہوئے پینڈنگ انٹریز کو اگنور کرنا
                    double currentRunningBalance = 0.0;
                    for (int i = transactions.length - 1; i >= index; i--) {
                      var t = transactions[i];
                      if (t == null) continue;

                      String tType = 'get';
                      double tAmt = 0.0;
                      bool tIsPending = false;

                      if (t is Map) {
                        tType = t['type']?.toString() ?? 'get';
                        tAmt = double.tryParse(t['amount']?.toString() ?? '0') ?? 0.0;
                        if (t['status']?.toString() == 'pending' || t['isApproved'] == false) {
                          tIsPending = true;
                        }
                      } else {
                        try {
                          tType = t.type?.toString() ?? 'get';
                          tAmt = double.tryParse(t.amount?.toString() ?? '0') ?? 0.0;
                          if (t.status == 'pending' || t.isApproved == false) {
                            tIsPending = true;
                          }
                        } catch (_) {}
                      }

                      // پینڈنگ انٹریز کو رننگ بیلنس میں شامل نہیں کرنا
                      if (tIsPending) continue;

                      if (tType == 'given' || tType == 'give' || tType == 'paid' || tType == 'out') {
                        currentRunningBalance += tAmt;
                      } else if (tType == 'received' || tType == 'get') {
                        currentRunningBalance -= tAmt;
                      }
                    }

                    Color balanceColor = currentRunningBalance >= 0 ? Colors.red : Colors.green;

                    // 🌟 اگر انٹری پینڈنگ ہے تو اس کی ظاہری شکل کو مدھم (Opacity 0.4) کر دیں گے
                    return Opacity(
                      opacity: isPending ? 0.45 : 1.0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: Row(
                                    children: [
                                      Expanded(child: Center(child: Text(isReceived ? amount.toStringAsFixed(0) : "", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)))),
                                      Container(width: 1, height: 20, color: Colors.black26),
                                      Expanded(child: Center(child: Text(isReceived ? "" : amount.toStringAsFixed(0), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)))),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: balanceColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: balanceColor.withValues(alpha: 0.5), width: 0.8),
                                            ),
                                            child: Text(
                                              "بقایا: ${currentRunningBalance.abs().toStringAsFixed(0)}",
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: balanceColor),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (hasAttachment) ...[
                                            const Icon(Icons.attach_file, size: 13, color: Colors.grey),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(dateStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      // اگر پینڈنگ ہے تو تفصیل کے ساتھ واضح ٹیکسٹ شو ہو گا
                                      Text(
                                        isPending ? "$descStr (منظوری کا منتظر...)" : descStr, 
                                        style: TextStyle(
                                          fontSize: 12, 
                                          color: isPending ? Colors.orange[800] : Colors.black87,
                                          fontWeight: isPending ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.black12, thickness: 0.5, height: 1),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}