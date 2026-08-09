import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DiscountWidget extends StatefulWidget {
  final Function(String categoryName, double discountValue, bool isPercentage) onDiscountChanged;

  const DiscountWidget({
    super.key,
    required this.onDiscountChanged,
  });

  /// 🔥 'expenseBox' میں ڈیٹا کی نیو Map ساخت کے مطابق ریکارڈنگ 🔥
  static void recordDiscountInHive({
    required String categoryName,
    required double amount,
  }) {
    if (amount <= 0 || categoryName.isEmpty) return;

    if (Hive.isBoxOpen('expenseBox')) {
      final box = Hive.box('expenseBox');
      var rawVal = box.get(categoryName);

      double currentTotal = 0.0;
      bool isIncome = categoryName.trim().toLowerCase() == 'other income';

      if (rawVal is Map) {
        currentTotal = (rawVal['amount'] ?? 0.0).toDouble();
        isIncome = rawVal['isIncome'] ?? isIncome;
      } else if (rawVal is num) {
        currentTotal = rawVal.toDouble();
      }

      box.put(categoryName, {
        'amount': currentTotal + amount,
        'isIncome': isIncome,
      });
    }
  }

  @override
  State<DiscountWidget> createState() => _DiscountWidgetState();
}

class _DiscountWidgetState extends State<DiscountWidget> {
  final TextEditingController _discountController = TextEditingController();
  bool _isPercentage = false;
  String _selectedCategory = 'Discounts';

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _updateDiscount() {
    final value = double.tryParse(_discountController.text) ?? 0.0;
    widget.onDiscountChanged(_selectedCategory, value, _isPercentage);
  }

  // کیٹیگری کی نوعیت (Income/Expense) معلوم کرنے کا ہیلپر
  bool _checkIsIncome(Box box, String catName) {
    var raw = box.get(catName);
    if (raw is Map) {
      return raw['isIncome'] ?? false;
    }
    return catName.trim().toLowerCase() == 'other income';
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('expenseBox')) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('expenseBox').listenable(),
      builder: (context, box, child) {
        List<String> categories = box.keys.map((e) => e.toString()).toList();

        if (!categories.contains('Discounts')) categories.add('Discounts');
        if (!categories.contains('Other Income')) categories.add('Other Income');

        if (!categories.contains(_selectedCategory)) {
          _selectedCategory = categories.first;
        }

        bool selectedIsIncome = _checkIsIncome(box, _selectedCategory);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 🔥 آئیکن کا کلر نوعیت کے حساب سے (Green / Red) 🔥
              Icon(
                Icons.local_offer_outlined,
                size: 16,
                color: selectedIsIncome ? Colors.green[700] : const Color(0xFFE53935),
              ),
              const SizedBox(width: 4),

              // 🔥 ڈراپ ڈاؤن لسٹ کے تمام ائٹمز اور سلیکٹڈ ٹیکسٹ پر کلر ڈسکریمینیشن 🔥
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isDense: true,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: selectedIsIncome ? Colors.green[800] : Colors.red[800],
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 18),
                  items: categories.map((String category) {
                    bool isIncome = _checkIsIncome(box, category);
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isIncome ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                        _updateDiscount();
                      });
                    }
                  },
                ),
              ),

              const Spacer(),

              // ٹوگل سوئچ (Rs / %)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(value: false, label: Text('Rs', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
                    ButtonSegment<bool>(value: true, label: Text('%', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
                  ],
                  selected: {_isPercentage},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _isPercentage = newSelection.first;
                      _updateDiscount();
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return selectedIsIncome ? Colors.green[700]! : const Color(0xFFE53935);
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) return Colors.white;
                      return Colors.black87;
                    }),
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // ان پٹ فیلڈ
              SizedBox(
                width: 70,
                height: 32,
                child: TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateDiscount(),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: const TextStyle(fontSize: 10),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(
                        color: selectedIsIncome ? Colors.green[700]! : const Color(0xFFE53935),
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}