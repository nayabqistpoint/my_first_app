import 'package:flutter/material.dart';

class PaymentSourceSelector extends StatelessWidget {
  final TextEditingController cashController;
  final TextEditingController bankController;
  final TextEditingController otherIncomeController;
  final String? selectedBank;
  final List<String> registeredBanks; 
  final ValueChanged<String?> onBankChanged;

  const PaymentSourceSelector({
    super.key,
    required this.cashController,
    required this.bankController,
    required this.otherIncomeController,
    required this.selectedBank,
    required this.registeredBanks,
    required this.onBankChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ادائیگی کے ذرائع (Payment Sources)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
        ),
        const SizedBox(height: 12),
        
        // تینوں فیلڈز اب ایک ہی رو (Row) میں چھوٹے سائز میں نظر آئیں گی
        Row(
          children: [
            Expanded(
              child: _buildSmallTextField(
                controller: cashController,
                label: 'کیش ادائیگی',
                icon: Icons.money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallTextField(
                controller: bankController,
                label: 'بینک ادائیگی',
                icon: Icons.account_balance,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallTextField(
                controller: otherIncomeController,
                label: 'دیگر آمدن',
                icon: Icons.account_balance_wallet,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // بینک سلیکشن کا چھوٹا ڈراپ ڈاؤن
        Row(
          children: [
            const Text(
              'ادائیگی بینک اکاؤنٹ:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBank,
                    hint: const Text('بینک منتخب کریں', style: TextStyle(fontSize: 12)),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E3A8A)),
                    items: registeredBanks.map((bank) {
                      return DropdownMenuItem<String>(
                        value: bank,
                        child: Text(bank, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: onBankChanged,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        prefixIcon: Icon(icon, color: color, size: 18),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}