import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CustomerTransaction {
  String date;
  double amount;
  String type;
  String description;

  CustomerTransaction({
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'amount': amount,
        'type': type,
        'description': description,
      };

  factory CustomerTransaction.fromJson(Map json) {
    var rawAmount = json['amount'];
    double parsedAmount = 0.0;
    if (rawAmount is int) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is double) {
      parsedAmount = rawAmount;
    } else if (rawAmount is String) {
      parsedAmount = double.tryParse(rawAmount) ?? 0.0;
    }

    return CustomerTransaction(
      date: json['date']?.toString() ?? '',
      amount: parsedAmount,
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class CustomerModel {
  dynamic hiveKey;
  String name;
  String cast;
  String phone;
  List<CustomerTransaction> transactions;

  CustomerModel({
    this.hiveKey,
    required this.name,
    required this.cast,
    required this.phone,
    required this.transactions,
  });

  String get cleanPhone {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // 🔒 🎯 لیجر کے ساتھ 100% سنکرونائزڈ بیلنس کی لاجک
  double get calculateTotalBalance {
    List<Map<String, dynamic>> tempTransactions = [];

    for (var tx in transactions) {
      tempTransactions.add({
        'date': tx.date,
        'amount': tx.amount,
        'type': tx.type,
        'description': tx.description,
      });
    }

    if (Hive.isBoxOpen('transactionBox')) {
      var box = Hive.box('transactionBox');
      String targetPhone = cleanPhone;

      for (var key in box.keys) {
        var txValue = box.get(key);
        if (txValue != null && txValue is Map) {
          String txPhone = (txValue['customerPhone'] ?? txValue['customerId'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');

          if (targetPhone.isNotEmpty && txPhone == targetPhone) {
            bool alreadyExists = tempTransactions.any((existing) {
              if (existing['timestamp'] != null && txValue['timestamp'] != null) {
                return existing['timestamp'] == txValue['timestamp'];
              }
              return existing['date'] == txValue['date'] &&
                  existing['amount'].toString() == txValue['amount'].toString() &&
                  existing['description'] == txValue['description'];
            });

            if (!alreadyExists) {
              tempTransactions.add(Map<String, dynamic>.from(txValue));
            }
          }
        }
      }
    }

    // 🔒 تاریخ کے مطابق ترتیب (پرانی سے نئی)
    tempTransactions.sort((a, b) {
      DateTime dtA = DateTime.tryParse(a['timestamp']?.toString() ?? a['date']?.toString() ?? '') ?? DateTime(2000);
      DateTime dtB = DateTime.tryParse(b['timestamp']?.toString() ?? b['date']?.toString() ?? '') ?? DateTime(2000);
      return dtA.compareTo(dtB);
    });

    double runningBalance = 0.0;

    for (var t in tempTransactions) {
      String type = t['type']?.toString().toLowerCase().trim() ?? '';
      
      // پرچیز کی اینٹری کے لیے remainingBalance اور باقی کے لیے amount
      double amt = 0.0;
      if (type == 'purchase' && t['remainingBalance'] != null) {
        amt = double.tryParse(t['remainingBalance'].toString()) ?? 0.0;
      } else {
        amt = double.tryParse(t['amount']?.toString() ?? '0') ?? 0.0;
      }

      // 🔒 فائنل میپنگ
      bool isGreen = false;
      if (type == 'payment_in' || type == 'in' || type == 'received' || type == 'get') {
        isGreen = true;
      } else if (type == 'payment_out' || type == 'out' || type == 'paid' || type == 'give' || type == 'given') {
        isGreen = false;
      } else if (type == 'purchase') {
        isGreen = amt >= 0;
      } else {
        isGreen = true;
      }

      amt = amt.abs();

      if (isGreen) {
        runningBalance += amt; // پلس
      } else {
        runningBalance -= amt; // مائنس
      }
    }

    return runningBalance;
  }

  factory CustomerModel.fromJson(dynamic key, Map json) {
    var rawTxList = json['transactions'];
    List<CustomerTransaction> txList = [];

    if (rawTxList is List) {
      txList = rawTxList
          .where((t) => t != null && t is Map)
          .map((t) => CustomerTransaction.fromJson(t))
          .toList();
    }

    String resolvedName = json['customerName']?.toString() ?? json['name']?.toString() ?? 'نامعلوم';
    String resolvedCast = json['customerCaste']?.toString() ?? json['cast']?.toString() ?? json['caste']?.toString() ?? '';
    String resolvedPhone = json['customerPhone']?.toString() ?? json['phone']?.toString() ?? '';

    return CustomerModel(
      hiveKey: key,
      name: resolvedName,
      cast: resolvedCast,
      phone: resolvedPhone,
      transactions: txList,
    );
  }
}

class CustomerController extends ChangeNotifier {
  static const String _boxName = 'customerBox';

  Box get customerBox {
    if (!Hive.isBoxOpen(_boxName)) {
      throw HiveError('Box $_boxName is not open. Make sure to open it in main().');
    }
    return Hive.box(_boxName);
  }

  List<CustomerModel> get customers {
    try {
      final box = customerBox;
      List<CustomerModel> list = [];

      for (var key in box.keys) {
        final e = box.get(key);
        if (e != null && e is Map) {
          try {
            list.add(CustomerModel.fromJson(key, e));
          } catch (_) {}
        }
      }

      list.sort((a, b) {
        double balanceA = a.calculateTotalBalance;
        double balanceB = b.calculateTotalBalance;

        if (balanceA == 0 && balanceB == 0) {
          return a.name.compareTo(b.name);
        }
        if (balanceA == 0) return 1;
        if (balanceB == 0) return -1;

        return balanceB.abs().compareTo(balanceA.abs());
      });

      return list;
    } catch (e) {
      return [];
    }
  }

  void addManualCustomer({required String name, required String phone}) {
    if (name.trim().isEmpty) return;

    final Map<String, dynamic> manualCustomerData = {
      'customerName': name.trim(),
      'customerCaste': '',
      'customerPhone': phone.trim().isNotEmpty ? phone.trim() : 'نامعلوم',
      'transactions': [],
    };

    customerBox.add(manualCustomerData);
    notifyListeners();
  }

  void removeCustomer(int index) {
    customerBox.deleteAt(index);
    notifyListeners();
  }

  void refreshList() {
    notifyListeners();
  }
}

final CustomerController customerController = CustomerController();