import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaymentRowItem {
  String source;
  final TextEditingController amountController;

  PaymentRowItem({required this.source, String amount = '0'})
      : amountController = TextEditingController(text: amount);
}

class PaymentSourceCard extends StatefulWidget {
  final String? selectedSource;
  final ValueChanged<String?> onChanged;
  final bool isAdmin;

  const PaymentSourceCard({
    super.key,
    required this.selectedSource,
    required this.onChanged,
    this.isAdmin = false,
  });

  @override
  State<PaymentSourceCard> createState() => PaymentSourceCardState();
}

class PaymentSourceCardState extends State<PaymentSourceCard> {
  bool _isSplitMode = false;
  final List<PaymentRowItem> _rows = [];
  final TextEditingController noteController = TextEditingController();

  bool get isSplitMode => _isSplitMode;

  @override
  void dispose() {
    for (var row in _rows) {
      row.amountController.dispose();
    }
    noteController.dispose();
    super.dispose();
  }

  void _toggleSplitMode(List<String> sources) {
    setState(() {
      _isSplitMode = true;
      _rows.clear();
      String first = widget.selectedSource ?? 'Cash';
      String second = sources.firstWhere((s) => s != first, orElse: () => 'Cash');

      _rows.addAll([
        PaymentRowItem(source: first),
        PaymentRowItem(source: second),
      ]);
    });
  }

  void _addRow(List<String> sources) {
    setState(() {
      String next = sources.firstWhere(
        (s) => !_rows.any((r) => r.source == s),
        orElse: () => 'Cash',
      );
      _rows.add(PaymentRowItem(source: next));
    });
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].amountController.dispose();
      _rows.removeAt(index);
      if (_rows.length <= 1) {
        _isSplitMode = false;
        if (_rows.isNotEmpty) widget.onChanged(_rows.first.source);
      }
    });
  }

  double get totalReceived => _rows.fold(
      0, (sum, item) => sum + (double.tryParse(item.amountController.text) ?? 0));

  List<Map<String, dynamic>> getSplitPaymentsList() {
    if (!_isSplitMode) return [];
    return _rows
        .map((r) => {
              'source': r.source,
              'amount': double.tryParse(r.amountController.text) ?? 0.0,
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('bankBox').listenable(),
      builder: (context, box, child) {
        // ۱۔ پرانی cashInHand کو ختم کر کے Cash کے ساتھ مرج (Merge) کرنا
        double cashBalance = 0.0;
        if (box.containsKey('Cash')) {
          cashBalance += (box.get('Cash') ?? 0.0).toDouble();
        }
        if (box.containsKey('cashInHand')) {
          cashBalance += (box.get('cashInHand') ?? 0.0).toDouble();
          // مرج کرنے کے بعد پرانی کیز ختم کرنا
          box.put('Cash', cashBalance);
          box.delete('cashInHand');
        }

        Map<String, double> bankBalances = {};
        for (var key in box.keys) {
          String keyStr = key.toString();
          if (keyStr != 'cashInHand' && keyStr != 'Cash') {
            String cleanName = keyStr.startsWith('bank_')
                ? keyStr.replaceFirst('bank_', '')
                : keyStr;
            bankBalances[cleanName] = (box.get(key) ?? 0.0).toDouble();
          }
        }

        final Set<String> sourcesSet = {'Cash', ...bankBalances.keys};
        final List<String> sources = sourcesSet.toList();

        String current = (widget.selectedSource != null &&
                sources.contains(widget.selectedSource))
            ? widget.selectedSource!
            : 'Cash';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isSplitMode) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Payment Type",
                      style: TextStyle(fontSize: 15, color: Colors.black54)),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: current,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: sources
                          .map((s) => _buildDropdownItem(
                              s, cashBalance, bankBalances))
                          .toList(),
                      onChanged: widget.onChanged,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _toggleSplitMode(sources),
                child: const Text("+ Add Payment Type",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              ..._rows.asMap().entries.map((entry) {
                int idx = entry.key;
                var item = entry.value;

                String rowCurrent = sources.contains(item.source)
                    ? item.source
                    : 'Cash';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: rowCurrent,
                          isDense: true,
                          items: sources
                              .map((s) => _buildDropdownItem(
                                  s, cashBalance, bankBalances))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => item.source = val);
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.black45),
                        onPressed: () => _removeRow(idx),
                      ),
                      const Spacer(),
                      const Text("Rs ",
                          style: TextStyle(fontSize: 14, color: Colors.black87)),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: item.amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(isDense: true),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => _addRow(sources),
                    child: const Text("+ Add Payment Type",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                  Text(
                    "Received Rs ${totalReceived.toStringAsFixed(0)}",
                    style: const TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(color: Colors.black12, height: 1),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 65,
                    child: TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "Description",
                        hintText: "Add Note",
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.image_outlined,
                            color: Colors.black38, size: 32),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(Icons.add_circle,
                              color: Colors.blue, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(
      String source, double cashBalance, Map<String, double> banks) {
    bool isCash = source == 'Cash';
    double balance = isCash ? cashBalance : (banks[source] ?? 0.0);

    return DropdownMenuItem<String>(
      value: source,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCash ? Icons.money : Icons.account_balance,
            color: isCash ? Colors.green : Colors.blue,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(source),
          if (widget.isAdmin) ...[
            const SizedBox(width: 4),
            Text(
              "(Rs. ${balance.toStringAsFixed(0)})",
              style: TextStyle(
                color: balance < 0 ? Colors.red : Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}