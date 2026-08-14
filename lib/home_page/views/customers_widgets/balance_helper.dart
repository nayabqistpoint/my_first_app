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

          // 1. سیل (Sale) ➔ مائنس (Paid / Red)
          if (type == 'sale') {
            totalBalance -= _parseDouble(tx['amount'] ?? tx['netAmount']);
          }
          // 2. پرچیز (Purchase) ➔ صرف remainingBalance
          else if (type == 'purchase') {
            totalBalance += _parseDouble(tx['remainingBalance']);
          }
          // 3. پیمنٹ آؤٹ (Paid) ➔ مائنس (Red)
          else if (type == 'paid') {
            totalBalance -= _parseDouble(tx['netAmount'] ?? tx['amount']);
          }
          // 4. پیمنٹ ان / قسط (Received) ➔ 🎯 صرف پینڈنگ کو چھوڑ کر جمع ہوگا
          else if (type == 'received') {
            String status = (tx['status'] ?? '').toString().toLowerCase();

            // اگر سٹیٹس پینڈنگ (pending) ہے تو اگنور کریں، ورنہ جمع کریں
            if (status != 'pending') {
              totalBalance += _parseDouble(tx['amount'] ?? tx['netAmount']);
            }
          }
        }
      }
    }

    return totalBalance;
  }

  /// رقم کی بنیاد پر رنگ (پوزیٹو گرین، نیگیٹو ریڈ)
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