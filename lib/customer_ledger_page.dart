import 'package:flutter/material.dart';
import 'widgets/payment_in_dialog.dart';
import 'widgets/payment_out_dialog.dart';

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
  late Map<String, dynamic> _customer;

  @override
  void initState() {
    super.initState();
    _customer = Map<String, dynamic>.from(widget.customerData);
  }

  // پیمنٹ وصولی (IN) پاپ اپ لوڈ کرنے کا فنکشن
  void _showPaymentInDialog() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const PaymentInDialog();
      },
    );

    // اگر پاپ اپ سے ڈیٹا موصول ہوا
    if (result != null && mounted) {
      setState(() {
        final double amount = double.tryParse(result['amount'].toString()) ?? 0.0;
        final String details = result['details'] ?? 'پیمنٹ وصولی';
        
        // وصولی کی وجہ سے بیلنس کم کریں (You Will Get بیلنس میں سے مائنس ہوگا)
        final int currentBalance = (_customer['balance'] as num?)?.toInt() ?? 0;
        _customer['balance'] = currentBalance - amount.toInt();

        final List<dynamic> entries = List.from(_customer['entries'] ?? []);
        entries.insert(0, {
          'date': _formatCurrentDate(),
          'type': 'got',
          'amount': amount.toInt(),
          'details': details,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        _customer['entries'] = entries;
      });

      // ڈیش بورڈ/مین پیج کو نیا کسٹمر ابجیکٹ بھیجیں
      widget.onUpdateCustomer(_customer);
    }
  }

  // پیمنٹ ادائیگی (OUT) پاپ اپ لوڈ کرنے کا فنکشن
  void _showPaymentOutDialog() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const PaymentOutDialog();
      },
    );

    // اگر پاپ اپ سے ڈیٹا موصول ہوا
    if (result != null && mounted) {
      setState(() {
        final double amount = double.tryParse(result['amount'].toString()) ?? 0.0;
        final String details = result['details'] ?? 'پیمنٹ ادائیگی';
        
        // مزید ادھار یا ادائیگی سے بقایا بیلنس بڑھائیں
        final int currentBalance = (_customer['balance'] as num?)?.toInt() ?? 0;
        _customer['balance'] = currentBalance + amount.toInt();

        final List<dynamic> entries = List.from(_customer['entries'] ?? []);
        entries.insert(0, {
          'date': _formatCurrentDate(),
          'type': 'gave',
          'amount': amount.toInt(),
          'details': details,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        _customer['entries'] = entries;
      });

      // ڈیش بورڈ/مین پیج کو نیا کسٹمر ابجیکٹ بھیجیں
      widget.onUpdateCustomer(_customer);
    }
  }

  // تاریخ فارمیٹ کرنے کا فنکشن
  String _formatCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[now.weekday % 7];
    final day = now.day.toString().padLeft(2, '0');
    final month = months[now.month - 1];
    final year = now.year.toString().substring(2);

    return '$weekday, $day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    final entries = _customer['entries'] as List<dynamic>? ?? [];
    final bal = (_customer['balance'] as num?)?.toInt() ?? 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_customer['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF0D47A1),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // کسٹمر کا سٹیٹس کارڈ
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF0D47A1),
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    bal >= 0 ? 'رقم بقایا ہے (You Will Get)' : 'رقم دینی ہے (You Will Give)',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Rs. ${bal.abs()}',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // اینٹریز لسٹ
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('کوئی لین دین نہیں ملا!', style: TextStyle(fontWeight: FontWeight.bold)))
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final isGot = entry['type'] == 'got';
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          child: ListTile(
                            title: Text(entry['details'] ?? 'تفصیل نہیں ہے'),
                            subtitle: Text(entry['date'] ?? ''),
                            trailing: Text(
                              'Rs. ${entry['amount']}',
                              style: TextStyle(
                                color: isGot ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // بٹنز
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showPaymentInDialog,
                      icon: const Icon(Icons.arrow_downward, color: Colors.white),
                      label: const Text('پیمنٹ وصولی (IN)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showPaymentOutDialog,
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      label: const Text('پیمنٹ ادائیگی (OUT)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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