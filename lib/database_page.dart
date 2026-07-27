import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_page/controllers/item_controller.dart';

class DatabasePage extends StatelessWidget {
  const DatabasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اسٹاک ڈیٹا بیس',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        color: Colors.white,
        child: ValueListenableBuilder(
          valueListenable: itemController.stockBox.listenable(),
          builder: (context, Box box, widget) {
            if (box.isEmpty) {
              return const Center(
                child: Text(
                  'ڈیٹا بیس بالکل خالی ہے!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: box.length,
              itemBuilder: (context, index) {
                final rawData = box.get(index);
                
                if (rawData == null || rawData is! Map) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.2), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text(
                      'نام: ${rawData['name'] ?? 'نامعلوم'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'IMEI: ${rawData['imei'] ?? 'موجود نہیں'}\nمقدار: ${rawData['quantity'] ?? 0} | خرید قیمت: ${rawData['purchasePrice'] ?? 0}\nسप्लायर: ${rawData['supplierName'] ?? 'نامعلوم'}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ),
      // نیچے باٹم پر اسٹاک ڈیٹا بیس کا خاص بٹن
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12.0),
        color: Colors.white,
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              // یہاں آپ ڈیٹا بیس سے متعلق کوئی بھی مزید ایکشن (مثلاً ریفریش یا میسیج) کر سکتے ہیں
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('اسٹاک ڈیٹا بیس کا ریکارڈ کامیابی سے لوڈ ہے')),
              );
            },
            icon: const Icon(Icons.storage, color: Colors.white),
            label: const Text(
              'اسٹاک ڈیٹا بیس مینجمنٹ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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