import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_first_app/features/add_party_dialog.dart';

class PartySelectorWidget extends StatefulWidget {
  final Function(String? phone, String? name) onPartySelected;

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

  void _loadPartiesFromHive() {
    try {
      if (Hive.isBoxOpen('customerBox')) {
        final box = Hive.box('customerBox');
        setState(() {
          partiesList = box.values.map((item) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(item as Map);
            
            String extractedName = data['customerName']?.toString() ?? 
                                   data['name']?.toString() ?? 
                                   data['partyName']?.toString() ?? 
                                   'نامعلوم';

            String extractedPhone = data['customerPhone']?.toString() ?? 
                                    data['phone']?.toString() ?? 
                                    data['mobile']?.toString() ?? 
                                    '';

            return {
              'name': extractedName,
              'phone': extractedPhone,
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
                      value: party['phone'],
                      child: Text(
                        party['name'] ?? 'نامعلوم',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newPhoneValue) {
                    setState(() {
                      selectedPartyPhone = newPhoneValue;
                    });

                    String? selectedName;
                    if (newPhoneValue != null) {
                      final matchedParty = partiesList.firstWhere(
                        (element) => element['phone'] == newPhoneValue,
                        orElse: () => {'name': '', 'phone': ''},
                      );
                      selectedName = matchedParty['name'];
                    }

                    // نام اور فون دونوں کنٹرولر کو منتقل کرنا
                    widget.onPartySelected(newPhoneValue, selectedName);
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.person_add_alt_1, color: Colors.red.shade700, size: 22),
              tooltip: 'نئی پارٹی شامل کریں',
              onPressed: () async {
                await showAddPartyDialog(context);
                _loadPartiesFromHive();
              },
            ),
          ],
        ),
      ),
    );
  }
}