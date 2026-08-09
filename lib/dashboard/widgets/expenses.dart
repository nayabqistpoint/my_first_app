import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ExpensesWidget extends StatelessWidget {
  const ExpensesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('expenseBox')) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('expenseBox').listenable(),
      builder: (context, box, child) {
        Map<String, Map<String, dynamic>> categoriesMap = {};
        double totalExpenses = 0.0;
        double totalIncome = 0.0;

        // ۱۔ اگر باکس نیا ہو تو ڈیفالٹ کیٹیگریز ان کی نوعیت کے ساتھ ایڈ کریں
        if (box.isEmpty) {
          box.put('Direct Expenses', {'amount': 0.0, 'isIncome': false});
          box.put('Indirect Expenses', {'amount': 0.0, 'isIncome': false});
          box.put('Discounts', {'amount': 0.0, 'isIncome': false});
          box.put('Other Income', {'amount': 0.0, 'isIncome': true});
        }

        // ۲۔ ہائیو سے لائیو ڈیٹا کی لوڈنگ اور بیکورڈ مائگریشن ہینڈلنگ
        for (var key in box.keys) {
          String keyStr = key.toString();
          var rawVal = box.get(key);

          double amt = 0.0;
          bool isIncome = keyStr.trim().toLowerCase() == 'other income';

          if (rawVal is Map) {
            amt = (rawVal['amount'] ?? 0.0).toDouble();
            isIncome = rawVal['isIncome'] ?? isIncome;
          } else if (rawVal is num) {
            amt = rawVal.toDouble();
          }

          categoriesMap[keyStr] = {'amount': amt, 'isIncome': isIncome};

          if (isIncome) {
            totalIncome += amt;
          } else {
            totalExpenses += amt;
          }
        }

        // ۳۔ نیٹ بیلنس (Expenses - Income)
        double netBalance = totalExpenses - totalIncome;
        bool isNetExpense = netBalance >= 0;

        final expenseEntries = categoriesMap.entries.toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ہیڈر: پلس پاپ اپ، فارمولا ڈسپلے اور ہیڈنگ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PopupMenuButton<int>(
                      offset: const Offset(0, 30),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      icon: const Icon(Icons.add_circle, color: Colors.red, size: 26),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          enabled: false,
                          child: _AddCategoryDialogContent(box: box),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),

                    // 🔥 فارمولا ڈسپلے: (+آمدن - اخراجات) Net: رقم 🔥
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: "(+${totalIncome.toStringAsFixed(0)} ",
                            style: TextStyle(color: Colors.green[700]),
                          ),
                          TextSpan(
                            text: "-${totalExpenses.toStringAsFixed(0)}) ",
                            style: TextStyle(color: Colors.red[700]),
                          ),
                          TextSpan(
                            text: "Net: ${isNetExpense ? '-' : '+'}Rs.${netBalance.abs().toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: isNetExpense ? Colors.red[800] : Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Text(
                  "Expenses List",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // اسکرول ایبل کیٹیگری لسٹ
            Container(
              height: 125,
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
                    final double expenseAmount = expenseEntries[index].value['amount'];
                    final bool isIncomeCategory = expenseEntries[index].value['isIncome'];

                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            _showExpenseAdjustmentDialog(context, box, expenseName, expenseAmount, isIncomeCategory);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${isIncomeCategory ? '+' : '-'} Rs. ${expenseAmount.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isIncomeCategory ? Colors.green[700] : Colors.red[700],
                                  ),
                                ),
                                Text(
                                  expenseName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isIncomeCategory ? Colors.green[800] : Colors.black87,
                                  ),
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

  // پاپ اپ پلس/مائنس رقم ایڈجسٹمنٹ
  void _showExpenseAdjustmentDialog(BuildContext context, Box box, String expenseName, double currentAmount, bool isIncome) {
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
                box.put(expenseName, {'amount': currentAmount - amount, 'isIncome': isIncome});
              }
              Navigator.pop(context);
            },
            child: const Text("رقم کم کریں (-)", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null) {
                box.put(expenseName, {'amount': currentAmount + amount, 'isIncome': isIncome});
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

/// نئی کیٹیگری ایڈ کرنے کا سمارٹ پاپ اپ ڈائیلاگ
class _AddCategoryDialogContent extends StatefulWidget {
  final Box box;
  const _AddCategoryDialogContent({required this.box});

  @override
  State<_AddCategoryDialogContent> createState() => _AddCategoryDialogContentState();
}

class _AddCategoryDialogContentState extends State<_AddCategoryDialogContent> {
  final TextEditingController _nameController = TextEditingController();
  bool _isIncomeType = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Add New Category",
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _nameController,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              hintText: "کیٹیگری کا نام لکھیں",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<bool>(
            initialValue: _isIncomeType,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: false,
                child: Text("خرچہ (Expense)", style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              DropdownMenuItem(
                value: true,
                child: Text("آمدن (Income)", style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _isIncomeType = val;
                });
              }
            },
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                final name = _nameController.text.trim();
                widget.box.put(name, {
                  'amount': 0.0,
                  'isIncome': _isIncomeType,
                });
                _nameController.clear();
                Navigator.pop(context);
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
    );
  }
}