import 'package:flutter/material.dart';
import 'package:my_first_app/customer_ledger_page.dart';
import '../controllers/customer_controller.dart';

class CustomersListView extends StatelessWidget {
  const CustomersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: customerController,
      builder: (context, child) {
        final customersList = customerController.customers;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
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
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      minimumSize: const Size(100, 35),
                    ),
                    child: const Text("ایڈ پارٹی", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
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
            Expanded(
              child: customersList.isEmpty
                  ? const Center(
                      child: Text(
                        "کوئی کسٹمر موجود نہیں",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: customersList.length,
                      itemBuilder: (context, index) {
                        final customer = customersList[index];
                        
                        double totalBalance = 0.0;
                        String lastDate = "";
                        String lastDesc = "پہلی ٹرانزیکشن";

                        if (customer.transactions.isNotEmpty) {
                          for (var tx in customer.transactions) {
                            if (tx.type == 'get') {
                              totalBalance += tx.amount;
                            } else if (tx.type == 'give') {
                              totalBalance -= tx.amount;
                            }
                          }
                          lastDate = customer.transactions.last.date;
                          lastDesc = customer.transactions.last.description;
                          if (lastDesc.isEmpty) lastDesc = "قسط / سیل انٹری";
                        }

                        bool isAmountGreen = totalBalance >= 0; 
                        Color amountColor = isAmountGreen ? Colors.green : Colors.red;
                        Color dateColor = Colors.black87;

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
                                          Text("Rs ${totalBalance.abs().toStringAsFixed(0)}", style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 15)),
                                          const Spacer(flex: 2),
                                          Container(width: 1, height: 22, color: Colors.black),
                                          const Spacer(flex: 3),
                                          Text(lastDate.isNotEmpty ? lastDate : "-", style: TextStyle(color: dateColor, fontWeight: FontWeight.bold, fontSize: 13)),
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
                                              Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                              Text(lastDesc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
      },
    );
  }
}