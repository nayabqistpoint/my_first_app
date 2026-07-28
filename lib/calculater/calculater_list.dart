import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calculater_controller.dart';

class CalculaterList extends StatelessWidget {
  final Function(Map<String, dynamic>)? onPackageSelected;

  const CalculaterList({super.key, this.onPackageSelected});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculaterController>(
      builder: (context, controller, child) {
        final results = controller.calculateInstallments();

        return Column(
          children: [
            // ہیڈنگز: پیکج (ماہانہ) | ایڈوانس | قسط | ٹوٹل
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(flex: 2, child: Text("پیکج (ماہانہ)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 2, child: Text("ایڈوانس", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 2, child: Text("قسط", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 2, child: Text("ٹوٹل", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
            ),
            
            // پیکجز کی لسٹ
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  bool isAdvancePackage = item['isAdvance'] ?? false;

                  return InkWell(
                    onTap: onPackageSelected != null
                        ? () {
                            onPackageSelected!(item);
                            Navigator.pop(context);
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                        color: onPackageSelected != null ? Colors.grey.shade50 : null,
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          // پیکج (ماہانہ)
                          Expanded(
                            flex: 2, 
                            child: Text(
                              item['packageName']!,
                              textAlign: TextAlign.center, 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935), fontSize: 14)
                            ),
                          ),
                          // ایڈوانس: اگر A والا پیکج ہے تو اصل رقم (رزلٹ) آئے گی، B والے کے لیے "0"
                          Expanded(
                            flex: 2, 
                            child: Text(
                              isAdvancePackage ? item['advance']! : "0", 
                              textAlign: TextAlign.center, 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 13)
                            ),
                          ),
                          // قسط
                          Expanded(
                            flex: 2, 
                            child: Text(
                              item['installment']!, 
                              textAlign: TextAlign.center, 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)
                            ),
                          ),
                          // ٹوٹل
                          Expanded(
                            flex: 2, 
                            child: Text(
                              item['total']!, 
                              textAlign: TextAlign.center, 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 13)
                            ),
                          ),
                        ],
                      ),
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