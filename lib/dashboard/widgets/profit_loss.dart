import 'package:flutter/material.dart';
import '../controller.dart'; // پاتھ کو آپ کے پروجیکٹ کے مطابق سیٹ کر دیا گیا ہے

class ProfitLossWidget extends StatelessWidget {
  const ProfitLossWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dashboardController,
      builder: (context, child) {
        // پرافٹ مائنس میں ہو تو ریڈ کلر، پلس میں ہو تو گرین کلر شو کرنے کی لاجک
        final bool isProfit = dashboardController.netProfit >= 0;
        final Color profitColor = isProfit ? Colors.green.shade700 : Colors.red;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              // 1. Total Investment Card (پہلے Other Income تھا، اب ٹوٹل انویسٹمنٹ ہے)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade400, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total Investment: ",
                        style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        "Rs. ${dashboardController.otherIncome.toStringAsFixed(0)}",
                        style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // 2. Profit/Loss Card (اب یہ کلیکیبل ہے تاکہ پاپ اپ کھل سکے)
              Expanded(
                child: InkWell(
                  onTap: () {
                    _showProfitLossDetailsDialog(context);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isProfit ? Colors.green.shade400 : Colors.red.shade400, width: 1.2), 
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profit/Loss اسمارٹ ٹیکسٹ
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            children: [
                              TextSpan(text: "Profit", style: TextStyle(color: Colors.green.shade700)),
                              const TextSpan(text: "/", style: TextStyle(color: Colors.black87)),
                              const TextSpan(text: "Loss: ", style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Rs. ${dashboardController.netProfit.toStringAsFixed(0)}",
                          style: TextStyle(color: profitColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
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

  // پرافٹ اور لاس کی تفصیلات دیکھنے کے لیے پاپ اپ ڈائیلاگ
  void _showProfitLossDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Profit & Loss Details", textAlign: TextAlign.right, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("ٹرانزیکشنز اور ڈسکاؤنٹس کی تفصیلات:", textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 12),
              // یہاں ہم نے بنیادی لسٹ یا رو کا ڈھانچہ رکھ دیا ہے
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Rs. 0", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Total Discounts", style: TextStyle(fontSize: 13)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Rs. ${dashboardController.netProfit.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const Text("Net Profit / Loss", style: TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("بند کریں"),
          ),
        ],
      ),
    );
  }
}