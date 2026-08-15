import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../features/installment_plan_dialog.dart';
import '../home_page/views/customers_widgets/balance_helper.dart';

class LedgerTopHelper {
  /// ۱۔ کسٹمر فون نمبر نکالنا
  static String getCustomerPhone(dynamic customer, Map<String, dynamic> customerData) {
    if (customerData.isNotEmpty && customerData['phone'] != null) {
      return customerData['phone'].toString().trim();
    }
    if (customer != null && customer is Map) {
      return (customer['phone'] ?? customer['mobile'] ?? '').toString().trim();
    }
    return '';
  }

  /// ۲۔ ہیڈر کا عنوان (Title) بنانا (isAdmin = true اور false دونوں کیسز)
  static String getHeaderTitle({
    required dynamic customer,
    required Map<String, dynamic> customerData,
    required bool isAdmin,
  }) {
    String name = (customerData['name'] ?? (customer is Map ? customer['name'] : '') ?? 'کسٹمر').toString().trim();
    String cast = (customerData['cast'] ?? (customer is Map ? customer['cast'] : '') ?? '').toString().trim();

    if (isAdmin) {
      return "$name $cast".trim();
    } else {
      return "نایاب قسط پوائنٹ ($name)";
    }
  }

  /// ۳۔ لائیو کل بیلنس اور اس کا رنگ
  static Map<String, dynamic> getBalanceData(Box box, String customerPhone) {
    double totalBalance = BalanceHelper.calculateCustomerBalance(box, customerPhone);
    Color color = BalanceHelper.getAmountColor(totalBalance);
    String label = totalBalance >= 0 ? "بقایا لینا / ایڈوانس" : "بقایا دینا ہے";

    return {
      'amount': totalBalance.abs().toStringAsFixed(0),
      'color': color,
      'label': label,
    };
  }

  /// ۴۔ لائیو شارٹ ڈیو
  static double getShortAmount(String customerPhone) {
    return InstallmentPlanDialog.calculateTotalShort(customerPhone);
  }

  /// ۵۔ اقساط ڈائیلاگ کھولنا
  static void openInstallmentDialog(BuildContext context, String customerPhone, bool isAdmin) {
    showDialog(
      context: context,
      builder: (context) => InstallmentPlanDialog(
        customerPhone: customerPhone,
        isAdmin: isAdmin,
      ),
    );
  }
}