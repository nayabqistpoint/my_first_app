import 'package:flutter/material.dart';

class CustomerLedgerPage extends StatefulWidget {
  final Map<String, dynamic> customerData;

  const CustomerLedgerPage({super.key, required this.customerData});

  @override
  State<CustomerLedgerPage> createState() => _CustomerLedgerPageState();
}

class _CustomerLedgerPageState extends State<CustomerLedgerPage> {
  late Map<String, dynamic> _customer;
  late List<Map<String, dynamic>> _entries;

  @override
  void initState() {
    super.initState();
    _customer = Map<String, dynamic>.from(widget.customerData);
    _entries = List<Map<String, dynamic>>.from(_customer['entries'] ?? []);
  }

  void _addEntryDialog(bool isReceived) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              isReceived ? 'آپ کو ملے (رقم وصولی)' : 'آپ نے دیے (سامان/ادھار)',
              style: TextStyle(color: isReceived ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'رقم (Rs.)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(labelText: 'تفصیل', border: OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('منسوخ')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: isReceived ? Colors.green : Colors.red),
                onPressed: () {
                  final int amount = int.tryParse(amountController.text) ?? 0;
                  if (amount > 0) {
                    setState(() {
                      int currentBalance = _customer['balance'] as int;
                      int newBalance = isReceived ? currentBalance - amount : currentBalance + amount;
                      _customer['balance'] = newBalance;

                      _entries.insert(0, {
                        'date': 'آج, 05:00 PM',
                        'type': isReceived ? 'got' : 'gave',
                        'amount': amount,
                        'details': detailsController.text.isEmpty ? (isReceived ? 'قسط وصولی' : 'سامان ادھار') : detailsController.text,
                        'balanceAfter': newBalance,
                      });
                    });
                    Navigator.pop(context);
                  }
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
    int balance = _customer['balance'] ?? 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D47A1),
          iconTheme: const IconThemeData(color: Colors.white),
          title: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('پروفائل پیج اگلے مرحلے میں جڑے گا: ${_customer['name']}')),
              );
            },
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.white24, child: Text(_customer['name'][0], style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 10),
                Text(_customer['name'], style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.white,
              child: Column(
                children: [
                  Text('Rs ${balance.abs()}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: balance >= 0 ? Colors.red.shade700 : Colors.green.shade700)),
                  Text(balance >= 0 ? 'آپ کو ملیں گے' : 'آپ نے دینے ہیں', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _btn(Icons.picture_as_pdf, 'رپورٹ', Colors.orange),
                  _btn(Icons.calendar_month, _customer['dueDate'] ?? 'تاریخ', Colors.blue),
                  _btn(Icons.chat, 'ریمائنڈر', Colors.green),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final item = _entries[index];
                  bool isGot = item['type'] == 'got';
                  return ListTile(
                    title: Text(item['details']),
                    subtitle: Text('${item['date']} | بیلنس: Rs ${item['balanceAfter']}'),
                    trailing: Text('${item['amount']}', style: TextStyle(color: isGot ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () => _addEntryDialog(true), child: const Text('آپ کو ملے Rs', style: TextStyle(color: Colors.white)))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => _addEntryDialog(false), child: const Text('آپ نے دیے Rs', style: TextStyle(color: Colors.white)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String label, Color color) {
    return Column(children: [Icon(icon, color: color), Text(label, style: const TextStyle(fontSize: 11))]);
  }
}