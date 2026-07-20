import 'package:flutter/material.dart';

// اپنی فائلز کے پاتھ کے مطابق امپورٹ کریں
import 'customer_ledger/top.dart';
import 'customer_ledger/middle.dart';
import 'customer_ledger/bottom.dart';

class CustomerLedgerPage extends StatelessWidget {
  const CustomerLedgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      // آپ نے جو AppBar والا حصہ ہٹانے کو کہا تھا، وہ میں نے یہاں سے مکمل نکال دیا ہے
      body: Column(
        children: [
          // اوپر والا حصہ (ٹاپ) - اب یہ سیدھا خلیل سبزی والا سے شروع ہوگا
          LedgerTopWidget(),
          
          // بیچ والا حصہ (لائنز اور تفصیل)
          Expanded(
            child: LedgerMiddleWidget(),
          ),
          
          // نیچے والا حصہ (پیمنٹ ان اور پیمنٹ آؤٹ بٹن)
          LedgerBottomWidget(),
        ],
      ),
    );
  }
}