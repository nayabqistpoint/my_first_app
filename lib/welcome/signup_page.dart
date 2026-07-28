import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  bool _hasGuarantor = false;
  bool _hasSecurityCheck = false;
  
  // اقرار نامے اور اسکرول کی حالت
  bool _isCheckedTerms = false;
  bool _hasScrolledToBottom = false;
  final ScrollController _termsScrollController = ScrollController();

  // کسٹمر سیلفی کے لیے
  String? _customerSelfiePath;

  // پیکج اور اسٹاک کے ویری ایبلز
  String? _selectedPackageType;
  String? _selectedStockItem;

  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _advanceAmountController = TextEditingController();
  final TextEditingController _itemModelController = TextEditingController();
  
  final TextEditingController _checkNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  // کسٹمر کے کوائف
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _casteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // ضامن کے کوائف
  final TextEditingController _guarantorNameController = TextEditingController();
  final TextEditingController _guarantorFatherNameController = TextEditingController();
  final TextEditingController _guarantorCasteController = TextEditingController();
  final TextEditingController _guarantorPhoneController = TextEditingController();
  final TextEditingController _guarantorCnicController = TextEditingController();
  final TextEditingController _guarantorAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _termsScrollController.addListener(() {
      if (_termsScrollController.position.pixels >=
          _termsScrollController.position.maxScrollExtent - 20) {
        if (!_hasScrolledToBottom) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _termsScrollController.dispose();
    _nameController.dispose();
    _fatherNameController.dispose();
    _casteController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _addressController.dispose();
    _itemModelController.dispose();
    _itemPriceController.dispose();
    _advanceAmountController.dispose();
    _checkNumberController.dispose();
    _bankNameController.dispose();
    _guarantorNameController.dispose();
    _guarantorFatherNameController.dispose();
    _guarantorCasteController.dispose();
    _guarantorPhoneController.dispose();
    _guarantorCnicController.dispose();
    _guarantorAddressController.dispose();
    super.dispose();
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      var customerBox = Hive.box('customerBox');

      Map<String, dynamic> requestData = {
        'name': _nameController.text,
        'fatherName': _fatherNameController.text,
        'caste': _casteController.text,
        'phone': _phoneController.text,
        'cnic': _cnicController.text,
        'address': _addressController.text,
        'customerSelfie': _customerSelfiePath ?? '',
        'itemModel': _selectedStockItem ?? _itemModelController.text,
        'itemPrice': _itemPriceController.text,
        'packageType': _selectedPackageType,
        'advanceAmount': _advanceAmountController.text,
        'hasStampPaper': true, 
        'hasCheck': _hasSecurityCheck,
        'bankName': _bankNameController.text,
        'checkNumber': _checkNumberController.text,
        'hasGuarantor': _hasGuarantor,
        'guarantorName': _guarantorNameController.text,
        'guarantorFatherName': _guarantorFatherNameController.text,
        'guarantorCaste': _guarantorCasteController.text,
        'guarantorPhone': _guarantorPhoneController.text,
        'guarantorCnic': _guarantorCnicController.text,
        'guarantorAddress': _guarantorAddressController.text,
        'status': 'Pending',
        'timestamp': DateTime.now().toString(),
      };

      await customerBox.add(requestData);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تصویر / ڈیٹا محفوظ ہو گیا'),
          content: const Text('یو آئی کا یہ فارم کامیابی سے سیو ہو گیا ہے۔'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState!.reset();
              },
              child: const Text('ٹھیک ہے'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> availableStockItems = [
      'Vivo Y20 (دستیاب اسٹاک)',
      'Samsung Galaxy A12 (دستیاب اسٹاک)',
      'Oppo A54 (دستیاب اسٹاک)',
      'Xiaomi Redmi 9T (دستیاب اسٹاک)',
      'Infinix Hot 10 (دستیاب اسٹاک)'
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: const Text('نیا کسٹمر رجسٹریشن (UI Layout)', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _submitData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'لی آؤٹ محفوظ کریں',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            
            // 1. کسٹمر کی ذاتی معلومات
            _buildSectionHeader('1. کسٹمر کی ذاتی معلومات', Icons.person),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField('کسٹمر کا پورا نام', Icons.badge, controller: _nameController),
                    const SizedBox(height: 12),
                    _buildTextField('والد / شوہر کا نام', Icons.person_outline, controller: _fatherNameController),
                    const SizedBox(height: 12),
                    _buildTextField('قوم (مثلاً: آرائیں، بلوچ، ملک)', Icons.group, controller: _casteController),
                    const SizedBox(height: 12),
                    _buildTextField('موبائل نمبر', Icons.phone, controller: _phoneController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _buildTextField('شناختی کارڈ نمبر (CNIC)', Icons.credit_card, controller: _cnicController, keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    _buildTextField('مکمل گھر کا پتہ', Icons.home, controller: _addressController),
                    const SizedBox(height: 14),

                    // سیلفی والا کیمرہ سیکشن
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.camera_alt, color: Colors.red),
                              SizedBox(width: 8),
                              Text('کسٹمر کی لائیو سیلفی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _customerSelfiePath = 'selfie_captured_dummy.jpg';
                              });
                            },
                            icon: const Icon(Icons.camera, size: 16),
                            label: Text(_customerSelfiePath == null ? 'تصویر لیں' : 'تصویر موجود ہے'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. سکیورٹی (اسٹامپ، پرا نوٹ اور چیک)
            _buildSectionHeader('2. سکیورٹی اور قانونی دستاویزات', Icons.verified_user),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'نوٹ: اسٹامپ پیپر اور پرا نوٹ ہر ٹرانزیکشن کے لیے لازمی ہیں۔',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('کیا کسٹمر نے ایڈوانس چیک دیا ہے؟', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      value: _hasSecurityCheck,
                      activeThumbColor: Colors.red[800],
                      onChanged: (bool value) {
                        setState(() {
                          _hasSecurityCheck = value;
                        });
                      },
                    ),

                    if (_hasSecurityCheck) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            _buildTextField('بینک کا نام', Icons.account_balance, controller: _bankNameController),
                            const SizedBox(height: 10),
                            _buildTextField('چیک نمبر', Icons.confirmation_number, controller: _checkNumberController, keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. آئٹم اور پیکج کا انتخاب (اسٹاک ڈراپ ڈاؤن کے ساتھ)
            _buildSectionHeader('3. آئٹم اور قسط کا پیکج', Icons.shopping_bag),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // اسٹاک سے انتخاب کرنے کا ڈراپ ڈاؤن
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStockItem,
                      hint: const Text('دستیاب اسٹاک سے موبائل منتخب کریں'),
                      decoration: InputDecoration(
                        labelText: 'دکان کا موجودہ اسٹاک',
                        prefixIcon: Icon(Icons.inventory_2, color: Colors.red[800]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: availableStockItems.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStockItem = newValue;
                          if (newValue != null) {
                            _itemModelController.text = newValue;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildTextField('یا اپنی مرضی کا آئٹم / ماڈل لکھیں', Icons.phone_android, controller: _itemModelController),
                    const SizedBox(height: 12),
                    _buildTextField('آئٹم کی اصل نقد قیمت', Icons.money, controller: _itemPriceController, keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPackageType,
                      hint: const Text('پیکج کی مدت منتخب کریں'),
                      decoration: InputDecoration(
                        labelText: 'قسط کا پیکج',
                        prefixIcon: Icon(Icons.calendar_month, color: Colors.red[800]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: <String>[
                        'چھ ماہ کا پیکج (معیاری)',
                        'سات ماہ کا پیکج',
                        'آٹھ ماہ کا پیکج',
                        'نو ماہ کا پیکج',
                        'دس ماہ کا پیکج',
                        'بارہ ماہ کا پیکج'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPackageType = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField('ادائیگی کا ایڈوانس (اگر ہے)', Icons.payment, controller: _advanceAmountController, keyboardType: TextInputType.number),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. ضامن کی معلومات
            _buildSectionHeader('4. ضامن کی معلومات', Icons.people),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('کیا اس کیس میں ضامن شامل ہے؟', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      value: _hasGuarantor,
                      activeThumbColor: Colors.red[800],
                      onChanged: (bool value) {
                        setState(() {
                          _hasGuarantor = value;
                        });
                      },
                    ),

                    if (_hasGuarantor) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            _buildTextField('ضامن کا نام', Icons.person_outline, controller: _guarantorNameController),
                            const SizedBox(height: 10),
                            _buildTextField('ضامن کے والد / شوہر کا نام', Icons.person, controller: _guarantorFatherNameController),
                            const SizedBox(height: 10),
                            _buildTextField('ضامن کی قوم', Icons.group, controller: _guarantorCasteController),
                            const SizedBox(height: 10),
                            _buildTextField('ضامن کا فون نمبر', Icons.phone, controller: _guarantorPhoneController, keyboardType: TextInputType.phone),
                            const SizedBox(height: 10),
                            _buildTextField('ضامن کا شناختی کارڈ (CNIC)', Icons.credit_card, controller: _guarantorCnicController, keyboardType: TextInputType.number),
                            const SizedBox(height: 10),
                            _buildTextField('ضامن کا پتہ اور رشتہ', Icons.location_on, controller: _guarantorAddressController),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 5. اسکرولیبل اقرار نامہ
            _buildSectionHeader('5. اقرار نامہ اور ضابطہ اخلاق', Icons.gavel),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'براہ کرم درج ذیل بیان حلفی اور شرائط کو آخر تک پڑھیں:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 140,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Scrollbar(
                        controller: _termsScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _termsScrollController,
                          child: const Text(
                            'میں ہوش و حواس میں اقرار کرتا/کرتی ہوں کہ میں یہ موبائل قسطوں پر لے رہا/رہی ہوں۔ تمام درج کردہ کوائف بشمول نام، ولدیت اور قوم سو فیصد درست ہیں۔ میں بروقت ماہانہ قسط ادا کرنے کا مکمل پابند ہوں۔ کسی بھی تنازع یا خلاف ورزی کی صورت میں معاملہ عدالت جانے کے بجائے ہمارے پہلے سے طے شدہ ثالثوں کے بورڈ کے سامنے پیش کیا جائے گا، اور ثالثی ایکٹ کے تحت فیصلہ صادر ہوگا۔ تمام شرائط و ضوابط مجھ پر لازم ہوں گے۔ (براہ کرم اس عبارت کو آخر تک اسکرول کریں)',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: const Text('میں نے شرائط پڑھ لی ہیں اور ان سے متفق ہوں', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      value: _isCheckedTerms,
                      activeColor: Colors.red[800],
                      onChanged: _hasScrolledToBottom
                          ? (bool? value) {
                              setState(() {
                                _isCheckedTerms = value ?? false;
                              });
                            }
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (!_hasScrolledToBottom)
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Text(
                          'چیک باکس کو فعال کرنے کے لیے اوپر دیے گئے اقرار نامے کو آخر تک اسکرول کریں',
                          style: TextStyle(color: Colors.red, fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.red[800], size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red[800],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, {TextEditingController? controller, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red[800], size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}