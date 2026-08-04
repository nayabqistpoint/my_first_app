import 'package:flutter/material.dart';
import '../../welcome/signup/item_package_ui.dart'; // صحیح فائل کی امپورٹ

class PurchaseNow extends StatelessWidget {
  const PurchaseNow({super.key});

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
      // یہاں ہم نے بالکل درست کلاس نیم کے ساتھ یو آئی ویجٹ کو کال کر لیا ہے
      body: const Padding(
        padding: EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: ItemPackageUI(),
        ),
      ),
      // نیچے باٹم پر سمارٹ 'سبمٹ کریں' کا بٹن
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
                // سبمٹ کرنے کی لاجک یہاں آئے گی
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