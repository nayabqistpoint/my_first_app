import 'package:flutter/material.dart';
import 'single_item_data.dart';

class AddStockDialog extends StatefulWidget {
  const AddStockDialog({super.key});

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // ان پٹ کنٹرولرز
  final _modelController = TextEditingController();
  final _supplierController = TextEditingController();
  final _priceController = TextEditingController();
  final _imeiController = TextEditingController();

  @override
  void dispose() {
    _modelController.dispose();
    _supplierController.dispose();
    _priceController.dispose();
    _imeiController.dispose();
    super.dispose();
  }

  // محفوظ کرنے کا فنکشن
  void _submitData() {
    if (_formKey.currentState!.validate()) {
      // تاریخ خود بخود آج کی سیٹ ہو جائے گی
      final String currentDate = '2026-07-16'; // 2026 کے حساب سے سیٹ کر دیا ہے

      final newItem = SingleItemData(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // عارضی منفرد آئی ڈی
        model: _modelController.text.trim(),
        supplier: _supplierController.text.trim(),
        category: 'موبائل',
        purchasePrice: int.parse(_priceController.text.trim()),
        date: currentDate,
        imei: _imeiController.text.trim(),
      );

      // ڈیٹا واپس مین پیج پر بھیج دیں
      Navigator.of(context).pop(newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ۱۔ ہیڈر (Header)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'نیا اسٹاک شامل کریں',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),

                // ۲۔ موبائل ماڈل ان پٹ
                TextFormField(
                  controller: _modelController,
                  decoration: InputDecoration(
                    labelText: 'موبائل ماڈل (مثلاً: Vivo Y17s)',
                    prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF1E3A8A)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'براہ کرم موبائل کا ماڈل درج کریں';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ۳۔ سپلائر کا نام ان پٹ
                TextFormField(
                  controller: _supplierController,
                  decoration: InputDecoration(
                    labelText: 'سپلائر کا نام (مثلاً: Ali Mobiles)',
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF1E3A8A)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'براہ کرم سپلائر کا نام درج کریں';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ۴۔ خریداری کی قیمت ان پٹ
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'قیمتِ خریداری (صرف ہندسے)',
                    prefixIcon: const Icon(Icons.money, color: Color(0xFF1E3A8A)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'براہ کرم خریداری کی قیمت لکھیں';
                    }
                    if (int.tryParse(value) == null) {
                      return 'صرف ہندسے لکھیں (مثلاً: 35000)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ۵۔ آئی ایم ای آئی (IMEI) نمبر ان پٹ
                TextFormField(
                  controller: _imeiController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'IMEI نمبر (15 ہندسے)',
                    prefixIcon: const Icon(Icons.qr_code_scanner, color: Color(0xFF1E3A8A)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'براہ کرم IMEI نمبر درج کریں';
                    }
                    if (value.trim().length != 15) {
                      return 'IMEI نمبر 15 ہندسوں کا ہونا چاہیے';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ۶۔ ایکشن بٹنز (Cancel & Save)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('کینسل', style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitData,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF1E3A8A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('محفوظ کریں', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}