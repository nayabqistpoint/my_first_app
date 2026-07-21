import 'package:flutter/material.dart';
import '../controller.dart';

class SourceSelecter extends StatefulWidget {
  final Function(String? bankSource, double cashAmount, double bankAmount) onSplitPaymentChanged;

  const SourceSelecter({
    super.key,
    required this.onSplitPaymentChanged,
  });

  @override
  State<SourceSelecter> createState() => _SourceSelecterState();
}

class _SourceSelecterState extends State<SourceSelecter> {
  String? _selectedBankSource;

  final TextEditingController _cashAmountController = TextEditingController(text: '0');
  final TextEditingController _bankAmountController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _cashAmountController.addListener(_notifyChanges);
    _bankAmountController.addListener(_notifyChanges);
  }

  void _notifyChanges() {
    double cashAmt = double.tryParse(_cashAmountController.text) ?? 0;
    double bankAmt = double.tryParse(_bankAmountController.text) ?? 0;
    widget.onSplitPaymentChanged(_selectedBankSource, cashAmt, bankAmt);
  }

  @override
  void dispose() {
    _cashAmountController.dispose();
    _bankAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dashboardController,
      builder: (context, child) {
        // ڈیش بورڈ سے صرف لائیو بینکوں کی لسٹ
        final List<String> bankSources = dashboardController.bankBalances.keys.toList();

        if (_selectedBankSource != null && !bankSources.contains(_selectedBankSource)) {
          _selectedBankSource = null;
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE53935), width: 1.5),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ادائیگی کے ذرائع (اسپلٹ پیمنٹ: کیش + بینک)",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              // --- 1. کیش ان ہینڈ (فکسڈ نام اور رقم کا باکس - کوئی ڈراپ ڈاؤن نہیں) ---
              Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "Cash in Hand",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _cashAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "کیش رقم",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- 2. بینک سورس (بینک کی ڈراپ ڈاؤن + بینک کی رقم کا باکس) ---
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedBankSource,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: "بینک منتخب کریں",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                      hint: const Text('کوئی بینک نہیں', style: TextStyle(fontSize: 13)),
                      items: bankSources.map((bank) {
                        return DropdownMenuItem<String>(
                          value: bank,
                          child: Text(bank, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedBankSource = val;
                        });
                        _notifyChanges();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _bankAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "بینک رقم",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}