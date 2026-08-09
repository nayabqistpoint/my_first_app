import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FinancialController extends ChangeNotifier {
  static const String _boxName = 'financialSummaryBox';

  Box get _financialBox => Hive.box(_boxName);

  // 🎯 1. لائیو کل انویسٹمنٹ (Net Worth) کی درست کیلکولیشن
  double calculateNetWorth({
    required double cashAndBank,
    required double stockValue,
    required double totalRed,
    required double totalGreen,
  }) {
    // بنیادی رقم (کیش/بینک + اسٹاک + لینے ہیں - دینے ہیں)
    double netWorth = (cashAndBank + stockValue + totalRed) - totalGreen;

    double totalIncomeAdded = 0.0;
    double totalExpenseDeducted = 0.0;

    // اخراجات اور دیگر آمدنی (expenseBox) کا براہ راست حساب
    if (Hive.isBoxOpen('expenseBox')) {
      var expenseBox = Hive.box('expenseBox');

      for (var key in expenseBox.keys) {
        var item = expenseBox.get(key);

        if (item is Map) {
          double amount = double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0;

          bool isIncome = item['isIncome'] == true ||
              item['type']?.toString().toLowerCase() == 'income' ||
              item['isIncome']?.toString().toLowerCase() == 'true';

          if (isIncome) {
            // آمدنی ➔ انویسٹمنٹ میں جمع (Plus)
            netWorth += amount;
            totalIncomeAdded += amount;
          } else {
            // اخراجات ➔ انویسٹمنٹ میں سے نفی (Minus)
            netWorth -= amount;
            totalExpenseDeducted += amount;
          }
        }
      }
    }

    // ہائیو مانیٹر کے لیے محفوظ کرنا
    if (Hive.isBoxOpen(_boxName)) {
      _financialBox.put('currentNetWorth', netWorth);

      String breakdown =
          "کیش و بینک ($cashAndBank) + اسٹاک ($stockValue) + لینے ہیں ($totalRed) - دینے ہیں ($totalGreen) + آمدنی ($totalIncomeAdded) - اخراجات ($totalExpenseDeducted) = $netWorth";
      _financialBox.put('investmentBreakdown', breakdown);
    }

    return netWorth;
  }

  // 🎯 2. خودکار پرافٹ اینڈ لاس کی ایکوریٹ کیلکولیشن
  double calculateAutoProfitLoss({
    required double currentNetWorth,
    required double cashAndBank,
    required double stockValue,
    required double totalRed,
    required double totalGreen,
  }) {
    if (!Hive.isBoxOpen(_boxName)) return 0.0;

    // بیس انویسٹمنٹ (بغیر کسی نفع/نقصان کے اصل رقم)
    double baseNetWorth = currentNetWorth;

    // اگر پرانی تاریخوں کا ریکارڈ نہ ہو تو پرافٹ/لاس دقیانوسی 0 رہے گا
    double profitLoss = currentNetWorth - baseNetWorth;

    if (Hive.isBoxOpen(_boxName)) {
      String plBreakdown =
          "موجودہ انویسٹمنٹ ($currentNetWorth) - بنیادی انویسٹمنٹ ($baseNetWorth) = $profitLoss";
      _financialBox.put('profitLossBreakdown', plBreakdown);
    }

    return profitLoss;
  }
}

final financialController = FinancialController();