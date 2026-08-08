import 'package:flutter/material.dart';
import 'purchase_page_controller.dart';
import 'common/header_capsules.dart';
import 'common/party_selector_widget.dart';
import 'common/item_selector_row_widget.dart';
import 'common/discount_widget.dart';
import 'common/transaction_summary_widget.dart';

// بالکل درست پاتھ کے ساتھ نیا پیمنٹ سورس کارڈ امپورٹ
import '../../dashboard/widgets/payment_source_card.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  late final PurchasePageController controller;

  double _discountValue = 0.0;
  bool _isDiscountPercentage = false;

  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = PurchasePageController();
  }

  @override
  void dispose() {
    _receivedController.dispose();
    _descriptionController.dispose();
    controller.dispose();
    super.dispose();
  }

  double get _subTotal {
    double total = 0.0;
    for (var item in controller.itemsList) {
      final val = double.tryParse(item['subTotal']?.toString() ?? '0') ?? 0.0;
      total += val;
    }
    return total;
  }

  double get _calculatedDiscountAmount {
    if (_isDiscountPercentage) {
      return (_subTotal * _discountValue) / 100;
    }
    return _discountValue;
  }

  double get _grandTotal {
    final total = _subTotal - _calculatedDiscountAmount;
    return total < 0 ? 0.0 : total;
  }

  Future<void> _openItemDetails(int index, {bool isEdit = false}) async {
    await controller.handleItemDetailNavigation(context, index, isEdit: isEdit);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onSavePressed() async {
    double paid = double.tryParse(_receivedController.text.trim()) ?? 0.0;
    double grand = _grandTotal;
    double remaining = grand - paid;

    controller.grandTotalAmount = grand;
    controller.paidAmount = paid;
    controller.remainingBalance = remaining;
    controller.discountValue = _calculatedDiscountAmount;
    controller.isDiscountPercentage = _isDiscountPercentage;
    controller.descriptionText = _descriptionController.text.trim();

    bool success = await controller.savePurchase();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ڈیٹا کامیابی سے محفوظ ہو گیا ہے!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برائے مہربانی پہلے آئٹم کا انتخاب کریں!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const HeaderCapsulesWidget(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      children: [
                        // Party Selector Widget
                        PartySelectorWidget(
                          onPartySelected: (String? phone, String? name) {
                            controller.selectedPartyPhone = phone;
                            controller.selectedPartyName = name;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Item Rows List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.itemsList.length,
                          itemBuilder: (context, index) {
                            final item = controller.itemsList[index];

                            return ItemSelectorRowWidget(
                              itemName: item['itemName'] ?? '',
                              imeiNo: item['imeiNo'] ?? '',
                              subTotal: item['subTotal'] ?? '0.00',
                              calculationText: item['calculationText'] ?? '1 × 0',
                              onAddPressed: () {
                                bool isAdded = controller.addNewItemRow();
                                if (!isAdded) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('برائے مہربانی پہلے آئٹم کا انتخاب کریں!'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  setState(() {});
                                }
                              },
                              onDeletePressed: () {
                                if (controller.itemsList.length > 1) {
                                  setState(() {
                                    controller.removeItemRow(index);
                                  });
                                }
                              },
                              onEditPressed: () => _openItemDetails(index, isEdit: true),
                              onRowPressed: () => _openItemDetails(index, isEdit: false),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        // Discount Widget
                        DiscountWidget(
                          onDiscountChanged: (discountValue, isPercentage) {
                            setState(() {
                              _discountValue = discountValue;
                              _isDiscountPercentage = isPercentage;
                            });
                          },
                        ),

                        const SizedBox(height: 10),

                        // Transaction Summary Widget
                        TransactionSummaryWidget(
                          subTotal: _subTotal,
                          discountAmount: _calculatedDiscountAmount,
                          grandTotal: _grandTotal,
                          receivedController: _receivedController,
                          descriptionController: _descriptionController,
                        ),

                        const SizedBox(height: 10),

                        // Payment Source Card (ترتیب کے مطابق اینڈ پر رکھا گیا ہے)
                        PaymentSourceCard(
                          key: controller.paymentCardKey, // <-- صرف یہ ایک لائن شامل کی گئی ہے تاکہ اسپلٹ پیمنٹ کام کر سکے
                          selectedSource: controller.selectedPaymentSource,
                          onChanged: (val) {
                            setState(() {
                              controller.selectedPaymentSource = val;
                            });
                          },
                          isAdmin: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onSavePressed,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'محفوظ کریں',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}