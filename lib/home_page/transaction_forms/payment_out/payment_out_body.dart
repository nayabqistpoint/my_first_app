import 'package:flutter/material.dart';
import 'package:my_first_app/home_page/transaction_forms/payment_out/payment_out_controller.dart';
import 'package:my_first_app/home_page/transaction_forms/common/discount_widget.dart';
import 'package:my_first_app/dashboard/widgets/payment_source_card.dart';

class PaymentOutBody extends StatefulWidget {
  final PaymentOutController controller;

  const PaymentOutBody({super.key, required this.controller});

  @override
  State<PaymentOutBody> createState() => _PaymentOutBodyState();
}

class _PaymentOutBodyState extends State<PaymentOutBody> {
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(widget.controller.amountFocusNode);
    });
  }

  Future<void> _handleAudioRecording() async {
    if (_isRecording) {
      setState(() => _isRecording = false);
      return;
    }

    bool hasPermission = await _checkMicrophonePermission();

    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مائیکروفون کی اجازت درکار ہے...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() => _isRecording = true);
  }

  Future<bool> _checkMicrophonePermission() async => false;

  void _clearAudio() {
    setState(() {
      _isRecording = false;
      widget.controller.audioPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تاریخ کی پٹی
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

          // رقم درج کرنے کا خانہ
          TextField(
            controller: widget.controller.amountController,
            focusNode: widget.controller.amountFocusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'رقم درج کریں (Amount)',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // مشروط ڈسپلے وزٹس
          ValueListenableBuilder<bool>(
            valueListenable: widget.controller.hasAmountEntered,
            builder: (context, hasAmount, child) {
              if (!hasAmount) return const SizedBox.shrink();

              final bool hasAudioSaved = widget.controller.audioPath != null && widget.controller.audioPath!.isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // وائس نوٹ باکس
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: hasAudioSaved ? Colors.red : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: hasAudioSaved ? Colors.red.shade50 : Colors.grey[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.mic,
                              color: _isRecording ? Colors.red : (hasAudioSaved ? Colors.red[700] : Colors.grey),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isRecording
                                  ? 'ریکارڈنگ ہو رہی ہے...'
                                  : (hasAudioSaved ? 'وائس نوٹ حاصل ہو گیا ہے' : 'وائس نوٹ ریکارڈ کریں'),
                              style: TextStyle(
                                color: hasAudioSaved ? Colors.red[900] : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (hasAudioSaved && !_isRecording)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: _clearAudio,
                              ),
                            IconButton(
                              icon: Icon(
                                _isRecording ? Icons.stop : Icons.fiber_manual_record,
                                color: Colors.red,
                              ),
                              onPressed: _handleAudioRecording,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ڈسکاؤنٹ وزٹ
                  DiscountWidget(
                    onDiscountChanged: (categoryName, discountValue, isPercentage) {
                      widget.controller.updateDiscount(categoryName, discountValue, isPercentage);
                    },
                  ),
                  const SizedBox(height: 16),

                  // پیمنٹ سورس کارڈ
                  PaymentSourceCard(
                    key: widget.controller.sourceCardKey,
                    isAdmin: true,
                    selectedSource: widget.controller.selectedPaymentSource,
                    onChanged: (newSource) {
                      setState(() {
                        widget.controller.updateSelectedSource(newSource);
                      });
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