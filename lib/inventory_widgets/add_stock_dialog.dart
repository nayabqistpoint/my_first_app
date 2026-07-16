import 'package:flutter/material.dart';

// ہر پروڈکٹ لائن کا ڈیٹا رکھنے کے لیے ماڈل
class StockItemInput {
  String category;
  final TextEditingController modelController;
  final TextEditingController qtyController;
  final TextEditingController priceController;
  final TextEditingController imeiController;

  StockItemInput({
    this.category = 'Mobile',
    required String model,
    required String qty,
    required String price,
    required String imei,
  })  : modelController = TextEditingController(text: model),
        qtyController = TextEditingController(text: qty),
        priceController = TextEditingController(text: price),
        imeiController = TextEditingController(text: imei);

  void dispose() {
    modelController.dispose();
    qtyController.dispose();
    priceController.dispose();
    imeiController.dispose();
  }
}

class AddStockDialog extends StatefulWidget {
  const AddStockDialog({super.key});

  @override
  State<AddStockDialog> createState() => AddStockDialogState();
}

class AddStockDialogState extends State<AddStockDialog> {
  final _remarksController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedSupplier = 'Ali Mobiles'; 

  // ڈائنامک آئٹمز کی لسٹ (شروع میں ایک لائن خودکار نظر آئے گی)
  final List<StockItemInput> _itemRows = [
    StockItemInput(category: 'Mobile', model: '', qty: '', price: '', imei: '')
  ];

  // ادائیگی کی فیلڈز (ایک ہی لائن میں پارشل پیمنٹ کے لیے)
  final _cashController = TextEditingController(text: '0');
  final _bankAmountController = TextEditingController(text: '0');
  final _otherAmountController = TextEditingController(text: '0');

  // رجسٹرڈ بینکوں کی لسٹ (جو ڈیش بورڈ سے منسلک ہوں گے)
  String _selectedRegisteredBank = 'Meezan Bank';
  final List<String> _registeredBanks = ['Meezan Bank', 'HBL', 'Alfalah', 'Faysal Bank'];

  // تاریخ فارمیٹ کرنے کا سادہ فنکشن
  String _getFormattedDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // کل بل کا حساب کتاب (Grand Total)
  double get grandTotal {
    double total = 0.0;
    for (var row in _itemRows) {
      final double price = double.tryParse(row.priceController.text) ?? 0.0;
      final int qty = int.tryParse(row.qtyController.text) ?? 0;
      total += price * qty;
    }
    return total;
  }

  // کل ادا شدہ رقم (کیش + بینک + ادھر)
  double get totalPaid {
    final double cash = double.tryParse(_cashController.text) ?? 0.0;
    final double bank = double.tryParse(_bankAmountController.text) ?? 0.0;
    final double other = double.tryParse(_otherAmountController.text) ?? 0.0;
    return cash + bank + other;
  }

  // واجب الادا بیلنس
  double get remainingBalance => grandTotal - totalPaid;

  // نئی آئٹم لائن شامل کرنا (Add Line)
  void _addNewLine() {
    setState(() {
      _itemRows.add(StockItemInput(category: 'Mobile', model: '', qty: '', price: '', imei: ''));
    });
  }

