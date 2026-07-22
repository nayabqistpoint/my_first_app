import 'package:flutter/material.dart';
import 'sale_purchase_controller.dart';
import 'common/party_selector_widget.dart';
import 'common/item_selector_row_widget.dart';

class SalePurchaseForm extends StatefulWidget {
  const SalePurchaseForm({super.key});

  @override
  State<SalePurchaseForm> createState() => _SalePurchaseFormState();
}

class _SalePurchaseFormState extends State<SalePurchaseForm> {
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _partyPhoneController = TextEditingController();

  final List<Map<String, String>> _dummyContacts = const [
    {'name': 'علی خان', 'phone': '03001234567'},
    {'name': 'محمد احمد', 'phone': '03219876543'},
    {'name': 'عمران حیدر', 'phone': '03335557788'},
    {'name': 'بلال جنرل سٹور', 'phone': '03124445566'},
  ];

  bool _hasItems = false;
  String _selectedItemName = '';
  int _itemQty = 0;
  double _itemSubTotal = 0.0;

  @override
  void dispose() {
    _partyNameController.dispose();
    _partyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: salePurchaseController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ٹاپ ہیڈر
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment<int>(
                              value: 0,
                              label: Text('خرید', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            ButtonSegment<int>(
                              value: 1,
                              label: Text('فروخت', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                          selected: {salePurchaseController.selectedMode == 1 ? 1 : 0},
                          onSelectionChanged: (Set<int> newSelection) {
                            salePurchaseController.setMode(newSelection.first);
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return Colors.transparent;
                            }),
                            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFFE53935);
                              }
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
                          currentTime: '1:36 AM',
                          phoneContacts: _dummyContacts,
                          onNewPartyAdded: (name, phone) {},
                        ),

                        const SizedBox(height: 12),

                        ItemSelectorRowWidget(
                          hasItems: _hasItems,
                          itemName: _selectedItemName,
                          totalQty: _itemQty,
                          subTotal: _itemSubTotal,
                          onTap: () {
                            // فی الحال ٹیسٹ کے لیے ڈمی ڈیٹا، جب آپ چاہیں گے تو الگ فارম لگالیں گے
                            setState(() {
                              _hasItems = true;
                              _selectedItemName = 'Samsung Galaxy A54';
                              _itemQty = 1;
                              _itemSubTotal = 75000.0;
                            });
                          },
                          onScanTap: () {},
                        ),

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