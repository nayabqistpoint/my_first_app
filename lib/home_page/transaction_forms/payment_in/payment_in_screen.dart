import 'package:flutter/material.dart';
import 'payment_in_controller.dart';
import 'payment_header.dart';
import 'payment_body.dart';

class PaymentInScreen extends StatefulWidget {
  const PaymentInScreen({super.key});

  @override
  State<PaymentInScreen> createState() => _PaymentInScreenState();
}

class _PaymentInScreenState extends State<PaymentInScreen> {
  final PaymentInController _controller = PaymentInController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // اوپر والا ہیڈر (فروزن / فکسڈ)
      appBar: const PaymentHeader(
        title: 'پیمنٹ ان (Payment In)',
        themeColor: Colors.green,
      ),
      // درمیان والا فارم باڈی
      body: PaymentBody(controller: _controller),
      // نیچے سیو کرنے کا بٹن (فکسڈ فوٹر)
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
            onPressed: () => _controller.savePaymentIn(context),
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