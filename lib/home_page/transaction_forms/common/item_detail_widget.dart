import 'package:flutter/material.dart';

class ItemDetailWidget extends StatefulWidget {
  final String initialModel;
  final int initialQty;
  final double initialPurchasePrice;
  final double initialSalePrice;
  final String initialDescription;
  final String initialImei;
  final String initialCategory;
  
  final Function(
    String model, 
    int qty, 
    double purchasePrice, 
    double salePrice, 
    String description, 
    String imei, 
    String category
  ) onItemSaved;

  const ItemDetailWidget({
    super.key,
    this.initialModel = '',
    this.initialQty = 1,
    this.initialPurchasePrice = 0.0,
    this.initialSalePrice = 0.0,
    this.initialDescription = '',
    this.initialImei = '',
    this.initialCategory = 'موبائل فون (Mobile Phone)',
    required this.onItemSaved,
  });

  @override
  State<ItemDetailWidget> createState() => _ItemDetailWidgetState();
}

class _ItemDetailWidgetState extends State<ItemDetailWidget> {
  late TextEditingController _modelController;
  late TextEditingController _qtyController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _imeiController;
  
  late String _selectedCategory;
  final List<String> _categories = [
    'موبائل فون (Mobile)',
    'استعمال شدہ (Used)',
    'ایکسیسریز (Accessory)',
    'دیگر (Other)',
  ];

  String? _selectedColor;
  final List<String> _commonColors = [
    'سیاہ (Black)',
    'سفید (White)',
    'نیلا (Blue)',
    'گولڈ (Gold)',
    'سلور (Silver)',
    'گرین (Green)',
    'سرخ (Red)',
    'پرپل (Purple)',
  ];

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController(text: widget.initialModel);
    _qtyController = TextEditingController(text: widget.initialQty.toString());
    _purchasePriceController = TextEditingController(
      text: widget.initialPurchasePrice > 0 ? widget.initialPurchasePrice.toStringAsFixed(0) : '',
    );
    _salePriceController = TextEditingController(
      text: widget.initialSalePrice > 0 ? widget.initialSalePrice.toStringAsFixed(0) : '',
    );
    _imeiController = TextEditingController(text: widget.initialImei);
    
    _selectedCategory = _categories.contains(widget.initialCategory) 
        ? widget.initialCategory 
        : _categories.first;

    if (widget.initialDescription.isNotEmpty && _commonColors.contains(widget.initialDescription)) {
      _selectedColor = widget.initialDescription;
    } else {
      _selectedColor = _commonColors.first;
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _qtyController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _imeiController.dispose();
    super.dispose();
  }

  bool _saveItemLocally() {
    final model = _modelController.text.trim();
    final qty = int.tryParse(_qtyController.text) ?? 1;
    final purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;
    final salePrice = double.tryParse(_salePriceController.text) ?? 0.0;
    final imei = _imeiController.text.trim();
    final description = _selectedColor ?? '';
    final category = _selectedCategory;

    if (model.isNotEmpty) {
      widget.onItemSaved(model, qty, purchasePrice, salePrice, description, imei, category);
      return true;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('براہ کرم ماڈل یا آئٹم کا نام درج کریں')),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.initialModel.isNotEmpty;

    final qty = int.tryParse(_qtyController.text) ?? 0;
    final salePrice = double.tryParse(_salePriceController.text) ?? 0.0;
    final purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;
    final activePrice = salePrice > 0 ? salePrice : purchasePrice;
    final liveSubTotal = qty * activePrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        title: Text(
          isEditing ? 'آئٹم میں ترمیم کریں' : 'نیا آئٹم درج کریں',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. کیٹیگری اور ماڈل کا نام (ایک ہی لائن میں سمارٹ انداز سے)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE53935), size: 20),
                        items: _categories.map((String cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _modelController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'ماڈل / آئٹم کا نام',
                        labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          borderSide: BorderSide(color: Color(0xFFE53935), width: 1.5),
                        ),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. قیمتِ خرید و فروخت
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _purchasePriceController,
                    label: 'قیمتِ خرید (Rs)',
                    icon: Icons.account_balance_wallet_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    controller: _salePriceController,
                    label: 'قیمتِ فروخت (Rs)',
                    icon: Icons.point_of_sale_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3. تعداد (Qty) اور سمارٹ رنگ ڈراپ ڈاؤن (وائٹ بیک گراؤنڈ کے ساتھ)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _qtyController,
                    label: 'تعداد (Qty)',
                    icon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedColor,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        hint: const Text('رنگ منتخب کریں', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE53935), size: 20),
                        items: _commonColors.map((String color) {
                          return DropdownMenuItem<String>(
                            value: color,
                            child: Text(color, style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedColor = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. IMEI نمبر
            _buildTextField(
              controller: _imeiController,
              label: 'IMEI نمبر (15 ہندسے)',
              icon: Icons.qr_code,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // 5. لائیو سب ٹوٹل
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'کل رقم (Subtotal):',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    'Rs ${liveSubTotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // بٹنز
            if (!isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE53935), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {
                          if (_saveItemLocally()) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'محفوظ کریں',
                          style: TextStyle(color: Color(0xFFE53935), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {
                          if (_saveItemLocally()) {
                            setState(() {
                              _modelController.clear();
                              _qtyController.text = '1';
                              _purchasePriceController.clear();
                              _salePriceController.clear();
                              _imeiController.clear();
                              _selectedColor = _commonColors.first;
                            });
                          }
                        },
                        child: const Text(
                          'سیو اینڈ نیو (+)',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    if (_saveItemLocally()) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'تبدیلیاں محفوظ کریں',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
          prefixIcon: Icon(icon, size: 16, color: const Color(0xFFE53935)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide(color: Color(0xFFE53935), width: 1.5),
          ),
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}