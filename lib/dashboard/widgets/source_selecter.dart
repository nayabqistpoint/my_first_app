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
  
  String _selectedSourceType = 'Cash in Hand'; 
  String? _selectedBankSource;

  late final TextEditingController _amountController;
  final TextEditingController _bankAmountController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.defaultAmount.toStringAsFixed(0));
    
    _amountController.addListener(_notifyChanges);
    _bankAmountController.addListener(_notifyChanges);
  }

  @override
  void didUpdateWidget(covariant SourceSelecter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSplitMode && widget.defaultAmount != oldWidget.defaultAmount) {
      _amountController.text = widget.defaultAmount.toStringAsFixed(0);
    }
  }

  void _notifyChanges() {
    double amt1 = double.tryParse(_amountController.text) ?? 0;
    double amt2 = _isSplitMode ? (double.tryParse(_bankAmountController.text) ?? 0) : 0;

    if (!_isSplitMode) {
      if (_selectedSourceType == 'Cash in Hand') {
        widget.onSplitPaymentChanged(null, amt1, 0);
      } else {
        widget.onSplitPaymentChanged(_selectedSourceType, amt1, 0);
      }
    } else {
      widget.onSplitPaymentChanged(_selectedBankSource, amt1, amt2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dashboardController,
      builder: (context, child) {
        final List<String> bankSources = dashboardController.bankBalances.keys.toList();
        final List<String> allSources = ['Cash in Hand', ...bankSources];

        if (!_isSplitMode && !allSources.contains(_selectedSourceType)) {
          _selectedSourceType = 'Cash in Hand';
        }
        if (_isSplitMode && _selectedBankSource != null && !bankSources.contains(_selectedBankSource)) {
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
              // اوپر والی لائن: عنوان اور دوسرا سورس (پلس بٹن)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "ادائیگی کا ذریعہ (Payment Source)",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
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
                          _amountController.text = widget.defaultAmount.toStringAsFixed(0);
                        } else {
                          _selectedSourceType = 'Cash in Hand';
                          _amountController.text = widget.defaultAmount.toStringAsFixed(0);
                          _bankAmountController.text = '0';
                        }
                      });
                      _notifyChanges();
                    },
                    icon: Icon(_isSplitMode ? Icons.remove : Icons.add, size: 16, color: const Color(0xFFE53935)),
                    label: Text(
                      _isSplitMode ? "سنگل سورس پر آئें" : "+ دوسرا سورس",
                      style: const TextStyle(fontSize: 12, color: Color(0xFFE53935)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // --- پہلا سورس (ڈراپ ڈاؤن + رقم) ---
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      // یہاں ڈپیکیٹ 'value' کی جگہ 'initialValue' استعمال کیا گیا ہے
                      initialValue: _isSplitMode ? 'Cash in Hand' : _selectedSourceType,
                      isDense: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        isDense: true,
                      ),
                      items: (_isSplitMode ? ['Cash in Hand'] : allSources).map((source) {
                        return DropdownMenuItem<String>(
                          value: source,
                          child: Text(source, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                      onChanged: _isSplitMode ? null : (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSourceType = val;
                          });
                          _notifyChanges();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "رقم",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),

              // --- اگر سپلٹ موڈ آن ہو تو دوسرا بینک سورس ظاہر ہوگا ---
              if (_isSplitMode) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        // یہاں بھی 'value' کی جگہ 'initialValue' کر دیا گیا ہے
                        initialValue: _selectedBankSource,
                        isDense: true,
                        decoration: const InputDecoration(
                          labelText: "دوسرا بینک منتخب کریں",
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