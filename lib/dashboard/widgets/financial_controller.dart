import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FinancialController extends ChangeNotifier {
  static const String _boxName = 'financialSummaryBox';

  Box get _financialBox => Hive.box(_boxName);

  // 🎯 1. فریزڈ انویسٹمنٹ (Base Investment / Locked Capital)
  // یہ کیش، بینک اور اسٹاک کی بنیادی انویسٹمنٹ کو فریز رکھے گی
  double calculateBaseInvestment({
    required double cashAndBank,
    required double stockValue,
    required double totalRed,
    required double totalGreen,
  }) {
    // بنیادی انویسٹمنٹ (کیش + اسٹاک + لینے ہیں - دینے ہیں)
    double baseInvestment = (cashAndBank + stockValue + totalRed) - totalGreen;

    if (Hive.isBoxOpen(_boxName)) {
      _financialBox.put('baseInvestment', baseInvestment);
    }

    return baseInvestment;
  }

  // 🎯 2. لائیو پرافٹ / لاس (روزمرہ کے اخراجات اور درآمدات کا خالص اثر)
  double calculateDynamicProfitLoss() {
    double netProfitLoss = 0.0;

    // اخراجات اور دیگر آمدنی (expenseBox) کا لائیو حساب
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
            // آمدنی ➔ پرافٹ کو بڑھائے گی (+ Profit)
            netProfitLoss += amount;
          } else {
            // اخراجات ➔ لاس کی طرف لے جائیں گے (- Loss)
            netProfitLoss -= amount;
          }
        }
      }
    }

    if (Hive.isBoxOpen(_boxName)) {
      _financialBox.put('currentProfitLoss', netProfitLoss);
    }

    return netProfitLoss;
  }
}

final financialController = FinancialController();