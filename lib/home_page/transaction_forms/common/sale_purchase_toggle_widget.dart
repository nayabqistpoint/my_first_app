import 'package:flutter/material.dart';

class SalePurchaseToggleWidget extends StatelessWidget {
  final bool isSaleSelected;
  final VoidCallback onPurchaseTap;
  final VoidCallback onSaleTap;

  const SalePurchaseToggleWidget({
    super.key,
    required this.isSaleSelected,
    required this.onPurchaseTap,
    required this.onSaleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // خرید کا بٹन
          InkWell(
            onTap: onPurchaseTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // یہاں لیفٹ/رائٹ سائز بڑھا دیا گیا ہے
              decoration: BoxDecoration(
                color: !isSaleSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'خرید',
                style: TextStyle(
                  color: !isSaleSelected ? const Color(0xFFE53935) : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // فروخت کا بٹन
          InkWell(
            onTap: onSaleTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // یہاں بھی لیفٹ/رائٹ سائز بڑھا دیا گیا ہے
              decoration: BoxDecoration(
                color: isSaleSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'فروخت',
                style: TextStyle(
                  color: isSaleSelected ? const Color(0xFFE53935) : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}