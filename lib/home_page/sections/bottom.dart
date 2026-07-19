import 'package:flutter/material.dart';

class BottomSection extends StatelessWidget {
  const BottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: _buildFilledButton("قسط کیلکولیٹر", Colors.blue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildFilledButton("خرید و فروخت", Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildFilledButton(String title, Color color) {
    return SizedBox(
      height: 45, // یہ ہائٹ ہے، اگر مزید نیرو کرنا ہو تو اسے 40 کر دیں
      child: ElevatedButton(
        onPressed: () {
          // یہاں بٹن کا ایکشن آئے گا
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white, // لکھائی کا رنگ سفید
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // مستطیل شکل (تھوڑے گول کونے)
          ),
          elevation: 2, // بٹن ابھرا ہوا محسوس ہو
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}