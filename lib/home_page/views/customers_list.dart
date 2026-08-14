import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/add_party_dialog.dart';
import 'customers_widgets/customer_row_ui.dart';
import 'customers_widgets/customer_controller.dart';

<<<<<<< HEAD
// ==========================================
// 1. CUSTOMER TRANSACTION MODEL
// ==========================================
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

// ==========================================
// 2. CUSTOMER MODEL
// ==========================================
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
          String txPhone = (txValue['customerPhone'] ?? txValue['customerId'] ?? '')
              .toString()
              .replaceAll(RegExp(r'[^0-9]'), '');

          // 🎯 منظوری کی فیلڈز چیک کرنا (Approval Status Checks)
          bool isApproved = txValue['isApproved'] == true;
          String status = txValue['status']?.toString().toLowerCase().trim() ?? '';

          // 🔒 شرط: فون نمبر میچ کرے اور صرف وہی ٹرانزیکشنز لیں جو منظور شدہ ہوں
          bool isValidAndApproved = isApproved || status == 'approved';

          if (targetPhone.isNotEmpty && txPhone == targetPhone && isValidAndApproved) {
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

    tempTransactions.sort((a, b) {
      DateTime dtA = DateTime.tryParse(a['timestamp']?.toString() ?? a['date']?.toString() ?? '') ?? DateTime(2000);
      DateTime dtB = DateTime.tryParse(b['timestamp']?.toString() ?? b['date']?.toString() ?? '') ?? DateTime(2000);
      return dtA.compareTo(dtB);
    });

    double runningBalance = 0.0;

    for (var t in tempTransactions) {
      String type = t['type']?.toString().toLowerCase().trim() ?? '';
      
      double amt = 0.0;
      if (type == 'purchase' && t['remainingBalance'] != null) {
        amt = double.tryParse(t['remainingBalance'].toString()) ?? 0.0;
      } else {
        amt = double.tryParse(t['amount']?.toString() ?? '0') ?? 0.0;
      }

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
        runningBalance += amt;
      } else {
        runningBalance -= amt;
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

// ==========================================
// 4. CUSTOMERS LIST VIEW
// ==========================================
class CustomersListView extends StatelessWidget {
=======
class CustomersListView extends StatefulWidget {
>>>>>>> a
  const CustomersListView({super.key});

  @override
  State<CustomersListView> createState() => _CustomersListViewState();
}

class _CustomersListViewState extends State<CustomersListView> {
  final CustomerController _controller = CustomerController();

  @override
  void initState() {
    super.initState();
    _controller.loadAndSortCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ------------------ ٹاپ بار (RTL) ------------------
        Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () => showAddPartyDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      elevation: 4.0,
                      shadowColor: Colors.green.shade900.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text("ایڈ پارٹی", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),

                const SizedBox(width: 8),

<<<<<<< HEAD
                for (var c in allCustomers) {
                  double bal = c.calculateTotalBalance;
                  if (bal < 0) {
                    totalRed += bal.abs();
                  } else if (bal > 0) {
                    totalGreen += bal;
                  }
                }

                // 🎯 2. اوپر والے بٹنز میں ٹوٹل رقم بھیجنا
                sectionsController.updateTotals(
                  redTotal: totalRed,
                  greenTotal: totalGreen,
                );

                // 🎯 3. بٹن سلیکشن کے مطابق کسٹمرز کی ترتیب (Sorting)
                List<CustomerModel> displayedCustomers = List.from(allCustomers);

                displayedCustomers.sort((a, b) {
                  double balA = a.calculateTotalBalance;
                  double balB = b.calculateTotalBalance;

                  if (sectionsController.customerSortMode == "RED_FIRST") {
                    // ریڈ پہلے (bal < 0)، پھر گرین (bal > 0)، پھر زیرو (bal == 0)
                    int rankA = balA < 0 ? 0 : (balA > 0 ? 1 : 2);
                    int rankB = balB < 0 ? 0 : (balB > 0 ? 1 : 2);
                    if (rankA != rankB) return rankA.compareTo(rankB);
                    return balB.abs().compareTo(balA.abs());
                  } else if (sectionsController.customerSortMode == "GREEN_FIRST") {
                    // گرین پہلے (bal > 0)، پھر ریڈ (bal < 0)، پھر زیرو (bal == 0)
                    int rankA = balA > 0 ? 0 : (balA < 0 ? 1 : 2);
                    int rankB = balB < 0 ? 0 : (balB < 0 ? 1 : 2);
                    if (rankA != rankB) return rankA.compareTo(rankB);
                    return balB.abs().compareTo(balA.abs());
                  } else {
                    // نارمل ترتیب (ترتیبِ نو)
                    if (balA == 0 && balB == 0) return a.name.compareTo(b.name);
                    if (balA == 0) return 1;
                    if (balB == 0) return -1;
                    return balB.abs().compareTo(balA.abs());
                  }
                });

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
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: const TextStyle(fontSize: 12)),
                                  );
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
                            onPressed: () {
                              showAddPartyDialog(context);
                            },
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
=======
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      textAlign: TextAlign.right,
                      onChanged: (value) {
                        setState(() {
                          _controller.searchCustomers(value);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "سرچ...",
                        hintStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
>>>>>>> a
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                SizedBox(
                  height: 38,
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
              ],
            ),
          ),
        ),

        const Divider(color: Colors.black12, thickness: 1, height: 1),

        // ------------------ محفوظ لائیو کسٹمر لسٹ ------------------
        Expanded(
          child: Hive.isBoxOpen('customerBox')
              ? ValueListenableBuilder(
                  valueListenable: Hive.box('customerBox').listenable(),
                  builder: (context, Box box, _) {
                    _controller.loadAndSortCustomers();

                    if (_controller.customers.isEmpty) {
                      return const Center(
                        child: Text("کوئی کسٹمر موجود نہیں ہے", style: TextStyle(color: Colors.grey)),
                      );
                    }

                    return ListView.builder(
                      itemCount: _controller.customers.length,
                      itemBuilder: (context, index) {
                        var customer = _controller.customers[index];
                        return CustomerRowUI(
                          name: customer['name'] ?? 'نامعلوم',
                          phone: customer['phone'] ?? '',
                          description: customer['description'] ?? '',
                        );
                      },
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ],
    );
  }
}