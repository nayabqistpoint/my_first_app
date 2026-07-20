import 'package:flutter/material.dart';

class CashWidget extends StatelessWidget {
  const CashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // بینکس کی تعداد بڑھا دی ہے تاکہ پیج بھرا ہوا لگے
    final List<Map<String, String>> bankList = [
      {"name": "HBL Bank", "amount": "Rs. 25,000"},
      {"name": "Meezan Bank", "amount": "Rs. 18,500"},
      {"name": "UBL Bank", "amount": "Rs. 12,000"},
      {"name": "Alfalah Bank", "amount": "Rs. 8,000"},
      {"name": "Easypaisa", "amount": "Rs. 4,500"},
      {"name": "JazzCash", "amount": "Rs. 3,200"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // اوپر والا حصہ: Cash in Hand اور بینک بیلنس
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // بینک بیلنس بلاک
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: const Column(
                    children: [
                      Text("Rs. 71,200", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green)),
                      SizedBox(height: 2),
                      Text("Bank Balance", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // کیش ان ہینڈ بلاک
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: const Column(
                    children: [
                      Text("Rs. 15,000", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue)),
                      SizedBox(height: 2),
                      Text("Cash In Hand", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // بینک لسٹ کا ہیڈر (پلس پاپ اپ اور ہیڈنگ)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // پلس بٹن جو بالکل اپنے ساتھ ہی سفید بیک گراؤنڈ والا پاپ اپ کھولے گا
              PopupMenuButton<int>(
                offset: const Offset(0, 30), // پاپ اپ کو بالکل بٹن کے نیچے لانے کے لیے
                color: Colors.white, // سفید بیک گراؤنڈ
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                icon: const Icon(Icons.add_circle, color: Colors.blue, size: 26),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false, // تاکہ یہ مینو آئٹم کی طرح کلک نہ ہو، صرف ڈبہ دکھائے
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Add Bank",
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          const TextField(
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: "بینک کا نام لکھیں",
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
                              backgroundColor: Colors.blue,
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
              const Text(
                "Banks List",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // بینک لسٹ بلاک - اب یہ بڑا (Height: 280) ہے اور نیچے تک جگہ پر کر رہا ہے
          Container(
            height: 280, 
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: bankList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // رقم بائیں طرف
                          Text(
                            bankList[index]["amount"]!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          // بینک کا نام دائیں طرف
                          Text(
                            bankList[index]["name"]!,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    if (index < bankList.length - 1)
                      const Divider(color: Colors.black12, height: 1),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}