import 'package:flutter/material.dart';
import 'payment_out_controller.dart';
import 'payment_out_header.dart';
import 'payment_out_body.dart';

class PaymentOutScreen extends StatefulWidget {
  final String? customerId;
  const PaymentOutScreen({super.key, this.customerId});

  @override
  State<PaymentOutScreen> createState() => _PaymentOutScreenState();
}

class _PaymentOutScreenState extends State<PaymentOutScreen> {
  late final PaymentOutController controller;

  @override
  void initState() {
    super.initState();
    controller = PaymentOutController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PaymentOutHeader(
        title: 'پیمنٹ آؤٹ',
        themeColor: Colors.red,
      ),
      body: PaymentOutBody(controller: controller),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              controller.savePaymentOut(context, customerId: widget.customerId);
            },
            child: const Text(
              'محفوظ کریں',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}