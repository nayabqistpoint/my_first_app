import 'package:flutter/material.dart';
import 'package:my_first_app/home_page/transaction_forms/payment_in/payment_in_controller.dart';
import 'package:my_first_app/home_page/transaction_forms/payment_in/payment_header.dart';
import 'package:my_first_app/home_page/transaction_forms/payment_in/payment_body.dart';

class PaymentInScreen extends StatefulWidget {
  final String? customerId; // 🔑 کسٹमर آئی ڈی (موبائل نمبر) یہاں وصول کی جائے گی
  const PaymentInScreen({super.key, this.customerId});

  @override
  State<PaymentInScreen> createState() => _PaymentInScreenState();
}

class _PaymentInScreenState extends State<PaymentInScreen> {
  late final PaymentInController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaymentInController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PaymentHeader(
        title: 'پیمنٹ ان (Payment In)',
        themeColor: Colors.green,
      ),
      body: PaymentBody(controller: _controller),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // 🔑 یہاں اب درست طریقے سے customerId پاس ہو رہا ہے
            onPressed: () => _controller.savePaymentIn(context, customerId: widget.customerId),
            child: const Text(
              'پیمنٹ محفوظ کریں',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}