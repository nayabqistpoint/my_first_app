import 'package:flutter/material.dart';
import '../controller.dart';

class SourceSelecter extends StatefulWidget {
  final Function(String selectedSource) onSourceChanged;

  const SourceSelecter({super.key, required this.onSourceChanged});

  @override
  State<SourceSelecter> createState() => _SourceSelecterState();
}

class _SourceSelecterState extends State<SourceSelecter> {
  String? _selectedSource;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dashboardController,
      builder: (context, child) {
        // کنٹرولر سے کیش اور لائیو ایڈ شدہ بینکس کی لسٹ بنانا
        // اگر کوئی بینک یا کیش نہ ہو تو کم از کم 'Cash in Hand' دکھائے گا تاکہ ڈراپ ڈاؤن خالی نہ رہے
        final List<String> allSources = [
          'Cash in Hand',
          ...dashboardController.bankBalances.keys,
        ];

        if (_selectedSource == null || !allSources.contains(_selectedSource)) {
          _selectedSource = allSources.first;
        }

        return InputDecorator(
          decoration: const InputDecoration(
            labelText: "ادائیگی کا ذریعہ (Payment Source)",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance_wallet, color: Color(0xFFE53935)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSource,
              isDense: true,
              items: allSources.map((sourceName) {
                return DropdownMenuItem<String>(
                  value: sourceName,
                  child: Text(
                    sourceName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSource = newValue;
                });
                if (newValue != null) {
                  widget.onSourceChanged(newValue);
                }
              },
            ),
          ),
        );
      },
    );
  }
}