  // لائن ختم کرنا
  void _removeLine(int index) {
    if (_itemRows.length > 1) {
      setState(() {
        _itemRows[index].dispose();
        _itemRows.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    for (var row in _itemRows) {
      row.dispose();
    }
    _remarksController.dispose();
    _cashController.dispose();
    _bankAmountController.dispose();
    _otherAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // پوپ اپ سائز کو چھوٹا اور اسکرین کے مطابق فٹ رکھنے کے لیے کنسٹرینٹس
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85, 
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ہیڈر زون
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "نیا سٹاک اور بل بنائیں",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 10),

              // تاریخ اور سپلائر سلیکٹر (چھوٹی لائن)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 12),
                        label: Text(_getFormattedDate(_selectedDate), style: const TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSupplier,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                          items: ['Ali Mobiles', 'Hassan Traders', 'Subhan Communications']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSupplier = val);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text(
                "بل کے آئٹمز درج کریں:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 6),

              // ڈائنامک آئٹم روز (Dynamic Rows)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _itemRows.length,
                itemBuilder: (context, index) {
                  final row = _itemRows[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // کیٹیگری سلیکٹر
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: row.category,
                                    isExpanded: true,
                                    style: const TextStyle(fontSize: 11, color: Colors.black),
                                    items: ['Mobile', 'Accessories', 'Electronics', 'Other']
                                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => row.category = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // ماڈل کا نام
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 32,
                                child: TextField(
                                  controller: row.modelController,
                                  style: const TextStyle(fontSize: 12),
                                  onChanged: (val) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText: "آئٹم یا ماڈل نام",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                  ),
                                ),
                              ),
                            ),
                            // حذف کرنے کا بٹن (اگر 1 سے زیادہ روز ہوں)
                            if (_itemRows.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _removeLine(index),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // تعداد (Qty)
                            Expanded(
                              child: SizedBox(
                                height: 32,
                                child: TextField(
                                  controller: row.qtyController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 12),
                                  onChanged: (val) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText: "تعداد (Qty)",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // قیمت
                            Expanded(
                              child: SizedBox(
                                height: 32,
                                child: TextField(
                                  controller: row.priceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 12),
                                  onChanged: (val) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText: "قیمتِ خرید",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // IMEI
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 32,
                                child: TextField(
                                  controller: row.imeiController,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: const InputDecoration(
                                    hintText: "IMEI/بارکوڈ (اختیاری)",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ایڈ لائن بٹن (Add Line)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addNewLine,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text("آئٹم شامل کریں (+ Add Line)", style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ),
              const Divider(height: 15),

              // گرینڈ ٹوٹل شو کرنا
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("کل گرینڈ ٹوٹل:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text("Rs. $grandTotal", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ادائیگی کا نیا متوازی سسٹم (Cash, Bank + Dynamic Dropdown, Other)
              const Text(
                "وصولی یا ادائیگی کی تفصیل (پارشل پیمنٹ ممکن ہے):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              
              Row(
                children: [
                  // کیش آپشن
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("کیش (Cash)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 3),
                        SizedBox(
                          height: 32,
                          child: TextField(
                            controller: _cashController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 11),
                            onChanged: (val) => setState(() {}),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  
                  // بینک آپشن + رجسٹرڈ بینک سلیکٹر
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("بینک اکاؤنٹ میں رقم", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            // رقم کی فیلڈ
                            Expanded(
                              child: SizedBox(
                                height: 32,
                                child: TextField(
                                  controller: _bankAmountController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 11),
                                  onChanged: (val) => setState(() {}),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // ڈیش بورڈ رجسٹرڈ بینک سلیکٹر
                            Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedRegisteredBank,
                                  style: const TextStyle(fontSize: 10, color: Colors.black),
                                  items: _registeredBanks
                                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedRegisteredBank = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // دیگر آمدن (Other)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("دیگر (Other)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 3),
                        SizedBox(
                          height: 32,
                          child: TextField(
                            controller: _otherAmountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 11),
                            onChanged: (val) => setState(() {}),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // بقایا بیلنس
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("باقی واجب الادا رقم:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(
                    "Rs. $remainingBalance",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: remainingBalance > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ریمارکس
              SizedBox(
                height: 36,
                child: TextField(
                  controller: _remarksController,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: "بل کی اضافی تفصیل یا ریمارکس",
                    labelStyle: TextStyle(fontSize: 11),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // کیمرہ بٹن
              SizedBox(
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // کیمرہ لاجک یہاں لگے گی
                  },
                  icon: const Icon(Icons.camera_alt, size: 14),
                  label: const Text("بل یا کاغذ کی تصویر منسلک کریں", style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // نیچے ایکشن بٹنز
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text("منسوخ کریں", style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          // تمام روز کا ڈیٹا اکٹھا کرنا
                          final finalItems = _itemRows.map((r) {
                            return {
                              'category': r.category,
                              'model': r.modelController.text,
                              'qty': int.tryParse(r.qtyController.text) ?? 0,
                              'price': double.tryParse(r.priceController.text) ?? 0.0,
                              'imei': r.imeiController.text,
                            };
                          }).toList();

                          final invoiceData = {
                            'supplier': _selectedSupplier,
                            'date': _selectedDate,
                            'items': finalItems,
                            'total': grandTotal,
                            'cashPaid': double.tryParse(_cashController.text) ?? 0.0,
                            'bankPaid': double.tryParse(_bankAmountController.text) ?? 0.0,
                            'bankName': _selectedRegisteredBank,
                            'otherPaid': double.tryParse(_otherAmountController.text) ?? 0.0,
                            'balance': remainingBalance,
                            'remarks': _remarksController.text,
                            'shouldShare': false,
                          };
                          Navigator.pop(context, invoiceData);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text("صرف محفوظ کریں", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // محفوظ کریں اور واٹس ایپ پر شیئر کریں والا بٹن
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final finalItems = _itemRows.map((r) {
                      return {
                        'category': r.category,
                        'model': r.modelController.text,
                        'qty': int.tryParse(r.qtyController.text) ?? 0,
                        'price': double.tryParse(r.priceController.text) ?? 0.0,
                        'imei': r.imeiController.text,
                      };
                    }).toList();

                    final invoiceData = {
                      'supplier': _selectedSupplier,
                      'date': _selectedDate,
                      'items': finalItems,
                      'total': grandTotal,
                      'cashPaid': double.tryParse(_cashController.text) ?? 0.0,
                      'bankPaid': double.tryParse(_bankAmountController.text) ?? 0.0,
                      'bankName': _selectedRegisteredBank,
                      'otherPaid': double.tryParse(_otherAmountController.text) ?? 0.0,
                      'balance': remainingBalance,
                      'remarks': _remarksController.text,
                      'shouldShare': true, 
                    };
                    Navigator.pop(context, invoiceData);
                  },
                  icon: const Icon(Icons.share, color: Colors.white, size: 14),
                  label: const Text("محفوظ کریں اور واٹس ایپ کریں", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}