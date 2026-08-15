import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../features/installment_plan_dialog.dart';
import '../home_page/views/customers_widgets/balance_helper.dart';

class LedgerTopHelper {
  static String getHeaderTitle({
    required dynamic customer,
    required Map<String, dynamic> customerData,
    required bool isAdmin,
  }) {
    // ۱۔ فون نمبر کی فچنگ اور فلٹرنگ
    String phone = '';
    if (customer != null) {
      try {
        phone = (customer.phone ?? (customer is Map ? customer['customerPhone'] : '')).toString();
      } catch (_) {}
    }
    if (phone.isEmpty && customerData.isNotEmpty) {
      phone = (customerData['customerPhone'] ?? customerData['phone'] ?? customerData['mobile'] ?? '').toString();
    }
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    String name = '';
    String cast = '';

    // ۲۔ customerBox سے ڈیٹا فچ کرنا
    if (phone.isNotEmpty && Hive.isBoxOpen('customerBox')) {
      final box = Hive.box('customerBox');
      for (final val in box.values.whereType<Map>()) {
        final p = (val['phone'] ?? val['mobile'] ?? val['customerPhone'] ?? val['customerId'] ?? '')
            .toString()
            .replaceAll(RegExp(r'[^0-9]'), '');
        if (p == phone) {
          name = (val['name'] ?? val['customerName'] ?? val['fullName'] ?? '').toString().trim();
          cast = (val['cast'] ?? val['caste'] ?? val['customerCaste'] ?? '').toString().trim();
          break;
        }
      }
    }

    // ۳۔ اگر باکس سے نہ ملے تو لوکل پاس شدہ ڈیٹا سے نکالنا
    if (name.isEmpty) {
      name = (customerData['name'] ?? customerData['customerName'] ?? (customer is Map ? customer['name'] : '') ?? '').toString().trim();
      cast = (customerData['cast'] ?? customerData['caste'] ?? (customer is Map ? customer['cast'] : '') ?? '').toString().trim();
    }

    // ۴۔ ٹائٹل فارمیٹنگ
    if (isAdmin) {
      return name.isNotEmpty ? (cast.isNotEmpty ? "$name ($cast)" : name) : "کسٹمر لیجر";
    } else {
      return name.isNotEmpty ? "نایاب قسط پوائنٹ ($name)" : "نایاب قسط پوائنٹ";
    }
  }

  static Map<String, dynamic> getBalanceData(Box box, String customerPhone) {
    final double balance = BalanceHelper.calculateCustomerBalance(box, customerPhone);
    return {
      'amount': balance.abs().toStringAsFixed(0),
      'color': BalanceHelper.getAmountColor(balance),
      'label': balance >= 0 ? "بقایا لینا / ایڈوانس" : "بقایا دینا ہے",
    };
  }

  static double getShortAmount(String customerPhone) => InstallmentPlanDialog.calculateTotalShort(customerPhone);

  static void openInstallmentDialog(BuildContext context, String customerPhone, bool isAdmin) {
    showDialog(
      context: context,
      builder: (_) => InstallmentPlanDialog(customerPhone: customerPhone, isAdmin: isAdmin),
    );
  }

  static BoxDecoration boxDecoration(Color borderClr, Color shadowClr) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderClr, width: 1.5),
    boxShadow: [BoxShadow(color: shadowClr, blurRadius: 8, offset: const Offset(0, 4))],
  );
}