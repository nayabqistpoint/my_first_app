import 'package:flutter/material.dart';

class CashWidget extends StatelessWidget {
  const CashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // فرضی بینکوں کی تعداد بڑھا کر 15 کر دی ہے تاکہ آپ اسکرولنگ اور بارڈرز کو اچھی طرح چیک کر سکیں
    final List<Map<String, String>> bankList = [
      {"name": "Bank 1 (HBL)", "amount": "Rs. 25,000"},
      {"name": "Bank 2 (Meezan)", "amount": "Rs. 18,500"},
      {"name": "Bank 3 (UBL)", "amount": "Rs. 12,000"},
      {"name": "Bank 4 (Alfalah)", "amount": "Rs. 8,000"},
      {"name": "Bank 5 (Easypaisa)", "amount": "Rs. 4,500"},
      {"name": "Bank 6 (JazzCash)", "amount": "Rs. 3,200"},
      {"name": "Bank 7 (NBP)", "amount": "Rs. 14,000"},
      {"name": "Bank 8 (BOP)", "amount": "Rs. 9,500"},
      {"name": "Bank 9 (MCB)", "amount": "Rs. 22,000"},
      {"name": "Bank 10 (Askari)", "amount": "Rs. 7,000"},
      {"name": "Bank 11 (Faysal)", "amount": "Rs. 16,500"},
      {"name": "Bank 12 (Allied)", "amount": "Rs. 11,000"},
      {"name": "Bank 13 (SadaPay)", "amount": "Rs. 2,500"},
      {"name": "Bank 14 (NayaPay)", "amount": "Rs. 1,800"},
      {"name": "Bank 15 (Dubai Islamic)", "amount": "Rs. 35,000"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ۱۔ اوپر والا حصہ: Bank Balance اور Cash in Hand بلاک
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

          // ۲۔ بینک لسٹ کا ہیڈر (پلس پاپ اپ، گرینڈ ٹوٹل اور ہیڈنگ)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  PopupMenuButton<int>(
                    offset: const Offset(0, 30),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    icon: const Icon(Icons.add_circle, color: Colors.blue, size: 26),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
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
                                  Navigator.pop(context);
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
                  const SizedBox(width: 8),
                  const Text(
                    "Rs. 2,33,000",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.blue),
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

          // ۳۔ بینک لسٹ بلاک - یہ ڈبہ اوپر اور نیچے سے بالکل بند (Locked) ہے
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              // لسٹ کو ڈبے کی حد میں رکھنے کے لیے ہم ClipRRect کا استعمال کر رہے ہیں تاکہ بارڈر کے کونوں سے بھی ڈیٹا باہر نہ جھانکے
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: bankList.length,
                  // اسکرول فزکس بالکل ایکٹو ہے تاکہ ڈبے کے اندر ہی لسٹ گھومتی رہے
                  physics: const AlwaysScrollableScrollPhysics(),
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
            ),
          ),
        ],
      ),
    );
  }
}