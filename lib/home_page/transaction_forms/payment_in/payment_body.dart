import 'package:flutter/material.dart';
import 'payment_in_controller.dart';
import '../common/discount_widget.dart';
import '../../../dashboard/widgets/payment_source_card.dart';

class PaymentBody extends StatefulWidget {
  final PaymentInController controller;

  const PaymentBody({super.key, required this.controller});

  @override
  State<PaymentBody> createState() => _PaymentBodyState();
}

class _PaymentBodyState extends State<PaymentBody> {
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

    final bool hasPermission = await _checkMicrophonePermission();

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
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تاریخ: 19 اگست 2026',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.green[700]),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // رقم درج کرنے کا باکس
          TextField(
            controller: widget.controller.amountController,
            focusNode: widget.controller.amountFocusNode,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'رقم درج کریں (Amount)',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // رقم درج کرنے کے بعد کا وزٹ پورشن
          ValueListenableBuilder<bool>(
            valueListenable: widget.controller.hasAmountEntered,
            builder: (context, hasAmount, child) {
              if (!hasAmount) return const SizedBox.shrink();

              final bool hasAudio = widget.controller.audioPath?.isNotEmpty ?? false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // وائس نوٹ باکس
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: hasAudio ? Colors.green : Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: hasAudio ? Colors.green.shade50 : Colors.grey[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.mic,
                              color: _isRecording ? Colors.red : (hasAudio ? Colors.green : Colors.grey),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isRecording
                                  ? 'ریکارڈنگ ہو رہی ہے...'
                                  : (hasAudio ? 'وائس نوٹ حاصل ہو گیا ہے' : 'وائس نوٹ ریکارڈ کریں'),
                              style: TextStyle(
                                color: hasAudio ? Colors.green[800] : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (hasAudio && !_isRecording)
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
                    onDiscountChanged: widget.controller.updateDiscount,
                  ),
                  const SizedBox(height: 16),

                  // پیمنٹ سورس کارڈ
                  PaymentSourceCard(
                    key: widget.controller.paymentSourceCardKey,
                    isAdmin: true,
                    selectedSource: widget.controller.selectedPaymentSource,
                    onChanged: (newSource) {
                      setState(() => widget.controller.updateSelectedSource(newSource));
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