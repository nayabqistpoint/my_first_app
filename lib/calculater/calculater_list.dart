import 'package:flutter/material.dart';

class CalculaterList extends StatelessWidget {
  const CalculaterList({super.key});

  @override
  Widget build(BuildContext context) {
    // فرضی ڈیٹا کی لسٹ
    final List<Map<String, String>> dummyData = [
      {"months": "6 ماہ", "total": "60,000", "without": "10,000", "with": "11,000"},
      {"months": "7 ماہ", "total": "62,000", "without": "8,857", "with": "9,700"},
      {"months": "8 ماہ", "total": "64,000", "without": "8,000", "with": "8,800"},
      {"months": "9 ماہ", "total": "66,000", "without": "7,333", "with": "8,100"},
      {"months": "10 ماہ", "total": "68,000", "without": "6,800", "with": "7,500"},
      {"months": "11 ماہ", "total": "70,000", "without": "6,363", "with": "7,000"},
      {"months": "12 ماہ", "total": "72,000", "without": "6,000", "with": "6,600"},
    ];

    return Column(
      children: [
        // ہیڈنگ باکس
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(flex: 2, child: Text("ٹوٹل", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
              Expanded(flex: 2, child: Text("قسط(بغیر)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
              Expanded(flex: 2, child: Text("قسط(بمعہ)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
              Expanded(flex: 2, child: Text("پیکج", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
            ],
          ),
        ),
        
        // پیکجز کی لسٹ
        Expanded(
          child: ListView.builder(
            itemCount: dummyData.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                ),
                child: Row(
                  children: [
                    // ٹوٹل (نیلا رنگ - نمایاں)
                    Expanded(flex: 2, child: Text(dummyData[index]['total']!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 16))),
                    // قسط (بغیر) (سبز رنگ - سکون بخش)
                    Expanded(flex: 2, child: Text(dummyData[index]['without']!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16))),
                    // قسط (بمعہ) (جامنی رنگ)
                    Expanded(flex: 2, child: Text(dummyData[index]['with']!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16))),
                    // پیکج (سرخ رنگ - آپ کا پسندیدہ)
                    Expanded(flex: 2, child: Text(dummyData[index]['months']!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935), fontSize: 16))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}