import 'package:flutter/material.dart';
import 'customer_ledger/customer_ledger_controller.dart';
import 'customer_ledger/top.dart';
import 'customer_ledger/middle.dart';
import 'customer_ledger/bottom.dart';

class CustomerLedgerPage extends StatefulWidget {
  final dynamic customer; // 👈 اب ہم یہاں ماڈل یا ڈیٹا کچھ بھی ریسیو کر سکتے ہیں
  final Map<String, dynamic> customerData;
  final bool isAdmin; 

  const CustomerLedgerPage({
    super.key,
    this.customer,
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
      customer: widget.customer, // 👈 ماڈل کنٹرولر کو بھیج دیا
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
          body: Column(
            children: [
              // ۱. اوپر والا حصہ (ٹاپ: نام، بیلنس، کیپسولز)
              LedgerTopWidget(controller: _controller),
              
              // ۲. درمیان والا حصہ (مڈل: سرچ بار اور ٹرانزیکشنز کی لسٹ)
              Expanded(
                child: LedgerMiddleWidget(controller: _controller),
              ),

              // ۳. نیچے والا حصہ (باٹم: پیمنٹ آؤٹ اور پیمنٹ ان کے دو بٹن)
              LedgerBottomWidget(controller: _controller),
            ],
          ),
        );
      },
    );
  }
}