import 'package:flutter/material.dart';

class ManualBoxesWidget extends StatefulWidget {
  final TextEditingController purchasePriceController;
  final TextEditingController quantityController;
  final TextEditingController salePriceController;
  final TextEditingController adjustmentController;
  final TextEditingController supplierController;
  final bool isPercentageMode;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<double> onPriceAdjust;

  const ManualBoxesWidget({
    super.key,
    required this.purchasePriceController,
    required this.quantityController,
    required this.salePriceController,
    required this.adjustmentController,
    required this.supplierController,
    required this.isPercentageMode,
    required this.onModeChanged,
    required this.onPriceAdjust,
  });

  @override
  State<ManualBoxesWidget> createState() => _ManualBoxesWidgetState();
}

class _ManualBoxesWidgetState extends State<ManualBoxesWidget> {
  double _currentAmountAdd = 0.0;
  int _currentPercentAdd = 0;

  @override
  void initState() {
    super.initState();
    // لسٹنر لگانے اور ویلیو کیلکولیٹ کرنے کے لیے فریم کا انتظار
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeExistingAdjustment();
        widget.purchasePriceController.addListener(_onPurchasePriceChanged);
      }
    });
  }

  @override
  void dispose() {
    widget.purchasePriceController.removeListener(_onPurchasePriceChanged);
    super.dispose();
  }

  // محفوظ شدہ قیمت کو بغیر کریش کیے کیپچر کرنے کی لاجک
  void _initializeExistingAdjustment() {
    double purchasePrice = double.tryParse(widget.purchasePriceController.text) ?? 0.0;
    double salePrice = double.tryParse(widget.salePriceController.text) ?? purchasePrice;

    double diff = salePrice - purchasePrice;

    if (widget.isPercentageMode) {
      if (purchasePrice > 0) {
        _currentPercentAdd = ((diff / purchasePrice) * 100).round();
      } else {
        _currentPercentAdd = 0;
      }
    } else {
      _currentAmountAdd = diff;
    }

    _recalculateAndSet(purchasePrice, updateSalePriceText: false);
  }

  void _onPurchasePriceChanged() {
    if (!mounted) return;
    double purchasePrice = double.tryParse(widget.purchasePriceController.text) ?? 0.0;
    _recalculateAndSet(purchasePrice);
  }

  void _adjust(bool isIncrement) {
    double purchasePrice = double.tryParse(widget.purchasePriceController.text) ?? 0.0;

    if (widget.isPercentageMode) {
      if (isIncrement) {
        _currentPercentAdd += 1;
      } else {
        _currentPercentAdd -= 1;
      }
    } else {
      if (isIncrement) {
        _currentAmountAdd += 500.0;
      } else {
        _currentAmountAdd -= 500.0;
      }
    }

    _recalculateAndSet(purchasePrice);
  }

  void _recalculateAndSet(double purchasePrice, {bool updateSalePriceText = true}) {
    double finalSalePrice = purchasePrice;

    if (widget.isPercentageMode) {
      widget.adjustmentController.text = "${_currentPercentAdd > 0 ? '+' : ''}$_currentPercentAdd%";
      double percentVal = (purchasePrice * _currentPercentAdd) / 100;
      finalSalePrice = purchasePrice + percentVal;
    } else {
      widget.adjustmentController.text = "${_currentAmountAdd > 0 ? '+' : ''}${_currentAmountAdd.toStringAsFixed(0)}";
      finalSalePrice = purchasePrice + _currentAmountAdd;
    }

    if (finalSalePrice < 0) finalSalePrice = 0;

    if (updateSalePriceText) {
      widget.salePriceController.text = finalSalePrice.toStringAsFixed(0);
    }

    widget.onPriceAdjust(finalSalePrice);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.purchasePriceController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'قیمتِ خرید (Purchase)',
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
        Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: widget.adjustmentController,
                readOnly: true,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                decoration: InputDecoration(
                  labelText: widget.isPercentageMode ? 'اضافہ (%)' : 'اضافہ (Rs)',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 6,
              child: TextField(
                controller: widget.salePriceController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'قیمتِ فروخت (Sale Price)',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                        onPressed: () => _adjust(false),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 22),
                        onPressed: () => _adjust(true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('موڈ سلیکٹ کریں: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            ChoiceChip(
              label: const Text('Rs (+500)', style: TextStyle(fontSize: 10)),
              selected: !widget.isPercentageMode,
              selectedColor: Colors.blue.shade100,
              onSelected: (selected) {
                if (selected) {
                  widget.onModeChanged(false);
                  double purchasePrice = double.tryParse(widget.purchasePriceController.text) ?? 0.0;
                  double salePrice = double.tryParse(widget.salePriceController.text) ?? purchasePrice;
                  _currentAmountAdd = salePrice - purchasePrice;
                  _currentPercentAdd = 0;
                  _recalculateAndSet(purchasePrice);
                }
              },
            ),
            const SizedBox(width: 6),
            ChoiceChip(
              label: const Text('% (+1%)', style: TextStyle(fontSize: 10)),
              selected: widget.isPercentageMode,
              selectedColor: Colors.blue.shade100,
              onSelected: (selected) {
                if (selected) {
                  widget.onModeChanged(true);
                  double purchasePrice = double.tryParse(widget.purchasePriceController.text) ?? 0.0;
                  double salePrice = double.tryParse(widget.salePriceController.text) ?? purchasePrice;
                  double diff = salePrice - purchasePrice;
                  _currentPercentAdd = purchasePrice > 0 ? ((diff / purchasePrice) * 100).round() : 0;
                  _currentAmountAdd = 0.0;
                  _recalculateAndSet(purchasePrice);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
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