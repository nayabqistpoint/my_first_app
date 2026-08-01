import 'package:flutter/material.dart';
import '../installment_calculater_page.dart'; // قسط کیلکولیٹر پیج کی امپورٹ

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

  // کسٹمر کا نام محفوظ طریقے سے نکالنا (فارم اور ہائیو باکس کیز کے مطابق)
  String get customerName => 
      customerData['customerName'] ?? 
      customerData['name'] ?? 
      customerData['fullName'] ?? 
      'نام موجود نہیں';

  // کسٹمر کی قوم (Cast) محفوظ طریقے سے نکالنے کا گیٹر جو اب ایرر ختم کر دے گا
  String get customerCast => 
      customerData['customerCaste'] ?? 
      customerData['cast'] ?? 
      customerData['caste'] ?? 
      '';

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
        {
          'date': '10 Jul 26',
          'amount': 300,
          'type': 'given',
          'description': 'انسٹالمنٹ ایڈوانس',
          'hasAttachment': false,
        },
      ];
    }
    notifyListeners();
  }

  // سرچ فلٹر کا گیٹر
  List<Map<String, dynamic>> get filteredTransactions {
    if (searchQuery.trim().isEmpty) return transactions;
    return transactions.where((t) {
      String desc = t['description']?.toString().toLowerCase() ?? '';
      String amt = t['amount']?.toString() ?? '';
      return desc.contains(searchQuery.toLowerCase()) || amt.contains(searchQuery);
    }).toList();
  }

  // سرچ کیوری سیٹ کرنے کا فنکشن
  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  // قسط کیلکولیٹر کھولنے کا فنکشن
  void openInstallmentCalculator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InstallmentCalculaterPage(),
      ),
    );
  }
}