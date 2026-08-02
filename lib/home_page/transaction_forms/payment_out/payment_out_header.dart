import 'package:flutter/material.dart';

class PaymentOutHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color themeColor;

  const PaymentOutHeader({
    super.key,
    this.title = 'پیمنٹ آؤٹ',
    this.themeColor = Colors.red, // پیمنٹ آؤٹ کے لیے ڈیفالٹ سرخ رنگ
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 12,
        right: 12,
        bottom: 12,
      ),
      color: themeColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}