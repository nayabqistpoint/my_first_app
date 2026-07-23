import 'package:flutter/material.dart';
import 'sale_purchase_controller.dart';
import 'common/party_selector_widget.dart';
import 'common/item_selector_row_widget.dart';
import 'common/item_detail_widget.dart';
import 'common/discount_widget.dart';
import 'common/transaction_summary_widget.dart';
import '../../dashboard/widgets/source_selecter.dart';

class SalePurchaseForm extends StatefulWidget {
  const SalePurchaseForm({super.key});

  @override
  State<SalePurchaseForm> createState() => _SalePurchaseFormState();
}

class _SalePurchaseFormState extends State<SalePurchaseForm> {
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _partyPhoneController = TextEditingController();
  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedBankSource;
  double _cashAmount = 0.0;
  double _bankAmount = 0.0;

  final List<Map<String, String>> _dummyContacts = const [
    {'name': 'علی خان', 'phone': '03001234567'},
    {'name': 'محمد احمد', 'phone': '03219876543'},
    {'name': 'عمران حیدر', 'phone': '03335557788'},
    {'name': 'بلال جنرل سٹور', 'phone': '03124445566'},
  ];

  @override
  void initState() {
    super.initState();
    _receivedController.addListener(_onReceivedAmountChanged);
  }

  void _onReceivedAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    _partyPhoneController.dispose();
    _receivedController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openItemDetail({int? editIndex}) {
    final isEditing = editIndex != null;
    final itemList = salePurchaseController.itemList;
    final item = isEditing ? itemList[editIndex] : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailWidget(
          initialModel: isEditing ? item!['model'] : '',
          initialQty: isEditing ? item!['qty'] : 1,
          initialPurchasePrice: isEditing ? item!['purchasePrice'] : 0.0,
          initialSalePrice: isEditing ? item!['salePrice'] : 0.0,
          initialDescription: isEditing ? item!['desc'] : '',
          initialImei: isEditing ? item!['imei'] : '',
          initialCategory: isEditing ? item!['category'] : 'موبائل فون (Mobile Phone)',
          onItemSaved: (model, qty, purchasePrice, salePrice, desc, imei, category) {
            salePurchaseController.saveItem(
              editIndex: editIndex,
              model: model,
              qty: qty,
              purchasePrice: purchasePrice,
              salePrice: salePrice,
              desc: desc,
              imei: imei,
              category: category,
            );
          },
        ),
      ),
    );
  }

  void _onSavePressed() {
    bool success = salePurchaseController.completeTransaction(
      bankSource: _selectedBankSource,
      cashAmount: _cashAmount,
      bankAmount: _bankAmount,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کم از کم ایک آئٹم شامل کرنا ضروری ہے')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ٹرانزیکشن کامیابی سے محفوظ ہو گئی ہے')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: salePurchaseController,
      builder: (context, child) {
        final itemList = salePurchaseController.itemList;
        final isPurchaseMode = salePurchaseController.selectedMode == 0;
        final grandTotal = salePurchaseController.grandTotal;

        // اگر وصول شدہ خانہ خالی یا زیرو ہو تو 0 جائے گا، ورنہ یوزر کی لکھی ہوئی رقم
        double currentReceivedAmount = double.tryParse(_receivedController.text) ?? 0.0;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: const Color(0xFFE53935),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'نایاب قسط پوائنٹ',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment<int>(value: 0, label: Text('خرید', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                            ButtonSegment<int>(value: 1, label: Text('فروخت', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                          ],
                          selected: {salePurchaseController.selectedMode},
                          onSelectionChanged: (Set<int> newSelection) {
                            salePurchaseController.setMode(newSelection.first);
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.selected)) return Colors.white;
                              return Colors.transparent;
                            }),
                            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.selected)) return const Color(0xFFE53935);
                              return Colors.white;
                            }),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        PartySelectorWidget(
                          nameController: _partyNameController,
                          phoneController: _partyPhoneController,
                          invoiceNo: 'INV-001',
                          currentDate: '23-07-2026',
                          currentTime: '4:37 AM',
                          phoneContacts: _dummyContacts,
                          onNewPartyAdded: (name, phone) {},
                        ),
                        const SizedBox(height: 12),
                        if (itemList.isEmpty)
                          ItemSelectorRowWidget(
                            hasItems: false,
                            onTap: () => _openItemDetail(),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: itemList.length,
                            itemBuilder: (context, index) {
                              final item = itemList[index];
                              final isLastItem = (index == itemList.length - 1);
                              final qty = item['qty'] as int;
                              final unitPrice = isPurchaseMode 
                                  ? (item['purchasePrice'] as double) 
                                  : (item['salePrice'] as double);

                              final colorDesc = item['desc'] ?? '';
                              final imeiText = (item['imei'] != null && item['imei'].toString().isNotEmpty) 
                                  ? ' | IMEI: ${item['imei']}' 
                                  : '';
                              final displayDescription = '$colorDesc$imeiText';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ItemSelectorRowWidget(
                                  hasItems: true,
                                  itemName: item['model'],
                                  totalQty: qty,
                                  unitPrice: unitPrice,
                                  subTotal: qty * unitPrice,
                                  description: displayDescription.isNotEmpty ? displayDescription : 'کیٹیگری: ${item['category']}',
                                  onEditTap: () => _openItemDetail(editIndex: index),
                                  onDeleteTap: () => salePurchaseController.deleteItem(index),
                                  onPlusTap: isLastItem ? () => _openItemDetail() : null,
                                ),
                              );
                            },
                          ),
                        if (itemList.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          DiscountWidget(
                            onDiscountChanged: (value, isPercentage) {
                              salePurchaseController.setDiscount(value, isPercentage);
                            },
                          ),
                          const SizedBox(height: 12),
                          TransactionSummaryWidget(
                            subTotal: salePurchaseController.subTotal,
                            discountAmount: salePurchaseController.discountAmount,
                            grandTotal: grandTotal,
                            receivedController: _receivedController,
                            descriptionController: _descriptionController,
                            onAddPhotoPressed: () {},
                          ),
                          const SizedBox(height: 12),
                          SourceSelecter(
                            defaultAmount: currentReceivedAmount,
                            onSplitPaymentChanged: (primaryBankSource, totalCash, totalBank, detailedSplits) {
                              setState(() {
                                _selectedBankSource = primaryBankSource;
                                _cashAmount = totalCash;
                                _bankAmount = totalBank;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _onSavePressed,
                              child: const Text(
                                'ٹرانزیکشن محفوظ کریں',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}