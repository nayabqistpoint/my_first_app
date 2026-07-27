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
  String phone;
  List<CustomerTransaction> transactions;

  CustomerModel({
    required this.name,
    required this.phone,
    required this.transactions,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory CustomerModel.fromJson(Map<dynamic, dynamic> json) {
    var rawTxList = json['transactions'] as List? ?? [];
    List<CustomerTransaction> txList =
        rawTxList.map((t) => CustomerTransaction.fromJson(t as Map<dynamic, dynamic>)).toList();

    return CustomerModel(
      name: json['name'] ?? '',
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

  List<CustomerModel> get customers {
    try {
      final rawData = customerBox.values.toList();
      return rawData.map((e) => CustomerModel.fromJson(e as Map<dynamic, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  void addOrUpdateCustomer({
    required String name,
    required String phone,
    required double amount,
    required String type,
    required String description,
  }) {
    if (name.trim().isEmpty) return;

    int existingKey = -1;
    CustomerModel? existingCustomer;

    for (var key in customerBox.keys) {
      final rawData = customerBox.get(key);
      if (rawData != null && rawData is Map) {
        String dbName = rawData['name'] ?? '';
        if (dbName.trim().toLowerCase() == name.trim().toLowerCase()) {
          existingKey = key;
          existingCustomer = CustomerModel.fromJson(rawData);
          break;
        }
      }
    }

    String currentDate = DateTime.now().toString().split(' ')[0];
    
    CustomerTransaction newTx = CustomerTransaction(
      date: currentDate,
      amount: amount,
      type: type,
      description: description,
    );

    if (existingKey != -1 && existingCustomer != null) {
      existingCustomer.name = name.trim();
      if (phone.trim().isNotEmpty && phone.trim() != 'نامعلوم') {
        existingCustomer.phone = phone.trim();
      }
      existingCustomer.transactions.add(newTx);
      customerBox.put(existingKey, existingCustomer.toJson());
    } else {
      CustomerModel newCustomer = CustomerModel(
        name: name.trim(),
        phone: phone.trim().isNotEmpty ? phone.trim() : 'نامعلوم',
        transactions: [newTx],
      );
      customerBox.add(newCustomer.toJson());
    }

    notifyListeners();
  }

  void removeCustomer(int index) {
    customerBox.deleteAt(index);
    notifyListeners();
  }
}

final CustomerController customerController = CustomerController();