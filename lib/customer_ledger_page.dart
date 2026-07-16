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
  void _showPaymentInDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const PaymentInDialog();
      },
    );
  }

  // پیمنٹ ادائیگی (OUT) پاپ اپ لوڈ کرنے کا فنکشن
  void _showPaymentOutDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const PaymentOutDialog();
      },
    );
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

            // نیوی گیشن بٹنز (پیمنٹ اِن اور آؤٹ)
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