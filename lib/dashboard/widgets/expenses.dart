import 'package:flutter/material.dart';
import '../controller.dart'; // پاتھ کو آپ کے پروجیکٹ کے مطابق سیٹ کر دیا گیا ہے

class ExpensesWidget extends StatelessWidget {
  const ExpensesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // ٹیکسٹ کنٹرولر نیا ایکسپنس کیٹیگری نام لکھنے کے لیے
    final TextEditingController expenseNameController = TextEditingController();

    return ListenableBuilder(
      listenable: dashboardController,
      builder: (context, child) {
        // کنٹرولر سے ایکسپنسز کی لسٹ کو Map سے List میں تبدیل کرنا
        final expenseEntries = dashboardController.expenseCategories.entries.toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. ہیڈر: پلس پاپ اپ، گرینڈ ٹوٹل اور ہیڈنگ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // پلس بٹن جو بالکل اپنے ساتھ ہی سفید بیک گراؤنڈ والا پاپ اپ کھولے گا
                    PopupMenuButton<int>(
                      offset: const Offset(0, 30), // پاپ اپ کو بالکل بٹن کے نیچے لانے کے لیے
                      color: Colors.white, // سفید بیک گراؤنڈ
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      icon: const Icon(Icons.add_circle, color: Colors.red, size: 26),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          enabled: false, // مینو کلک بند، صرف ڈبہ دکھانے کے لیے
                          child: SizedBox(
                            width: 200,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  "Add Expense Category",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: expenseNameController,
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                    hintText: "کیٹیگری کا نام لکھیں",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    if (expenseNameController.text.isNotEmpty) {
                                      // کنٹرولر میں نیا ایکسپنس صفر رقم کے ساتھ ایڈ کرنا
                                      dashboardController.addExpenseCategory(expenseNameController.text, 0.0);
                                      expenseNameController.clear();
                                      Navigator.pop(context); // پاپ اپ بند کرنے کے لیے
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE53935),
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                  ),
                                  child: const Text("Add", style: TextStyle(color: Colors.white, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // گرینڈ ٹوٹل رقم (کنٹرولر کے لائیو ڈیٹا سے)
                    Text(
                      "Rs. ${dashboardController.totalExpenses.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Text(
                  "Expenses List", 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // 2. ایکسپنسز بلاک: کنٹرولر کے لائیو ڈیٹا کے ساتھ اسکرول ایبل لسٹ
            Container(
              height: 125, // ہائٹ فکس کر دی تاکہ صرف مطلوبہ لائنیں آئیں
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: expenseEntries.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final expenseName = expenseEntries[index].key;
                    final expenseAmount = expenseEntries[index].value;

                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            _showExpenseAdjustmentDialog(context, expenseName, expenseAmount);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Rs. ${expenseAmount.toStringAsFixed(0)}", 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  expenseName,
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (index < expenseEntries.length - 1)
                          const Divider(color: Colors.black12, height: 1),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // کسی بھی ایکسپنس کی رقم کو اپ ڈیٹ کرنے کا پاپ اپ
  void _showExpenseAdjustmentDialog(BuildContext context, String expenseName, double currentAmount) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expenseName, textAlign: TextAlign.right, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("موجودہ رقم: Rs. ${currentAmount.toStringAsFixed(0)}", style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: "رقم درج کریں",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null) {
                dashboardController.adjustExpenseAmount(expenseName, -amount);
              }
              Navigator.pop(context);
            },
            child: const Text("رقم کم کریں (-)", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null) {
                dashboardController.adjustExpenseAmount(expenseName, amount);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("رقم ایڈ کریں (+)", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}