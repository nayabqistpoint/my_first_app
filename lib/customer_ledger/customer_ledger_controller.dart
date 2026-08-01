import 'package:flutter/material.dart';
import '../installment_calculater_page.dart';

class CustomerLedgerController extends ChangeNotifier {
  final dynamic customer;
  final Map<String, dynamic> customerData;
  final String? directName; 
  final String? directCast;
  final bool isAdmin;
  
  String searchQuery = '';
  List<dynamic> transactions = [];

  CustomerLedgerController({
    this.customer,
    this.customerData = const {},
    this.directName,
    this.directCast,
    this.isAdmin = true,
  }) {
    loadCustomerTransactions();
  }

  // نام کے لیے انتہائی محفوظ طریقہ
  String get customerName {
    if (directName != null && directName!.trim().isNotEmpty) {
      return directName!;
    }
    if (customer != null) {
      try {
        if (customer.name != null && customer.name.toString().trim().isNotEmpty) {
          return customer.name.toString();
        }
      } catch (_) {}
    }
    if (customerData.isNotEmpty) {
      return customerData['customerName']?.toString() ?? 
             customerData['name']?.toString() ?? 
             customerData['fullName']?.toString() ?? 
             'نام موجود نہیں';
    }
    return 'نام موجود نہیں';
  }

  // قوم کے لیے انتہائی محفوظ طریقہ
  String get customerCast {
    if (directCast != null && directCast!.trim().isNotEmpty) {
      return directCast!;
    }
    if (customer != null) {
      try {
        if (customer.cast != null) return customer.cast.toString();
      } catch (_) {}
    }
    if (customerData.isNotEmpty) {
      return customerData['customerCaste']?.toString() ?? 
             customerData['cast']?.toString() ?? 
             customerData['caste']?.toString() ?? 
             '';
    }
    return '';
  }

  // 🛡️ کل بیلنس کا متفقہ اور درست حساب (جو مین سکرین اور اندر لیجر دونوں کے لیے ایک جیسا ہو)
  double get totalBalance {
    double total = 0.0;
    for (var t in transactions) {
      if (t == null) continue;
      double amount = 0.0;
      String type = 'get';

      if (t is Map) {
        amount = double.tryParse(t['amount']?.toString() ?? '0') ?? 0.0;
        type = t['type']?.toString() ?? 'get';
      } else {
        try {
          amount = double.tryParse(t.amount?.toString() ?? '0') ?? 0.0;
          type = t.type?.toString() ?? 'get';
        } catch (_) {}
      }

      // یہاں ٹائپ کا معیار بالکل درست کر دیا گیا ہے
      if (type == 'get' || type == 'received') {
        total += amount;
      } else if (type == 'give' || type == 'given') {
        total -= amount;
      }
    }
    // اگر ٹوٹل بالکل صفر کے قریب ہے (جیسے -0.0 یا 0.0001)، تو اسے بالکل 0.0 کر دیں تاکہ ریड کلر کا جھنجھٹ نہ رہے
    if (total.abs() < 0.01) {
      return 0.0;
    }
    return total;
  }

  // ٹرانزیکشنز لوڈ کرنا (کریش سے پاک)
  void loadCustomerTransactions() {
    transactions = [];
    try {
      if (customer != null) {
        dynamic rawTxs;
        try {
          rawTxs = customer.transactions;
        } catch (_) {}

        if (rawTxs != null && rawTxs is List) {
          transactions = List<dynamic>.from(rawTxs);
        }
      } else if (customerData.isNotEmpty) {
        var txs = customerData['transactions'] ?? customerData['customerTransactions'];
        if (txs != null && txs is List) {
          transactions = List<dynamic>.from(txs);
        }
      }
    } catch (_) {
      transactions = [];
    }
    notifyListeners();
  }

  // فلٹر شدہ ٹرانزیکشنز (محفوظ طریقے سے)
  List<dynamic> get filteredTransactions {
    if (searchQuery.trim().isEmpty) return transactions;
    return transactions.where((t) {
      if (t == null) return false;
      String desc = '';
      String amt = '';
      if (t is Map) {
        desc = t['description']?.toString().toLowerCase() ?? '';
        amt = t['amount']?.toString() ?? '';
      } else {
        try {
          desc = t.description?.toString().toLowerCase() ?? '';
          amt = t.amount?.toString() ?? '';
        } catch (_) {}
      }
      return desc.contains(searchQuery.toLowerCase()) || amt.contains(searchQuery);
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void openInstallmentCalculator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InstallmentCalculaterPage(),
      ),
    );
  }
}