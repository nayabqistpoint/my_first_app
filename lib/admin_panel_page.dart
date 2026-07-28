import 'package:flutter/material.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  // قانونی ڈاکومنٹس کے باکسز (جنہیں جنریٹ کرنا ہے)
  bool _checkAgreement = false;
  bool _checkAffidavit = false;
  bool _checkGuarantorDoc = false;
  
  // تصدیقی اور چیک باکسز (جن پر سائن شدہ ہونے کی تصدیق کرنی ہے)
  bool _checkCnicVerified = false;
  bool _checkStampVerified = false;
  bool _checkSecurityCheckVerified = false;
  
  // فائنل ڈیل کلوز چیک
  bool _dealClosedChecked = false;

  // ہینڈ اوور تصویر کی حالت
  String? _handoverSelfiePath;

  // اسٹاک اور IMEI کے ویری ایبلز
  String? _selectedAdminStockItem;
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  @override
  void dispose() {
    _imeiController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> availableStockItems = [
      'Vivo Y20 (IMEI: 998877-1)',
      'Samsung Galaxy A12 (IMEI: 445566-2)',
      'Oppo A54 (IMEI: 112233-3)',
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: const Text('ایڈمن پینل - درخواست کی جانچ پڑتال', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.red[800], size: 24),
              const SizedBox(width: 8),
              const Text(
                'موصول ہونے والی کسٹمر درخواست',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: const Text('محمد علی (موبائل درخواست)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: const Text('پیکج: 6 ماہ | حیثیت: منظوری کا منتظر (Pending)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child: Icon(Icons.person, color: Colors.red[800]),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const Text('1. کسٹمر کے کوائف اور سیلفی:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(height: 8),
                      const Text('• نام: محمد علی\n• ولدیت: احمد علی\n• شناختی کارڈ: 36302-1234567-1\n• فون نمبر: 0300-1234567'),
                      const SizedBox(height: 10),
                      
                      Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                        child: const Center(child: Text('کسٹمر کی لائیو سیلفی', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      ),
                      const SizedBox(height: 16),

                      // 2. اسٹاک سے ماڈل، IMEI اور رنگ کا انتخاب
                      const Text('2. اسٹاک سے موبائل اسائنمنٹ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAdminStockItem,
                        hint: const Text('دکان کے اسٹاک سے ماڈل منتخب کریں'),
                        decoration: InputDecoration(
                          labelText: 'موجودہ اسٹاک',
                          prefixIcon: Icon(Icons.inventory, color: Colors.red[800]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: availableStockItems.map((item) {
                          return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedAdminStockItem = val;
                            _imeiController.text = 'IMEI-998877-XYZ';
                            _colorController.text = 'گولڈن (Golden)';
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _imeiController,
                              decoration: InputDecoration(
                                labelText: 'IMEI نمبر',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _colorController,
                              decoration: InputDecoration(
                                labelText: 'موبائل کا رنگ',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. موبائل ہینڈ اوور کی تصویر
                      const Text('3. موبائل ہینڈ اوور کی تصویر:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _handoverSelfiePath == null ? 'تصویر نہیں لی گئی' : 'ہینڈ اوور تصویر موجود ہے ✔', 
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() { _handoverSelfiePath = 'handover_captured.jpg'; });
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('موبائل ہینڈ اوور تصویر لے لی گئی!')));
                              },
                              icon: const Icon(Icons.camera_alt, size: 14),
                              label: const Text('تصویر لیں'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], foregroundColor: Colors.white, visualDensity: VisualDensity.compact),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. قانونی ڈاکومنٹس جنریٹ کریں (چوتھا نمبر)
                      const Text('4. قانونی ڈاکومنٹس جنریٹ کریں (سائن کے لیے):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      CheckboxListTile(
                        title: const Text('ایگریمنٹ ڈاکومنٹ', style: TextStyle(fontSize: 13)),
                        value: _checkAgreement,
                        activeColor: Colors.red[800],
                        onChanged: (val) => setState(() => _checkAgreement = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                      CheckboxListTile(
                        title: const Text('بیان حلفی', style: TextStyle(fontSize: 13)),
                        value: _checkAffidavit,
                        activeColor: Colors.red[800],
                        onChanged: (val) => setState(() => _checkAffidavit = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                      CheckboxListTile(
                        title: const Text('ضمانت نامہ', style: TextStyle(fontSize: 13)),
                        value: _checkGuarantorDoc,
                        activeColor: Colors.red[800],
                        onChanged: (val) => setState(() => _checkGuarantorDoc = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ڈاکومنٹس جنریٹ ہو گئے اور واٹس ایپ پر شیئر کیے جا رہے ہیں!')));
                          },
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('ڈاکومنٹس جنریٹ اور واٹس ایپ پر شیئر کریں'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 5. کاغذات کی جانچ پڑتال (سائن شدہ دستاویزات موصول ہونے کی تصدیق)
                      const Text('5. سائن شدہ کاغذات کی وصولی اور تصدیق:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      CheckboxListTile(
                        title: const Text('شناختی کارڈ کی اصل کاپی چیک کر لی گئی ہے', style: TextStyle(fontSize: 13)),
                        value: _checkCnicVerified,
                        activeColor: Colors.red[800],
                        onChanged: (val) => setState(() => _checkCnicVerified = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                      CheckboxListTile(
                        title: const Text('سائن شدہ اسٹامپ پیپر اور پرا نوٹ وصول ہو گیا ہے', style: TextStyle(fontSize: 13)),
                        value: _checkStampVerified,
                        activeColor: Colors.red[800],
                        onChanged: (val) => setState(() => _checkStampVerified = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                      CheckboxListTile(
                        title: const Text('سائن شدہ سکیورٹی چیک وصول ہو گیا ہے', style: TextStyle(fontSize: 13)),
                        value: _checkSecurityCheckVerified,
                        activeColor: Colors.red[800],
                        onChanged: (val) => setState(() => _checkSecurityCheckVerified = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                      const SizedBox(height: 16),

                      // 6. ڈیل کلوز کریں سیکشن
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: CheckboxListTile(
                          title: const Text('تمام ڈاکومنٹس چیک اور وصول کر لیے گئے ہیں', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          value: _dealClosedChecked,
                          activeColor: Colors.red[800],
                          onChanged: (val) => setState(() => _dealClosedChecked = val ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _dealClosedChecked
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('ڈیل کامیابی سے کلوز ہو گئی!'),
                                      content: const Text('کسٹمر کا اکاؤنٹ ایکٹیو ہو گیا ہے اور اسٹاک تفویض کر دیا گیا ہے۔'),
                                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ٹھیک ہے'))],
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[800],
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('ڈیل کلوز کریں', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}