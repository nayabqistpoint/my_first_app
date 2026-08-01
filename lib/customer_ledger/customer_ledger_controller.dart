import 'package:flutter/material.dart';

class CustomerLedgerController extends ChangeNotifier {
  final Map<String, dynamic> customerData;
  final bool isAdmin; // رول بیسڈ فلیگ (True = ایڈمن, False = کسٹمر)
  
  String searchQuery = '';
  List<Map<String, dynamic>> transactions = [];

  CustomerLedgerController({
    this.customerData = const {},
    this.isAdmin = true,
  }) {
    loadCustomerTransactions();
  }

  // کسٹمر کا نام محفوظ طریقے سے نکالنا
  String get customerName => 
      customerData['name'] ?? 
      customerData['customerName'] ?? 
      'خلیل سبزی والا';

  // کل بیلنس کا حساب
  double get totalBalance {
    double total = 0.0;
    for (var t in transactions) {
      double amount = double.tryParse(t['amount']?.toString() ?? '0') ?? 0.0;
      if (t['type'] == 'given') {
        total += amount;
      } else if (t['type'] == 'received') {
        total -= amount;
      }
    }
    return total;
  }

  // ٹرانزیکشنز لوڈ کرنے کا فنکشن
  void loadCustomerTransactions() {
    if (customerData['transactions'] != null && customerData['transactions'] is List) {
      transactions = List<Map<String, dynamic>>.from(customerData['transactions']);
    } else {
      // ٹیسٹنگ کے لیے عارضی ڈیٹا
      transactions = [
        {
          'date': '18 Jul 26',
          'amount': 500,
          'type': 'received',
          'description': 'ماہانہ قسط وصولی',
          'hasAttachment': true,
        },
      ];
    }
    notifyListeners();
  }
}