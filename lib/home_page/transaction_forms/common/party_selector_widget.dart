import 'package:flutter/material.dart';
import '../../../../features/add_party_dialog.dart'; // درست امپورٹ پاتھ

class PartySelectorWidget extends StatefulWidget {
  final Function(String?) onPartySelected;

  const PartySelectorWidget({super.key, required this.onPartySelected});

  @override
  State<PartySelectorWidget> createState() => _PartySelectorWidgetState();
}

class _PartySelectorWidgetState extends State<PartySelectorWidget> {
  String? selectedParty;
  
  // عارضی ڈمی لسٹ (بعد میں ہائیو کسٹمر باکس سے لنک ہوگی)
  final List<String> parties = ['علی ٹریڈرز', 'خان موبائل زون', 'مدینہ سنٹر', 'الرحمٰن کمیونیکیشن'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade700, width: 1.0),
        ),
        child: Row(
          children: [
            // 1. پارٹی ڈراپ ڈاؤن / سلیکٹر
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedParty,
                  hint: const Text(
                    'پارٹی / سپلائر منتخب کریں',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.red.shade700),
                  items: parties.map((String party) {
                    return DropdownMenuItem<String>(
                      value: party,
                      child: Text(
                        party,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedParty = newValue;
                    });
                    widget.onPartySelected(newValue);
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 8),

            // 2. نئی پارٹی ایڈ کرنے کا بٹن (جو سیدھا فیچرز فولڈر والا ڈائیلاگ کال کرے گا)
            IconButton(
              icon: Icon(Icons.person_add_alt_1, color: Colors.red.shade700, size: 22),
              tooltip: 'نئی پارٹی شامل کریں',
              onPressed: () {
                // یہاں سے براہِ راست امپورٹ شدہ ڈائیلاگ کال ہو رہا ہے
                showAddPartyDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}