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
      width: double.infinity,
      // دائیں بائیں سے پیڈنگ 24 سے کم کر کے 10 کر دی ہے تاکہ بٹنز سکرین پر زیادہ پھیلیں
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // آپس میں اسی طرح قریب اور سینٹر میں رکھنے کے لیے
        children: [
          // 1. پارٹیز (سائیڈ والا - سمارٹ کیپسول)
          _buildButton(0, "پارٹیز", isSideButton: true),
          
          const SizedBox(width: 5), // آپس کا وہی خوبصورت اور قریبی فاصلہ
          
          // 2. ٹرانزیکشن (سینٹر والا - سب سے زیادہ پھیلایا ہوا سمارٹ کیپسول)
          _buildButton(1, "ٹرانزیکشن", isSideButton: false),
          
          const SizedBox(width: 5), 
          
          // 3. اسٹاک (سائیڈ والا - سمارٹ کیپسول)
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
        // دائیں بائیں (Horizontal) سے بٹنز کو خوب پھیلایا ہے، اور اوپر نیچے (Vertical) سے کم کر کے سمارٹ کیا ہے
        padding: EdgeInsets.symmetric(
          horizontal: isSideButton ? 28 : 50, // سائیڈ والے 28 اور سینٹر والے کو پورا 50 پر پھیلایا ہے
          vertical: 5 // اوپر نیچے سے باریک (سمارٹ) رکھنے کے لیے
        ),
        decoration: BoxDecoration(
          // سلیکٹڈ پر وہی پیارا پرپل رنگ، اور ان-سلیکٹڈ بالکل سفید (White)
          color: isSelected ? Colors.deepPurple.shade400 : Colors.white,
          borderRadius: BorderRadius.circular(30), // پرفیکٹ اور حقیقی کیپسول شیپ
          border: Border.all(
            // سلیکٹڈ کا پرپل بارڈر، اور ان-سلیکٹڈ کا بلیک (سیاہ) بارڈر
            color: isSelected ? Colors.deepPurple.shade500 : Colors.black87,
            width: isSelected ? 1 : 1.2, // بلیک لکیر کو واضح رکھنے کے لیے 1.2 وڈتھ
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            // سلیکٹڈ ٹیکسٹ کا رنگ سفید، ان-سلیکٹڈ کا گہرا بلیک
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold, // گہری اور واضح لکھائی جو آسانی سے پڑھی جائے
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}