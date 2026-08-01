import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_first_app/customer_ledger_page.dart';

// ==========================================
// 1. CUSTOMER TRANSACTION MODEL
// ==========================================
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

// ==========================================
// 2. CUSTOMER MODEL
// ==========================================
class CustomerModel {
  String name;
  String cast; // قوم
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
      name: json['customerName'] ?? json['name'] ?? '',
      cast: json['customerCaste'] ?? json['cast'] ?? json['caste'] ?? '',
      phone: json['customerPhone'] ?? json['phone'] ?? '',
      transactions: txList,
    );
  }
}

// ==========================================
// 3. CUSTOMER CONTROLLER
// ==========================================
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

  void removeCustomer(int index) {
    customerBox.deleteAt(index);
    notifyListeners();
  }
}

final CustomerController customerController = CustomerController();

// ==========================================
// 4. CUSTOMERS LIST VIEW
// ==========================================
class CustomersListView extends StatelessWidget {
  const CustomersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: customerController,
      builder: (context, child) {
        final customersList = customerController.customers;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    height: 35,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        items: ["سب", "باقی", "مکمل"].map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (_) {},
                        hint: const Text("فلٹر", style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1, 
                    child: SizedBox(
                      height: 35,
                      child: TextField(
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: "سرچ...",
                          hintStyle: const TextStyle(fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      minimumSize: const Size(100, 35),
                    ),
                    child: const Text("ایڈ پارٹی", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.black, thickness: 1.2, height: 1),
            Expanded(
              child: customersList.isEmpty
                  ? const Center(
                      child: Text(
                        "کوئی کسٹمر موجود نہیں",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: customersList.length,
                      itemBuilder: (context, index) {
                        final customer = customersList[index];
                        
                        double totalBalance = 0.0;
                        if (customer.transactions.isNotEmpty) {
                          for (var tx in customer.transactions) {
                            if (tx.type == 'get') {
                              totalBalance += tx.amount;
                            } else if (tx.type == 'give') {
                              totalBalance -= tx.amount;
                            }
                          }
                        }

                        // رنگ کا تعین: اگر پلس ہے تو گرین (لینے ہیں)، مائنس ہے تو ریڈ (دینے ہیں)
                        bool isAmountGreen = totalBalance >= 0; 
                        Color amountColor = isAmountGreen ? Colors.green : Colors.red;

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CustomerLedgerPage(),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // بائیں طرف صرف رقم
                                    Text(
                                      "Rs ${totalBalance.abs().toStringAsFixed(0)}", 
                                      style: TextStyle(
                                        color: amountColor, 
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 16,
                                      ),
                                    ),
                                    // دائیں طرف نام، قوم اور چھوٹا آئیکن
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "${customer.name} ${customer.cast}".trim(), 
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        const CircleAvatar(
                                          radius: 15, 
                                          backgroundColor: Colors.black12, 
                                          child: Icon(Icons.person, size: 18, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(color: Colors.black26, thickness: 0.5, height: 1),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}