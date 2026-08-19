import 'package:flutter/material.dart';

class TransactionSummaryWidget extends StatefulWidget {
  final double subTotal;
  final double discountAmount;
  final double grandTotal;
  final TextEditingController receivedController;

  const TransactionSummaryWidget({
    super.key,
    required this.subTotal,
    required this.discountAmount,
    required this.grandTotal,
    required this.receivedController,
  });

  @override
  State<TransactionSummaryWidget> createState() => _TransactionSummaryWidgetState();
}

class _TransactionSummaryWidgetState extends State<TransactionSummaryWidget> {
  bool _isFullPaid = false;

  @override
  Widget build(BuildContext context) {
    final paidAmount = double.tryParse(widget.receivedController.text) ?? 0.0;
    final balance = widget.grandTotal - paidAmount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ۱. سب ٹوٹل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('سب ٹوٹل (Subtotal):', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Rs ${widget.subTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          if (widget.discountAmount > 0) ...[
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ڈسکاؤنٹ (Discount):', style: TextStyle(fontSize: 11, color: Colors.red)),
                Text('- Rs ${widget.discountAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ],
          const Divider(height: 12),

          // ۲. گرینڈ ٹوٹل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('کل قابلِ ادائیگی (Grand Total):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text('Rs ${widget.grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
            ],
          ),
          const SizedBox(height: 10),

          // ۳۔ وصول / ادا شدہ رقم اور فل پیڈ باکس
          Row(
            children: [
              const Text('وصول / ادا شدہ:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    _isFullPaid = !_isFullPaid;
                    widget.receivedController.text = _isFullPaid ? widget.grandTotal.toStringAsFixed(0) : '';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isFullPaid ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _isFullPaid ? Colors.green : Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isFullPaid ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 14,
                        color: _isFullPaid ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      const Text('فل پیڈ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 95,
                height: 34,
                child: TextField(
                  controller: widget.receivedController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      final entered = double.tryParse(val) ?? 0.0;
                      _isFullPaid = (entered == widget.grandTotal && widget.grandTotal > 0);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '0',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
                    ),
                  ),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ۴۔ بقایا بیلنس
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('بقیہ رقم (Balance):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text(
                'Rs ${balance.abs().toStringAsFixed(0)} ${balance < 0 ? "(ایڈوانس / اضافی)" : ""}',
                style: TextStyle(
                  fontSize: 11, 
                  fontWeight: FontWeight.bold, 
                  color: balance < 0 ? Colors.red : (balance > 0 ? Colors.green : Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}