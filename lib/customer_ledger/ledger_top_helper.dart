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
    String name = (customerData['name'] ?? (customer is Map ? customer['name'] : '') ?? 'کسٹمر').toString().trim();
    String cast = (customerData['cast'] ?? (customer is Map ? customer['cast'] : '') ?? '').toString().trim();
    return isAdmin ? "$name $cast".trim() : "نایاب قسط پوائنٹ ($name)";
  }

  static Map<String, dynamic> getBalanceData(Box box, String customerPhone) {
    double totalBalance = BalanceHelper.calculateCustomerBalance(box, customerPhone);
    Color color = BalanceHelper.getAmountColor(totalBalance);
    String label = totalBalance >= 0 ? "بقایا لینا / ایڈوانس" : "بقایا دینا ہے";
    return {'amount': totalBalance.abs().toStringAsFixed(0), 'color': color, 'label': label};
  }

  static double getShortAmount(String customerPhone) => InstallmentPlanDialog.calculateTotalShort(customerPhone);

  static void openInstallmentDialog(BuildContext context, String customerPhone, bool isAdmin) {
    showDialog(
      context: context,
      builder: (context) => InstallmentPlanDialog(customerPhone: customerPhone, isAdmin: isAdmin),
    );
  }

  static BoxDecoration boxDecoration(Color borderClr, Color shadowClr) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderClr, width: 1.5),
    boxShadow: [BoxShadow(color: shadowClr, blurRadius: 8, offset: const Offset(0, 4))],
  );
}