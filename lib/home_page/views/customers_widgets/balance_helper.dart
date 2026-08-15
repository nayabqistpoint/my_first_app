import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BalanceHelper {
  /// کسٹمر فون کی بنیاد پر درست بیلنس نکالنا
  static double calculateCustomerBalance(Box? transactionBox, String customerPhone) {
    if (transactionBox == null || customerPhone.trim().isEmpty) return 0.0;

    double totalBalance = 0.0;
    String targetPhone = customerPhone.trim();

    for (var key in transactionBox.keys) {
      var txData = transactionBox.get(key);

      if (txData is Map) {
        Map<String, dynamic> tx = Map<String, dynamic>.from(txData);
        String phoneInTx = (tx['customerPhone'] ?? tx['customerId'] ?? '').toString().trim();

        if (phoneInTx == targetPhone) {
          String type = (tx['type'] ?? '').toString().toLowerCase();
          String status = (tx['status'] ?? '').toString().toLowerCase();
          bool isApproved = (tx['isApproved'] == true) || (status != 'pending' && tx['isApproved'] != false);

          // 🎯 صرف منظور شدہ (Approved) اینٹریز ہی ٹوٹل بیلنس میں حساب ہوں گی
          if (!isApproved) continue;

          // 1. پرچیز (Purchase) ➔ براہِ راست remainingBalance کا اصل سائن (+ / -) شامل ہوگا
          if (type == 'purchase') {
            double rem = _parseDouble(tx['remainingBalance'] ?? tx['remaining']);
            totalBalance += rem; // مثبت پر جمع (+)، منفی پر تفریق (-)
          }
          // 2. سیل (Sale) ➔ مائنس (Red)
          else if (type == 'sale') {
            totalBalance -= _parseDouble(tx['amount'] ?? tx['netAmount']);
          }
          // 3. پیمنٹ آؤٹ (Paid) ➔ مائنس (Red)
          else if (type == 'paid') {
            totalBalance -= _parseDouble(tx['netAmount'] ?? tx['amount']);
          }
          // 4. پیمنٹ ان / قسط (Received) ➔ جمع (Green)
          else if (type == 'received') {
            totalBalance += _parseDouble(tx['amount'] ?? tx['netAmount']);
          }
        }
      }
    }

    return totalBalance;
  }

  /// رقم کی بنیاد پر رنگ (ابو زیرو / پوزیٹو ➔ گرین، بیلو زیرو / نیگیٹو ➔ ریڈ)
  static Color getAmountColor(double balance) {
    if (balance > 0) return Colors.green.shade700;
    if (balance < 0) return Colors.red.shade700;
    return Colors.black87;
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}