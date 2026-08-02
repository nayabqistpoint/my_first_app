import 'package:flutter/material.dart';
import 'payment_in_controller.dart'; // کنٹرولر کی امپورٹ

class PaymentInScreen extends StatefulWidget {
  const PaymentInScreen({super.key});

  @override
  State<PaymentInScreen> createState() => _PaymentInScreenState();
}

class _PaymentInScreenState extends State<PaymentInScreen> {
  // یہاں کنٹرولر کا ابجیکٹ بنا لیا ہے
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بیک بٹن اور ٹائ틀 (اپنی مرضی کا ڈیزائن)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'پیمنٹ ان (Payment In)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // رقم لکھنے کی فیلڈ
              TextField(
                controller: _controller.amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رقم درج کریں (Amount)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // ریمارکس لکھنے کی فیلڈ
              TextField(
                controller: _controller.remarksController,
                decoration: const InputDecoration(
                  labelText: 'تفصیل / ریمارکس (Remarks)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // سیو کرنے کا بٹن
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _controller.savePaymentIn(context),
                  child: const Text(
                    'پیمنٹ محفوظ کریں',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}