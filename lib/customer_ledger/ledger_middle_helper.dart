import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../home_page/views/customers_widgets/balance_helper.dart';

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
    if (phone.isEmpty) return [];

    double runningAcc = 0.0;
    List<LedgerItemData> list = [];

    for (var val in box.values) {
      if (val is! Map) continue;
      Map<String, dynamic> tx = Map<String, dynamic>.from(val);
      if ((tx['customerPhone'] ?? tx['customerId'] ?? '').toString().trim() != phone) continue;

      double amt = double.tryParse((tx['amount'] ?? tx['netAmount'] ?? 0).toString()) ?? 0.0;
      String type = (tx['type'] ?? '').toString().toLowerCase();
      String status = (tx['status'] ?? '').toString().toLowerCase();
      
      bool isApproved = (tx['isApproved'] == true) || (status != 'pending' && tx['isApproved'] != false);

      // 🎯 صرف اپرووڈ اینٹریز ہی رننگ بیلنس میں جمع/تفریق ہوں گی
      if (isApproved) {
        runningAcc += (type == 'received' || type == 'purchase') ? amt : -amt;
      }

      String day = "15", month = "اگست", year = "2026";
      try {
        DateTime dt = DateTime.parse((tx['date'] ?? '').toString());
        day = dt.day.toString();
        month = (dt.month >= 1 && dt.month <= 12) ? _m[dt.month - 1] : "اگست";
        year = dt.year.toString();
      } catch (_) {}

      bool isRec = (type == 'received' || type == 'purchase');
      
      // 🎯 ایڈمن موڈ میں پینڈنگ اینٹریز فلٹر، کسٹمر موڈ میں شو ہوں گی
      if (!isAdmin || isApproved) {
        list.add(LedgerItemData(
          amount: amt, 
          runningBalance: runningAcc, 
          type: type,
          day: day, 
          month: month, 
          year: year,
          description: (tx['description'] ?? tx['note'] ?? 'تفصیل...').toString(),
          isApproved: isApproved,
          amountColor: isRec ? Colors.green.shade700 : Colors.red.shade700,
          capColor: BalanceHelper.getAmountColor(runningAcc),
        ));
      }
    }
    return list.reversed.toList();
  }
}