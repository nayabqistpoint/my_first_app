import 'package:flutter/material.dart';
// کسٹمر لیجر کے مین پیج کو یہاں امپورٹ کر لیا تاکہ کلک ایکشن کام کر سکے
import 'package:my_first_app/customer_ledger_page.dart';

class CustomersListView extends StatelessWidget {
  const CustomersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // کنٹرول بار: فلٹر | سرچ بار | ایڈ پارٹی (بڑا) + مینو
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              // فلٹر ڈراپ ڈاؤن
              SizedBox(
                height: 35,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items: ["سب", "باقی", "مکمل"].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (_) {},
                    hint: const Text("فلٹر", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // سرچ بار (مزید چھوٹا کیا)
              Expanded(
                flex: 1, 
                child: SizedBox(
                  height: 35,
                  child: TextField(
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: "سرچ...",
                      hintStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // ایڈ پارٹی بٹن (بڑا کیا)
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 20), // سائیڈز بڑھا کر بڑا کیا
                  minimumSize: const Size(100, 35),
                ),
                child: const Text("ایڈ پارٹی", style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              
              // مینو ڈاٹس
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        
        // ہیڈنگ (وہی تھیم جو فائنل تھی)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              const SizedBox(
                width: 155,
                child: Row(
                  children: [
                    Text("رقم", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Spacer(flex: 2),
                    SizedBox(width: 1, height: 18, child: ColoredBox(color: Colors.black)),
                    Spacer(flex: 3),
                    Text("وعدہ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: Text("تفصیل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.black, thickness: 1.2, height: 1),
        
        // لسٹ (مکمل بحال شدہ ڈیٹا)
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 10,
            itemBuilder: (context, index) {
              bool isAmountGreen = (index % 2 == 0); 
              bool isDateExpired = (index > 4); 
              Color amountColor = isAmountGreen ? Colors.green : Colors.red;
              Color dateColor = isDateExpired ? Colors.red : Colors.green;

              // یہاں پوری رو کو InkWell سے لک کر دیا ہے تاکہ کلک ایبل بن جائے
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomerLedgerPage(),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 155,
                            child: Row(
                              children: [
                                Text("Rs ${(index + 1) * 2000}", style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 15)),
                                const Spacer(flex: 2),
                                Container(width: 1, height: 22, color: Colors.black),
                                const Spacer(flex: 3),
                                Text("2026-07-25", style: TextStyle(color: dateColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                const Spacer(),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("Party Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const Text("2026-07-19 06:17 PM", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                const CircleAvatar(radius: 15, backgroundColor: Colors.black12, child: Icon(Icons.person, size: 18, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black26, thickness: 0.5, height: 1),
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