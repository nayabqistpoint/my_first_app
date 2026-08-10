import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  String? _selectedStockKey; // ہائیو کی یونیک کی یا IMEI
  String? _selectedStockMobileName;

  final TextEditingController _manualModelController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _manualTotalController = TextEditingController();
  final TextEditingController _checkNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  void _notifyDataChanged(CalculaterController controller) {
    if (widget.onDataChanged != null) {
      String mobileName = _selectedMode == 1 
          ? (_selectedStockMobileName ?? '') 
          : _manualModelController.text;

      widget.onDataChanged!({
        'mobileName': mobileName,
        'cashPrice': controller.totalAmount.toStringAsFixed(0),
        'advanceAmount': _advanceController.text,
        'imei': _imeiController.text,
        'totalAmount': controller.totalAmount.toStringAsFixed(0),
        'checkNumber': _checkNumberController.text,
        'bankName': _bankNameController.text,
        'isBuyStockMode': _selectedMode == 1,
      });
    }
  }

  @override
  void dispose() {
    _manualModelController.dispose();
    _advanceController.dispose();
    _imeiController.dispose();
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
                // موڈ سلیکشن
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
                        _selectedStockKey = null;
                        _selectedStockMobileName = null;
                        _manualModelController.clear();
                        _manualTotalController.clear();
                        _advanceController.clear();
                        _imeiController.clear();
                        controller.setTotalAmount("0");
                        controller.setAdvanceAmount("0");
                        _notifyDataChanged(controller);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // موڈ 1: دستیاب سٹاک سے انتخاب (ڈائریکٹ ڈراپ ڈاؤن کارڈ لے آؤٹ)
                if (_selectedMode == 1) ...[
                  ValueListenableBuilder(
                    valueListenable: Hive.box('stockBox').listenable(),
                    builder: (context, Box box, _) {
                      // صرف 'available' اسٹیٹس والے آئٹمز فلٹر کرنا
                      final availableItems = box.keys.map((key) {
                        final val = box.get(key);
                        if (val is Map) {
                          final data = Map<String, dynamic>.from(val);
                          data['hiveKey'] = key.toString();
                          return data;
                        }
                        return null;
                      }).where((element) {
                        if (element == null) return false;
                        return (element['status']?.toString() ?? 'available') == 'available';
                      }).toList();

                      if (availableItems.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              "اسٹاک میں کوئی موبائل دستیاب نہیں ہے",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        initialValue: _selectedStockKey,
                        isExpanded: true,
                        itemHeight: 65,
                        decoration: InputDecoration(
                          hintText: "دستیاب سٹاک سے موبائل منتخب کریں",
                          hintStyle: const TextStyle(fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                        selectedItemBuilder: (context) {
                          return availableItems.map((item) {
                            final name = item!['itemName']?.toString() ?? '';
                            final imei = item['imeiNo']?.toString() ?? '';
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$name ${imei.isNotEmpty ? "($imei)" : ""}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList();
                        },
                        items: availableItems.map((item) {
                          final key = item!['hiveKey'].toString();
                          final name = item['itemName']?.toString() ?? 'نامعلوم';
                          final imei = item['imeiNo']?.toString() ?? 'کوئی IMEI نہیں';
                          final ram = item['ram']?.toString() ?? '';
                          final rom = item['rom']?.toString() ?? '';
                          final cond = item['condition']?.toString() == 'new' ? 'نیا' : 'پرانا';
                          final war = '${item['warranty'] ?? 0} ماہ';

                          return DropdownMenuItem<String>(
                            value: key,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04), // اصلاح: withValues کا استعمال
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // بائیں طرف: موبائل کا نام اور IMEI
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'IMEI: $imei',
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // دائیں طرف: RAM/ROM، New/Old اور وارنٹی
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            ram.isNotEmpty ? '$ram / $rom' : 'N/A',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$cond | $war',
                                          style: TextStyle(fontSize: 9, color: Colors.grey.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? selectedKey) {
                          if (selectedKey == null) return;

                          final selectedData = availableItems.firstWhere(
                            (element) => element!['hiveKey'] == selectedKey,
                          );

                          if (selectedData != null) {
                            setState(() {
                              _selectedStockKey = selectedKey;
                              _selectedStockMobileName = selectedData['itemName']?.toString() ?? '';
                              _imeiController.text = selectedData['imeiNo']?.toString() ?? '';

                              // اسٹاک کی قیمتِ فروخت کو کنٹرولر میں سیٹ کرنا
                              String salePrice = selectedData['salePrice']?.toString() ?? '0';
                              controller.setTotalAmount(salePrice);

                              _notifyDataChanged(controller);
                            });
                          }
                        },
                      );
                    },
                  ),
                  
                  if (_selectedStockMobileName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _advanceController,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                controller.setAdvanceAmount(value);
                                _notifyDataChanged(controller);
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
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _imeiController,
                              readOnly: true,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: "IMEI نمبر",
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(),
                              ),
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
                        _notifyDataChanged(controller);
                      },
                      decoration: const InputDecoration(
                        hintText: "موبائل کا نام اور ماڈل لکھیں",
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  
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
                                _notifyDataChanged(controller);
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
                                _notifyDataChanged(controller);
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
                      onChanged: (bool value) {
                        controller.toggleSecurityCheck(value);
                        _notifyDataChanged(controller);
                      },
                      activeTrackColor: Colors.blue.withValues(alpha: 0.5),
                      activeThumbColor: Colors.blue,
                    ),
                  ],
                ),
                
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
                            onChanged: (value) => _notifyDataChanged(controller),
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
                            onChanged: (value) => _notifyDataChanged(controller),
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