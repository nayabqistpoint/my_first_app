import 'package:flutter/material.dart';
import 'dashboard/widgets/profit_loss.dart'; 
import 'dashboard/widgets/cash.dart'; 
import 'dashboard/widgets/expenses.dart'; 

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedFilter = 'یہ مہینہ';
  late DateTime fromDate;
  late DateTime toDate;

  @override
  void initState() {
    super.initState();
    fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    toDate = DateTime.now();
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  Future<void> _pickCustomDateRange(BuildContext context) async {
    final pickerTheme = Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFE53935),
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFFE53935)),
      ),
    );

    final DateTime? pickedFrom = await showDatePicker(
      context: context,
      helpText: "شروع کی تاریخ (From Date)",
      initialDate: fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: pickerTheme, child: child!),
    );

    if (pickedFrom != null) {
      if (!context.mounted) return;

      final DateTime? pickedTo = await showDatePicker(
        context: context,
        helpText: "آخری تاریخ (To Date)",
        initialDate: toDate.isBefore(pickedFrom) ? pickedFrom : toDate,
        firstDate: pickedFrom,
        lastDate: DateTime(2030),
        builder: (context, child) => Theme(data: pickerTheme, child: child!),
      );

      if (pickedTo != null) {
        setState(() {
          fromDate = pickedFrom;
          toDate = pickedTo;
          selectedFilter = 'کسٹم';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            "نایاب قسط پوائنٹ",
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, 
              fontSize: 22,
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xfff8f9fa),
      body: SafeArea(
        // LayoutBuilder اسکرین کا اصل سائز معلوم کر کے لے آؤٹ کو فکس رکھتا ہے
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. ڈیٹ فلٹر پٹی (Height: 38)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white, 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12, 
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        height: 26,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                          color: const Color(0xFFFAFAFA),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedFilter,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 18),
                            style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                            dropdownColor: Colors.white,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedFilter = newValue!;
                                if (selectedFilter == 'آج') {
                                  fromDate = DateTime.now();
                                  toDate = DateTime.now();
                                } else if (selectedFilter == 'یہ ہفتہ') {
                                  fromDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
                                  toDate = DateTime.now();
                                } else if (selectedFilter == 'یہ مہینہ') {
                                  fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
                                  toDate = DateTime.now();
                                } else if (selectedFilter == 'کسٹم') {
                                  _pickCustomDateRange(context);
                                }
                              });
                            },
                            items: <String>['آج', 'یہ ہفتہ', 'یہ مہینہ', 'کسٹم']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _pickCustomDateRange(context),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month, size: 14, color: Colors.grey[700]),
                            const SizedBox(width: 4),
                            Text(
                              "From: ${_formatDate(fromDate)}  To: ${_formatDate(toDate)}",
                              style: TextStyle(
                                fontSize: 11, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. پرافٹ لاس بلاک
                const ProfitLossWidget(),

                // 3. کیش اور بینک لسٹ بلاک (ساری فالتو جگہ ختم کر کےExpanded)
                // یہ سکرین پر بینک بلاک کو بڑا رکھے گا بغیر کسی اوور فلو کے
                const Expanded(
                  child: CashWidget(),
                ),

                // 4. اخراجات کا بلاک (بغیر فالتو جگہ کے بالکل نیچے سیٹ)
                const ExpensesWidget(),

                // 5. ایڈ ایکسپینس بٹن (صرف ضروری پیڈنگ کے ساتھ)
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Add Expenses",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}