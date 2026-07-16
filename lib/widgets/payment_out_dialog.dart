import 'package:flutter/material.dart';

class PaymentOutDialog extends StatefulWidget {
  const PaymentOutDialog({super.key});

  @override
  State<PaymentOutDialog> createState() => _PaymentOutDialogState();
}

class _PaymentOutDialogState extends State<PaymentOutDialog> {
  DateTime _selectedDate = DateTime.now();
  String _transactionType = 'money'; 
  String? _selectedBank;
  String? _selectedTargetCustomer;

  final List<String> _banks = ['الائیڈ بینک', 'میزان بینک', 'حبیب بینک (HBL)', 'کیش دراز'];
  final List<String> _allCustomers = ['احمد کریانہ اسٹور', 'محمد اشرف', 'علی رضا', 'طارق محمود'];

  final _cashController = TextEditingController();
  final _bankController = TextEditingController();
  final _discountController = TextEditingController();
  final _transferController = TextEditingController();
  final _detailsController = TextEditingController();

  // سیلز کے نئے کنٹرولرز (ایڈوانس اور قسط سمیت)
  final _mobileModelController = TextEditingController();
  final _imeiController = TextEditingController();
  final _totalPriceController = TextEditingController(); // کل رقم
  final _advanceController = TextEditingController();    // ایڈوانس رقم
  final _installmentController = TextEditingController(); // قسط کی رقم

  double _calculateTotal() {
    if (_transactionType == 'sale') {
      // سیل کی صورت میں کل رقم ہی شو ہوگی
      return double.tryParse(_totalPriceController.text) ?? 0.0;
    }
    double cash = double.tryParse(_cashController.text) ?? 0.0;
    double bank = double.tryParse(_bankController.text) ?? 0.0;
    double discount = double.tryParse(_discountController.text) ?? 0.0;
    double transfer = double.tryParse(_transferController.text) ?? 0.0;
    return cash + bank + discount + transfer;
  }

  @override
  void dispose() {
    _cashController.dispose();
    _bankController.dispose();
    _discountController.dispose();
    _transferController.dispose();
    _detailsController.dispose();
    _mobileModelController.dispose();
    _imeiController.dispose();
    _totalPriceController.dispose();
    _advanceController.dispose();
    _installmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.red, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'ادائیگی / سیل (Payment OUT)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _transactionType == 'money' ? Colors.red.shade50 : Colors.white,
                        side: BorderSide(color: _transactionType == 'money' ? Colors.red : Colors.grey.shade300),
                      ),
                      onPressed: () => setState(() => _transactionType = 'money'),
                      child: Text('پیسے دیئے (Cash Out)', style: TextStyle(color: _transactionType == 'money' ? Colors.red : Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _transactionType == 'sale' ? Colors.blue.shade50 : Colors.white,
                        side: BorderSide(color: _transactionType == 'sale' ? Colors.blue : Colors.grey.shade300),
                      ),
                      onPressed: () => setState(() => _transactionType = 'sale'),
                      child: Text('موبائل بیچا (Sold Item)', style: TextStyle(color: _transactionType == 'sale' ? Colors.blue : Colors.black)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _detailsController,
                      decoration: const InputDecoration(
                        hintText: 'تفصیل / ریمارکس لکھیں',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              if (_transactionType == 'money') ...[
                const Text('ادائیگی کا سورس منتخب کریں:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _cashController,
                  label: 'کیش دراز سے دیا (Cash Out)',
                  icon: Icons.money_off_outlined,
                  color: Colors.red,
                ),
                _buildInputField(
                  controller: _bankController,
                  label: 'بینک اکاؤنٹ سے دیا (Bank Out)',
                  icon: Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
                if ((double.tryParse(_bankController.text) ?? 0) > 0) ...[
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBank,
                    hint: const Text('بینک منتخب کریں جہاں سے دیا'),
                    items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (val) => setState(() => _selectedBank = val),
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                  ),
                  const SizedBox(height: 10),
                ],
                _buildInputField(
                  controller: _discountController,
                  label: 'ڈسکاؤنٹ ملا (Discount Received)',
                  icon: Icons.card_giftcard,
                  color: Colors.purple,
                ),
                _buildInputField(
                  controller: _transferController,
                  label: 'پارٹی ٹرانسفر (Party Transfer)',
                  icon: Icons.swap_horiz,
                  color: Colors.teal,
                ),
                if ((double.tryParse(_transferController.text) ?? 0) > 0) ...[
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTargetCustomer,
                    hint: const Text('کسٹمر منتخب کریں جہاں ٹرانسفر ہوا'),
                    items: _allCustomers.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedTargetCustomer = val),
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                  ),
                  const SizedBox(height: 10),
                ],
              ] else ...[
                const Text('موبائل سیل کی تفصیلات درج کریں:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                TextField(
                  controller: _mobileModelController,
                  decoration: const InputDecoration(
                    labelText: 'موبائل ماڈل کا نام',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _imeiController,
                  decoration: const InputDecoration(
                    labelText: 'سیریل نمبر / IMEI نمبر (وارنٹی کے لیے)',
                    prefixIcon: Icon(Icons.qr_code),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // کل رقم (Total Price)
                TextField(
                  controller: _totalPriceController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'ٹوٹل رقم (Rs.)',
                    prefixIcon: Icon(Icons.calculate),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // ایڈوانس رقم (Advance)
                TextField(
                  controller: _advanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ایڈوانس رقم (Rs.)',
                    prefixIcon: Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // قسط رقم (Installment Amount)
                TextField(
                  controller: _installmentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'قسط کی رقم (Rs.)',
                    prefixIcon: Icon(Icons.schedule),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mic, color: Colors.red),
                    label: const Text('وائس نوٹ ثبوت', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.blueGrey),
                    label: const Text('رسید / پی ڈی ایف', style: TextStyle(color: Colors.blueGrey)),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ٹوٹل رقم:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)), // یہاں "کھاتا رقم" ہٹا کر صرف "ٹوٹل رقم" کر دیا گیا ہے
                    Text('Rs. ${_calculateTotal().toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('محفوظ کریں', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: color),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
    );
  }
}