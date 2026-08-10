import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// پوری ایپ میں کہیں بھی IMEI کی تفصیلی ونڈو کھولنے کا مرکزی فنکشن
void showImeiDetailsDialog(BuildContext context, String imeiNo) {
  final bool isBoxOpen = Hive.isBoxOpen('stockBox');
  dynamic stockItem;

  if (isBoxOpen) {
    final stockBox = Hive.box('stockBox');
    stockItem = stockBox.values.firstWhere(
      (element) {
        if (element is Map) {
          return element['imeiNo']?.toString().trim() == imeiNo.trim();
        }
        return false;
      },
      orElse: () => null,
    );
  }

  showDialog(
    context: context,
    builder: (dialogContext) {
      if (stockItem == null) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 36),
                const SizedBox(height: 8),
                const Text('تفصیلات دستیاب نہیں', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('اس IMEI ($imeiNo) کا ڈیٹا اسٹاک میں نہیں ملا۔', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('ٹھیک ہے', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
          ),
        );
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(stockItem as Map);

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        backgroundColor: Colors.transparent, // ابھرا ہوا کارڈ لک دینے کے لیے
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white, // مکمل وائٹ بیک گراؤنڈ
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12), // ابھرا ہوا 3D اثر
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ہیڈر کی پٹی
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phone_android, color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['itemName']?.toString() ?? 'موبائل کی تفصیلات',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // اندرونی کارڈز (موبائل کی خصوصیات)
              _buildInfoRow('IMEI نمبر:', data['imeiNo']?.toString() ?? 'N/A'),
              _buildInfoRow('RAM / ROM:', '${data['ram'] ?? 'N/A'} / ${data['rom'] ?? 'N/A'}'),
              _buildInfoRow('حالت (Condition):', data['condition'] == 'new' ? 'نیا (New)' : 'پرانا (Old)'),
              _buildInfoRow('وارنٹی:', '${data['warranty'] ?? 0} ماہ'),

              const SizedBox(height: 8),

              // قیمت اور پیکج سے متعلق گائیڈنس نوٹ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.calculate_outlined, size: 16, color: Colors.red),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'قیمت اور اقساط کا انتخاب قسط کیلکولیٹر سے کریں سکرین پر پیکج کی تفصیلات کے مطابق قیمت طے ہوگی۔',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('بند کریں', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ابھری ہوئی کارڈ کی شکل والی خوبصورت پٹی کا ہیلپر
Widget _buildInfoRow(String label, String value) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 3),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    ),
  );
}