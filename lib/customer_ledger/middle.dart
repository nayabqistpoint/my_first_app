import 'package:flutter/material.dart';

class LedgerMiddleWidget extends StatelessWidget {
  const LedgerMiddleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // سرچ بار
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: SizedBox(
            height: 35,
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "تلاش کریں...",
                hintStyle: const TextStyle(fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ),
        ),

        // ہیڈنگ
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("ملی", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
              SizedBox(width: 45),
              Text("دیے", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
              Spacer(),
              Text("تفصیل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ),
        const Divider(color: Colors.black, thickness: 1.2, height: 1),

        // ٹرانزیکشن لسٹ
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 15,
            itemBuilder: (context, index) {
              bool isReceived = (index % 2 == 0); 
              Color entryColor = isReceived ? Colors.green : Colors.red;
              
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            // کالمز والا حصہ
                            SizedBox(
                              width: 110,
                              child: Row(
                                children: [
                                  Expanded(child: Center(child: Text(isReceived ? "500" : "", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 17)))),
                                  Container(width: 1.5, height: 20, color: Colors.black38),
                                  Expanded(child: Center(child: Text(isReceived ? "" : "300", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 17)))),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // ترتیب: رقم -> تاریخ -> اٹیچمنٹ پن
                            Row(
                              children: [
                                Icon(Icons.attach_file, size: 14, color: entryColor), // پن اب آخر میں ہے
                                const SizedBox(width: 5),
                                Text("18 Jul 26", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(width: 10),
                                Text("161,630", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: entryColor)),
                              ],
                            ),
                          ],
                        ),
                        // تفصیل
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text("تفصیل...", style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.black12, thickness: 0.5, height: 1),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}