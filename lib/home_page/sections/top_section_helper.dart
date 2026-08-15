import 'package:hive_flutter/hive_flutter.dart';
import '../views/customers_widgets/balance_helper.dart';

class TopSectionHelper {
  // کیش / بینک بیلنس کا حساب
  static double getBankTotal() {
    double totalBank = 0.0;
    if (Hive.isBoxOpen('bankBox')) {
      for (var v in Hive.box('bankBox').values) {
        if (v != null) {
          totalBank += double.tryParse(v.toString()) ?? 0.0;
        }
      }
    }
    return totalBank;
  }

  // کسٹمرز کے لینے اور دینے والے بیلنس کا حساب
  static Map<String, double> getCustomerTotals() {
    double totalRed = 0.0;
    double totalGreen = 0.0;

    if (Hive.isBoxOpen('customerBox') && Hive.isBoxOpen('transactionBox')) {
      var customerBox = Hive.box('customerBox');
      var txBox = Hive.box('transactionBox');

      for (var key in customerBox.keys) {
        var customerData = customerBox.get(key);
        if (customerData is Map) {
          String phone = (customerData['customerPhone'] ?? key ?? '').toString();
          double b = BalanceHelper.calculateCustomerBalance(txBox, phone);
          if (b < 0) {
            totalRed += b.abs();
          } else if (b > 0) {
            totalGreen += b;
          }
        }
      }
    }
    return {'red': totalRed, 'green': totalGreen};
  }
}