import 'package:flutter/material.dart';

class SalePurchaseScreen extends StatefulWidget {
  const SalePurchaseScreen({super.key});

  @override
  State<SalePurchaseScreen> createState() => _SalePurchaseScreenState();
}

class _SalePurchaseScreenState extends State<SalePurchaseScreen> {
  int _selectedMode = 0; 
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  final TextEditingController _cashPaidController = TextEditingController();
  final TextEditingController _bankPaidController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  
  // یہاں لسٹ کا پہلا آئٹم ہی سیدھا انیشل ویلیو کے طور پر رکھ دیا تاکہ کوئی mismatch نہ ہو
  final List<String> _bankList = ['حبیب بینک (HBL)', 'الصلح بینک', 'جاز کیش / ایزی پیسا'];
  late String _selectedBank;

  final List<Map<String, dynamic>> _purchaseItems = [
    {
      'category': 'موبائل',
      'modelController': TextEditingController(),
      'colorController': TextEditingController(),
      'imeiController': TextEditingController(),
      'priceController': TextEditingController(),
    }
  ];

  @override
  void initState() {
    super.initState();
    _selectedBank = _bankList[0]; // محفوظ طریقہ تاکہ ویلیو ہمیشہ لسٹ میں سے ہی ہو
  }

  void _addItemRow() {
    setState(() {
      _purchaseItems.add({
        'category': 'موبائل',
        'modelController': TextEditingController(),
        'colorController': TextEditingController(),
        'imeiController': TextEditingController(),
        'priceController': TextEditingController(),
      });
    });
  }

  void _removeItemRow(int index) {
    if (_purchaseItems.length > 1) {
      setState(() {
        _purchaseItems.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            children: [
              // 1. کسٹم ٹاپ ہیڈر
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.red[700],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "خرید و فروخت (انوائس)",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 2. موڈ سلیکٹر
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(child: _buildModeButton("صرف پرچیز", 0)),
                    const SizedBox(width: 5),
                    Expanded(child: _buildModeButton("صرف سیل", 1)),
                    const SizedBox(width: 5),
                    Expanded(child: _buildModeButton("پرچیز اینڈ سیل", 2)),
                  ],
                ),
              ),

              // 3. اسکرول ایبل فارم
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    // پارٹی کی تفصیلات
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("پارٹی / گاہک کی تفصیلات", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _partyNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'نام *',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _whatsappController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'واٹس ایپ نمبر *',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // تاریخ
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedDate = picked;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'تاریخ',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  child: Text(
                                    "${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // آئٹمز لسٹ
                    ..._purchaseItems.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("آئٹم #${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700])),
                                  if (_purchaseItems.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () => _removeItemRow(index),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _purchaseItems[index]['category'],
                                      decoration: const InputDecoration(labelText: 'کیٹیگری', border: OutlineInputBorder(), isDense: true),
                                      items: ['موبائل', 'لابتاپ', 'دیگر']
                                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13))))
                                          .toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _purchaseItems[index]['category'] = val;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _purchaseItems[index]['modelController'],
                                      decoration: const InputDecoration(
                                        labelText: 'موبائل ماڈل *',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _purchaseItems[index]['colorController'],
                                      decoration: const InputDecoration(
                                        labelText: 'کلر *',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _purchaseItems[index]['imeiController'],
                                      decoration: const InputDecoration(
                                        labelText: 'IMEI نمبر *',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _purchaseItems[index]['priceController'],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'قیمت *',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // پلس بٹن
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        side: BorderSide(color: Colors.red.shade300),
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      onPressed: _addItemRow,
                      icon: const Icon(Icons.add),
                      label: const Text("مزید آئٹم شامل کریں (+)"),
                    ),
                    const SizedBox(height: 10),

                    // ملٹی پیمنٹ سیکشن
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("پیمنٹ اور ایڈجسٹمنٹ (ملٹی آپشنز)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _cashPaidController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'کیش ادائگی',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _discountController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'رعایت / ڈسکاؤنٹ',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedBank,
                                    decoration: const InputDecoration(
                                      labelText: 'بینک اکاؤنٹ سلیکٹ کریں',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    items: _bankList
                                        .map((bank) => DropdownMenuItem(value: bank, child: Text(bank, style: const TextStyle(fontSize: 13))))
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedBank = val!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: _bankPaidController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'بینک رقم',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. نیچے والے بٹن
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {},
                        child: const Text("محفوظ کریں", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text("محفوظ اور شیئر", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String title, int modeIndex) {
    bool isSelected = _selectedMode == modeIndex;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.red[700] : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: () {
        setState(() {
          _selectedMode = modeIndex;
        });
      },
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}