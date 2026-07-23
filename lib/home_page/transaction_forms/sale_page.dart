import 'package:flutter/material.dart';
import 'sale_purchase_controller.dart';

class SalePage extends StatelessWidget {
  const SalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: salePurchaseController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // یہ رہا وہ ہیڈر اور ٹوگل جو اب اس پیج پر بھی مستقل نظر آئے گا
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: const Color(0xFFE53935),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'نایاب قسط پوائنٹ',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment<int>(value: 0, label: Text('خرید', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                            ButtonSegment<int>(value: 1, label: Text('فروخت', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                          ],
                          selected: {salePurchaseController.selectedMode},
                          onSelectionChanged: (Set<int> newSelection) {
                            int selectedVal = newSelection.first;
                            salePurchaseController.setMode(selectedVal);

                            // اگر یہاں سے صارف واپس "خرید" (0) پر کلک کرے گا تو یہ پیج بند ہو کر پچھلے پرچیز پیج پر چلا جائے گا
                            if (selectedVal == 0) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.selected)) return Colors.white;
                              return Colors.transparent;
                            }),
                            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.selected)) return const Color(0xFFE53935);
                              return Colors.white;
                            }),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // سیل پیج کا باقی حصہ
                const Expanded(
                  child: Center(
                    child: Text(
                      'یہ فروخت (Sale) کا پیج ہے - اب ٹوگل یہاں بھی موجود ہے!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}