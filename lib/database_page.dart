import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  // پہلے سے منتخب کردہ باکس اسٹاک ہے
  String _selectedBoxName = 'stockBox';

  // چاروں باکسز کے نام اور ان کے رنگ
  final Map<String, Map<String, dynamic>> _boxesInfo = {
    'stockBox': {'title': 'اسٹاک باکس', 'color': Colors.red},
    'customerBox': {'title': 'کسٹمر باکس', 'color': Colors.blue},
    'transactionBox': {'title': 'ٹرانزیکشن باکس', 'color': Colors.green},
    'bankBox': {'title': 'بینک باکس', 'color': Colors.orange},
  };

  @override
  Widget build(BuildContext context) {
    // نام کی بنیاد پر ہائیو باکس حاصل کرنا
    final Box currentBox = Hive.box(_selectedBoxName);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ڈیٹا بیس مانیٹر (تمام باکسز)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // اوپر چاروں باکسز کے بٹنز / ٹیبز
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _boxesInfo.entries.map((entry) {
                  final key = entry.key;
                  final info = entry.value;
                  final isSelected = _selectedBoxName == key;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        info['title'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: info['color'],
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? info['color'] : Colors.grey.shade300,
                        ),
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedBoxName = key;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // منتخب کردہ باکس کا ڈیٹا لسٹ کی شکل میں دکھانا
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: currentBox.listenable(),
              builder: (context, Box box, widget) {
                if (box.isEmpty) {
                  return Center(
                    child: Text(
                      '${_boxesInfo[_selectedBoxName]!['title']} بالکل خالی ہے!',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final key = box.keyAt(index);
                    final rawData = box.getAt(index);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: (_boxesInfo[_selectedBoxName]!['color'] as Color)
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'انڈیکس / کی: $key',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (_boxesInfo[_selectedBoxName]!['color']
                                            as Color)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _boxesInfo[_selectedBoxName]!['title'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _boxesInfo[_selectedBoxName]!['color'],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 10),

                            // اگر ڈیٹا Map کی شکل میں ہے تو تمام فیلڈز دکھائیں
                            if (rawData is Map)
                              ...rawData.entries.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(
                                    '${e.key}: ${e.value}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              })
                            else
                              Text(
                                'قدر (Value): $rawData',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
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
      // نیچے باٹم پر ریفریش / انفارمیشن کا بٹن
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12.0),
        color: Colors.white,
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'موجودہ ${_boxesInfo[_selectedBoxName]!['title']} میں کل ${currentBox.length} انٹریز موجود ہیں',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.storage, color: Colors.white),
            label: Text(
              'کل انٹریز: ${currentBox.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _boxesInfo[_selectedBoxName]!['color'],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}