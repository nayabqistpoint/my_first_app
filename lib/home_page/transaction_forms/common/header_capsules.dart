import 'package:flutter/material.dart';

class HeaderCapsulesWidget extends StatelessWidget {
  const HeaderCapsulesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. ریڈ ایپ بار والا حصہ (بہتر اور واضح پیڈنگ اور بولڈ ٹیکسٹ کے ساتھ)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // سائیڈز سے اندر کی طرف کیا گیا ہے
          color: Colors.red.shade700,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'خریداری بل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'نایاب قسط پوائنٹ',
                style: TextStyle(
                  fontSize: 15, // سائز بڑا کیا گیا ہے
                  fontWeight: FontWeight.bold, // بالکل واضح بولڈ
                  color: Colors.white, // مدھم پن ختم کر کے خالص وائٹ کر دیا گیا ہے
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),

        // 2. تین چھوٹے کیپسولز والا حصہ
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCapsule(title: 'انوائس #', value: 'INV-1001'),
              const SizedBox(width: 6),
              _buildCapsule(title: 'تاریخ', value: '06-08-2026'),
              const SizedBox(width: 6),
              _buildCapsule(title: 'وقت', value: '03:48 PM'),
            ],
          ),
        ),
      ],
    );
  }

  // کیپسول بنانے کا ہیلپر
  Widget _buildCapsule({required String title, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade700, width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.red.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}