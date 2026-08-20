import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_first_app/calculater/calculater_controller.dart'; 
import 'package:my_first_app/calculater/calculater_config.dart';

class CalculaterHeader extends StatefulWidget {
  final Function(Map<String, dynamic>)? onDataChanged;

  const CalculaterHeader({super.key, this.onDataChanged});

  @override
  State<CalculaterHeader> createState() => _CalculaterHeaderState();
}

class _CalculaterHeaderState extends State<CalculaterHeader> {
  int _selectedMode = 1; // 1: دستیاب سٹاک, 2: مینول
  String? _selectedStockKey;
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
                      ButtonSegment<int>(value: 1, label: Text("دستیاب سٹاک سے", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      ButtonSegment<int>(value: 2, label: Text("اپنی مرضی (مینول)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
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

                // موڈ 1: دستیاب سٹاک سے ڈراپ ڈاؤن
                if (_selectedMode == 1) ...[
                  ValueListenableBuilder(
                    valueListenable: Hive.box('stockBox').listenable(),
                    builder: (context, Box box, _) {
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
                            child: Text("اسٹاک میں کوئی موبائل دستیاب نہیں ہے", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        initialValue: _selectedStockKey,
                        isExpanded: true,
                        itemHeight: 60,
                        decoration: InputDecoration(
                          hintText: "دستیاب سٹاک سے موبائل منتخب کریں",
                          hintStyle: const TextStyle(fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        selectedItemBuilder: (context) {
                          return availableItems.map((item) {
                            final name = item!['itemName']?.toString() ?? '';
                            final imei = item['imeiNo']?.toString() ?? '';
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Text('$name ${imei.isNotEmpty ? "($imei)" : ""}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            );
                          }).toList();
                        },
                        items: availableItems.map((item) {
                          final key = item!['hiveKey'].toString();
                          return DropdownMenuItem<String>(
                            value: key,
                            child: _buildDropdownCardItem(item), // کارڈ لے آؤٹ کا علیحدہ ہیلپر فنکشن
                          );
                        }).toList(),
                        onChanged: (String? selectedKey) {
                          if (selectedKey == null) return;
                          final selectedData = availableItems.firstWhere((e) => e!['hiveKey'] == selectedKey);
                          if (selectedData != null) {
                            setState(() {
                              _selectedStockKey = selectedKey;
                              _selectedStockMobileName = selectedData['itemName']?.toString() ?? '';
                              _imeiController.text = selectedData['imeiNo']?.toString() ?? '';
                              controller.setTotalAmount(selectedData['salePrice']?.toString() ?? '0');
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
                        Expanded(child: _buildTextField(_advanceController, "ایڈوانس", TextInputType.number, (v) {
                          controller.setAdvanceAmount(v);
                          _notifyDataChanged(controller);
                        })),
                        const SizedBox(width: 6),
                        Expanded(child: _buildTextField(_imeiController, "IMEI نمبر", TextInputType.text, null, readOnly: true)),
                      ],
                    ),
                  ],
                ],

                // موڈ 2: مینول انتخاب
                if (_selectedMode == 2) ...[
                  _buildTextField(_manualModelController, "موبائل کا نام اور ماڈل لکھیں", TextInputType.text, (v) {
                    setState(() {});
                    _notifyDataChanged(controller);
                  }),
                  
                  if (_manualModelController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_manualTotalController, "نقد قیمت", TextInputType.number, (v) {
                          controller.setTotalAmount(v);
                          _notifyDataChanged(controller);
                        })),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTextField(_advanceController, "ایڈوانس", TextInputType.number, (v) {
                          controller.setAdvanceAmount(v);
                          _notifyDataChanged(controller);
                        })),
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
                      child: Text(message, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // سیکیورٹی چیک سوئچ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(child: Text("کیا آپ نے رعایت کے لیے سیکیورٹی چیک مہیا کیا ہے؟", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    Switch(
                      value: controller.hasSecurityCheck,
                      onChanged: (bool value) {
                        controller.toggleSecurityCheck(value);
                        _notifyDataChanged(controller);
                      },
                      activeThumbColor: Colors.blue,
                    ),
                  ],
                ),
                
                if (controller.hasSecurityCheck) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_checkNumberController, "چیک نمبر", TextInputType.text, (v) => _notifyDataChanged(controller))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTextField(_bankNameController, "بینک کا نام", TextInputType.text, (v) => _notifyDataChanged(controller))),
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

  // --- کوڈ کی لمبائی کم کرنے کے لیے ٹیکسٹ فیلڈ کا ری یوزیبل ہیلپر ---
  Widget _buildTextField(TextEditingController ctrl, String hint, TextInputType type, Function(String)? onChange, {bool readOnly = false}) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: ctrl,
        readOnly: readOnly,
        textAlign: TextAlign.center,
        keyboardType: type,
        onChanged: onChange,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // --- ڈراپ ڈاؤن لسٹ آئٹم کا خوبصورت وائٹ 3D کارڈ لے آؤٹ ---
  Widget _buildDropdownCardItem(Map<String, dynamic> item) {
    final name = item['itemName']?.toString() ?? 'نامعلوم';
    final imei = item['imeiNo']?.toString() ?? 'N/A';
    final ram = item['ram']?.toString() ?? '';
    final rom = item['rom']?.toString() ?? '';
    final cond = item['condition']?.toString() == 'new' ? 'نیا' : 'پرانا';
    final war = '${item['warranty'] ?? 0} ماہ';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
                Text('IMEI: $imei', style: TextStyle(fontSize: 10, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                  child: Text(ram.isNotEmpty ? '$ram / $rom' : 'N/A', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                ),
                const SizedBox(height: 1),
                Text('$cond | $war', style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}