import 'package:flutter/material.dart';
import '../../controllers/item_controller.dart';

class QuickSellWidget extends StatefulWidget {
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
    String desc, 
    String imei, 
    String category
  ) onItemSaved;

  const QuickSellWidget({
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
  State<QuickSellWidget> createState() => _QuickSellWidgetState();
}

class _QuickSellWidgetState extends State<QuickSellWidget> {
  late TextEditingController _modelController;
  late TextEditingController _qtyController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _imeiController;

  final TextEditingController _searchFieldController = TextEditingController();

  String _selectedCategory = 'موبائل فون (Mobile Phone)';
  String _selectedColor = '';

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
    _salePriceController.addListener(_updateProfitCalculation);
    _qtyController.addListener(_updateProfitCalculation);
    
    _imeiController = TextEditingController(text: widget.initialImei);
    _selectedCategory = widget.initialCategory;
    _selectedColor = widget.initialDescription;

    if (widget.initialModel.isNotEmpty) {
      _searchFieldController.text = widget.initialModel;
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _qtyController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _imeiController.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }

  void _updateProfitCalculation() {
    setState(() {});
  }

  void _autofillFromStock(StockItem stockItem) {
    setState(() {
      _modelController.text = stockItem.name;
      _purchasePriceController.text = stockItem.purchasePrice.toStringAsFixed(0);
      _salePriceController.text = stockItem.salePrice.toStringAsFixed(0);
      _imeiController.text = stockItem.imei;
    });
  }

  void _clearFormForNextItem() {
    setState(() {
      _modelController.clear();
      _searchFieldController.clear();
      _qtyController.text = '1';
      _purchasePriceController.clear();
      _salePriceController.clear();
      _imeiController.clear();
      _selectedColor = '';
    });
  }

  bool _saveItemData() {
    final model = _modelController.text.trim();
    final qty = int.tryParse(_qtyController.text) ?? 1;
    final purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;
    final salePrice = double.tryParse(_salePriceController.text) ?? 0.0;
    final imei = _imeiController.text.trim();
    final desc = _selectedColor;
    final category = _selectedCategory;

    if (model.isNotEmpty) {
      widget.onItemSaved(model, qty, purchasePrice, salePrice, desc, imei, category);
      return true;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('براہ کرم آئٹم کا نام یا ماڈل درج کریں')),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final List<StockItem> availableStock = itemController.items;

    double purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;
    double salePrice = double.tryParse(_salePriceController.text) ?? 0.0;
    int qty = int.tryParse(_qtyController.text) ?? 1;

    double totalProfitPerUnit = salePrice - purchasePrice;
    double totalProfit = totalProfitPerUnit * qty;
    double profitPercentage = purchasePrice > 0 ? (totalProfitPerUnit / purchasePrice) * 100 : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        title: const Text(
          'فروخت - کوئک سیل (ملٹیپل آئٹمز)',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Autocomplete<StockItem>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<StockItem>.empty();
                }
                return availableStock.where((item) {
                  final name = item.name.toLowerCase();
                  final imei = item.imei.toLowerCase();
                  final query = textEditingValue.text.toLowerCase();
                  return name.contains(query) || imei.contains(query);
                });
              },
              displayStringForOption: (StockItem option) => '${option.name} (IMEI: ${option.imei.isEmpty ? 'N/A' : option.imei})',
              onSelected: (StockItem selection) {
                _autofillFromStock(selection);
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                if (controller.text.isEmpty && _searchFieldController.text.isNotEmpty) {
                  controller.text = _searchFieldController.text;
                }
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'ماڈل یا IMEI لکھ کر تلاش کریں (Auto-fill)',
                    labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFE53935)),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              controller.clear();
                              _searchFieldController.clear();
                              _clearFormForNextItem();
                            },
                          )
                        : null,
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
                  onChanged: (value) {
                    _searchFieldController.text = value;
                    _modelController.text = value;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _purchasePriceController,
                    label: 'قیمتِ خرید (Rs)',
                    icon: Icons.account_balance_wallet_outlined,
                    keyboardType: TextInputType.number,
                    readOnly: true,
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
                  child: _buildTextField(
                    controller: _imeiController,
                    label: 'IMEI نمبر',
                    icon: Icons.qr_code,
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // پرافٹ / بچت کا باکس
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: totalProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: totalProfit >= 0 ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        totalProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: totalProfit >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تخمینہ شدہ بچت (Profit):',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: totalProfit >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Rs ${totalProfit.toStringAsFixed(0)} (${profitPercentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: totalProfit >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // بٹنز
            Row(
              children: [
                // 1. سیو اور نیا (Save & New)
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE53935), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        if (_saveItemData()) {
                          _clearFormForNextItem();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('آئٹم سیل میں شامل ہو گیا، اب اگلا آئٹم درج کریں'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFFE53935), size: 18),
                      label: const Text(
                        'سیو اور نیا',
                        style: TextStyle(color: Color(0xFFE53935), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // 2. سیل میں شامل کریں اور واپس جائیں (Save & Back)
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        if (_saveItemData()) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'سیل میں شامل کریں',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    bool readOnly = false,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
          prefixIcon: Icon(icon, size: 16, color: const Color(0xFFE53935)),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
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