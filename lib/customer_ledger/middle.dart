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
            height: 38,
            child: TextField(
              onChanged: (value) => controller.setSearchQuery(value),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "تلاش کریں...",
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
              ),
            ),
          ),
        ),

        const Divider(color: Colors.black12, thickness: 1, height: 1),

        // ۲۔ کلین لسٹ
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

                    Map<String, String> dateMap = {'day': '', 'month': '', 'year': ''};
                    String descStr = '';
                    bool hasAttachment = false;
                    bool isPending = false;

                    if (tx is Map) {
                      dateMap = CustomerLedgerController.getParsedUrduDate(tx['date'], tx['timestamp']);
                      descStr = tx['description']?.toString().trim() ?? tx['remarks']?.toString().trim() ?? '';
                      hasAttachment = tx['hasAttachment'] ?? false;
                      if (tx['status']?.toString() == 'pending' || tx['isApproved'] == false) {
                        isPending = true;
                      }
                    } else {
                      try {
                        dateMap = CustomerLedgerController.getParsedUrduDate(tx.date, tx.timestamp);
                        descStr = tx.description?.toString().trim() ?? '';
                        hasAttachment = tx.hasAttachment ?? false;
                        if (tx.status == 'pending' || tx.isApproved == false) {
                          isPending = true;
                        }
                      } catch (_) {}
                    }

                    // 🔒 رقم اور ٹائپ
                    double displayAmt = CustomerLedgerController.getTransactionAmount(tx);
                    bool isGreen = CustomerLedgerController.isGreenTransaction(tx);
                    Color txnColor = isGreen ? Colors.green : Colors.red;

                    // 💰 رننگ بیلنس اور کیپسول کا رنگ
                    double runningBal = controller.getRunningBalanceAtIndex(index);
                    Color balanceColor = runningBal >= 0 ? Colors.green : Colors.red;

                    return Opacity(
                      opacity: isPending ? 0.45 : 1.0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🟢/🔴 ۱۔ بائیں طرف رقم
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    displayAmt.toStringAsFixed(0),
                                    style: TextStyle(
                                      color: txnColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                // ۲۔ تفصیل، تاریخ اور دائیں طرف کا کیپسول
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          if (hasAttachment) ...[
                                            const Icon(Icons.attach_file, size: 12, color: Colors.grey),
                                            const SizedBox(width: 3),
                                          ],
                                          
                                          // 🗓️ 🎯 پکا حل: 8 اگست 2026 بالکل سیدھا دکھانے کے لیے
                                          if (dateMap['day']!.isNotEmpty) ...[
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // سال
                                                Text(
                                                  dateMap['year']!,
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                                ),
                                                const SizedBox(width: 4),
                                                // مہینہ
                                                Text(
                                                  dateMap['month']!,
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                                ),
                                                const SizedBox(width: 4),
                                                // دن (تاریخ)
                                                Text(
                                                  dateMap['day']!,
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ] else ...[
                                            Text(
                                              dateMap['month']!,
                                              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                            ),
                                          ],

                                          const SizedBox(width: 8),

                                          // 🎯 ۳۔ دائیں سائیڈ کا فکسڈ کیپسول
                                          SizedBox(
                                            width: 100,
                                            height: 26,
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(15),
                                                border: Border.all(color: balanceColor, width: 1.3),
                                              ),
                                              child: Text(
                                                runningBal.abs().toStringAsFixed(0),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: balanceColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 6),

                                      // تفصیل
                                      Text(
                                        descStr.isNotEmpty 
                                            ? (isPending ? "$descStr (منظوری کا منتظر...)" : descStr)
                                            : (isPending ? "تفصیل... (منظوری کا منتظر...)" : "تفصیل..."), 
                                        style: TextStyle(
                                          fontSize: 12, 
                                          color: descStr.isNotEmpty 
                                              ? (isPending ? Colors.orange[800] : Colors.black87)
                                              : Colors.black38,
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