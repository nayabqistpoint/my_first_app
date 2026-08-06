import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../features/add_party_dialog.dart'; // درست امپورٹ پاتھ

class PartySelectorWidget extends StatefulWidget {
  final Function(String?) onPartySelected;

  const PartySelectorWidget({super.key, required this.onPartySelected});

  @override
  State<PartySelectorWidget> createState() => _PartySelectorWidgetState();
}

class _PartySelectorWidgetState extends State<PartySelectorWidget> {
  String? selectedPartyPhone;
  List<Map<String, String>> partiesList = [];

  @override
  void initState() {
    super.initState();
    _loadPartiesFromHive();
  }

  // Hive کسٹمر باکس سے اصلی ڈیٹا لوڈ کرنا
  void _loadPartiesFromHive() {
    try {
      if (Hive.isBoxOpen('customerBox')) {
        final box = Hive.box('customerBox');
        setState(() {
          partiesList = box.values.map((item) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(item as Map);
            return {
              'name': data['customerName']?.toString() ?? 'نامعلوم',
              'phone': data['customerPhone']?.toString() ?? '',
            };
          }).where((element) => element['phone']!.isNotEmpty).toList();
        });
      }
    } catch (e) {
      debugPrint("Hive Data Loading Error: $e");
    }
  }

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
            // 1. اصلی کسٹمرز کا ڈراپ ڈاؤن
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPartyPhone,
                  hint: const Text(
                    'پارٹی / سپلائر منتخب کریں',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.red.shade700),
                  items: partiesList.map((party) {
                    return DropdownMenuItem<String>(
                      value: party['phone'], // Unique ID (Phone)
                      child: Text(
                        '${party['name']} (${party['phone']})', // نام اور فون نمبر
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPartyPhone = newValue;
                    });
                    widget.onPartySelected(newValue);
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 2. نئی پارٹی ایڈ کرنے کا بٹن
            IconButton(
              icon: Icon(Icons.person_add_alt_1, color: Colors.red.shade700, size: 22),
              tooltip: 'نئی پارٹی شامل کریں',
              onPressed: () {
                showAddPartyDialog(context);
                _loadPartiesFromHive();
              },
            ),
          ],
        ),
      ),
    );
  }
}