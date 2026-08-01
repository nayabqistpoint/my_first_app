import 'package:flutter/material.dart';
import 'customer_ledger/customer_ledger_controller.dart';
import 'customer_ledger/top.dart'; // یہاں ہم نے ٹاپ فائل کو امپورٹ کر لیا ہے

class CustomerLedgerPage extends StatefulWidget {
  final Map<String, dynamic> customerData;
  final bool isAdmin; 

  const CustomerLedgerPage({
    super.key,
    this.customerData = const {}, 
    this.isAdmin = true, 
  });

  @override
  State<CustomerLedgerPage> createState() => _CustomerLedgerPageState();
}

class _CustomerLedgerPageState extends State<CustomerLedgerPage> {
  late final CustomerLedgerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomerLedgerController(
      customerData: widget.customerData,
      isAdmin: widget.isAdmin,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          // چونکہ ٹاپ فائل کے اندر اپنا ریڈ کلر کا ہیڈر اور بیک ایرو موجود ہے، 
          // اس لیے ہم نے یہاں سے پرانا AppBar ہٹا دیا ہے تاکہ ڈیزائن دو دفعہ نہ آئے
          body: Column(
            children: [
              // ۱. یہاں ٹاپ وجٹ کو جوڑ دیا گیا ہے اور کنٹرولر پاس کر دیا ہے
              LedgerTopWidget(controller: _controller),
              
              // ۲. مڈل اور باٹم کے لیے فی الحال عارضی جگہ
              Expanded(
                child: Center(
                  child: Text(
                    _controller.isAdmin 
                        ? "اوپر والا حصہ (ٹاپ) کامیابی سے جڑ گیا ہے!\n(اب مڈل اور باٹم کی باری ہے)"
                        : "کسٹمر کا ٹاپ ویو بالکل تیار ہے!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}