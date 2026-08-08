import 'package:flutter/material.dart';
import 'payment_out_controller.dart';
import '../common/discount_widget.dart';
import '../../../dashboard/widgets/payment_source_card.dart';

class PaymentOutBody extends StatelessWidget {
  final PaymentOutController controller;

  const PaymentOutBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تاریخ: ${DateTime.now().day} اگست ${DateTime.now().year}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.red[700]),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // رقم کا خانہ (Amount)
          TextField(
            controller: controller.amountController,
            focusNode: controller.amountFocusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'رقم درج کریں (Amount)',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // رقم درج ہونے پر باقی فارم ظاہر ہوگا
          ValueListenableBuilder<bool>(
            valueListenable: controller.hasAmountEntered,
            builder: (context, hasAmount, child) {
              if (!hasAmount) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller.remarksController,
                    maxLines: 2,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'تفصیل یا ریمارکس (Remarks)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.red),
                            onPressed: () {},
                            tooltip: 'تصویر لیں',
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file, color: Colors.red),
                            onPressed: () {},
                            tooltip: 'فائل اٹیچ کریں',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.mic, color: Colors.red),
                            SizedBox(width: 10),
                            Text(
                              'وائس نوٹ ریکارڈ کریں',
                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.fiber_manual_record, color: Colors.red),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DiscountWidget(
                    onDiscountChanged: (double discountValue, bool isPercentage) {
                      controller.updateDiscount(discountValue, isPercentage);
                    },
                  ),
                  const SizedBox(height: 16),

                  // ڈائنامک PaymentSourceCard (Key کے ساتھ ڈائریکٹ لنک)
                  PaymentSourceCard(
                    key: controller.sourceCardKey,
                    isAdmin: true,
                    selectedSource: controller.selectedPaymentSource,
                    onChanged: (String? newSource) {
                      controller.updateSelectedSource(newSource);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}