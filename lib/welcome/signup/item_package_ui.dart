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

  // کیلکولیٹر سے آنے والا ڈیٹا یہاں محفوظ ہوگا
  Map<String, dynamic> _calculatorData = {};

  Map<String, dynamic> getPackageData() {
    // لاجک اور کیلکولیٹر کا مکس ڈیٹا واپس کریں
    return {
      ..._logic.getPackageData(),
      ..._calculatorData,
    };
  }

  void _openCalculator(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InstallmentCalculaterPage(),
      ),
    );

    // جب کیلکولیٹر سے ڈیٹا واپس آئے تو سکرین کو اپڈیٹ کریں
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _calculatorData = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ڈیٹا نکالنے کے طریقے
    final String modelName = _calculatorData['mobileName'] ?? '';
    final String packageName = _calculatorData['packageName'] ?? '';
    final String advanceAmount = _calculatorData['advanceAmount'] ?? '';
    final String monthlyInstallment = _calculatorData['monthlyInstallment'] ?? '';
    final String totalPrice = _calculatorData['totalPrice'] ?? '';
    
    final String imei = _calculatorData['imei'] ?? '';
    final String color = _calculatorData['color'] ?? '';
    final String checkNumber = _calculatorData['checkNumber'] ?? '';
    final String bankName = _calculatorData['bankName'] ?? '';

    bool hasImeiOrColor = imei.isNotEmpty || color.isNotEmpty;
    bool hasCheckOrBank = checkNumber.isNotEmpty || bankName.isNotEmpty;

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
                    Expanded(child: _buildBox('ماڈل:', modelName.isEmpty ? 'منتخب کریں' : modelName)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildBox('پیکج:', packageName.isEmpty ? 'منتخب کریں' : packageName)),
                  ],
                ),
                const SizedBox(height: 6),

                // 2. دوسری لائن: ایڈوانس اور ماہانہ قسط
                Row(
                  children: [
                    Expanded(child: _buildBox('ایڈوانس:', advanceAmount.isEmpty ? '0' : advanceAmount)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildBox('ماہانہ قسط:', monthlyInstallment.isEmpty ? '0' : monthlyInstallment)),
                  ],
                ),
                const SizedBox(height: 6),

                // 3. تیسری لائن: کل ادھار قیمت
                _buildBox('کل ادھار قیمت:', totalPrice.isEmpty ? '0' : totalPrice, isTotal: true),
                
                // 4. چوتھی لائن: IMEI نمبر اور کلر (صرف تب ظاہر ہوں گے جب موجود ہوں)
                if (hasImeiOrColor) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (imei.isNotEmpty)
                        Expanded(child: _buildBox('IMEI نمبر:', imei, isSpecial: true))
                      else
                        const Spacer(),
                      if (imei.isNotEmpty && color.isNotEmpty) const SizedBox(width: 6),
                      if (color.isNotEmpty)
                        Expanded(child: _buildBox('کلر:', color, isSpecial: true))
                      else
                        const Spacer(),
                    ],
                  ),
                ],

                // 5. پانچویں لائن: چیک نمبر اور بینک کا نام (صرف تب ظاہر ہوں گے جب سیکیورٹی چیک آن ہو)
                if (hasCheckOrBank) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (checkNumber.isNotEmpty)
                        Expanded(child: _buildBox('چیک نمبر:', checkNumber, isSpecial: true))
                      else
                        const Spacer(),
                      if (checkNumber.isNotEmpty && bankName.isNotEmpty) const SizedBox(width: 6),
                      if (bankName.isNotEmpty)
                        Expanded(child: _buildBox('بینک کا نام:', bankName, isSpecial: true))
                      else
                        const Spacer(),
                    ],
                  ),
                ],
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