import 'package:flutter/material.dart';
import 'customer_ledger/customer_ledger_controller.dart';
import 'customer_ledger/top.dart';
import 'customer_ledger/middle.dart';
import 'customer_ledger/bottom.dart';

class CustomerLedgerPage extends StatefulWidget {
  final dynamic customer;
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
      customer: widget.customer,
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
              // ۱. ٹاپ ویجٹ (نام، بیلنس اور دیگر معلومات)
              LedgerTopWidget(controller: _controller),
              
              // ۲. مڈل ویجٹ (سرچ بار اور ٹرانزیکشن لسٹ)
              Expanded(
                child: LedgerMiddleWidget(controller: _controller),
              ),

              // ۳. باٹم ویجٹ (پیمنٹ ان اور پیمنٹ آؤٹ کے بٹن)
              LedgerBottomWidget(controller: _controller),
            ],
          ),
        );
      },
    );
  }
}