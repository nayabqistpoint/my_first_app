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

  // آئٹم کا سب ٹوٹل معلوم کرنا
  double get subtotal {
    final double price = double.tryParse(priceController.text) ?? 0.0;
    final int qty = int.tryParse(qtyController.text) ?? 0;
    return price * qty;
  }

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
  
  // ڈائنامک سپلائر کی لسٹ اور سلیکٹڈ سپلائر
  String _selectedSupplier = 'Ali Mobiles'; 
  final List<String> _suppliers = ['Ali Mobiles', 'Hassan Traders', 'Subhan Communications'];

  // ڈائنامک کیٹیگریز کی لسٹ
  final List<String> _categories = ['Mobile', 'Accessories', 'Electronics', 'Other'];

  // ڈائنامک آئٹمز کی لسٹ (شروع میں ایک لائن خودکار نظر آئے گی)
  late List<StockItemInput> _itemRows;

  @override
  void initState() {
    super.initState();
    _itemRows = [
      StockItemInput(category: 'Mobile', model: '', qty: '', price: '', imei: '')
    ];
  }

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
      total += row.subtotal;
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
      _itemRows.add(StockItemInput(category: _categories.first, model: '', qty: '', price: '', imei: ''));
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

  // نیا سپلائر شامل کرنے کا پوپ اپ ڈائیلاگ
  void _showAddSupplierDialog() {
    final nameCtrl = TextEditingController();
    final whatsappCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text("نیا سپلائر شامل کریں", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 36,
                child: TextField(
                  controller: nameCtrl,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: "سپلائر کا نام",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: TextField(
                  controller: whatsappCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: "واٹس ایپ نمبر",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("منسوخ کریں", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _suppliers.add(nameCtrl.text.trim());
                    _selectedSupplier = nameCtrl.text.trim();
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("محفوظ کریں", style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  // نئی کیٹیگری شامل کرنے کا پوپ اپ ڈائیلاگ
  void _showAddCategoryDialog(StockItemInput row) {
    final categoryCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text("نئی کیٹیگری شامل کریں", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: SizedBox(
            height: 36,
            child: TextField(
              controller: categoryCtrl,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                hintText: "کیٹیگری کا نام (مثلاً LED, Charger)",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("منسوخ کریں", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () {
                if (categoryCtrl.text.trim().isNotEmpty) {
                  final newCat = categoryCtrl.text.trim();
                  setState(() {
                    if (!_categories.contains(newCat)) {
                      _categories.add(newCat);
                    }
                    row.category = newCat;
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("محفوظ کریں", style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.90, 
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        padding: const EdgeInsets.all(12),
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 8),

              // تاریخ اور سپلائر سلیکٹر (بشمول سپلائر پلس بٹن)
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 32,
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
                        icon: const Icon(Icons.calendar_today, size: 11),
                        label: Text(_getFormattedDate(_selectedDate), style: const TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 6,
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSupplier,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 11, color: Colors.black),
                          items: [
                            ..._suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                            const DropdownMenuItem<String>(
                              value: 'ADD_NEW_SUPPLIER',
                              child: Row(
                                children: [
                                  Icon(Icons.add_circle_outline, size: 14, color: Colors.blue),
                                  SizedBox(width: 4),
                                  Text("نیا سپلائر شامل کریں...", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == 'ADD_NEW_SUPPLIER') {
                              _showAddSupplierDialog();
                            } else if (val != null) {
                              setState(() => _selectedSupplier = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const Text(
                "بل کے آئٹمز درج کریں:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 4),

              // ڈائنامک آئٹم روز (تمام تفصیلات ایک ہی کارڈ کے اندر انتہائی کمپیکٹ اور سب ٹوٹل کے ساتھ)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _itemRows.length,
                itemBuilder: (context, index) {
                  final row = _itemRows[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        // پہلی لائن: کیٹیگری، ماڈل نام اور ڈیلیٹ بٹن
                        Row(
                          children: [
                            // کیٹیگری ڈراپ ڈاؤن (بشمول پلس بٹن)
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: 28,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: row.category,
                                    isExpanded: true,
                                    style: const TextStyle(fontSize: 10, color: Colors.black),
                                    items: [
                                      ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                                      const DropdownMenuItem<String>(
                                        value: 'ADD_NEW_CATEGORY',
                                        child: Row(
                                          children: [
                                            Icon(Icons.add_circle_outline, size: 12, color: Colors.blue),
                                            SizedBox(width: 3),
                                            Text("نئی کیٹیگری...", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val == 'ADD_NEW_CATEGORY') {
                                        _showAddCategoryDialog(row);
                                      } else if (val != null) {
                                        setState(() => row.category = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // ماڈل یا پروڈکٹ کا نام
                            Expanded(
                              flex: 5,
                              child: SizedBox(
                                height: 28,
                                child: TextField(
                                  controller: row.modelController,
                                  style: const TextStyle(fontSize: 11),
                                  onChanged: (val) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText: "ماڈل یا آئٹم کا نام",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 6),
                                  ),
                                ),
                              ),
                            ),
                            // ڈیلیٹ بٹن
                            if (_itemRows.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_forever, color: Colors.red, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _removeLine(index),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // دوسری لائن: تعداد (Qty)، قیمت، سب ٹوٹل اور IMEI فیلڈ
                        Row(
                          children: [
                            // تعداد (Qty)
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 28,
                                child: TextField(
                                  controller: row.qtyController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 11),
                                  onChanged: (val) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText: "تعداد",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // قیمت
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 28,
                                child: TextField(
                                  controller: row.priceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 11),
                                  onChanged: (val) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText: "قیمتِ خرید",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // اس ایک آئٹم کا سب ٹوٹل (صرف ڈسپلے ڈبہ)
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.amber[50],
                                  border: Border.all(color: Colors.amber[200]!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "ٹوٹل: ${row.subtotal.toStringAsFixed(0)}",
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // IMEI
                            Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 28,
                                child: TextField(
                                  controller: row.imeiController,
                                  style: const TextStyle(fontSize: 11),
                                  decoration: const InputDecoration(
                                    hintText: "IMEI (اختیاری)",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
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
                  icon: const Icon(Icons.add, size: 13),
                  label: const Text("آئٹم شامل کریں (+ Add Line)", style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ),
              const Divider(height: 10),

              // گرینڈ ٹوٹل شو کرنا
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("کل گرینڈ ٹوٹل:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text("Rs. ${grandTotal.toStringAsFixed(0)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ادائیگی کا نیا متوازی سسٹم (Cash, Bank + Dynamic Dropdown, Other)
              const Text(
                "وصولی یا ادائیگی کی تفصیل (پارشل پیمنٹ ممکن ہے):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              
              Row(
                children: [
                  // کیش آپشن
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("کیش (Cash)", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        SizedBox(
                          height: 28,
                          child: TextField(
                            controller: _cashController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 10),
                            onChanged: (val) => setState(() {}),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  
                  // بینک آپشن + رجسٹرڈ بینک سلیکٹر
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("بینک اکاؤنٹ میں رقم", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            // رقم کی فیلڈ
                            Expanded(
                              child: SizedBox(
                                height: 28,
                                child: TextField(
                                  controller: _bankAmountController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 10),
                                  onChanged: (val) => setState(() {}),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            // ڈیش بورڈ رجسٹرڈ بینک سلیکٹر
                            Container(
                              height: 28,
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedRegisteredBank,
                                  style: const TextStyle(fontSize: 9, color: Colors.black),
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
                  const SizedBox(width: 4),

                  // دیگر آمدن (Other)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("دیگر (Other)", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        SizedBox(
                          height: 28,
                          child: TextField(
                            controller: _otherAmountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 10),
                            onChanged: (val) => setState(() {}),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // بقایا بیلنس
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("باقی واجب الادا رقم:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  Text(
                    "Rs. ${remainingBalance.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: remainingBalance > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ریمارکس
              SizedBox(
                height: 32,
                child: TextField(
                  controller: _remarksController,
                  style: const TextStyle(fontSize: 11),
                  decoration: const InputDecoration(
                    labelText: "بل کی اضافی تفصیل یا ریمارکس",
                    labelStyle: TextStyle(fontSize: 10),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // کیمرہ بٹن
              SizedBox(
                height: 28,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // کیمرہ لاجک یہاں لگے گی
                  },
                  icon: const Icon(Icons.camera_alt, size: 12),
                  label: const Text("بل یا کاغذ کی تصویر منسلک کریں", style: TextStyle(fontSize: 10)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // نیچے ایکشن بٹنز
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text("منسوخ کریں", style: TextStyle(color: Colors.black54, fontSize: 11)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SizedBox(
                      height: 32,
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
                        child: const Text("صرف محفوظ کریں", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              // محفوظ کریں اور واٹس ایپ پر شیئر کریں والا بٹن
              SizedBox(
                height: 36,
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
                  icon: const Icon(Icons.share, color: Colors.white, size: 12),
                  label: const Text("محفوظ کریں اور واٹس ایپ کریں", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
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