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
            const SizedBox(height: 8),
            
            // پیکجز کی لسٹ (ہلکے اور مدہم دو مختلف کلرز کے ساتھ)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  bool isAdvancePackage = item['isAdvance'] ?? false;

                  // دو مختلف ہلکے مدہم رنگ (ایک ہلکا بلیو/سیاں ٹچ اور دوسرا ہلکا گرین ٹچ)
                  final Color rowBackgroundColor = index.isEven 
                      ? const Color(0xFFF0F4F8) // بہت ہی مدہم سا ہلکا نیلا/سلیٹی شیڈ
                      : const Color(0xFFF1F8F5); // بہت ہی مدہم سا ہلکا سبز شیڈ

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: rowBackgroundColor,
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {
                          if (onPackageSelected != null) {
                            onPackageSelected!(item);
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              // پیکج (ماہانہ)
                              Expanded(
                                flex: 2, 
                                child: Text(
                                  item['packageName']!,
                                  textAlign: TextAlign.center, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935), fontSize: 13)
                                ),
                              ),
                              // ایڈوانس
                              Expanded(
                                flex: 2, 
                                child: Text(
                                  isAdvancePackage ? item['advance']! : "0", 
                                  textAlign: TextAlign.center, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 12.5)
                                ),
                              ),
                              // قسط
                              Expanded(
                                flex: 2, 
                                child: Text(
                                  item['installment']!, 
                                  textAlign: TextAlign.center, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12.5)
                                ),
                              ),
                              // ٹوٹل
                              Expanded(
                                flex: 2, 
                                child: Text(
                                  item['total']!, 
                                  textAlign: TextAlign.center, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 12.5)
                                ),
                              ),
                            ],
                          ),
                        ),
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