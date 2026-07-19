import 'package:flutter/material.dart';

class MiddleSection extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const MiddleSection({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 10.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildCapsuleButton("پارٹیز", 0)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: _buildCapsuleButton("ٹرانزیکشن", 1)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildCapsuleButton("اسٹاک", 2)),
        ],
      ),
    );
  }

  Widget _buildCapsuleButton(String title, int index) {
    bool isSelected = (selectedIndex == index);

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          // یہ رنگ `0xFFF5A9A9` بہت ہی مدھم اور نرم سرخ ہے
          color: isSelected ? const Color(0xFFF5A9A9) : Colors.white,
          border: Border.all(color: Colors.red, width: 1.5),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              // جب سلیکٹ ہو تو لکھائی سفید، ورنہ سرخ
              color: isSelected ? Colors.white : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}