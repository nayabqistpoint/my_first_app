import 'package:flutter/material.dart';
import 'payment_in_controller.dart';
import '../common/discount_widget.dart';
import '../../../dashboard/widgets/source_selecter.dart';

class PaymentBody extends StatefulWidget {
  final PaymentInController controller;

  const PaymentBody({super.key, required this.controller});

  @override
  State<PaymentBody> createState() => _PaymentBodyState();
}

class _PaymentBodyState extends State<PaymentBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(widget.controller.amountFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ۱. تاریخ (Date) کی پٹی
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تاریخ: 02 اگست 2026',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.green[700]),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ۲. رقم (Amount) لکھنے کا خانہ
          TextField(
            controller: widget.controller.amountController,
            focusNode: widget.controller.amountFocusNode,
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
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ۳. باقی تمام فیلڈز جو رقم درج کرنے کے بعد کھلیں گی
          ValueListenableBuilder<bool>(
            valueListenable: widget.controller.hasAmountEntered,
            builder: (context, hasAmount, child) {
              if (!hasAmount) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الف) تفصیل (Remarks) کا باکس
                  TextField(
                    controller: widget.controller.remarksController,
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
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.green),
                            onPressed: () {},
                            tooltip: 'تصویر لیں',
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file, color: Colors.green),
                            onPressed: () {},
                            tooltip: 'فائل اٹیچ کریں',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ب) وائس نوٹ (Voice Note)
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
                            Icon(Icons.mic, color: Colors.green),
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

                  // ج) ڈسکاؤنٹ ویجیٹ
                  DiscountWidget(
                    onDiscountChanged: (double discountValue, bool isPercentage) {
                      // ڈسکاؤنٹ کی لاجک یہاں آئے گی
                    },
                  ),
                  const SizedBox(height: 16),

                  // د) سورس سلیکٹر ویجیٹ
                  ValueListenableBuilder<double>(
                    valueListenable: widget.controller.currentAmountNotifier,
                    builder: (context, currentAmount, child) {
                      return SourceSelecter(
                        defaultAmount: currentAmount,
                        onSplitPaymentChanged: (String? source, double amount, double extra, List<Map<String, dynamic>> splits) {
                          // سپلٹ پیمنٹ کا ڈیٹا یہاں آئے گا
                        },
                      );
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