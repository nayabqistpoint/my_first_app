import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CustomerTransaction {
  String date;
  double amount;
  String type; // 'give' (دینا ہے) یا 'get' (لینا ہے)
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

  factory CustomerTransaction.fromJson(Map<dynamic, dynamic> json) {
    return CustomerTransaction(
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'get',
      description: json['description'] ?? '',
    );
  }
}

class CustomerModel {
  String name;
  String cast; // قوم یا ولدیت
  String phone;
  List<CustomerTransaction> transactions;

  CustomerModel({
    required this.name,
    required this.cast,
    required this.phone,
    required this.transactions,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'cast': cast,
        'phone': phone,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory CustomerModel.fromJson(Map<dynamic, dynamic> json) {
    var rawTxList = json['transactions'] as List? ?? [];
    List<CustomerTransaction> txList =
        rawTxList.map((t) => CustomerTransaction.fromJson(t as Map<dynamic, dynamic>)).toList();

    return CustomerModel(
      name: json['name'] ?? '',
      cast: json['cast'] ?? '', 
      phone: json['phone'] ?? '',
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

  // کسٹمرز کی لسٹ حاصل کرنا اور ساتھ ہی زیرو بیلنس والوں کو نیچے سارٹ کرنا
  List<CustomerModel> get customers {
    try {
      final rawData = customerBox.values.toList();
      List<CustomerModel> list = rawData
          .map((e) => CustomerModel.fromJson(e as Map<dynamic, dynamic>))
          .toList();

      list.sort((a, b) {
        double balanceA = _calculateBalance(a);
        double balanceB = _calculateBalance(b);

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

  double _calculateBalance(CustomerModel customer) {
    double total = 0.0;
    for (var tx in customer.transactions) {
      if (tx.type == 'get') {
        total += tx.amount;
      } else if (tx.type == 'give') {
        total -= tx.amount;
      }
    }
    return total;
  }

  // صرف نام اور فون کے ساتھ مینول پارٹی ایڈ کرنے کا محفوظ فنکشن
  void addManualCustomer({required String name, required String phone}) {
    if (name.trim().isEmpty) return;

    CustomerModel newCustomer = CustomerModel(
      name: name.trim(),
      cast: '',
      phone: phone.trim().isNotEmpty ? phone.trim() : 'نامعلوم',
      transactions: [],
    );

    customerBox.add(newCustomer.toJson());
    notifyListeners();
  }

  void removeCustomer(int index) {
    customerBox.deleteAt(index);
    notifyListeners();
  }
}

final CustomerController customerController = CustomerController();