import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedCategory = "تمام";
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _getButtonText(DateTime? date, String defaultText) {
    if (date == null) return defaultText;
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 4.0, bottom: 4.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 34,
                      child: TextField(
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: "تلاش کریں...",
                          prefixIcon: const Icon(Icons.search, size: 16, color: Colors.black54),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Colors.black87, width: 1.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 34,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: Colors.black87, width: 1.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => _selectDate(context, true),
                        icon: const Icon(Icons.calendar_month, size: 12, color: Colors.black87),
                        label: Text(_getButtonText(_startDate, "پہلی تاریخ"), style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 34,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: Colors.black87, width: 1.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => _selectDate(context, false),
                        icon: const Icon(Icons.calendar_month, size: 12, color: Colors.black87),
                        label: Text(_getButtonText(_endDate, "آخری تاریخ"), style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 34,
                    width: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black87, width: 1.3),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: PopupMenuButton<String>(
                      initialValue: _selectedCategory,
                      icon: const Icon(Icons.filter_alt, size: 16, color: Colors.deepPurple),
                      padding: EdgeInsets.zero,
                      color: Colors.white,
                      elevation: 3,
                      onSelected: (String value) { setState(() { _selectedCategory = value; }); },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(value: 'تمام', child: Text('تمام', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                        const PopupMenuDivider(height: 1),
                        const PopupMenuItem<String>(value: 'SALE', child: Text('SALE', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold))),
                        const PopupMenuDivider(height: 1),
                        const PopupMenuItem<String>(value: 'PURCHASE', child: Text('PURCHASE', style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold))),
                        const PopupMenuDivider(height: 1),
                        const PopupMenuItem<String>(value: 'PAYMENT-IN', child: Text('PAYMENT-IN', style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold))),
                        const PopupMenuDivider(height: 1),
                        const PopupMenuItem<String>(value: 'PAYMENT-OUT', child: Text('PAYMENT-OUT', style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // اب یہاں لسٹ کی تعداد بڑھا دی ہے تاکہ اسکرولنگ چیک ہو سکے
              Expanded(
                child: ListView(
                  children: [
                    for (int i = 1; i <= 20; i++) ...[
                      _buildTransactionItem("عمران مونڈ دستی $i", "2026-07-19", "Rs ${i * 1000}", i % 2 == 0 ? "SALE" : "PURCHASE", i % 2 == 0 ? Colors.red : Colors.blue),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String name, String date, String amount, String type, Color color) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(amount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                      Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.grey, size: 18),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}