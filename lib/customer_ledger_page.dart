import 'package:flutter/material.dart';

class CustomerLedgerPage extends StatefulWidget {
  final Map<String, dynamic> customerData;
  final Function(Map<String, dynamic>) onUpdateCustomer;

  const CustomerLedgerPage({
    super.key,
    required this.customerData,
    required this.onUpdateCustomer,
  });

  @override
  State<CustomerLedgerPage> createState() => _CustomerLedgerPageState();
}

class _CustomerLedgerPageState extends State<CustomerLedgerPage> {
  late Map<String, dynamic> customer;

  @override
  void initState() {
    super.initState();
    customer = Map<String, dynamic>.from(widget.customerData);
    customer['entries'] = List<dynamic>.from(widget.customerData['entries'] ?? []);
  }

  void _addNewTransaction(String type) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              type == 'got' ? 'پیمنٹ اِن (وصولی)' : 'پیمنٹ آؤٹ (ادھار)',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: type == 'got' ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'رقم (Rs.)'),
                ),
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(labelText: 'تفصیل (آئٹم یا وجہ)'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('کینسل'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: type == 'got' ? Colors.green.shade800 : Colors.red.shade800,
                ),
                onPressed: () {
                  final amount = int.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) return;

                  final details = detailsController.text;
                  final now = DateTime.now();
                  
                  final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                  final formattedDate = "${days[now.weekday % 7]}, ${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year.toString().substring(2)}";

                  final newEntry = {
                    'date': formattedDate,
                    'type': type,
                    'amount': amount,
                    'details': details,
                    'timestamp': now.millisecondsSinceEpoch,
                  };

                  setState(() {
                    customer['entries'].insert(0, newEntry);
                    
                    int currentBalance = (customer['balance'] as num?)?.toInt() ?? 0;
                    if (type == 'got') {
                      currentBalance -= amount;
                    } else {
                      currentBalance += amount;
                    }
                    customer['balance'] = currentBalance;
                  });

                  widget.onUpdateCustomer(customer);
                  Navigator.pop(context);
                },
                child: const Text('محفوظ کریں', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDeleteDialog(int index) {
    final entry = customer['entries'][index];
    final TextEditingController amountController = TextEditingController(text: entry['amount'].toString());
    final TextEditingController detailsController = TextEditingController(text: entry['details'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('ٹرانزیکشن تبدیل کریں', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'رقم (Rs.)'),
                ),
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(labelText: 'تفصیل'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    final oldAmount = (entry['amount'] as num?)?.toInt() ?? 0;
                    final type = entry['type'] ?? 'gave';
                    int currentBalance = (customer['balance'] as num?)?.toInt() ?? 0;

                    if (type == 'got') {
                      currentBalance += oldAmount;
                    } else {
                      currentBalance -= oldAmount;
                    }

                    customer['balance'] = currentBalance;
                    customer['entries'].removeAt(index);
                  });

                  widget.onUpdateCustomer(customer);
                  Navigator.pop(context);
                },
                child: const Text('ڈیلیٹ کریں', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('کینسل'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                onPressed: () {
                  final newAmount = int.tryParse(amountController.text) ?? 0;
                  final newDetails = detailsController.text;
                  final oldAmount = (entry['amount'] as num?)?.toInt() ?? 0;
                  final type = entry['type'] ?? 'gave';

                  setState(() {
                    int currentBalance = (customer['balance'] as num?)?.toInt() ?? 0;

                    if (type == 'got') {
                      currentBalance += oldAmount;
                    } else {
                      currentBalance -= oldAmount;
                    }

                    if (type == 'got') {
                      currentBalance -= newAmount;
                    } else {
                      currentBalance += newAmount;
                    }

                    customer['balance'] = currentBalance;
                    customer['entries'][index] = {
                      'date': entry['date'],
                      'type': type,
                      'amount': newAmount,
                      'details': newDetails,
                      'timestamp': entry['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
                    };
                  });

                  widget.onUpdateCustomer(customer);
                  Navigator.pop(context);
                },
                child: const Text('محفوظ کریں', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = customer['entries'] as List<dynamic>;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(customer['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: const Color(0xFF0D47A1),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF0D47A1),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('فون: ${customer['phone']}', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${customer['balance']}',
                            style: TextStyle(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold,
                              color: ((customer['balance'] as num?)?.toInt() ?? 0) >= 0 ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                          Text(
                            ((customer['balance'] as num?)?.toInt() ?? 0) >= 0 ? 'باقی آؤٹ (ادھار)' : 'باقی اِن (ایڈوانس)',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: entries.isEmpty
                  ? const Center(
                      child: Text('کوئی لین دین نہیں ہے، نیچے دیے گئے بٹنوں سے اینٹری شروع کریں۔'),
                    )
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final isGot = entry['type'] == 'got';

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: ListTile(
                            onTap: () => _showEditDeleteDialog(index),
                            leading: CircleAvatar(
                              backgroundColor: isGot ? Colors.green.shade100 : Colors.red.shade100,
                              child: Icon(
                                isGot ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isGot ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                            title: Text(
                              entry['details'] != null && entry['details'].toString().isNotEmpty
                                  ? entry['details']
                                  : (isGot ? 'پیمنٹ اِن' : 'پیمنٹ آؤٹ'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(entry['date'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Rs. ${entry['amount']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isGot ? Colors.green.shade700 : Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.edit, size: 14, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _addNewTransaction('got'),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('پیمنٹ اِن (آئے)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _addNewTransaction('gave'),
                      icon: const Icon(Icons.remove, color: Colors.white),
                      label: const Text('پیمنٹ آؤٹ (گئے)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}