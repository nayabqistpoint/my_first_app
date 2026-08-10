import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AvailableStockSelectorWidget extends StatefulWidget {
  const AvailableStockSelectorWidget({super.key});

  @override
  State<AvailableStockSelectorWidget> createState() => _AvailableStockSelectorWidgetState();
}

class _AvailableStockSelectorWidgetState extends State<AvailableStockSelectorWidget> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // سکرین کا 75 فیصد حصہ
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ہیڈر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'دستیاب اسٹاک سے منتخب کریں',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),

          // 2. تلاش (Search Bar)
          TextField(
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'نام یا IMEI سے تلاش کریں...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (val) {
              setState(() {
                searchQuery = val.trim().toLowerCase();
              });
            },
          ),
          const SizedBox(height: 12),

          // 3. لائیو ہائیو اسٹاک لسٹ
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box('stockBox').listenable(),
              builder: (context, Box box, _) {
                // صرف 'available' سٹیٹس والے آئٹمز نکالنا
                final availableItems = box.values.where((element) {
                  if (element is! Map) return false;
                  final status = element['status']?.toString() ?? 'available';
                  if (status != 'available') return false;

                  if (searchQuery.isEmpty) return true;

                  final name = element['itemName']?.toString().toLowerCase() ?? '';
                  final imei = element['imeiNo']?.toString().toLowerCase() ?? '';
                  return name.contains(searchQuery) || imei.contains(searchQuery);
                }).toList();

                if (availableItems.isEmpty) {
                  return const Center(
                    child: Text('کوئی دستیاب اسٹاک نہیں ملا', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  );
                }

                return ListView.separated(
                  itemCount: availableItems.length,
                  // اصلاح: '(__)' کی جگہ '(_)' یا '(context, index)' استعمال کیا ہے تاکہ وارننگ ختم ہو جائے
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = Map<String, dynamic>.from(availableItems[index] as Map);

                    final String name = item['itemName'] ?? 'نامعلوم';
                    final String imei = item['imeiNo'] ?? 'کوئی IMEI نہیں';
                    final String ram = item['ram'] ?? '';
                    final String rom = item['rom'] ?? '';
                    final String price = item['salePrice']?.toString() ?? '0';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 18,
                        child: Icon(Icons.phone_android, color: Colors.white, size: 18),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        'IMEI: $imei ${ram.isNotEmpty ? '| $ram/$rom' : ''}',
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      trailing: Text(
                        'Rs. $price',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12),
                      ),
                      onTap: () {
                        // کلک ہونے پر صرف نام اور IMEI کی فلٹرڈ ڈکشنری واپس پاس ہوگی
                        Navigator.pop(context, {
                          'mobileName': name,
                          'imeiNo': imei,
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}