import 'package:flutter/material.dart';

class PaymentHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color themeColor;

  const PaymentHeader({
    super.key,
    required this.title,
    this.themeColor = Colors.green, // پیمنٹ ان کے لیے ڈیفالٹ گرین
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