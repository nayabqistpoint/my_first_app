import 'package:flutter/material.dart';
import 'sale_purchase_controller.dart';
import '../../dashboard/widgets/source_selecter.dart';

class SalePurchaseForm extends StatefulWidget {
  const SalePurchaseForm({super.key});

  @override
  State<SalePurchaseForm> createState() => _SalePurchaseFormState();
}

class _SalePurchaseFormState extends State<SalePurchaseForm> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: salePurchaseController,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'خرید و فروخت (انواٹس بل)',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Center(
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 0,
                      label: Text('صرف پرچیز', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      label: Text('صرف سیل', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    ButtonSegment<int>(
                      value: 2,
                      label: Text('پرچیز اینڈ سیل', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  selected: {salePurchaseController.selectedMode},
                  onSelectionChanged: (Set<int> newSelection) {
                    salePurchaseController.setMode(newSelection.first);
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 1.2),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: salePurchaseController.partyNameController,
                      decoration: const InputDecoration(
                        labelText: 'پارٹی کا نام *',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.person, size: 18, color: Color(0xFFE53935)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: salePurchaseController.whatsappController,
                      decoration: const InputDecoration(
                        labelText: 'واٹس ایپ نمبر *',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.phone, size: 16, color: Color(0xFFE53935)),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  SizedBox(
                    width: 170,
                    child: TextField(
                      controller: salePurchaseController.dateController,
                      decoration: InputDecoration(
                        labelText: 'تاریخ',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFFE53935)),
                          onPressed: () => salePurchaseController.pickDate(context),
                        ),
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: salePurchaseController.itemsList.length,
                itemBuilder: (context, index) {
                  var item = salePurchaseController.itemsList[index];
                  double qty = double.tryParse(item['qty']?.text ?? '0') ?? 0;
                  double price = double.tryParse(item['purchasePrice']?.text ?? '0') ?? 0;
                  double subTotal = qty * price;

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${index + 1} آئٹم کی تفصیل',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.green.shade200),
                                    ),
                                    child: Text(
                                      'سب ٹوٹل: Rs ${subTotal.toStringAsFixed(0)}',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                    ),
                                  ),
                                  if (salePurchaseController.itemsList.length > 1) ...[
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                      onPressed: () => salePurchaseController.removeItemRow(index),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: item['model'],
                                  decoration: const InputDecoration(labelText: 'موبائل ماڈل *', border: OutlineInputBorder(), isDense: true),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: item['imei'],
                                  decoration: const InputDecoration(labelText: 'IMEI نمبر *', border: OutlineInputBorder(), isDense: true),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: item['color'],
                                  decoration: const InputDecoration(labelText: 'کلر', border: OutlineInputBorder(), isDense: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: item['qty'],
                                  decoration: const InputDecoration(labelText: 'تعداد', border: OutlineInputBorder(), isDense: true),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: item['purchasePrice'],
                                  decoration: const InputDecoration(labelText: 'خرید قیمت', border: OutlineInputBorder(), isDense: true),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: item['salePrice'],
                                  decoration: const InputDecoration(labelText: 'فروخت قیمت', border: OutlineInputBorder(), isDense: true),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () => salePurchaseController.addItemRow(),
                  icon: const Icon(Icons.add, size: 16, color: Color(0xFFE53935)),
                  label: const Text('مزید آئٹم شامل کریں', style: TextStyle(fontSize: 12, color: Color(0xFFE53935))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE53935)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('گرانڈ ٹوٹل (خرید):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('Rs ${salePurchaseController.grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Expanded(flex: 2, child: Text('رعایت (دکاندار کی طرف سے):', style: TextStyle(fontSize: 12))),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: salePurchaseController.discountController,
                            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, prefixText: 'Rs '),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('فائنل ادائیگی کل رقم:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Rs ${salePurchaseController.finalPayableAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // یہاں سورس سلیکٹر جڑ گیا ہے جو کنٹرولر کو ڈیٹا بھیج رہا ہے
              SourceSelecter(
                onSplitPaymentChanged: (bankSource, cashAmount, bankAmount) {
                  salePurchaseController.setSplitPayment(bankSource, cashAmount, bankAmount);
                },
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () => salePurchaseController.saveData(),
                        icon: const Icon(Icons.share, color: Colors.white, size: 16),
                        label: const Text('محفوظ اور شیئر', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () => salePurchaseController.saveData(),
                        icon: const Icon(Icons.save, color: Colors.white, size: 16),
                        label: const Text('محفوظ کریں', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}