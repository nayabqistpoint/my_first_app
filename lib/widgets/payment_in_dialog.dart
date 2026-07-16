import 'package:flutter/material.dart';

class PaymentInDialog extends StatefulWidget {
  const PaymentInDialog({super.key});

  @override
  State<PaymentInDialog> createState() => _PaymentInDialogState();
}

class _PaymentInDialogState extends State<PaymentInDialog> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedBank;
  String? _selectedExpenseCat;
  String? _selectedTargetCustomer;

  final List<String> _banks = ['الائیڈ بینک', 'میزان بینک', 'حبیب بینک (HBL)', 'کیش دراز'];
  final List<String> _expenseCategories = ['دکان کا کرایہ', 'بجلی بل', 'چائے پانی / مہمان نوازی', 'ملازم کی تنخواہ'];
  final List<String> _allCustomers = ['احمد کریانہ اسٹور', 'محمد اشرف', 'علی رضا', 'طارق محمود'];

  final _cashController = TextEditingController();
  final _bankController = TextEditingController();
  final _expenseController = TextEditingController();
  final _discountController = TextEditingController();
  final _transferController = TextEditingController();
  final _detailsController = TextEditingController();

  double _calculateTotal() {
    double cash = double.tryParse(_cashController.text) ?? 0.0;
    double bank = double.tryParse(_bankController.text) ?? 0.0;
    double expense = double.tryParse(_expenseController.text) ?? 0.0;
    double discount = double.tryParse(_discountController.text) ?? 0.0;
    double transfer = double.tryParse(_transferController.text) ?? 0.0;
    return cash + bank + expense + discount + transfer;
  }

  @override
  void dispose() {
    _cashController.dispose();
    _bankController.dispose();
    _expenseController.dispose();
    _discountController.dispose();
    _transferController.dispose();
    _detailsController.dispose();
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
                      Icon(Icons.arrow_downward, color: Colors.green, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'پیمنٹ وصولی (Payment IN)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
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
                        hintText: 'تفصیل لکھیں', // یہاں سے وزن وغیرہ ہٹا دیا گیا ہے
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                'ادائیگی کی تفصیل درج کریں (پارشل پیمنٹ):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _cashController,
                label: 'نقد وصولی (Cash IN)',
                icon: Icons.money_outlined,
                color: Colors.green,
              ),
              _buildInputField(
                controller: _bankController,
                label: 'بینک ٹرانسفر (Bank IN)',
                icon: Icons.account_balance,
                color: Colors.blue,
              ),
              if ((double.tryParse(_bankController.text) ?? 0) > 0) ...[
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBank,
                  hint: const Text('بینک منتخب کریں'),
                  items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (val) => setState(() => _selectedBank = val),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              _buildInputField(
                controller: _expenseController,
                label: 'براہ راست خرچہ (Direct Expense)',
                icon: Icons.handyman,
                color: Colors.orange,
              ),
              if ((double.tryParse(_expenseController.text) ?? 0) > 0) ...[
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  initialValue: _selectedExpenseCat,
                  hint: const Text('ایکسپینس کیٹیگری منتخب کریں'),
                  items: _expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedExpenseCat = val),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              _buildInputField(
                controller: _discountController,
                label: 'ڈسکاؤنٹ / رعایت (Discount)',
                icon: Icons.discount_outlined,
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
                  hint: const Text('کسٹمر منتخب کریں جہاں ٹرانسفر کرنے ہیں'),
                  items: _allCustomers.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedTargetCustomer = val),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                const SizedBox(height: 10),
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ٹوٹل وصولی رقم:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                    Text('Rs. ${_calculateTotal().toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('وصولی محفوظ کریں', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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