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
    'financialSummaryBox': {'title': 'نفع نقصان باکس', 'color': Colors.indigo},
    'summaryBox': {'title': 'سمری باکس (نیا)', 'color': Colors.deepPurple},
  };

  void _checkAndCleanupBankBox(Box box) {
    if (_selectedBoxName != 'bankBox') return;

    if (box.containsKey('cashInHand')) {
      final double oldCash = (box.get('cashInHand') ?? 0.0).toDouble();
      final double currentCash = (box.get('Cash') ?? 0.0).toDouble();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await box.put('Cash', currentCash + oldCash);
        await box.delete('cashInHand');
      });
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
          fontSize: 11,
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
        if (selected) {
          setState(() {
            _selectedBoxName = key;
          });
        }
      },
    );
  }

  // ڈیٹا کو خوبصورت اور صاف فارمیٹ میں پرنٹ کرنے کا ہیلپر
  Widget _buildFormattedData(dynamic rawData, Color themeColor) {
    if (rawData is Map) {
      return Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: rawData.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: themeColor.withValues(alpha: 0.2)),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  children: [
                    TextSpan(
                      text: '${entry.key}: ',
                      style: TextStyle(fontWeight: FontWeight.bold, color: themeColor),
                    ),
                    TextSpan(
                      text: '${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Text(
      rawData.toString(),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
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
          title: const Text(
            'ڈیٹا بیس مانیٹر',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              color: Colors.grey[100],
              width: double.infinity,
              child: Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                alignment: WrapAlignment.center,
                children: _boxesInfo.keys.map(_buildChip).toList(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: currentBox.listenable(),
                builder: (context, Box box, _) {
                  _checkAndCleanupBankBox(box);

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
                        elevation: 1.5,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: themeColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Key: $key',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  if (_selectedBoxName == 'bankBox' && key != 'Cash')
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => box.delete(key),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              _buildFormattedData(rawData, themeColor),
                            ],
                          ),
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