import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../home_page/sections/sections_controller.dart';
import 'financial_controller.dart';

class ProfitLossWidget extends StatelessWidget {
  const ProfitLossWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.isBoxOpen('financialSummaryBox')
          ? Hive.box('financialSummaryBox').listenable()
          : ValueNotifier(null),
      builder: (context, _, child) {
        return ListenableBuilder(
          listenable: Listenable.merge([sectionsController, financialController]),
          builder: (context, child) {
            // 1. bankBox سے کیش + بینک
            double cashAndBank = 0.0;
            if (Hive.isBoxOpen('bankBox')) {
              var bankBox = Hive.box('bankBox');
              for (var key in bankBox.keys) {
                var value = bankBox.get(key);
                if (value != null) {
                  cashAndBank += double.tryParse(value.toString()) ?? 0.0;
                }
              }
            }

            // 2. stockBox سے اسٹاک
            double stockValue = 0.0;
            if (Hive.isBoxOpen('stockBox')) {
              var stockBox = Hive.box('stockBox');
              for (var key in stockBox.keys) {
                var item = stockBox.get(key);
                if (item is Map) {
                  double qty = double.tryParse(item['quantity']?.toString() ?? '0') ?? 0.0;
                  double price = double.tryParse(item['purchasePrice']?.toString() ?? '0') ?? 0.0;
                  stockValue += (qty * price);
                }
              }
            }

            // 3. فریزڈ انویسٹمنٹ (Locked Investment)
            double baseInvestment = financialController.calculateBaseInvestment(
              cashAndBank: cashAndBank,
              stockValue: stockValue,
              totalRed: sectionsController.totalRedAmount,
              totalGreen: sectionsController.totalGreenAmount,
            );

            // 4. لائیو پرافٹ / لاس (اخراجات/انکم کا ڈائریکٹ اثر)
            double netProfitLoss = financialController.calculateDynamicProfitLoss();

            final bool isProfit = netProfitLoss >= 0;
            final Color profitColor = isProfit ? Colors.green.shade700 : Colors.red;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  // Total Investment Card (فریز رہے گی)
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
                            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                          Text(
                            "Rs. ${baseInvestment.toStringAsFixed(0)}",
                            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Profit/Loss Card (ہر لمحہ لائیو اپ ڈیٹ ہوگی)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _showProfitLossDetailsDialog(context, netProfitLoss, baseInvestment);
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
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                children: [
                                  TextSpan(text: "Profit", style: TextStyle(color: Colors.green.shade700)),
                                  const TextSpan(text: "/", style: TextStyle(color: Colors.black87)),
                                  const TextSpan(text: "Loss: ", style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "Rs. ${netProfitLoss.toStringAsFixed(0)}",
                              style: TextStyle(color: profitColor, fontWeight: FontWeight.bold, fontSize: 15),
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
      },
    );
  }

  void _showProfitLossDetailsDialog(BuildContext context, double profitLoss, double investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("پرافٹ اینڈ لاس کی تفصیلات", textAlign: TextAlign.right, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("کاروباری پوزیشن:", textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Rs. ${investment.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text("بنیادی انویسٹمنٹ (فریز)", style: TextStyle(fontSize: 12)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rs. ${profitLoss.toStringAsFixed(0)}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: profitLoss >= 0 ? Colors.green : Colors.red),
                  ),
                  const Text("خالص نفع / نقصان", style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("بند کریں"),
          ),
        ],
      ),
    );
  }
}