import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  String _selectedBoxName = 'stockBox';

  final Map<String, Map<String, dynamic>> _boxesInfo = {
    'customerBox': {'title': 'کسٹمر باکس', 'color': Colors.blue},
    'guarantorBox': {'title': 'ضامن باکس', 'color': Colors.teal},
    'packageBox': {'title': 'پیکجز باکس', 'color': Colors.purple},
    'stockBox': {'title': 'اسٹاک باکس', 'color': Colors.red},
    'transactionBox': {'title': 'ٹرانزیکشن باکس', 'color': Colors.green},
    'expenseBox': {'title': 'اخراجات باکس', 'color': Colors.deepOrange},
    'bankBox': {'title': 'بینک باکس', 'color': Colors.amber},
    // 🎯 نیا نفع نقصان باکس شامل کر دیا گیا ہے
    'financialSummaryBox': {'title': 'نفع نقصان باکس', 'color': Colors.indigo},
  };

  // ہائیو بینک باکس کا اٹومیٹک کلین اپ اور مرج فنکشن
  void _cleanupBankBox(Box box) {
    if (_selectedBoxName != 'bankBox') return;

    if (box.containsKey('cashInHand')) {
      final double oldCash = (box.get('cashInHand') ?? 0.0).toDouble();
      final double currentCash = (box.get('Cash') ?? 0.0).toDouble();

      // ۱. دونوں کیش رقم کو ایک ہی 'Cash' کی کے تحت مرج کرنا
      box.put('Cash', currentCash + oldCash);

      // ۲. پرانی 'cashInHand' کی کو ہمیشہ کے لیے ڈیلیٹ کرنا
      box.delete('cashInHand');
    }
  }

  Widget _buildChip(String key) {
    final info = _boxesInfo[key]!;
    final isSelected = _selectedBoxName == key;
    final color = info['color'] as Color;

    return ChoiceChip(
      label: Text(
        info['title'] as String,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? color : Colors.grey.shade300),
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedBoxName = key);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentBox = Hive.box(_selectedBoxName);
    final themeColor = _boxesInfo[_selectedBoxName]!['color'] as Color;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ڈیٹا بیس مانیٹر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['customerBox', 'guarantorBox', 'packageBox'].map(_buildChip).toList(),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['stockBox', 'transactionBox', 'expenseBox'].map(_buildChip).toList(),
                  ),
                  const SizedBox(height: 4),
                  // 🎯 بینک باکس اور نفع نقصان باکس کو ایک ہی رو (Row) میں ایڈجسٹ کر دیا گیا ہے
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['bankBox', 'financialSummaryBox'].map(_buildChip).toList(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: currentBox.listenable(),
                builder: (context, Box box, _) {
                  // خودکار صفائی کال کرنا
                  _cleanupBankBox(box);

                  if (box.isEmpty) {
                    return Center(
                      child: Text(
                        '${_boxesInfo[_selectedBoxName]!['title']} بالکل خالی ہے!',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final key = box.keyAt(index);
                      final rawData = box.getAt(index);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            'Key: $key',
                            style: TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: 13),
                          ),
                          subtitle: Text(rawData.toString(), style: const TextStyle(fontSize: 12)),
                          trailing: _selectedBoxName == 'bankBox' && key != 'Cash'
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () => box.delete(key),
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}