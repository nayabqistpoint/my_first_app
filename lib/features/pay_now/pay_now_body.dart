import 'package:flutter/material.dart';
import 'pay_now_controller.dart';

class PayNowBody extends StatelessWidget {
  const PayNowBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. تفصیل والا خانہ (پہلا کنٹرولر)
        TextField(
          controller: payNowController.descriptionController,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: "تفصیل درج کریں (اختیاری)",
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
        const SizedBox(height: 12),

        // 2. ریکارڈنگ / پلے والا خانہ (دوسرا کنٹرولر)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "آڈیو ریکارڈنگ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(
                onPressed: () {
                  // ریکارڈنگ کی لاجک یہاں آئے گی
                },
                icon: const Icon(Icons.mic, color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}