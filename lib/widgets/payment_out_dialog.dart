import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentOutDialog extends StatefulWidget {
  const PaymentOutDialog({super.key});

  @override
  State<PaymentOutDialog> createState() => _PaymentOutDialogState();
}

class _PaymentOutDialogState extends State<PaymentOutDialog> {
  final TextEditingController _customerNameController = TextEditingController(); 
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _penaltyController = TextEditingController(); 

  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _installmentController = TextEditingController();
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String _transactionType = 'نقد'; 
  String _selectedItem = 'Vivo Y17s'; 
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30)); 
  DateTime _selectedDate = DateTime.now(); 
  double _liveTotal = 0.0;

  String _selectedBank = 'لاکر (Locker)';
  final List<String> _bankList = [
    'لاکر (Locker)',
    'احمد (دستی لین دین)',
    'میزان بینک',
    'ایزی پیسہ',
    'جائز کیش',
    'الائیڈ بینک'
  ];

  String _selectedExpenseCategory = 'دکان کا کرایہ';
  final List<String> _expenseCategories = [
    'دکان کا کرایہ',
    'بجلی کا بل',
    'چائے پانی / کھانا',
    'ملازمین کی تنخواہ',
    'سفری اخراجات',
    'متفرق خرچہ'
  ];

  bool _hasImage = false;
  bool _hasPdf = false;
  bool _hasAudio = false;
  bool _hasVideo = false;

  final List<String> _stockItems = [
    'Vivo Y17s',
    'Samsung A15',
    'Infinix Hot 40',
    'Tecno Spark 20',
    'Realme C67',
    'Redmi 13C',
    'چارجر / ہینڈز فری پیکٹ'
  ];

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_calculateTotal);
    _bankController.addListener(_calculateTotal);
    _penaltyController.addListener(_calculateTotal);

    _totalPriceController.addListener(_calculateSaleTotal);
    _advanceController.addListener(_calculateSaleTotal);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _cashController.dispose();
    _bankController.dispose();
    _penaltyController.dispose();
    _totalPriceController.dispose();
    _advanceController.dispose();
    _installmentController.dispose();
    _imeiController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_transactionType == 'نقد' || _transactionType == 'ایکسپنس') {
      final double cash = double.tryParse(_cashController.text.trim()) ?? 0.0;
      final double bank = double.tryParse(_bankController.text.trim()) ?? 0.0;
      final double penalty = double.tryParse(_penaltyController.text.trim()) ?? 0.0;

      setState(() {
        _liveTotal = cash + bank + penalty;
      });
    }
  }

  void _calculateSaleTotal() {
    if (_transactionType == 'سیل') {
      final double total = double.tryParse(_totalPriceController.text.trim()) ?? 0.0;
      final double advance = double.tryParse(_advanceController.text.trim()) ?? 0.0;

      setState(() {
        _liveTotal = total - advance;
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTxDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _shareOutOnWhatsApp() async {
    String message = "";
    String customer = _customerNameController.text.isEmpty ? 'معزز کسٹمر' : _customerNameController.text;

    if (_transactionType == 'نقد') {
      message = "🧾 *رسید - ادائیگی (Payment Out)*\n"
          "کسٹمر کا نام: $customer\n"
          "تاریخ: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}\n"
          "-------------------\n"
          "کیش ادا کی: ${_cashController.text.isEmpty ? '0' : _cashController.text} روپے\n"
          "بینک بھیجی: ${_bankController.text.isEmpty ? '0' : _bankController.text} روپے ($_selectedBank)\n"
          "جرمانہ / نقصان: ${_penaltyController.text.isEmpty ? '0' : _penaltyController.text} روپے\n"
          "-------------------\n"
          "کل ادا کردہ رقم: *$_liveTotal روپے*\n"
          "تفصیل: ${_detailsController.text.isEmpty ? 'پیمنٹ ادائیگی' : _detailsController.text}\n"
          "شکریہ!";
    } else if (_transactionType == 'سیل') {
      message = "🧾 *رسید - سیل / آئٹم بیچی (Item Sold)*\n"
          "کسٹمر کا نام: $customer\n"
          "تاریخ: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}\n"
          "آئٹم کا نام: $_selectedItem\n"
          "IMEI نمبر: ${_imeiController.text}\n"
          "-------------------\n"
          "کل قیمت: ${_totalPriceController.text} روپے\n"
          "ایڈوانس وصولی: ${_advanceController.text.isEmpty ? '0' : _advanceController.text} روپے\n"
          "قسط کی رقم: ${_installmentController.text} روپے\n"
          "وعدہ تاریخ اگلی قسط: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}\n"
          "-------------------\n"
          "باقی رقم (کھاتہ): *$_liveTotal روپے*\n"
          "تفصیل: ${_detailsController.text.isEmpty ? 'نیا اسمارٹ فون فروخت کیا' : _detailsController.text}\n"
          "شکریہ!";
    } else {
      message = "🧾 *رسید - کاروباری خرچہ (Expense)*\n"
          "کیٹیگری: $_selectedExpenseCategory\n"
          "تاریخ: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}\n"
          "-------------------\n"
          "کیش خرچ: ${_cashController.text.isEmpty ? '0' : _cashController.text} روپے\n"
          "بینک سے خرچ: ${_bankController.text.isEmpty ? '0' : _bankController.text} روپے ($_selectedBank)\n"
          "-------------------\n"
          "کل خرچہ رقم: *$_liveTotal روپے*\n"
          "تفصیل: ${_detailsController.text.isEmpty ? 'کاروباری اخراجات' : _detailsController.text}\n"
          "شکریہ!";
    }
    
    final Uri whatsappUrl = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('واٹس ایپ اوپن کرنے میں مسئلہ آیا یا انسٹال نہیں ہے!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'پیمنٹ ادائیگی / سیل رسید',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  IconButton(
                    icon: const Icon(Icons.reply, size: 30, color: Colors.blue),
                    tooltip: 'واٹس ایپ پر شیئر کریں',
                    onPressed: _shareOutOnWhatsApp,
                  ),
                ],
              ),
              const Divider(),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customerNameController,
                      enabled: _transactionType != 'ایکسپنس', 
                      decoration: InputDecoration(
                        labelText: _transactionType == 'ایکسپنس' ? 'اخراجات کی انٹری' : 'کسٹمر کا نام (ضروری)',
                        border: const UnderlineInputBorder(),
                        prefixIcon: const Icon(Icons.person, color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'تاریخ: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () => _selectTxDate(context),
                        child: const Text('تبدیل کریں', style: TextStyle(fontSize: 12, color: Color(0xFF0D47A1))),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),

              const Text('ادائیگی کی نوعیت منتخب کریں:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _transactionType = 'نقد';
                          _calculateTotal();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _transactionType == 'نقد' ? Colors.red.shade50 : Colors.grey.shade100,
                          border: Border.all(
                            color: _transactionType == 'نقد' ? Colors.red : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text('پیسے دیئے (Out)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _transactionType = 'سیل';
                          _calculateSaleTotal();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _transactionType == 'سیل' ? Colors.red.shade50 : Colors.grey.shade100,
                          border: Border.all(
                            color: _transactionType == 'سیل' ? Colors.red : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text('سیل / قسط (Sale)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _transactionType = 'ایکسپنس';
                          _calculateTotal();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _transactionType == 'ایکسپنس' ? Colors.orange.shade50 : Colors.grey.shade100,
                          border: Border.all(
                            color: _transactionType == 'ایکسپنس' ? Colors.orange : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text('اخراجات (Expense)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.orange))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_transactionType == 'ایکسپنس') ...[
                DropdownButtonFormField<String>(
                  // یہاں value کو اب initialValue سے تبدیل کر دیا گیا ہے (لائن نمبرز کے مطابق)
                  initialValue: _selectedExpenseCategory,
                  decoration: const InputDecoration(
                    labelText: 'ایکسپنس کیٹگری کا انتخاب کریں',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category, color: Colors.orange),
                  ),
                  items: _expenseCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedExpenseCategory = val!;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],

              if (_transactionType == 'نقد' || _transactionType == 'ایکسپنس') ...[
                TextField(
                  controller: _cashController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'کیش رقم ادا کی (Cash Paid)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.wallet, color: Colors.red),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _bankController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'بینک رقم بھیجی (Bank Sent)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance, color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        // یہاں بھی value کو اب initialValue سے تبدیل کر دیا گیا ہے
                        initialValue: _selectedBank,
                        decoration: const InputDecoration(
                          labelText: 'بینک / بندہ',
                          border: OutlineInputBorder(),
                        ),
                        items: _bankList.map((bank) {
                          return DropdownMenuItem(value: bank, child: Text(bank, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedBank = val!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_transactionType == 'نقد') ...[
                  TextField(
                    controller: _penaltyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'جرمانہ / فالتو نقصان (Penalty/Loss)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.gavel, color: Colors.orange),
                    ),
                  ),
                ],
              ] else ...[
                DropdownButtonFormField<String>(
                  // یہاں بھی value کو اب initialValue سے تبدیل کر دیا گیا ہے
                  initialValue: _selectedItem,
                  decoration: const InputDecoration(
                    labelText: 'سٹاک آئٹم کا انتخاب کریں',
                    border: OutlineInputBorder(),
                  ),
                  items: _stockItems.map((item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedItem = val!;
                    });
                  },
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _imeiController,
                  decoration: const InputDecoration(
                    labelText: 'IMEI / سیریل نمبر لکھیں',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phonelink_setup, color: Colors.blueGrey),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _totalPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'کل قیمتِ فروخت',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _advanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ایڈوانس وصولی',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _installmentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'قسط کی رقم',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_clock),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'وعدہ تاریخ (Due Date): ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () => _selectDueDate(context),
                      icon: const Icon(Icons.edit_calendar, color: Colors.red),
                      label: const Text('تبدیل کریں'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              TextField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'تفصیل (Details)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 15),

              const Text('فائل اور ریکارڈنگ اٹیچمنٹس:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.image, color: _hasImage ? Colors.red : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasImage = !_hasImage),
                  ),
                  IconButton(
                    icon: Icon(Icons.picture_as_pdf, color: _hasPdf ? Colors.red : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasPdf = !_hasPdf),
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: _hasAudio ? Colors.blue : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasAudio = !_hasAudio),
                  ),
                  IconButton(
                    icon: Icon(Icons.videocam, color: _hasVideo ? Colors.purple : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasVideo = !_hasVideo),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _transactionType == 'ایکسپنس' ? Colors.orange.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _transactionType == 'ایکسپنس' ? Colors.orange.shade200 : Colors.red.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _transactionType == 'نقد' 
                          ? 'کل ادا کردہ رقم (ٹوٹل ادائیگی):' 
                          : _transactionType == 'سیل'
                              ? 'باقی رقم (جو کھاتے میں چڑھے گی):'
                              : 'کل اخراجات کی رقم (Expense):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 14, 
                        color: _transactionType == 'ایکسپنس' ? Colors.orange.shade900 : Colors.red
                      ),
                    ),
                    Text(
                      'Rs. ${_liveTotal.toStringAsFixed(0)}', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18, 
                        color: _transactionType == 'ایکسپنس' ? Colors.orange.shade900 : Colors.red
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _transactionType == 'ایکسپنس' ? Colors.orange : Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_transactionType != 'ایکسپنس' && _customerNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('برائے مہربانی کسٹمر کا نام درج کریں!')),
                      );
                      return;
                    }
                    if (_liveTotal == 0.0 && (_transactionType == 'نقد' || _transactionType == 'ایکسپنس')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('برائے مہربانی کوئی رقم درج کریں!')),
                      );
                      return;
                    }

                    String details = _detailsController.text.trim();
                    if (_transactionType == 'سیل') {
                      final double total = double.tryParse(_totalPriceController.text.trim()) ?? 0.0;
                      if (total == 0.0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('برائے مہربانی سیل کی کل قیمت درج کریں!')),
                        );
                        return;
                      }
                      if (details.isEmpty) {
                        details = 'فروخت کردہ: $_selectedItem (IMEI: ${_imeiController.text})';
                      }
                    } else if (_transactionType == 'ایکسپنس') {
                      if (details.isEmpty) details = 'کاروباری اخراجات: $_selectedExpenseCategory';
                    } else {
                      if (details.isEmpty) details = 'پیمنٹ ادائیگی';
                    }

                    Navigator.pop(context, {
                      'transaction_type': _transactionType, 
                      'customer_name': _transactionType == 'ایکسپنس' ? 'کاروباری اخراجات' : _customerNameController.text.trim(),
                      'amount': _liveTotal, 
                      'cash_amount': double.tryParse(_cashController.text.trim()) ?? 0.0,
                      'bank_amount': double.tryParse(_bankController.text.trim()) ?? 0.0,
                      'bank_name': _selectedBank,
                      'expense_category': _transactionType == 'ایکسپنس' ? _selectedExpenseCategory : null,
                      'penalty': double.tryParse(_penaltyController.text.trim()) ?? 0.0,
                      'type': 'gave',
                      'date': '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      'details': details,
                      'sale_details': _transactionType == 'سیل' ? {
                        'item_name': _selectedItem,
                        'imei': _imeiController.text.trim(),
                        'total_price': double.tryParse(_totalPriceController.text.trim()) ?? 0.0,
                        'advance': double.tryParse(_advanceController.text.trim()) ?? 0.0,
                        'installment': double.tryParse(_installmentController.text.trim()) ?? 0.0,
                        'due_date': '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      } : null,
                      'attachments': {
                        'image': _hasImage,
                        'pdf': _hasPdf,
                        'audio': _hasAudio,
                        'video': _hasVideo,
                      }
                    });
                  },
                  child: Text(
                    _transactionType == 'ایکسپنس' 
                        ? 'خرچہ محفوظ کریں (Save Expense)' 
                        : 'ادائیگی محفوظ کریں (Save Out)',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}