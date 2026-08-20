import 'package:flutter/material.dart';
import 'package:my_first_app/customer_ledger/customer_ledger_controller.dart';
import 'package:my_first_app/customer_ledger/top.dart';
import 'package:my_first_app/customer_ledger/middle.dart';
import 'package:my_first_app/customer_ledger/bottom.dart';

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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LedgerTopWidget(controller: _controller),
                      
                      // 🎯 یہاں const ہٹا کر controller پاس کر دیا گیا ہے
                      LedgerMiddleWidget(controller: _controller),
                    ],
                  ),
                ),
              ),

              // ۳. باٹم ویجٹ
              LedgerBottomWidget(controller: _controller),
            ],
          ),
        );
      },
    );
  }
}