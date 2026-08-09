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

  // 🎯 تاریخ کی درست اردو/انگلش فارمیٹنگ
  static Map<String, String> getParsedUrduDate(dynamic rawDate, dynamic rawTimestamp) {
    DateTime? dt;
    if (rawTimestamp != null && rawTimestamp.toString().isNotEmpty) {
      dt = DateTime.tryParse(rawTimestamp.toString());
    }
    if (dt == null && rawDate != null && rawDate.toString().isNotEmpty) {
      dt = DateTime.tryParse(rawDate.toString());
    }

    if (dt != null) {
      List<String> urduMonths = [
        'جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون',
        'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر'
      ];
      return {
        'day': dt.day.toString(),
        'month': urduMonths[dt.month - 1],
        'year': dt.year.toString(),
      };
    }

    return {'day': '', 'month': rawDate?.toString() ?? '', 'year': ''};
  }

  static double getRawTransactionAmount(dynamic tx) {
    if (tx == null) return 0.0;
    double amt = 0.0;
    String type = getTransactionType(tx);

    if (tx is Map) {
      if (type == 'purchase' && tx['remainingBalance'] != null) {
        amt = double.tryParse(tx['remainingBalance'].toString()) ?? 0.0;
      } else {
        amt = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
      }
    } else {
      try {
        if (type == 'purchase' && tx.remainingBalance != null) {
          amt = double.tryParse(tx.remainingBalance.toString()) ?? 0.0;
        } else {
          amt = double.tryParse(tx.amount?.toString() ?? '0') ?? 0.0;
        }
      } catch (_) {}
    }
    return amt;
  }

  static double getTransactionAmount(dynamic tx) {
    return getRawTransactionAmount(tx).abs();
  }

  static String getTransactionType(dynamic tx) {
    if (tx == null) return '';
    String type = '';
    if (tx is Map) {
      type = tx['type']?.toString().toLowerCase().trim() ?? '';
    } else {
      try {
        type = tx.type?.toString().toLowerCase().trim() ?? '';
      } catch (_) {}
    }
    return type;
  }

  static bool isGreenTransaction(dynamic tx) {
    String type = getTransactionType(tx);

    if (type == 'payment_in' || type == 'in' || type == 'received' || type == 'get') {
      return true;
    }
    
    if (type == 'payment_out' || type == 'out' || type == 'paid' || type == 'give' || type == 'given') {
      return false;
    }

    if (type == 'purchase') {
      double rawAmt = getRawTransactionAmount(tx);
      return rawAmt >= 0;
    }

    return true;
  }

  static bool isGreenColumn(dynamic tx) => isGreenTransaction(tx);

  double getRunningBalanceAtIndex(int index) {
    double runningBalance = 0.0;

    for (int i = transactions.length - 1; i >= index; i--) {
      var t = transactions[i];
      if (t == null) continue;

      bool isPending = false;
      if (t is Map) {
        if (t['status']?.toString() == 'pending' || t['isApproved'] == false) {
          isPending = true;
        }
      } else {
        try {
          if (t.status == 'pending' || t.isApproved == false) {
            isPending = true;
          }
        } catch (_) {}
      }

      if (isPending) continue;

      double amt = getTransactionAmount(t);
      bool isGreen = isGreenTransaction(t);

      if (isGreen) {
        runningBalance += amt;
      } else {
        runningBalance -= amt;
      }
    }

    return runningBalance;
  }

  double get totalBalance {
    if (transactions.isEmpty) return 0.0;
    return getRunningBalanceAtIndex(0);
  }

  DateTime _parseTxDate(dynamic tx) {
    try {
      if (tx is Map) {
        if (tx['timestamp'] != null) return DateTime.parse(tx['timestamp'].toString());
        if (tx['date'] != null) {
          var parsed = DateTime.tryParse(tx['date'].toString());
          if (parsed != null) return parsed;
        }
      } else {
        if (tx.timestamp != null) return DateTime.parse(tx.timestamp.toString());
        if (tx.date != null) {
          var parsed = DateTime.tryParse(tx.date.toString());
          if (parsed != null) return parsed;
        }
      }
    } catch (_) {}
    return DateTime(2000);
  }

  void loadCustomerTransactions() {
    List<dynamic> tempTransactions = [];
    try {
      if (customer != null) {
        dynamic rawTxs;
        try { rawTxs = customer.transactions; } catch (_) {}
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
            String txPhone = (txValue['customerPhone'] ?? txValue['customerId'] ?? '').toString().trim();
            if (targetPhone.isNotEmpty && txPhone == targetPhone) {
              
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
                tempTransactions.add(Map<String, dynamic>.from(txValue));
              }
            }
          }
        }
      }
    } catch (_) {}

    tempTransactions.sort((a, b) => _parseTxDate(b).compareTo(_parseTxDate(a)));
    transactions = tempTransactions;
    notifyListeners();
  }

  List<dynamic> get filteredTransactions {
    if (searchQuery.trim().isNotEmpty) {
      return transactions.where((t) {
        if (t == null) return false;
        String desc = '';
        String amt = getTransactionAmount(t).toString();
        if (t is Map) {
          desc = (t['description'] ?? t['remarks'])?.toString().toLowerCase() ?? '';
        } else {
          try {
            desc = t.description?.toString().toLowerCase() ?? '';
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