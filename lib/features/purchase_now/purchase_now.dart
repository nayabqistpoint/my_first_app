import 'package:flutter/material.dart';
import '../../welcome/signup/item_package_ui.dart';
import 'purchase_now_controller.dart';

class PurchaseNow extends StatefulWidget {
  const PurchaseNow({super.key});

  @override
  State<PurchaseNow> createState() => _PurchaseNowState();
}

class _PurchaseNowState extends State<PurchaseNow> {
  final PurchaseNowController _controller = PurchaseNowController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "خریداری کی درخواست",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: const ItemPackageUI(),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: Colors.white,
        child: SafeArea(
          child: SizedBox(
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _controller.tempSubmit();
              },
              child: const Text(
                "سبمٹ کریں",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}