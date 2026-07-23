import 'package:flutter/material.dart';

class DiscountWidget extends StatefulWidget {
  final Function(double discountValue, bool isPercentage) onDiscountChanged;

  const DiscountWidget({
    super.key,
    required this.onDiscountChanged,
  });

  @override
  State<DiscountWidget> createState() => _DiscountWidgetState();
}

class _DiscountWidgetState extends State<DiscountWidget> {
  final TextEditingController _discountController = TextEditingController();
  bool _isPercentage = false;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _updateDiscount() {
    final value = double.tryParse(_discountController.text) ?? 0.0;
    widget.onDiscountChanged(value, _isPercentage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, size: 16, color: Color(0xFFE53935)),
          const SizedBox(width: 8),
          const Text(
            'ڈسکاؤنٹ (Discount)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const Spacer(),
          // ٹوگل سوئچ
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: false, label: Text('Rs', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
                ButtonSegment<bool>(value: true, label: Text('%', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
              ],
              selected: {_isPercentage},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isPercentage = newSelection.first;
                  _updateDiscount();
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) return const Color(0xFFE53935);
                  return Colors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) return Colors.white;
                  return Colors.black87;
                }),
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // ان پٹ فیلڈ
          SizedBox(
            width: 75,
            height: 34,
            child: TextField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateDiscount(),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: const TextStyle(fontSize: 10),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(color: Color(0xFFE53935), width: 1.5),
                ),
              ),
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}