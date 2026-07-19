import 'package:flutter/material.dart';

class MiddleSection extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const MiddleSection({
    super.key, 
    required this.selectedIndex, 
    required this.onTabSelected
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // اینڈ سے تھوڑا پیچھے رکھنے کے لیے دائیں بائیں زیادہ پیڈنگ دی ہے
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // بکسز کے درمیان برابر فاصلہ
        children: [
          // 1. پارٹیز (سائیڈ والا - چھوٹا بٹن)
          _buildButton(0, "پارٹیز", isSideButton: true),
          
          // 2. ٹرانزیکشن (سینٹر والا - بڑا بٹن)
          _buildButton(1, "ٹرانزیکشن", isSideButton: false),
          
          // 3. اسٹاک (سائیڈ والا - چھوٹا بٹن)
          _buildButton(2, "اسٹاک", isSideButton: true),
        ],
      ),
    );
  }

  Widget _buildButton(int index, String title, {required bool isSideButton}) {
    bool isSelected = (selectedIndex == index);
    
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        // سینٹر والے بٹن کی دائیں بائیں (Horizontal) پیڈنگ زیادہ رکھی ہے
        padding: EdgeInsets.symmetric(
          horizontal: isSideButton ? 14 : 35, 
          vertical: 6
        ),
        decoration: BoxDecoration(
          // سلیکشن کا رنگ بالکل ہلکا پرپل کر دیا ہے اور غیر سلیکٹڈ گرے ہے
          color: isSelected ? Colors.deepPurple.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8), // ہلکا سا راؤنڈ جو پروفیشنل لگتا ہے
          border: Border.all(
            color: isSelected ? Colors.deepPurple.shade300 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            // سلیکٹڈ ٹیکسٹ کا رنگ گہرا پرپل تاکہ واضح پڑھے جائے
            color: isSelected ? Colors.deepPurple.shade900 : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}