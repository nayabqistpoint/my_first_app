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
    loadCustomerTransactions();
  }

  // 🛡️ کسٹمر کا موبائل نمبر جو ہائیو باکس کی یونیک آئی ڈی ہے
  String get customerPhone {
    String phone = '';
    if (customer != null) {
      try {
        if (customer.phone != null) {
          phone = customer.phone.toString();
        } else if (customer is Map && customer['customerPhone'] != null) {
          phone = customer['customerPhone'].toString();
        }
      } catch (_) {}
    }
    if (phone.isEmpty && customerData.isNotEmpty) {
      phone = customerData['customerPhone']?.toString() ?? 
              customerData['phone']?.toString() ?? 
              customerData['mobile']?.toString() ?? 
              customerData['phoneNumber']?.toString() ?? '';
    }
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String get customerId => customerPhone;

  String get customerName {
    if (directName != null && directName!.trim().isNotEmpty) {
      return directName!;
    }
    if (customer != null) {
      try {
        if (customer.name != null && customer.name.toString().trim().isNotEmpty) {
          return customer.name.toString();
        } else if (customer is Map && (customer['customerName'] != null || customer['name'] != null)) {
          return (customer['customerName'] ?? customer['name']).toString();
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
        if (customer is Map && customer['customerCaste'] != null) return customer['customerCaste'].toString();
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

  // 💰 ٹوٹل بیلنس (اگر ایڈمن ہے تو پینڈنگ انٹریز بیلنس میں شمار نہیں ہوں گی)
  double get totalBalance {
    double total = 0.0;
    for (var t in transactions) {
      if (t == null) continue;
      double amount = 0.0;
      String type = 'get';
      bool isPending = false;

      if (t is Map) {
        amount = double.tryParse(t['amount']?.toString() ?? '0') ?? 0.0;
        type = t['type']?.toString() ?? 'get';
        String status = t['status']?.toString() ?? '';
        if (status == 'pending' || t['isApproved'] == false) {
          isPending = true;
        }
      } else {
        try {
          amount = double.tryParse(t.amount?.toString() ?? '0') ?? 0.0;
          type = t.type?.toString() ?? 'get';
          if (t.status == 'pending' || t.isApproved == false) {
            isPending = true;
          }
        } catch (_) {}
      }

      // اگر ایڈمن ہے اور انٹری پینڈنگ ہے تو اسے ٹوٹل بیلنس سے نکال باہر رکھیں
      if (isAdmin && isPending) continue;

      if (type == 'give' || type == 'given' || type == 'paid' || type == 'out') {
        total += amount;
      } else if (type == 'get' || type == 'received' || type == 'in') {
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
        String targetPhone = customerPhone.trim();

        for (var key in box.keys) {
          var txValue = box.get(key);
          if (txValue != null && txValue is Map) {
            String txPhone = (txValue['customerPhone'] ?? '').toString().trim();
            if (targetPhone.isNotEmpty && txPhone == targetPhone) {
              
              // 🔍 اگر یہ ایڈمن ہے اور انٹری پینڈنگ ہے، تو اسے ایڈمن کے لیجر سے بالکل ہٹا دو
              bool isPendingTx = (txValue['status']?.toString() == 'pending' || txValue['isApproved'] == false);
              if (isAdmin && isPendingTx) {
                continue; 
              }

              bool alreadyExists = tempTransactions.any((existing) {
                if (existing is Map) {
                  if (existing['timestamp'] != null && txValue['timestamp'] != null) {
                    return existing['timestamp'] == txValue['timestamp'];
                  }
                  return existing['date'] == txValue['date'] && 
                         existing['amount'] == txValue['amount'] &&
                         existing['description'] == txValue['description'];
                }
                return false;
              });

              if (!alreadyExists) {
                String amtCheck = txValue['amount']?.toString() ?? '';
                if (amtCheck.isNotEmpty) {
                  tempTransactions.add(Map<String, dynamic>.from(txValue));
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    transactions = tempTransactions.reversed.toList();
    notifyListeners();
  }

  Future<void> saveTransaction({
    required String type, 
    required double amount,
    required String description,
    required String date,
    bool hasAttachment = false,
  }) async {
    if (Hive.isBoxOpen('transactionBox')) {
      var box = Hive.box('transactionBox');

      Map<String, dynamic> newTx = {
        'customerPhone': customerPhone,
        'customerId': customerPhone,
        'customerName': customerName,
        'type': type,
        'amount': amount,
        'description': description,
        'date': date,
        'hasAttachment': hasAttachment,
        'timestamp': DateTime.now().toString(),
        'status': 'approved', // عام انٹریز فوری منظور شدہ ہوتی ہیں
      };

      await box.add(newTx);
      loadCustomerTransactions();
    }
  }

  List<dynamic> get filteredTransactions {
    if (searchQuery.trim().isNotEmpty) {
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
    return transactions;
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