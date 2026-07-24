import 'package:flutter/material.dart';
import '../controller.dart';

class PaymentSourceRow {
  String sourceType;
  TextEditingController amountController;

  PaymentSourceRow({required this.sourceType, required double initialAmount})
      : amountController = TextEditingController(text: initialAmount == 0 ? '' : initialAmount.toStringAsFixed(0));
}

class SourceSelecter extends StatefulWidget {
  final double defaultAmount;
  final Function(String? primaryBankSource, double totalCash, double totalBank, List<Map<String, dynamic>> detailedSplits) onSplitPaymentChanged;

  const SourceSelecter({
    super.key,
    required this.defaultAmount,
    required this.onSplitPaymentChanged,
  });

  @override
  State<SourceSelecter> createState() => _SourceSelecterState();
}

class _SourceSelecterState extends State<SourceSelecter> {
  final List<PaymentSourceRow> _sourcesList = [];

  @override
  void initState() {
    super.initState();
    _sourcesList.add(
      PaymentSourceRow(
        sourceType: 'Cash in Hand',
        initialAmount: widget.defaultAmount,
      ),
    );
    
    for (var source in _sourcesList) {
      source.amountController.addListener(_notifyChanges);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChanges();
    });
  }

  @override
  void didUpdateWidget(covariant SourceSelecter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultAmount != oldWidget.defaultAmount && _sourcesList.length == 1) {
      _sourcesList[0].amountController.text = widget.defaultAmount == 0 ? '' : widget.defaultAmount.toStringAsFixed(0);
    }
  }

  void _notifyChanges() {
    double totalCash = 0;
    double totalBank = 0;
    String? primaryBank;
    List<Map<String, dynamic>> detailedSplits = [];

    for (var row in _sourcesList) {
      double amt = double.tryParse(row.amountController.text) ?? 0;
      detailedSplits.add({
        'source': row.sourceType,
        'amount': amt,
      });

      if (row.sourceType == 'Cash in Hand') {
        totalCash += amt;
      } else {
        totalBank += amt;
        primaryBank ??= row.sourceType;
      }
    }

    widget.onSplitPaymentChanged(primaryBank, totalCash, totalBank, detailedSplits);
  }

  @override
  void dispose() {
    for (var row in _sourcesList) {
      row.amountController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dashboardController,
      builder: (context, child) {
        final Map<String, double> bankBalances = dashboardController.bankBalances;
        final List<String> bankNames = bankBalances.keys.toList();
        
        final double cashBalance = bankBalances['Cash in Hand'] ?? 0.0;
        final List<String> allSources = ['Cash in Hand', ...bankNames];

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
                    "ادائیگی کے ذرائع (Payment Sources)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if (bankNames.isEmpty && allSources.length <= 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('پہلے ڈیش بورڈ سے کوئی بینک ایڈ کریں')),
                        );
                        return;
                      }
                      setState(() {
                        String defaultNewSource = allSources.firstWhere(
                          (src) => !_sourcesList.any((r) => r.sourceType == src),
                          orElse: () => allSources.first,
                        );
                        
                        _sourcesList.add(
                          PaymentSourceRow(
                            sourceType: defaultNewSource,
                            initialAmount: 0,
                          ),
                        );
                        _sourcesList.last.amountController.addListener(_notifyChanges);
                      });
                      _notifyChanges();
                    },
                    icon: const Icon(Icons.add, size: 14, color: Color(0xFFE53935)),
                    label: const Text(
                      "+ مزید سورس",
                      style: TextStyle(fontSize: 11, color: Color(0xFFE53935)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sourcesList.length,
                itemBuilder: (context, index) {
                  final row = _sourcesList[index];

                  if (!allSources.contains(row.sourceType)) {
                    row.sourceType = 'Cash in Hand';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: row.sourceType,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
                                items: allSources.map((source) {
                                  String balanceText = '';
                                  if (source == 'Cash in Hand') {
                                    balanceText = '(${cashBalance.toStringAsFixed(0)} Rs)';
                                  } else {
                                    double bVal = bankBalances[source] ?? 0.0;
                                    balanceText = '(${bVal.toStringAsFixed(0)} Rs)';
                                  }

                                  return DropdownMenuItem<String>(
                                    value: source,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          source,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          balanceText,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      row.sourceType = val;
                                    });
                                    _notifyChanges();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 42,
                            child: TextField(
                              controller: row.amountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: "رقم",
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        if (_sourcesList.length > 1) ...[
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                setState(() {
                                  row.amountController.dispose();
                                  _sourcesList.removeAt(index);
                                });
                                _notifyChanges();
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}