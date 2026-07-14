import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final List<Map<String, dynamic>> customers;
  final Function(List<Map<String, dynamic>>) onUpdateCustomers;

  const HistoryPage({
    super.key,
    required this.customers,
    required this.onUpdateCustomers,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // تمام کسٹمرز کی ٹرانزیکشنز کو حالیہ ترین کے مطابق ترتیب دینے کا فنکشن
  List<Map<String, dynamic>> _getSortedTransactions() {
    List<Map<String, dynamic>> allTx = [];
    for (var customer in widget.customers) {
      final entries = customer['entries'] as List<dynamic>? ?? [];
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        allTx.add({
          'customerName': customer['name'],
          'customerPhone': customer['phone'],
          'entryIndex': i,
          'date': entry['date'] ?? '',
          'type': entry['type'] ?? 'gave',
          'amount': entry['amount'] ?? 0,
          'details': entry['details'] ?? '',
          'timestamp': entry['timestamp'] ?? 0, // ترتیب کے لیے ٹائم سٹیمپ
        });
      }
    }
    // ٹرانزیکشنز کو ٹائم سٹیمپ کے حساب سے ترتیب دیں (حالیہ ترین سب سے اوپر)
    allTx.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    return allTx;
  }

  // ٹرانزیکشن کو ایڈٹ/ڈیلیٹ کرنے کا ڈائیلاگ
  void _showEditDeleteDialog(Map<String, dynamic> tx) {
    final TextEditingController amountController =
        TextEditingController(text: tx['amount'].toString());
    final TextEditingController detailsController =
        TextEditingController(text: tx['details']);

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              'تبدیلی برائے: ${tx['customerName']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  decoration: const InputDecoration(labelText: 'تفصیل'),
                ),
              ],
            ),
            actions: [
              // ڈیلیٹ بٹن
              TextButton(
                onPressed: () {
                  _deleteTransaction(tx);
                  Navigator.pop(context);
                },
                child: const Text('ڈیلیٹ کریں', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              // کینسل
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('کینسل'),
              ),
              // محفوظ کریں (ایڈٹ شدہ ڈیٹا)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                onPressed: () {
                  final newAmount = int.tryParse(amountController.text) ?? 0;
                  final newDetails = detailsController.text;
                  _updateTransaction(tx, newAmount, newDetails);
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

  // ٹرانزیکشن ڈیلیٹ کرنے کا کام اور ریاضیاتی حساب
  void _deleteTransaction(Map<String, dynamic> tx) {
    List<Map<String, dynamic>> updatedCustomers = List.from(widget.customers);
    
    for (int i = 0; i < updatedCustomers.length; i++) {
      if (updatedCustomers[i]['phone'] == tx['customerPhone']) {
        List<dynamic> entries = List.from(updatedCustomers[i]['entries']);
        final int index = tx['entryIndex'];
        
        final entry = entries[index];
        final int amount = entry['amount'] ?? 0;
        final String type = entry['type'] ?? 'gave';
        
        // ریاضیاتی فارمولا: اگر وصولی (got) ڈیلیٹ کی، تو بیلنس دوبارہ بڑھ جائے گا۔ اگر دیا (gave) ڈیلیٹ کیا، تو بیلنس کم ہو جائے گا۔
        int currentBalance = updatedCustomers[i]['balance'] as int;
        if (type == 'got') {
          currentBalance += amount;
        } else {
          currentBalance -= amount;
        }
        
        entries.removeAt(index);
        
        setState(() {
          updatedCustomers[i]['balance'] = currentBalance;
          updatedCustomers[i]['entries'] = entries;
        });
        break;
      }
    }
    widget.onUpdateCustomers(updatedCustomers);
  }

  // ٹرانزیکشن کو ایڈٹ کرنے کا کام اور ریاضیاتی حساب
  void _updateTransaction(Map<String, dynamic> tx, int newAmount, String newDetails) {
    List<Map<String, dynamic>> updatedCustomers = List.from(widget.customers);

    for (int i = 0; i < updatedCustomers.length; i++) {
      if (updatedCustomers[i]['phone'] == tx['customerPhone']) {
        List<dynamic> entries = List.from(updatedCustomers[i]['entries']);
        final int index = tx['entryIndex'];
        
        final entry = entries[index];
        final int oldAmount = entry['amount'] ?? 0;
        final String type = entry['type'] ?? 'gave';

        int currentBalance = updatedCustomers[i]['balance'] as int;

        // پہلے پرانے بیلنس کا اثر ختم کریں
        if (type == 'got') {
          currentBalance += oldAmount;
        } else {
          currentBalance -= oldAmount;
        }

        // اب نیا بیلنس لاگو کریں
        if (type == 'got') {
          currentBalance -= newAmount;
        } else {
          currentBalance += newAmount;
        }

        entries[index] = {
          'date': entry['date'],
          'type': type,
          'amount': newAmount,
          'details': newDetails,
          'timestamp': entry['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
        };

        setState(() {
          updatedCustomers[i]['balance'] = currentBalance;
          updatedCustomers[i]['entries'] = entries;
        });
        break;
      }
    }
    widget.onUpdateCustomers(updatedCustomers);
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _getSortedTransactions();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('روزنامچہ / ہسٹری', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF0D47A1),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: transactions.isEmpty
            ? const Center(
                child: Text(
                  'ابھی تک کوئی لین دین ریکارڈ نہیں ہوا!',
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isGot = tx['type'] == 'got';

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _showEditDeleteDialog(tx),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isGot ? Colors.green.shade100 : Colors.red.shade100,
                              child: Icon(
                                isGot ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isGot ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx['customerName'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tx['details'].toString().isEmpty ? 'قسط یا لین دین' : tx['details'],
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tx['date'],
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs. ${tx['amount']}',
                                  style: TextStyle(
                                    color: isGot ? Colors.green.shade700 : Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Icon(Icons.edit, size: 14, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}