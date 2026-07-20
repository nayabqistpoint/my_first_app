import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calculater_controller.dart';

class CalculaterList extends StatelessWidget {
  const CalculaterList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculaterController>(
      builder: (context, controller, child) {
        final results = controller.calculateInstallments();

        return Column(
          children: [
            // ہیڈنگ باکس
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text("ٹوٹل", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 2, child: Text("صرف قسط", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 2, child: Text("قسط + ایڈوانس", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 2, child: Text("پیکج", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
            ),
            
            // پیکجز کی لسٹ - اسمارٹ اور کمپیکٹ
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero, // جگہ بچانے کے لیے
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2), // ورٹیکل مارجن کم کر دیا تاکہ زیادہ آئٹم آئیں
                    padding: const EdgeInsets.symmetric(vertical: 10), // پیڈنگ کم کر دی
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(item['total']!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                        Expanded(flex: 2, child: Text(item['without']!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14))),
                        Expanded(flex: 2, child: Text(item['with']!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 14))),
                        Expanded(flex: 2, child: Text(item['months']!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935), fontSize: 14))),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}