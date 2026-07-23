import 'package:flutter/material.dart';
import '../controller.dart';

class SourceSelecter extends StatefulWidget {
  final double defaultAmount;
  final Function(String? bankSource, double cashAmount, double bankAmount) onSplitPaymentChanged;

  const SourceSelecter({
    super.key,
    required this.defaultAmount,
    required this.onSplitPaymentChanged,
  });

  @override
  State<SourceSelecter> createState() => _SourceSelecterState();
}

class _SourceSelecterState extends State<SourceSelecter> {
  bool _isSplitMode = false;
  String? _selectedBankSource;

  late final TextEditingController _cashAmountController;
  final TextEditingController _bankAmountController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    // بائی ڈیفالٹ ساری رقم کیش ان ہینڈ میں آ جائے گی
    _cashAmountController = TextEditingController(text: widget.defaultAmount.toStringAsFixed(0));
    
    _cashAmountController.addListener(_notifyChanges);
    _bankAmountController.addListener(_notifyChanges);
  }

  @override
  void didUpdateWidget(covariant SourceSelecter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // اگر باہر سے گرینڈ ٹوٹل تبدیل ہو اور سپلٹ موڈ آن نہ ہو، تو کیش خود بخود اپ ڈیٹ ہو جائے
    if (!_isSplitMode && widget.defaultAmount != oldWidget.defaultAmount) {
      _cashAmountController.text = widget.defaultAmount.toStringAsFixed(0);
    }
  }

  void _notifyChanges() {
    double cashAmt = double.tryParse(_cashAmountController.text) ?? 0;
    double bankAmt = _isSplitMode ? (double.tryParse(_bankAmountController.text) ?? 0) : 0;
    widget.onSplitPaymentChanged(_isSplitMode ? _selectedBankSource : null, cashAmt, bankAmt);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "ادائیگی کا ذریعہ (Payment Source)",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  if (!(_isSplitMode && bankSources.isEmpty))
                    TextButton.icon(
                      onPressed: () {
                        if (bankSources.isEmpty && !_isSplitMode) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('پہلے ڈیش بورڈ سے کوئی بینک ایڈ کریں')),
                          );
                          return;
                        }
                        setState(() {
                          _isSplitMode = !_isSplitMode;
                          if (!_isSplitMode) {
                            _selectedBankSource = null;
                            _bankAmountController.text = '0';
                            _cashAmountController.text = widget.defaultAmount.toStringAsFixed(0);
                          } else {
                            _cashAmountController.text = widget.defaultAmount.toStringAsFixed(0);
                            _bankAmountController.text = '0';
                          }
                        });
                        _notifyChanges();
                      },
                      icon: Icon(_isSplitMode ? Icons.remove : Icons.add, size: 16, color: const Color(0xFFE53935)),
                      label: Text(
                        _isSplitMode ? "سنگل کیش پر آئें" : "+ دوسرا سورس (بینک) شامل کریں",
                        style: const TextStyle(fontSize: 12, color: Color(0xFFE53935)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // --- ہمیشہ ظاہر ہونے والا کیش والا خانہ ---
              Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "Cash in Hand",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
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

              // --- صرف اسپلٹ موڈ آن ہونے پر بینک کا خانہ ظاہر ہوگا ---
              if (_isSplitMode) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedBankSource, // یہاں 'value' کو 'initialValue' سے بدل دیا گیا ہے
                        isDense: true,
                        decoration: const InputDecoration(
                          labelText: "بینک منتخب کریں",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ),
                        hint: const Text('بینک منتخب کریں', style: TextStyle(fontSize: 13)),
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
            ],
          ),
        );
      },
    );
  }
}