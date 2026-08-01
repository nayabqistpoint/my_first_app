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
      cast: json['cast'] ?? '', // اگر پرانے ڈیٹا میں نہ ہو تو خالی
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

      // سارٹنگ: جن کا بیلنس ہے وہ اوپر، جن کا زیرو ہے وہ بالکل نیچے
      list.sort((a, b) {
        double balanceA = _calculateBalance(a);
        double balanceB = _calculateBalance(b);

        // اگر دونوں کا بیلنس زیرو ہے تو نام کے لحاظ سے ترتیب دیں
        if (balanceA == 0 && balanceB == 0) {
          return a.name.compareTo(b.name);
        }
        // اگر a کا بیلنس زیرو ہے تو اسے نیچے بھیجیں
        if (balanceA == 0) return 1;
        // اگر b کا بیلنس زیرو ہے تو اسے نیچے بھیجیں
        if (balanceB == 0) return -1;

        // بڑی رقم والے کو اوپر رکھیں
        return balanceB.abs().compareTo(balanceA.abs());
      });

      return list;
    } catch (e) {
      return [];
    }
  }

  // کل بیلنس نکالنے کا اندرونی فنکشن
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

  void addOrUpdateCustomer({
    required String name,
    String cast = '',
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
      if (cast.trim().isNotEmpty) existingCustomer.cast = cast.trim();
      if (phone.trim().isNotEmpty && phone.trim() != 'نامعلوم') {
        existingCustomer.phone = phone.trim();
      }
      if (amount > 0) {
        existingCustomer.transactions.add(newTx);
      }
      customerBox.put(existingKey, existingCustomer.toJson());
    } else {
      CustomerModel newCustomer = CustomerModel(
        name: name.trim(),
        cast: cast.trim(),
        phone: phone.trim().isNotEmpty ? phone.trim() : 'نامعلوم',
        transactions: amount > 0 ? [newTx] : [], // اگر رقم صفر ہو تو ٹرانزیکشن خالی بنے گی (زیرو بیلنس کسٹمر)
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