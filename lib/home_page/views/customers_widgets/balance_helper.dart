import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BalanceHelper {
  /// کسٹمر کے فون نمبر کی بنیاد پر ٹرانزیکشنز اور پیکج باکس سے مکمل بیلنس نکالنا
  static double calculateCustomerBalance(Box? transactionBox, String customerPhone) {
    if (customerPhone.trim().isEmpty) return 0.0;

    double totalBalance = 0.0;
    String targetPhone = customerPhone.trim();

    // ۱. ٹرانزیکشن باکس سے ہینڈلنگ
    if (transactionBox != null) {
      for (var key in transactionBox.keys) {
        var txData = transactionBox.get(key);

        if (txData is Map) {
          Map<String, dynamic> tx = Map<String, dynamic>.from(txData);
          String phoneInTx = (tx['customerPhone'] ?? tx['customerId'] ?? '').toString().trim();

          if (phoneInTx == targetPhone) {
            String type = (tx['type'] ?? '').toString().toLowerCase();

            // پرچیز (Purchase) - صرف remainingBalance
            if (type == 'purchase') {
              totalBalance += _parseDouble(tx['remainingBalance']);
            }
            // پیمنٹ آؤٹ (Paid)
            else if (type == 'paid') {
              totalBalance -= _parseDouble(tx['netAmount'] ?? tx['amount']);
            }
            // پیمنٹ ان (Received)
            else if (type == 'received') {
              bool isApproved = tx['isApproved'] ?? true;
              String status = (tx['status'] ?? 'approved').toString().toLowerCase();

              if (status != 'pending' && isApproved != false) {
                totalBalance += _parseDouble(tx['amount'] ?? tx['netAmount']);
              }
            }
            // قسط / پے ناؤ (Installment)
            else if (type == 'installment' || type == 'pay_now') {
              totalBalance += _parseDouble(tx['amount'] ?? tx['paidAmount']);
            }
          }
        }
      }
    }

    // ۲. پیکج باکس (packageBox) سے پرچیز ریکویسٹ کا ہینڈلنگ
    if (Hive.isBoxOpen('packageBox')) {
      Box packageBox = Hive.box('packageBox');

      for (var key in packageBox.keys) {
        var pkgData = packageBox.get(key);

        if (pkgData is Map) {
          Map<String, dynamic> pkg = Map<String, dynamic>.from(pkgData);
          String phoneInPkg = (pkg['customerPhone'] ?? key ?? '').toString().trim();

          if (phoneInPkg == targetPhone) {
            String status = (pkg['status'] ?? '').toString().trim();

            // 🎯 "Completed" سٹیٹس کا مطلب ہے سامان بیچا گیا (Paid / Out) -> رقم مائنس (-) ہوگی
            if (status.toLowerCase() == 'completed') {
              double totalPrice = _parseDouble(pkg['totalPrice']);
              totalBalance -= totalPrice; // 🎯 کسٹمر پر رقم مائنس ہوگی (سرخ / Red)
            }
          }
        }
      }
    }

    return totalBalance;
  }

  /// رقم کی بنیاد پر رنگ کا انتخاب (پوزیٹو گرین، نیگیٹو ریڈ)
  static Color getAmountColor(double balance) {
    if (balance > 0) {
      return Colors.green.shade700; // پوزیٹو (ان / Received)
    } else if (balance < 0) {
      return Colors.red.shade700; // نیگیٹو (آؤٹ / Paid)
    }
    return Colors.black87;
  }

  /// سیف پارسنگ (Safe double parsing)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}