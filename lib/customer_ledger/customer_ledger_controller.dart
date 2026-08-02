import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
    _initBoxAndLoad();
  }

  Future<void> _initBoxAndLoad() async {
    try {
      if (!Hive.isBoxOpen('transactionBox')) {
        await Hive.openBox('transactionBox');
      }
    } catch (_) {}
    
    loadCustomerTransactions();
    _listenToHiveBox();
  }

  void _listenToHiveBox() {
    try {
      if (Hive.isBoxOpen('transactionBox')) {
        Hive.box('transactionBox').listenable().addListener(() {
          loadCustomerTransactions();
        });
      }
    } catch (_) {}
  }

  String get customerId {
    if (customer != null) {
      try {
        if (customer.id != null && customer.id.toString().trim().isNotEmpty) {
          return customer.id.toString();
        }
        if (customer.key != null && customer.key.toString().trim().isNotEmpty) {
          return customer.key.toString();
        }
      } catch (_) {}
    }
    if (customerData.isNotEmpty) {
      String id = customerData['id']?.toString() ?? 
                 customerData['customerId']?.toString() ?? '';
      if (id.trim().isNotEmpty) return id;
    }
    return customerName;
  }

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

  // یہاں تمام ٹائپس ('give', 'given', 'paid' اور 'get', 'received') کا حساب درست کر دیا گیا ہے
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

      // 'give', 'given' یا 'paid' (پیمنٹ آؤٹ/سرخ) بیلنس میں جمع ہوں گے
      if (type == 'give' || type == 'given' || type == 'paid') {
        total += amount;
      } 
      // 'get' یا 'received' (پیمنٹ ان/سبز) بیلنس میں سے مائنس ہوں گے
      else if (type == 'get' || type == 'received') {
        total -= amount;
      }
    }
    if (total.abs() < 0.01) {
      return 0.0;
    }
    return total;
  }

  void loadCustomerTransactions() {
    List<dynamic> tempTransactions = [];
    try {
      if (customer != null) {
        dynamic rawTxs;
        try {
          rawTxs = customer.transactions;
        } catch (_) {}

        if (rawTxs != null && rawTxs is List) {
          tempTransactions.addAll(List<dynamic>.from(rawTxs));
        }
      } else if (customerData.isNotEmpty) {
        var txs = customerData['transactions'] ?? customerData['customerTransactions'];
        if (txs != null && txs is List) {
          tempTransactions.addAll(List<dynamic>.from(txs));
        }
      }

      if (Hive.isBoxOpen('transactionBox')) {
        var box = Hive.box('transactionBox');
        String targetId = customerId.trim().toLowerCase();
        String targetName = customerName.trim().toLowerCase();

        for (var key in box.keys) {
          var txValue = box.get(key);
          if (txValue != null && txValue is Map) {
            String txCustomerId = (txValue['customerId'] ?? '').toString().trim().toLowerCase();
            
            if (txCustomerId == targetId || 
                txCustomerId == targetName || 
                txCustomerId.contains(targetName) ||
                targetName.contains(txCustomerId) ||
                (txCustomerId == 'default_customer' && targetName.isNotEmpty)) {
              
              // فالتو فلٹر ہٹا دیا گیا ہے تاکہ کوئی بھی انٹری خودبخود غائب نہ ہو
              String amtCheck = txValue['amount']?.toString() ?? '';
              if (amtCheck.isNotEmpty && txCustomerId.isNotEmpty) {
                tempTransactions.add(Map<String, dynamic>.from(txValue));
              }
            }
          }
        }
      }
    } catch (_) {}

    transactions = tempTransactions.reversed.toList();
    notifyListeners();
  }

  List<dynamic> get filteredTransactions {
    if (searchQuery.trim().isEmpty) return transactions;
    return transactions.where((t) {
      if (t == null) return false;
      String desc = '';
      String amt = '';
      if (t is Map) {
        desc = (t['description'] ?? t['remarks'])?.toString().toLowerCase() ?? '';
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