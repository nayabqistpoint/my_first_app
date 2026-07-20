import 'package:flutter/material.dart';

class ExpensesWidget extends StatelessWidget {
  const ExpensesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // ایکسپنسز لسٹ ڈیٹا
    final List<Map<String, String>> defaultExpenses = [
      {"name": "Direct Expense", "amount": "Rs. 250"},
      {"name": "Indirect Expense", "amount": "Rs. 200"},
      {"name": "Discounts", "amount": "Rs. 0"},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. ہیڈر: پلس پاپ اپ، گرینڈ ٹوٹل اور ہیڈنگ
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // اب یہ پلس بٹن بھی بالکل اپنے ساتھ ہی سفید بیک گراؤنڈ والا پاپ اپ کھولے گا
                PopupMenuButton<int>(
                  offset: const Offset(0, 30), // پاپ اپ کو بالکل بٹن کے نیچے لانے کے لیے
                  color: Colors.white, // سفید بیک گراؤنڈ
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  icon: const Icon(Icons.add_circle, color: Colors.red, size: 26),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false, // مینو کلک بند، صرف ڈبہ دکھانے کے لیے
                      child: SizedBox(
                        width: 200,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Add Expense Category",
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            const TextField(
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: "کیٹیگری کا نام لکھیں",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // پاپ اپ بند کرنے کے لیے
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                padding: const EdgeInsets.symmetric(vertical: 4),
                              ),
                              child: const Text("Add", style: TextStyle(color: Colors.white, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // گرینڈ ٹوٹل رقم (فل بولڈ)
                const Text(
                  "Rs. 450",
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const Text(
              "Expenses List", 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // 2. ایکسپنسز بلاک (بیچ میں ڈیوائیڈر لائنز کے ساتھ)
        Container(
          height: 125, 
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: defaultExpenses.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // رقم بائیں طرف
                        Text(
                          defaultExpenses[index]["amount"]!, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        // نام دائیں طرف
                        Text(
                          defaultExpenses[index]["name"]!,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  // ہر دو لائنوں/آئٹمز کے بیچ میں ڈیوائیڈر لائن
                  if (index < defaultExpenses.length - 1) 
                    const Divider(color: Colors.black12, height: 1),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}