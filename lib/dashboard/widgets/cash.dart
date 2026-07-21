import 'package:flutter/material.dart';
import '../controller.dart';

class CashWidget extends StatelessWidget {
  const CashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController bankNameController = TextEditingController();

    return ListenableBuilder(
      listenable: dashboardController,
      builder: (context, child) {
        final bankEntries = dashboardController.bankBalances.entries.toList();
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ۱۔ اوپر والا حصہ: Bank Balance اور Cash in Hand بلاک
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // بینک بیلنس بلاک
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Rs. ${dashboardController.totalBankBalance.toStringAsFixed(0)}",
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          const SizedBox(height: 2),
                          const Text("Bank Balance", style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // کیش ان ہینڈ بلاک (کلک کرنے پر پاپ اپ آئے گا)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _showCashAdjustmentDialog(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Rs. ${dashboardController.cashInHand.toStringAsFixed(0)}",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            const SizedBox(height: 2),
                            const Text("Cash In Hand", style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ۲۔ بینک لسٹ کا ہیڈر (نیا بینک ایڈ کرنے والا پلس بٹن)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      PopupMenuButton<int>(
                        offset: const Offset(0, 30),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        icon: const Icon(Icons.add_circle, color: Colors.blue, size: 26),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            enabled: false,
                            child: SizedBox(
                              width: 200,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Add Bank",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: bankNameController,
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      hintText: "بینک کا نام لکھیں",
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (bankNameController.text.isNotEmpty) {
                                        // نیا بینک صفر بیلنس یا ڈیفولت ویلیو کے ساتھ لسٹ میں محفوظ ہو جائے گا
                                        dashboardController.updateBankBalance(bankNameController.text, 0.0);
                                        bankNameController.clear();
                                        Navigator.pop(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
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
                      Text(
                        "Rs. ${dashboardController.totalBankBalance.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.blue),
                      ),
                    ],
                  ),
                  const Text(
                    "Banks List",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // ۳۔ بینک لسٹ بلاک (ہر بینک پر کلک کرنے سے رقم کم یا زیادہ کرنے کا پاپ اپ کھلے گا)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: bankEntries.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final bankName = bankEntries[index].key;
                        final bankAmount = bankEntries[index].value;

                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                _showBankAdjustmentDialog(context, bankName, bankAmount);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Rs. ${bankAmount.toStringAsFixed(0)}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      bankName,
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < bankEntries.length - 1)
                              const Divider(color: Colors.black12, height: 1),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // کیش ان ہینڈ اپ ڈیٹ کرنے کا پاپ اپ
  void _showCashAdjustmentDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("کیش ان ہینڈ اپ ڈیٹ کریں", textAlign: TextAlign.right, style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: "رقم درج کریں",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null) {
                dashboardController.updateCash(-amount);
              }
              Navigator.pop(context);
            },
            child: const Text("رقم نکالیں (-)", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null) {
                dashboardController.updateCash(amount);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("جمع کریں (+)", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // بینک بیلنس اپ ڈیٹ کرنے کا پاپ اپ
  void _showBankAdjustmentDialog(BuildContext context, String bankName, double currentAmount) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bankName, textAlign: TextAlign.right, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("موجودہ بیلنس: Rs. ${currentAmount.toStringAsFixed(0)}", style: const TextStyle(color: Colors.black54)),
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
                dashboardController.adjustBankBalance(bankName, -amount);
              }
              Navigator.pop(context);
            },
            child: const Text("رقم نکالیں (-)", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null) {
                dashboardController.adjustBankBalance(bankName, amount);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("جمع کریں (+)", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}