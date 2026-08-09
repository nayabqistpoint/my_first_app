import 'package:flutter/material.dart';

class ConditionSelectorWidget extends StatefulWidget {
  final String selectedCondition;
  final ValueChanged<String> onConditionChanged;
  final TextEditingController nameController;
  final TextEditingController imeiController;
  final TextEditingController colorController; // کلر کے لیے ٹیکسٹ کنٹرولر
  final String? selectedColor;
  final ValueChanged<String?> onColorChanged;
  final int selectedWarrantyMonths;
  final ValueChanged<int?> onWarrantyChanged;

  const ConditionSelectorWidget({
    super.key,
    required this.selectedCondition,
    required this.onConditionChanged,
    required this.nameController,
    required this.imeiController,
    required this.colorController,
    required this.selectedColor,
    required this.onColorChanged,
    required this.selectedWarrantyMonths,
    required this.onWarrantyChanged,
  });

  @override
  State<ConditionSelectorWidget> createState() => _ConditionSelectorWidgetState();
}

class _ConditionSelectorWidgetState extends State<ConditionSelectorWidget> {
  bool isCustomColor = false; // چیک کرنے کے لیے کہ آیا یوزر نے مینوئل لکھنا ہے

  @override
  Widget build(BuildContext context) {
    // اردو اور انگلش کلر لسٹ
    final List<String> commonColors = [
      'بلیک (Black)',
      'وائٹ (White)',
      'گولڈ (Gold)',
      'سلور (Silver)',
      'بلیو (Blue)',
      'گرین (Green)',
      'ریڈ (Red)',
      'پرپل (Purple)',
      'دیگر (Other - خود لکھیں)'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. آئٹم کی قسم (نیا یا پرانا / یوزڈ)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('آئٹم کی قسم: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('نیا (New)', style: TextStyle(fontSize: 12)),
                selected: widget.selectedCondition == 'new',
                selectedColor: Colors.red.shade100,
                labelStyle: TextStyle(
                  color: widget.selectedCondition == 'new' ? Colors.red.shade800 : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (bool selected) {
                  if (selected) widget.onConditionChanged('new');
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('پرانا (Old)', style: TextStyle(fontSize: 12)),
                selected: widget.selectedCondition == 'old',
                selectedColor: Colors.red.shade100,
                labelStyle: TextStyle(
                  color: widget.selectedCondition == 'old' ? Colors.red.shade800 : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (bool selected) {
                  if (selected) widget.onConditionChanged('old');
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. پہلی لائن: موبائل کا نام اور IMEI نمبر
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'موبائل کا نام / ماڈل',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: widget.imeiController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'IMEI نمبر',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. دوسری لائن: کلر (ڈراپ ڈاؤن + مینوئل لکھنے کی سہولت) اور وارنٹی ڈراپ ڈاؤن
        Row(
          children: [
            // کلر والا باکس (اگر 'دیگر' سلیکٹ ہو تو ٹیکسٹ فیلڈ کھل جائے گا)
            Expanded(
              child: isCustomColor
                  ? TextField(
                      controller: widget.colorController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'کلر خود لکھیں',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_back, size: 18),
                          onPressed: () {
                            setState(() {
                              isCustomColor = false;
                            });
                          },
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('کلر:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          DropdownButton<String>(
                            value: commonColors.contains(widget.selectedColor) ? widget.selectedColor : null,
                            hint: const Text('منتخب کریں', style: TextStyle(fontSize: 12)),
                            underline: const SizedBox(),
                            dropdownColor: Colors.white,
                            isDense: true,
                            items: commonColors.map((String color) {
                              return DropdownMenuItem<String>(
                                value: color,
                                child: Text(color, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val == 'دیگر (Other - خود لکھیں)') {
                                setState(() {
                                  isCustomColor = true;
                                });
                              } else {
                                widget.onColorChanged(val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(width: 10),

            // وارنٹی ڈراپ ڈاؤن
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('وارنٹی:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    DropdownButton<int>(
                      value: widget.selectedWarrantyMonths,
                      underline: const SizedBox(),
                      dropdownColor: Colors.white,
                      isDense: true,
                      items: List.generate(13, (index) {
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(
                            index == 0 ? 'کوئی نہیں' : '$index ماہ',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        );
                      }),
                      onChanged: widget.onWarrantyChanged,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}