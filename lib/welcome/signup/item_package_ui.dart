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

  // پرچیز ریکویسٹ کا سوئچ
  bool _isPurchaseRequested = false;

  // کیلکولیٹر سے آنے والا ڈیٹا یہاں محفوظ ہوگا
  Map<String, dynamic> _calculatorData = {};

  Map<String, dynamic> getPackageData() {
    if (!_isPurchaseRequested) {
      return {'isPurchaseRequested': false};
    }
    return {
      'isPurchaseRequested': true,
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

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _calculatorData = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String modelName = _calculatorData['mobileName'] ?? '';
    final String packageName = _calculatorData['packageName'] ?? '';
    final String cashPrice = _calculatorData['cashPrice'] ?? '';
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
                Row(
                  children: [
                    const Text('پرچیز ریکویسٹ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Switch(
                      value: _isPurchaseRequested,
                      activeThumbColor: Colors.red[800],
                      onChanged: (value) {
                        setState(() {
                          _isPurchaseRequested = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            if (_isPurchaseRequested) ...[
              const SizedBox(height: 8),
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
              const SizedBox(height: 8),

              Column(
                children: [
                  // 1. پہلی لائن: ماڈل اور پیکج
                  Row(
                    children: [
                      Expanded(child: _buildBox('ماڈل:', modelName.isEmpty ? 'منتخب کریں' : modelName)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildBox('پیکج:', packageName.isEmpty ? 'منتخب کریں' : packageName)),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 2. دوسری لائن: نقد قیمت اور ایڈوانس
                  Row(
                    children: [
                      Expanded(child: _buildBox('نقد قیمت:', cashPrice.isEmpty ? '0' : cashPrice)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildBox('ایڈوانس:', advanceAmount.isEmpty ? '0' : advanceAmount)),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 3. تیسری لائن: ماہانہ قسط اور کل ادھار قیمت (دونوں ایک ساتھ)
                  Row(
                    children: [
                      Expanded(child: _buildBox('ماہانہ قسط:', monthlyInstallment.isEmpty ? '0' : monthlyInstallment)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildBox('کل ادھار قیمت:', totalPrice.isEmpty ? '0' : totalPrice, isTotal: true)),
                    ],
                  ),
                  
                  // 4. چوتھی لائن: IMEI نمبر اور کلر (اگر موجود ہوں)
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

                  // 5. پانچویں لائن: چیک نمبر اور بینک کا نام (اگر موجود ہوں)
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
          ],
        ),
      ),
    );
  }

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