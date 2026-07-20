import 'package:flutter/material.dart';

class LedgerTopWidget extends StatelessWidget {
  const LedgerTopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ۱۔ ہیڈر (ایرو + سینٹر نام + تصویر)
        Container(
          color: const Color(0xFFE53935),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // بیک ایرو (فعال کر دیا ہے)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                ),
                const Spacer(),
                const Text(
                  "خلیل سبزی والا",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                // بڑا پروفائل آئکن
                const CircleAvatar(
                  radius: 20, // سائز بڑھا دیا
                  backgroundColor: Colors.white24, 
                  child: Icon(Icons.person, color: Colors.white, size: 25),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ۲۔ بیلنس باکس
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE53935), width: 1.2),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: const Text(
              "Rs 161,630",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ۳۔ سمارٹ کیپسولز
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildActionCapsule(text: "رپورٹ"),
              const SizedBox(width: 6),
              _buildActionCapsule(text: "تاریخ"),
              const SizedBox(width: 6),
              _buildActionCapsule(text: "ریمائنڈر"),
              const SizedBox(width: 6),
              _buildActionCapsule(text: "ایس ایم ایس"),
            ],
          ),
        ),
        
        const SizedBox(height: 10),
        const Divider(color: Colors.black12, height: 1, thickness: 0.8),
      ],
    );
  }

  // کیپسول ڈیزائن (جو دبنے پر واپس اپنی حالت میں آ جائے)
  Widget _buildActionCapsule({required String text}) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // کیپسول شیپ
        child: InkWell(
          onTap: () {}, // یہاں فنکشن آئے گا
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.black12, // دبنے کا احساس
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}