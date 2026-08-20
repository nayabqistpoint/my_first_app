import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_first_app/home_page/views/customers_widgets/balance_helper.dart';

class LedgerItemData {
  final double amount, runningBalance;
  final String type, day, month, year, description;
  final bool isApproved;
  final Color amountColor, capColor;

  LedgerItemData({
    required this.amount, required this.runningBalance, required this.type,
    required this.day, required this.month, required this.year,
    required this.description, required this.isApproved,
    required this.amountColor, required this.capColor,
  });
}

class LedgerMiddleHelper {
  static const List<String> _m = ["جنوری","فروری","مارچ","اپریل","مئی","جون","جولائی","اگست","ستمبر","اکتوبر","نومبر","دسمبر"];

  static List<LedgerItemData> processTransactions({
    required Box box, required String customerPhone, required bool isAdmin,
  }) {
    final String phone = customerPhone.trim();
    if (phone.isEmpty) {
      return [];
    }

    // ۱۔ ڈیٹا فلٹر کرنا
    final rawTxList = box.keys.map((k) {
      final v = box.get(k);
      return (v is Map) ? (Map<String, dynamic>.from(v)..[ '_k'] = k) : null;
    }).where((tx) => tx != null && (tx['customerPhone'] ?? tx['customerId'] ?? '').toString().trim() == phone).cast<Map<String, dynamic>>().toList();

    if (rawTxList.isEmpty) {
      return [];
    }

    // ۲۔ ٹائم سٹیمپ پر سارٹنگ (Oldest -> Newest)
    rawTxList.sort((a, b) {
      final dtA = DateTime.tryParse((a['createdAt'] ?? a['timestamp'] ?? a['date'] ?? '').toString()) ?? DateTime(2000);
      final dtB = DateTime.tryParse((b['createdAt'] ?? b['timestamp'] ?? b['date'] ?? '').toString()) ?? DateTime(2000);
      final cmp = dtA.compareTo(dtB);
      return cmp != 0 ? cmp : a['_k'].toString().compareTo(b['_k'].toString());
    });

    double runningAcc = 0.0;
    List<LedgerItemData> list = [];

    // ۳۔ رننگ بیلنس اور ڈیٹا کی تیاری
    for (var tx in rawTxList) {
      String type = (tx['type'] ?? '').toString().toLowerCase();
      String status = (tx['status'] ?? '').toString().toLowerCase();
      bool isApproved = (tx['isApproved'] == true) || (status != 'pending' && tx['isApproved'] != false);

      double amt = (type == 'purchase')
          ? double.tryParse((tx['remainingBalance'] ?? tx['remaining'] ?? 0).toString()) ?? 0.0
          : double.tryParse((tx['amount'] ?? tx['netAmount'] ?? 0).toString()) ?? 0.0;

      if (isApproved) {
        if (type == 'received' || (type == 'purchase' && amt > 0)) {
          runningAcc += amt;
        } else if (type == 'paid' || type == 'sale' || (type == 'purchase' && amt < 0)) {
          runningAcc -= amt.abs();
        }
      }

      DateTime dt = DateTime.tryParse((tx['createdAt'] ?? tx['timestamp'] ?? tx['date'] ?? '').toString()) ?? DateTime.now();

      if (!isAdmin || isApproved) {
        list.add(LedgerItemData(
          amount: amt.abs(), runningBalance: runningAcc, type: type,
          day: dt.day.toString(),
          month: (dt.month >= 1 && dt.month <= 12) ? _m[dt.month - 1] : "اگست",
          year: dt.year.toString(),
          description: (tx['description'] ?? tx['note'] ?? 'تفصیل...').toString(),
          isApproved: isApproved,
          amountColor: (type == 'received' || (type == 'purchase' && amt > 0)) ? Colors.green.shade700 : Colors.red.shade700,
          capColor: BalanceHelper.getAmountColor(runningAcc),
        ));
      }
    }

    return list.reversed.toList();
  }
}