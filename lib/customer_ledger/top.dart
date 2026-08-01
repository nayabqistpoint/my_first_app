import 'package:flutter/material.dart';
import 'customer_ledger_controller.dart';

class LedgerTopWidget extends StatelessWidget {
  final CustomerLedgerController controller;

  const LedgerTopWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ۱۔ ہیڈر (ایرو + سینٹر نام + تصویر)
        Container(
          color: const Color(0xFFE53935),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // بیک ایرو
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                ),
                const Spacer(),
                // نام (کنٹرولر سے ڈائنامک نام آ رہا ہے)
                Text(
                  controller.customerName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                // بڑا پروفائل آئکن
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white24, 
                  child: Icon(Icons.person, color: Colors.white, size: 25),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ۲۔ بیلنس باکس (کنٹرولر سے کل بیلنس آ رہا ہے)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE53935), width: 1.2),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Text(
              "Rs ${controller.totalBalance.toStringAsFixed(0)}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ۳۔ سمارٹ کیپسولز
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildActionCapsule(text: "رپورٹ"),
              const SizedBox(width: 6),
              _buildActionCapsule(text: "تاریخ"),
              const SizedBox(width: 6),
              _buildActionCapsule(text: "ریمائنڈر"),
              const SizedBox(width: 6),
              _buildActionCapsule(text: "ایس ایم ایس"),
            ],
          ),
        ),
        
        const SizedBox(height: 10),
        const Divider(color: Colors.black12, height: 1, thickness: 0.8),
      ],
    );
  }

  // کیپسول ڈیزائن
  Widget _buildActionCapsule({required String text}) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.black12,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}