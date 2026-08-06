import 'package:flutter/material.dart';

class ManualBoxesWidget extends StatefulWidget {
  final TextEditingController purchasePriceController;
  final TextEditingController quantityController;
  final TextEditingController salePriceController;
  final TextEditingController supplierController;
  final bool isPercentageMode;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<double> onPriceAdjust;

  const ManualBoxesWidget({
    super.key,
    required this.purchasePriceController,
    required this.quantityController,
    required this.salePriceController,
    required this.supplierController,
    required this.isPercentageMode,
    required this.onModeChanged,
    required this.onPriceAdjust,
  });

  @override
  State<ManualBoxesWidget> createState() => _ManualBoxesWidgetState();
}

class _ManualBoxesWidgetState extends State<ManualBoxesWidget> {
  void _adjustPrice(double amount) {
    double currentSale = double.tryParse(widget.salePriceController.text) ?? 0.0;
    double currentPurchase = double.tryParse(widget.purchasePriceController.text) ?? 0.0;

    if (widget.isPercentageMode) {
      double adjusted = currentSale + (currentPurchase * (amount / 100));
      widget.salePriceController.text = adjusted.toStringAsFixed(2);
      widget.onPriceAdjust(adjusted);
    } else {
      double adjusted = currentSale + amount;
      if (adjusted < 0) adjusted = 0;
      widget.salePriceController.text = adjusted.toStringAsFixed(2);
      widget.onPriceAdjust(adjusted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. پہلی لائن: قیمتِ خرید اور مقدار
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.purchasePriceController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'قیمتِ خرید (Purchase Price)',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: widget.quantityController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'مقدار (Quantity)',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2. دوسری لائن: قیمتِ فروخت اور ساتھ میں روپے/پرسنٹ بڑھانے والے بٹنز
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: widget.salePriceController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'قیمتِ فروخت (Sale Price)',
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                      onPressed: () => _adjustPrice(widget.isPercentageMode ? -5.0 : -100.0),
                      tooltip: 'کم کریں', // یہاں toolTip کو ٹھیک کر کے tooltip کر دیا گیا ہے
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                      onPressed: () => _adjustPrice(widget.isPercentageMode ? 5.0 : 100.0),
                      tooltip: 'بڑھائیں', // یہاں بھی ٹھیک کر دیا گیا ہے
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            
            // موڈ سلیکٹر (روپے بمقابلہ پرسنٹیج)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('موڈ: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ChoiceChip(
                  label: const Text('روپے (Rs)', style: TextStyle(fontSize: 10)),
                  selected: !widget.isPercentageMode,
                  selectedColor: Colors.red.shade100,
                  onSelected: (selected) {
                    if (selected) widget.onModeChanged(false);
                  },
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('فیصد (%)', style: TextStyle(fontSize: 10)),
                  selected: widget.isPercentageMode,
                  selectedColor: Colors.red.shade100,
                  onSelected: (selected) {
                    if (selected) widget.onModeChanged(true);
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. تیسری لائن: سپلائر کا نام
        TextField(
          controller: widget.supplierController,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'سپلائر کا نام (Supplier Name)',
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}