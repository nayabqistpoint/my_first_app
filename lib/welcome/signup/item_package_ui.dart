// file: item_package_ui.dart
import 'package:flutter/material.dart';
import 'package:my_first_app/installment_calculater_page.dart';
import 'item_package_logic.dart';

class ItemPackageUI extends StatefulWidget {
  const ItemPackageUI({super.key});

  @override
  State<ItemPackageUI> createState() => ItemPackageUIState();
}

class ItemPackageUIState extends State<ItemPackageUI> {
  final ItemPackageLogic _logic = ItemPackageLogic();

  Map<String, dynamic> getPackageData() {
    return _logic.getPackageData();
  }

  void _openCalculator(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InstallmentCalculaterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ہیڈر اور قسط کیلکولیٹر بٹن
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '3. آئٹم اور پیکج کی معلومات',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: ElevatedButton.icon(
                    onPressed: () => _openCalculator(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.calculate, size: 14),
                    label: const Text('قسط کیلکولیٹر کھولیں', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // تمام خانے
            Column(
              children: [
                // 1. پہلی لائن: موبائل کا ماڈل اور پیکج کا نام
                Row(
                  children: [
                    Expanded(child: _buildBox('ماڈل:', 'Samsung A14 (ڈمی)')),
                    const SizedBox(width: 6),
                    Expanded(child: _buildBox('پیکج:', '6 ماہ (ڈمی)')),
                  ],
                ),
                const SizedBox(height: 6),

                // 2. دوسری لائن: ایڈوانس اور ماہانہ قسط
                Row(
                  children: [
                    Expanded(child: _buildBox('ایڈوانس:', '10,000')),
                    const SizedBox(width: 6),
                    Expanded(child: _buildBox('ماہانہ قسط:', '5,000')),
                  ],
                ),
                const SizedBox(height: 6),

                // 3. تیسری لائن: کل ادھار قیمت (پوری ایک لائن میں)
                _buildBox('کل ادھار قیمت:', '60,000', isTotal: true),
                const SizedBox(height: 6),

                // 4. چوتھی لائن: IMEI نمبر اور کلر
                Row(
                  children: [
                    Expanded(child: _buildBox('IMEI نمبر:', '123456789012345', isSpecial: true)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildBox('کلر:', 'Black', isSpecial: true)),
                  ],
                ),
                const SizedBox(height: 6),

                // 5. پانچویں لائن (بالکل آخر میں): چیک نمبر اور بینک کا نام
                Row(
                  children: [
                    Expanded(child: _buildBox('چیک نمبر:', 'CHQ-987654', isSpecial: true)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildBox('بینک کا نام:', 'Meezan Bank', isSpecial: true)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ایک لائن اور خوبصورت باکس بنانے کا سمپل ویجیٹ
  Widget _buildBox(String label, String value, {bool isTotal = false, bool isSpecial = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isTotal ? Colors.red.shade50 : (isSpecial ? Colors.amber.shade50 : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isTotal ? Colors.red.shade200 : (isSpecial ? Colors.amber.shade300 : Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isTotal ? Colors.red[800] : (isSpecial ? Colors.brown.shade800 : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}