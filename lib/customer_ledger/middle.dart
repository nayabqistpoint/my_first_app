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
              Text("تاریخ اور تفصیل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
              SizedBox(width: 20),
              Text("بقایا / ٹوٹل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                    double rawAmount = 0.0;
                    Map<String, String> dateMap = {'day': '', 'month': '', 'year': ''};
                    String descStr = '';
                    bool hasAttachment = false;
                    bool isPending = false;

                    if (tx is Map) {
                      type = tx['type']?.toString().toLowerCase() ?? 'get';

                      if (type == 'purchase' && tx['remainingBalance'] != null) {
                        rawAmount = double.tryParse(tx['remainingBalance']?.toString() ?? '0') ?? 0.0;
                      } else {
                        rawAmount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
                      }

                      dateMap = CustomerLedgerController.getParsedUrduDate(tx['date'], tx['timestamp']);
                      descStr = tx['description']?.toString().trim() ?? tx['remarks']?.toString().trim() ?? '';
                      hasAttachment = tx['hasAttachment'] ?? false;
                      
                      String status = tx['status']?.toString() ?? '';
                      if (status == 'pending' || tx['isApproved'] == false) {
                        isPending = true;
                      }
                    } else {
                      try {
                        type = tx.type?.toString().toLowerCase() ?? 'get';

                        if (type == 'purchase' && tx.remainingBalance != null) {
                          rawAmount = double.tryParse(tx.remainingBalance?.toString() ?? '0') ?? 0.0;
                        } else {
                          rawAmount = double.tryParse(tx.amount?.toString() ?? '0') ?? 0.0;
                        }

                        dateMap = CustomerLedgerController.getParsedUrduDate(tx.date, tx.timestamp);
                        descStr = tx.description?.toString().trim() ?? '';
                        hasAttachment = tx.hasAttachment ?? false;
                        
                        if (tx.status == 'pending' || tx.isApproved == false) {
                          isPending = true;
                        }
                      } catch (_) {}
                    }

                    // 🎯 پرچیز اور عام ٹرانزیکشنز کے لیے ریڈ (دیے) اور گرین (ملی) کا حتمی فیصلہ
                    bool isReceived = false;
                    if (type == 'purchase') {
                      // پرچیز میں اگر رقم پازیٹو ہے تو 'ملی' (Green)، اگر نیگیٹو ہے تو 'دیے' (Red)
                      isReceived = rawAmount >= 0;
                    } else {
                      // عام پیمنٹ ان / آؤٹ اینٹریز کے لیے
                      isReceived = (type == 'received' || type == 'get' || type == 'in' || type == 'payment_in');
                    }

                    // 💰 رننگ بیلنس کی لاجک
                    double currentRunningBalance = 0.0;
                    for (int i = transactions.length - 1; i >= index; i--) {
                      var t = transactions[i];
                      if (t == null) continue;

                      String tType = 'get';
                      double tAmt = 0.0;
                      bool tIsPending = false;

                      if (t is Map) {
                        tType = t['type']?.toString().toLowerCase() ?? 'get';

                        if (tType == 'purchase' && t['remainingBalance'] != null) {
                          tAmt = double.tryParse(t['remainingBalance']?.toString() ?? '0') ?? 0.0;
                        } else {
                          tAmt = double.tryParse(t['amount']?.toString() ?? '0') ?? 0.0;
                        }

                        if (t['status']?.toString() == 'pending' || t['isApproved'] == false) {
                          tIsPending = true;
                        }
                      } else {
                        try {
                          tType = t.type?.toString().toLowerCase() ?? 'get';

                          if (tType == 'purchase' && t.remainingBalance != null) {
                            tAmt = double.tryParse(t.remainingBalance?.toString() ?? '0') ?? 0.0;
                          } else {
                            tAmt = double.tryParse(t.amount?.toString() ?? '0') ?? 0.0;
                          }

                          if (t.status == 'pending' || t.isApproved == false) {
                            tIsPending = true;
                          }
                        } catch (_) {}
                      }

                      if (tIsPending) continue;

                      if (tType == 'given' || tType == 'give' || tType == 'out' || tType == 'payment_out' || tType == 'paid') {
                        currentRunningBalance += tAmt;
                      } else if (tType == 'received' || tType == 'get' || tType == 'in' || tType == 'payment_in') {
                        currentRunningBalance -= tAmt;
                      } else if (tType == 'purchase') {
                        // پرچیز رقم اپنے سائن کے حساب سے بیلنس میں جڑے گی
                        currentRunningBalance += tAmt;
                      }
                    }

                    Color balanceColor = currentRunningBalance >= 0 ? Colors.red : Colors.green;

                    return Opacity(
                      opacity: isPending ? 0.45 : 1.0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Row(
                              children: [
                                // 🟢/🔴 رقم کا کالم (ملی Green / دیے Red)
                                SizedBox(
                                  width: 110,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            isReceived ? rawAmount.abs().toStringAsFixed(0) : "", 
                                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      Container(width: 1, height: 20, color: Colors.black26),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            isReceived ? "" : rawAmount.abs().toStringAsFixed(0), 
                                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                
                                // 🎯 دائیں سائیڈ: بولڈ بقایا بکس، پھر تاریخ [7] [اگست] [2026]
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          if (hasAttachment) ...[
                                            const Icon(Icons.attach_file, size: 13, color: Colors.grey),
                                            const SizedBox(width: 4),
                                          ],
                                          
                                          // 🗓️ تاریخ ترتیبی ڈسپلے (7 اگست 2026)
                                          if (dateMap['day']!.isNotEmpty) ...[
                                            Text(dateMap['year']!, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                                            const SizedBox(width: 3),
                                            Text(dateMap['month']!, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                                            const SizedBox(width: 3),
                                            Text(dateMap['day']!, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                          ] else ...[
                                            Text(dateMap['month']!, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                                          ],

                                          const SizedBox(width: 8),
                                          
                                          // 💰 دائیں اینڈ پر بولڈ بقایا بکس
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
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      // 2. نیچے تفصیل
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