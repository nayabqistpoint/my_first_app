import 'package:flutter/material.dart';

class LedgerTopWidget extends StatelessWidget {
  const LedgerTopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ۱۔ سب سے اوپر والا لال ہیڈر (نام اور فون آئکن)
        Container(
          color: const Color(0xFFE53935), // تصویر والا لال رنگ
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // بائیں طرف فون کا آئکن
                Icon(Icons.phone, color: Colors.white, size: 24),
                // دائیں طرف کسٹمر کا نام
                Text(
                  "خلیل سبزی والا",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ۲۔ بڑا ٹوٹل بیلنس والا باکس (Rs 161,630)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE53935), width: 1.5), // لال بارڈر
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: const Text(
              "Rs 161,630",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935), // لال رنگ کی رقم
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ۳۔ چار بٹنز والی رو (ایس ایم ایس، ریمائنڈر، تاریخ، رپورٹ)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildActionButton(text: "رپورٹ", isSelected: false),
              const SizedBox(width: 8),
              _buildActionButton(text: "تاریخ", isSelected: false),
              const SizedBox(width: 8),
              _buildActionButton(text: "ریمائنڈر", isSelected: false),
              const SizedBox(width: 8),
              _buildActionButton(text: "ایس ایم ایس", isSelected: true),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        // یہاں black24 کو بدل کر black26 کر دیا ہے تاکہ ایرر ختم ہو جائے
        const Divider(color: Colors.black26, height: 1),
      ],
    );
  }

  // چار بٹنز بنانے کا ٹول
  Widget _buildActionButton({required String text, required bool isSelected}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE53935) : Colors.white,
          border: Border.all(color: const Color(0xFFE53935)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFFE53935),
          ),
        ),
      ),
    );
  }
}