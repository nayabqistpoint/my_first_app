import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'calculater_controller.dart'; 
import 'calculater_config.dart';

class CalculaterHeader extends StatefulWidget {
  final Function(Map<String, dynamic>)? onDataChanged;

  const CalculaterHeader({super.key, this.onDataChanged});

  @override
  State<CalculaterHeader> createState() => _CalculaterHeaderState();
}

class _CalculaterHeaderState extends State<CalculaterHeader> {
  int _selectedMode = 1; // 1: دستیاب سٹاک سے, 2: اپنی مرضی سے
  String? _selectedStockMobile;
  final TextEditingController _manualModelController = TextEditingController();
  
  // ان پٹس کے کنٹرولرز تاکہ ڈیٹا کو باہر بھیجا جا سکے
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _manualTotalController = TextEditingController();
  final TextEditingController _checkNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  
  final List<String> _dummyStockMobiles = [
    'Samsung Galaxy A15',
    'Xiaomi Redmi Note 13',
    'Infinix Hot 40 Pro',
    'Tecno Spark 20 Pro',
    'Realme C67',
  ];

  void _notifyDataChanged() {
    if (widget.onDataChanged != null) {
      String mobileName = _selectedMode == 1 
          ? (_selectedStockMobile ?? '') 
          : _manualModelController.text;

      widget.onDataChanged!({
        'mobileName': mobileName,
        'advanceAmount': _advanceController.text,
        'imei': _imeiController.text,
        'color': _colorController.text,
        'totalAmount': _manualTotalController.text,
        'checkNumber': _checkNumberController.text,
        'bankName': _bankNameController.text,
      });
    }
  }

  @override
  void dispose() {
    _manualModelController.dispose();
    _advanceController.dispose();
    _imeiController.dispose();
    _colorController.dispose();
    _manualTotalController.dispose();
    _checkNumberController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CalculaterController>(context);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            color: const Color(0xFFE53935),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("قسط کیلکولیٹر", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text("نایاب قسط پوائنٹ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // ماڈرن اور وارننگز سے پاک SegmentedButton موڈ سلیکشن
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment<int>(
                        value: 1,
                        label: Text("دستیاب سٹاک سے", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      ButtonSegment<int>(
                        value: 2,
                        label: Text("اپنی مرضی (مینول)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    selected: {_selectedMode},
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() {
                        _selectedMode = newSelection.first;
                        if (_selectedMode == 1) {
                          _selectedStockMobile = null;
                          _manualModelController.clear();
                          _manualTotalController.clear();
                          controller.setTotalAmount("0");
                        } else {
                          _selectedStockMobile = null;
                          _advanceController.clear();
                          controller.setAdvanceAmount("0");
                        }
                        _notifyDataChanged();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // موڈ 1: دستیاب سٹاک سے انتخاب
                if (_selectedMode == 1) ...[
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text("دستیاب سٹاک سے موبائل منتخب کریں", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                        value: _selectedStockMobile,
                        items: _dummyStockMobiles.map((String mobile) {
                          return DropdownMenuItem<String>(
                            value: mobile,
                            child: Text(mobile, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStockMobile = newValue;
                            _notifyDataChanged();
                          });
                        },
                      ),
                    ),
                  ),
                  
                  // جب موبائل سلیکٹ ہو جائے تو دوسری لائن میں: ایڈوانس، آئی ایم ای آئی، کلر
                  if (_selectedStockMobile != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _advanceController,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                controller.setAdvanceAmount(value);
                                _notifyDataChanged();
                              },
                              decoration: const InputDecoration(
                                hintText: "ایڈوانس",
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _imeiController,
                              textAlign: TextAlign.center,
                              onChanged: (value) => _notifyDataChanged(),
                              decoration: const InputDecoration(
                                hintText: "IMEI نمبر",
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _colorController,
                              textAlign: TextAlign.center,
                              onChanged: (value) => _notifyDataChanged(),
                              decoration: const InputDecoration(
                                hintText: "کلر",
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],

                // موڈ 2: اپنی مرضی سے انتخاب (مینول)
                if (_selectedMode == 2) ...[
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _manualModelController,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        setState(() {});
                        _notifyDataChanged();
                      },
                      decoration: const InputDecoration(
                        hintText: "موبائل کا نام اور ماڈل لکھیں",
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  
                  // جب ماڈل کا نام لکھا جائے تو دوسری لائن میں: نقد قیمت اور ایڈوانس
                  if (_manualModelController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _manualTotalController,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                controller.setTotalAmount(value);
                                _notifyDataChanged();
                              },
                              decoration: const InputDecoration(
                                hintText: "نقد قیمت",
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _advanceController,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                controller.setAdvanceAmount(value);
                                _notifyDataChanged();
                              },
                              decoration: const InputDecoration(
                                hintText: "ایڈوانس",
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
                
                Consumer<CalculaterController>(
                  builder: (context, controller, child) {
                    final message = controller.getValidationMessage();
                    if (message == null) return const SizedBox.shrink(); 
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // سوئچ والا حصہ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "کیا آپ نے رعایت کے لیے سیکیورٹی چیک مہیا کیا ہے؟",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Switch(
                      value: controller.hasSecurityCheck,
                      onChanged: (bool value) => controller.toggleSecurityCheck(value),
                      activeTrackColor: Colors.blue.withValues(alpha: 0.5),
                      activeThumbColor: Colors.blue,
                    ),
                  ],
                ),
                
                // جب سوئچ آن ہو تو چیک نمبر اور بینک کا نام
                if (controller.hasSecurityCheck) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _checkNumberController,
                            textAlign: TextAlign.center,
                            onChanged: (value) => _notifyDataChanged(),
                            decoration: const InputDecoration(
                              hintText: "چیک نمبر",
                              contentPadding: EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _bankNameController,
                            textAlign: TextAlign.center,
                            onChanged: (value) => _notifyDataChanged(),
                            decoration: const InputDecoration(
                              hintText: "بینک کا نام",
                              contentPadding: EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),

                InkWell(
                  onTap: () async {
                    final Uri launchUri = Uri(scheme: 'tel', path: CalculaterConfig.contactNumber);
                    await launchUrl(launchUri);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "رابطہ: ${CalculaterConfig.contactName} - ${CalculaterConfig.contactNumber}",
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline),
                    ),
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