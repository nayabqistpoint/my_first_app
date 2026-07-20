import 'package:flutter/material.dart';
import 'dashboard/widgets/profit_loss.dart'; 
import 'dashboard/widgets/cash.dart'; // کیش والی فائل کا امپورٹ

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xfff8f9fa),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              
              // 1. پرافٹ لاس کارڈز (جو پہلے فائنل ہو چکے ہیں)
              ProfitLossWidget(),
              
              SizedBox(height: 10),
              
              // 2. کیش اور بینک کارڈز (اب یہاں کال کروا دیا ہے)
              CashWidget(),
              
            ],
          ),
        ),
      ),
    );
  }
}